import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../api/api_youtube.dart';
import '../../helpers/helpers_shared_helper.dart';
import '../../models/models_channel_data.dart';
import '../../models/models_subscribed.dart';
import '../../widgets/widgets_video_widget.dart';

class Body extends StatefulWidget {
  final String title;
  final ChannelData channelData;
  final YoutubeApi youtubeApi;
  final String channelId;

  const Body(
      {super.key,
      required this.channelData,
      required this.title,
      required this.youtubeApi,
      required this.channelId});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  late ScrollController controller;
  late List contentList;
  Subscribed? subscribed;
  bool videosEnd = false;
  bool isLoading = true;
  bool? isSubscribed;
  SharedHelper sharedHelper = SharedHelper();
  List<String> subscribedChannelsIds = [];
  Logger logger = Logger();

  @override
  void initState() {
    contentList = widget.channelData.videosList;
    controller = ScrollController()..addListener(_scrollListener);
    subscribed = Subscribed(
        username: widget.title,
        channelId: widget.channelId,
        avatar: widget.channelData.channel.avatar,
        videosCount: "");
    isSubscribed = widget.channelData.isSubscribed;
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Stack(
        children: [
          Column(
            children: [
              widget.channelData.channel.banner != null
                  ? Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: Image.network(
                                      widget.channelData.channel.banner!)
                                  .image,
                              fit: BoxFit.cover)),
                    )
                  : Container(),
              Container(
                color: Colors.black26,
                padding: const EdgeInsets.only(
                    left: 100, right: 20, bottom: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                                fontSize: 18, fontFamily: 'Cairo'),
                          ),
                          Text(
                            widget.channelData.channel.subscribers,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Cairo'),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      width: 90,
                      child: isSubscribed!
                          ? TextButton(
                              onPressed: () async {
                                logger.i('unSubscribe');
                                unSubscribe();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.redAccent),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(
                                      fontSize: 11, fontFamily: 'Cairo'),
                                ),
                              ),
                              child: const Text(
                                'Subscribed',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Cairo'),
                              ),
                            )
                          : TextButton(
                              onPressed: () async {
                                logger.i('subscribe');
                                subscribe();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(
                                      fontSize: 11, fontFamily: 'Cairo'),
                                ),
                              ),
                              child: const Text(
                                'Subscribe',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Cairo'),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contentList.length,
                  itemBuilder: (context, index) {
                    if (contentList[index]
                        .toString()
                        .contains('videoRenderer')) {
                      // logger.i('Get Page Channel And Scroll All Videos in Channel 369');
                      return video(index, contentList);
                    }
                    return Container();
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 50),
            child: Container(
              height: 60,
              width: 60,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image:
                              Image.network(widget.channelData.channel.avatar)
                                  .image,
                          fit: BoxFit.cover))),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: Positioned(
                bottom: 10,
                right: 180,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _scrollListener() {
    if (controller.position.atEdge) {
      if (controller.position.pixels != 0 && videosEnd == false) {
        _loadMore();
      }
    }
  }

  Widget video(int index, List contentList) {
    String? simpleText = contentList[index]?['content']?['videoRenderer']
        ?['shortViewCountText']?['simpleText'];
    return VideoWidget(
      videoId: contentList[index]?['content']?['videoRenderer']?['videoId'],
      duration: contentList[index]?['content']?['videoRenderer']
              ?['thumbnailOverlays']?[0]?['thumbnailOverlayTimeStatusRenderer']
          ?['text']?['simpleText'],
      title: contentList[index]?['content']?['videoRenderer']?['title']?['runs']
          ?[0]?['text'],
      channelName: widget.title,
      views: (simpleText != null) ? simpleText : "???",
    );
  }

  void subscribe() async {
    sharedHelper.subscribeChannel(
        widget.channelId, jsonEncode(subscribed!.toJson()));
    setState(() {
      isSubscribed = true;
    });
  }

  void unSubscribe() async {
    sharedHelper.unSubscribeChannel(widget.channelId);
    setState(() {
      isSubscribed = false;
    });
  }

  void _loadMore() async {
    List? list = await widget.youtubeApi.loadMoreInChannel();
    if (list != null) {
      setState(() {
        contentList.addAll(list);
      });
    } else {
      videosEnd = true;
      setState(() {
        isLoading = false;
      });
    }
  }
}
