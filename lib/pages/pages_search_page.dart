import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:logger/logger.dart';

import '../api/api_youtube.dart';
import '../helpers/helpers_suggestion_history.dart';
import '../widgets/widgets_channel_widget.dart';
import '../widgets/widgets_playList_widget.dart';
import '../widgets/widgets_video_widget.dart';

class SearchPage extends StatefulWidget {
  final String query;

  const SearchPage(this.query, {super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final YoutubeApi _youtubeApi = YoutubeApi();
  List? contentList;
  bool isLoading = false;
  bool firstLoad = true;
  Logger logger = Logger();

  @override
  void initState() {
    contentList = [];
    _loadMore(widget.query);
    SuggestionHistory.store(widget.query);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return SafeArea(
      child: Stack(
        children: [
          Visibility(
            visible: firstLoad,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          LazyLoadScrollView(
            isLoading: isLoading,
            onEndOfPage: () => _loadMore(widget.query),
            child: ListView.builder(
              itemCount: contentList!.length,
              itemBuilder: (context, index) {
                if (isLoading && index == contentList!.length - 1) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (contentList![index]
                      .toString()
                      .contains('videoRenderer')) {
                    return video(index, contentList!);
                  } else if (contentList![index]
                      .toString()
                      .contains('channelRenderer')) {
                    return channel(index, contentList!);
                  } else if (contentList![index]
                      .toString()
                      .contains('playlistRenderer')) {
                    return playList(index, contentList!);
                  }
                  return Container();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget video(int index, List contentList) {
    var lengthText = contentList[index]?['videoRenderer']?['lengthText'];
    var simpleText = contentList[index]?['videoRenderer']?['shortViewCountText']
            ?['simpleText'] ??
        '';
    if (lengthText == null) {
      return Container();
    } else {
      return VideoWidget(
        videoId: contentList[index]?['videoRenderer']?['videoId'] ?? '',
        duration:
            ((lengthText == null) ? "Live" : lengthText['simpleText']) ?? '',
        title: contentList[index]?['videoRenderer']?['title']?['runs']?[0]
                ?['text'] ??
            '',
        channelName: contentList[index]?['videoRenderer']?['longBylineText']
                ?['runs']?[0]?['text'] ??
            '',
        views: (lengthText == null)
            ? "Views ${contentList[index]?['videoRenderer']?['viewCountText']?['runs']?[0]?['text']}"
            : simpleText ?? '',
      );
    }
  }

  Widget playList(int index, List contentList) {
    return PlayListWidget(
      id: contentList[index]['playlistRenderer']['playlistId'],
      thumbnails: contentList[index]['playlistRenderer']['thumbnails'][0]
          ['thumbnails'],
      videoCount: contentList[index]['playlistRenderer']['videoCount'],
      title: contentList[index]['playlistRenderer']['title']['simpleText'],
      channelName: contentList[index]['playlistRenderer']['shortBylineText']
          ['runs'][0]['text'],
    );
  }

  Widget channel(int index, List contentList) {
    return ChannelWidget(
      id: contentList[index]?['channelRenderer']?['channelId'] ?? '',
      thumbnail: contentList[index]?['channelRenderer']?['thumbnail']
              ?['thumbnails']?[0]?['url'] ??
          '',
      title:
          contentList[index]?['channelRenderer']?['title']?['simpleText'] ?? '',
      videoCount: contentList[index]?['channelRenderer']?['videoCountText']
              ?['simpleText'] ??
          '',
    );
  }

  Future _loadMore(String query) async {
    setState(() {
      isLoading = true;
    });
    List newList = await _youtubeApi.fetchSearchVideo(query);
    contentList!.addAll(newList);
    setState(() {
      isLoading = false;
      firstLoad = false;
    });
  }
}
