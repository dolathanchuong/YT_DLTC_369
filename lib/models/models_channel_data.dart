import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/api/helpers/helpers_extention.dart';
import 'models_channel.dart';

class ChannelData {
  Channel channel;
  List videosList;
  bool isSubscribed = false;

  ChannelData({required this.channel, required this.videosList});

  factory ChannelData.fromMap(Map<String, dynamic> map) {
    Logger logger = Logger();

    var headers = map.get('header');
    String? subscribers = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('subscriberCountText')?['simpleText'];
    var thumbnails = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('avatar')
        ?.getList('thumbnails');
    String avatar = thumbnails?.elementAtSafe(thumbnails.length - 1)?['url'];
    String? banner = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('banner')
        ?.getList('thumbnails')
        ?.first['url'];
    logger.i('beginner get channel_data 369');
    //https://www.youtube.com/channel/UC_9eLT-y0NkwlbcZaZKN7Mg/videos
    var contents = map
        .get('contents')
        ?.get('twoColumnBrowseResultsRenderer')
        ?.getList('tabs')?[1]
        .get('tabRenderer')
        ?.get('content')
        ?.get('richGridRenderer')
        ?.getList('contents');
    List list = contents!.expand((map) => map.values).toList();
    return ChannelData(
        channel: Channel(
            subscribers: (subscribers != null) ? subscribers : " ",
            avatar: avatar,
            banner: banner),
        videosList: list);
  }

  void checkIsSubscribed(String channelId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? s = sharedPreferences.getString(channelId);
    if (s == null) {
      isSubscribed = false;
    } else {
      isSubscribed = true;
    }
  }
}
