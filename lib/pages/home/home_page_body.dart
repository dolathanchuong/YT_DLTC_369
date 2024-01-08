import 'package:flutter/material.dart';

import '../../api/api_youtube.dart';
import '../../widgets/widgets_video_widget.dart';

class Body extends StatefulWidget {
  final List contentList;
  final YoutubeApi youtubeApi;

  const Body({
    Key? key,
    required this.contentList,
    required this.youtubeApi,
  }) : super(key: key);

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.contentList.length,
        itemBuilder: (context, index) {
          if (widget.contentList[index].toString().contains('videoRenderer')) {
            return video(index, widget.contentList);
          }
          return Container();
        },
      ),
    );
  }

  Widget video(int index, List contentList) {
    return VideoWidget(
      videoId: contentList[index]['videoRenderer']['videoId'],
      duration: contentList[index]['videoRenderer']['lengthText']['simpleText'],
      title: contentList[index]['videoRenderer']['title']['runs'][0]['text'],
      channelName: contentList[index]['videoRenderer']['longBylineText']['runs']
          [0]['text'],
      views: contentList[index]['videoRenderer']['shortViewCountText']
          ['simpleText'],
    );
  }
}
