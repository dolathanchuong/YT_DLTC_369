//import 'package:logger/logger.dart';

import 'package:yt_dltc_369/api/helpers/helpers_extention.dart';

class Fetchvideovataparameter {
  String title,
      username,
      viewCount,
      subscribeCount,
      likeCount,
      unlikeCount,
      date,
      channelThumb,
      channelId;
  List<Map<String, dynamic>>? videosList;
  Fetchvideovataparameter(
      {required this.title,
      required this.username,
      required this.viewCount,
      required this.subscribeCount,
      required this.likeCount,
      required this.unlikeCount,
      required this.date,
      required this.channelThumb,
      required this.channelId,
      required this.videosList});

  factory Fetchvideovataparameter.fromJson(Map<String, dynamic> jsonMap) {
    //Logger logger = Logger();
    var contents = jsonMap.get('contents')?.get('twoColumnWatchNextResults');
    return Fetchvideovataparameter(
        title: contents!['results']?['results']?['contents']?[0]
                ?['videoPrimaryInfoRenderer']?['title']?['runs']?[0]?['text'] ??
            "",
        username: contents['results']?['results']?['contents'][1]?['videoSecondaryInfoRenderer']?['owner']
                ?['videoOwnerRenderer']?['title']?['runs']?[0]?['text'] ??
            "",
        viewCount: contents['results']?['results']?['contents']?[0]
                    ?['videoPrimaryInfoRenderer']?['viewCount']
                ?['videoViewCountRenderer']?['shortViewCount']?['simpleText'] ??
            "",
        subscribeCount: contents['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']?['owner']?['videoOwnerRenderer']?['subscriberCountText']?['simpleText'] ?? "",
        likeCount: contents['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']?['videoActions']?['menuRenderer']?['topLevelButtons']?[0]?['segmentedLikeDislikeButtonViewModel']?['likeButtonViewModel']?['likeButtonViewModel']?['toggleButtonViewModel']?['toggleButtonViewModel']?['defaultButtonViewModel']?['buttonViewModel']?['title'] ?? "",
        unlikeCount: "",
        date: contents['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']?['dateText']?['simpleText'] ?? "",
        channelThumb: contents['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']?['owner']?['videoOwnerRenderer']?['thumbnail']?['thumbnails']?[1]?['url'] ?? "",
        channelId: contents['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']?['owner']?['videoOwnerRenderer']?['navigationEndpoint']?['browseEndpoint']?['browseId'] ?? "",
        videosList: contents.get('secondaryResults')?.get('secondaryResults')?.getList('results')?.toList());
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "username": username,
      "viewCount": viewCount,
      "subscribeCount": subscribeCount,
      "likeCount": likeCount,
      "unlikeCount": unlikeCount,
      "date": date,
      "channelThumb": channelThumb,
      "channelId": channelId,
      "videosList": videosList
    };
  }
}
