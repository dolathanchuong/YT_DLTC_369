import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:logger/logger.dart';
import 'package:xml2json/xml2json.dart';

import '../helpers/helpers_suggestion_history.dart';
import '../models/models_channel_data.dart';
import '../models/models_fetchvideodataparameter.dart';
import '../models/models_my_video.dart';
import '../models/models_video_data.dart';
import 'api_retry.dart';
import 'helpers/helpers_extract_json.dart';
import 'helpers/helpers_extention.dart';

class ApiConfig {
  final String apiKey;

  ApiConfig(this.apiKey);
}

class YoutubeApi {
  Logger logger = Logger();
  String? _searchToken;
  String? _channelToken;
  String? _playListToken;
  String? lastQuery;

  Future fetchSearchVideo(String query) async {
    List list = [];
    var client = http.Client();
    if (_searchToken != null && query == lastQuery) {
      logger.i('___TOKEN99999_fetchSearchVideo_99999 ==> {$_searchToken}');
      var url =
          'https://www.youtube.com/youtubei/v1/search?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
      return retry(() async {
        var body = {
          'context': const {
            'client': {
              'hl': 'en',
              'clientName': 'WEB',
              'clientVersion': '2.20200911.04.00'
            }
          },
          'continuation': _searchToken
        };
        var raw = await client.post(Uri.parse(url), body: json.encode(body));
        Map<String, dynamic> jsonMap = json.decode(raw.body);
        var contents = jsonMap
            .getList('onResponseReceivedCommands')
            ?.firstOrNull
            ?.get('appendContinuationItemsAction')
            ?.getList('continuationItems')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents');
        list = contents!.toList();
        _searchToken = _getContinuationToken(jsonMap);
        return list;
      });
    } else {
      lastQuery = query;
      var response = await client.get(
        Uri.parse(
          'https://www.youtube.com/results?search_query=$query',
        ),
      );
      var jsonMap = _getJsonMap(response);
      if (jsonMap != null) {
        var contents = jsonMap
            .get('contents')
            ?.get('twoColumnSearchResultsRenderer')
            ?.get('primaryContents')
            ?.get('sectionListRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents');

        list = contents!.toList();
        _searchToken = _getContinuationToken(jsonMap);
      }
    }
    return list;
  }

  Future fetchTrendingVideo() async {
    logger
        .i('API TrendingVideo ==> URL : https://www.youtube.com/feed/trending');
    SuggestionHistory.init();
    List list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));

    var jsonMap = extractJson(initialData!);

    if (jsonMap != null) {
      var firstcontents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');

      var secondcontents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.elementAtSafe(1)
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');

      var firstList = firstcontents != null
          ? firstcontents.toList()
          : (secondcontents != null ? secondcontents.toList() : []);
      var threeContents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.elementAtSafe(3)
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var fourContents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.elementAtSafe(2)
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var secondList = threeContents != null
          ? threeContents.toList()
          : (fourContents != null ? fourContents.toList() : []);
      list = [...firstList, ...secondList];
    }
    return list;
  }

  Future fetchTrendingMusic() async {
    String params = "4gINGgt5dG1hX2NoYXJ0cw%3D%3D";
    List list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending?bp=$params',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(1)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      list = contents != null ? contents.toList() : [];
    }
    return list;
  }

  Future fetchTrendingGaming() async {
    String params = "4gIcGhpnYW1pbmdfY29ycHVzX21vc3RfcG9wdWxhcg";
    List list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending?bp=$params',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(2)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      list = contents != null ? contents.toList() : [];
    }
    return list;
  }

  Future fetchTrendingMovies() async {
    String params = "4gIKGgh0cmFpbGVycw%3D%3D";
    List list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending?bp=$params',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(3)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      list = contents != null ? contents.toList() : [];
    }
    return list;
  }

  Future<List<String>> fetchSuggestions(String query) async {
    logger.i('fetchSuggestions $query');
    List<String> suggestions = [];
    String baseUrl =
        'http://suggestqueries.google.com/complete/search?output=toolbar&ds=yt&q=';
    var client = http.Client();
    final myTranformer = Xml2Json();
    var response = await client.get(Uri.parse(baseUrl + query));
    var body = response.body;
    myTranformer.parse(body);
    var json = myTranformer.toGData();
    List suggestionsData = jsonDecode(json)['toplevel']['CompleteSuggestion'];
    // suggestionsData.forEach((suggestion) {
    //   suggestions.add(suggestion['suggestion']['data'].toString());
    // });
    for (var suggestion in suggestionsData) {
      suggestions.add(suggestion['suggestion']['data'].toString());
    }
    return suggestions;
  }

  String? _getContinuationToken(Map<String, dynamic>? root) {
    logger.i('_getContinuationToken');
    if (root?['contents'] != null) {
      if (root?['contents']?['twoColumnBrowseResultsRenderer'] != null) {
        return root!
            .get('contents')
            ?.get('twoColumnBrowseResultsRenderer')
            ?.getList('tabs')
            ?.elementAtSafe(1)
            ?.get('tabRenderer')
            ?.get('content')
            ?.get('richGridRenderer')
            ?.getList('contents')
            ?.lastOrNull
            // ?.get('richItemRenderer')
            // ?.getList('contents')
            // ?.firstOrNull
            // ?.get('gridRenderer')
            // ?.getList('items')
            //.elementAtSafe(30)
            ?.get('continuationItemRenderer')
            ?.get('continuationEndpoint')
            ?.get('continuationCommand')
            ?.getT<String>('token');
      }
      var contents = root!
          .get('contents')
          ?.get('twoColumnSearchResultsRenderer')
          ?.get('primaryContents')
          ?.get('sectionListRenderer')
          ?.getList('contents');

      if (contents == null || contents.length <= 1) {
        return null;
      }
      return contents
          .elementAtSafe(1)
          ?.get('continuationItemRenderer')
          ?.get('continuationEndpoint')
          ?.get('continuationCommand')
          ?.getT<String>('token');
    }
    if (root?['onResponseReceivedCommands'] != null) {
      return root!
          .getList('onResponseReceivedCommands')
          ?.firstOrNull
          ?.get('appendContinuationItemsAction')
          ?.getList('continuationItems')
          ?.elementAtSafe(1)
          ?.get('continuationItemRenderer')
          ?.get('continuationEndpoint')
          ?.get('continuationCommand')
          ?.getT<String>('token');
    }
    return null;
  }

  Future fetchChannelData(String channelId) async {
    logger.i(
        'APT GET channel_page ==> url : https://www.youtube.com/channel/$channelId/videos');
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/channel/$channelId/videos', //https://www.youtube.com/channel/UC_9eLT-y0NkwlbcZaZKN7Mg/videos
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      ChannelData channelData = ChannelData.fromMap(jsonMap);
      channelData.checkIsSubscribed(channelId);
      _channelToken = _getContinuationToken(jsonMap);
      return channelData;
    }
    return null;
  }

  Future<List?> loadMoreInChannel() async {
    List? list;
    var client = http.Client();
    var url =
        'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
    var body = {
      'context': const {
        'client': {
          'hl': 'en',
          'clientName': 'TVHTML5_SIMPLY_EMBEDDED_PLAYER',
          'clientVersion': '2.0'
          // 'clientName': 'WEB',
          // 'clientVersion': '2.20200911.04.00'
        }
      },
      'continuation': _channelToken
    };
    var raw = await client.post(Uri.parse(url), body: json.encode(body));
    Map<String, dynamic> jsonMap = json.decode(raw.body);
    var contents = jsonMap
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems');
    if (contents != null) {
      list = contents.toList();
      _channelToken = _getChannelContinuationToken(jsonMap);
      logger.i(
          '___TOKEN99999_loadMoreInChannel_99999 ==> _searchToken{$_searchToken}');
    }
    return list;
  }

  Future<List?> loadMoreInPlayList() async {
    List? list;
    var client = http.Client();
    var url =
        'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
    var body = {
      'context': const {
        'client': {
          'hl': 'en',
          'clientName': 'TVHTML5_SIMPLY_EMBEDDED_PLAYER',
          'clientVersion': '2.0'
        }
      },
      'continuation': _playListToken
    };
    var raw = await client.post(Uri.parse(url), body: json.encode(body));
    Map<String, dynamic> jsonMap = json.decode(raw.body);
    var contents = jsonMap
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems');
    if (contents != null) {
      list = contents.toList();
      _playListToken = _getChannelContinuationToken(jsonMap);
    }
    return list;
  }

  String? _getChannelContinuationToken(Map<String, dynamic>? root) {
    logger.i('_getChannelContinuationToken');
    return root!
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems')
        ?.elementAtSafe(30)
        ?.get('continuationItemRenderer')
        ?.get('continuationEndpoint')
        ?.get('continuationCommand')
        ?.getT<String>('token');
  }

  String? _getPlayListContinuationToken(Map<String, dynamic>? root) {
    logger.i('_getPlayListContinuationToken');
    return root!
        .get('contents')
        ?.get('twoColumnBrowseResultsRenderer')
        ?.getList('tabs')
        ?.firstOrNull
        ?.get('tabRenderer')
        ?.get('content')
        ?.get('sectionListRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('itemSectionRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('playlistVideoListRenderer')
        ?.getList('contents')
        ?.elementAtSafe(100)
        ?.get('continuationItemRenderer')
        ?.get('continuationEndpoint')
        ?.get('continuationCommand')
        ?.getT<String>('token');
  }

  Future<List> fetchPlayListVideos(String id, int loaded) async {
    List videos = [];
    var url = 'https://www.youtube.com/playlist?list=$id&hl=en&persist_hl=1';
    var client = http.Client();
    var response = await client.get(
      Uri.parse(url),
    );
    var jsonMap = _getJsonMap(response);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('playlistVideoListRenderer')
          ?.getList('contents');
      videos = contents!.toList();
      _playListToken = _getPlayListContinuationToken(jsonMap);
    }
    return videos;
  }

  Future<VideoData?> fetchVideoData(String videoId) async {
    VideoData? videoData;
    Fetchvideovataparameter? fetchvideovataparameter;
    var client = http.Client();
    var response =
        await client.get(Uri.parse('https://www.youtube.com/watch?v=$videoId'));
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      fetchvideovataparameter = Fetchvideovataparameter.fromJson(jsonMap);
      videoData = VideoData(
          video: MyVideo(
            videoId: videoId,
            title: fetchvideovataparameter.title,
            username: fetchvideovataparameter.username,
            viewCount: fetchvideovataparameter.viewCount,
            subscribeCount: fetchvideovataparameter.subscribeCount,
            likeCount: fetchvideovataparameter.likeCount,
            unlikeCount: '',
            date: fetchvideovataparameter.date,
            channelThumb: fetchvideovataparameter.channelThumb,
            channelId: fetchvideovataparameter.channelId,
          ),
          videosList: fetchvideovataparameter.videosList);
    }
    return videoData;
  }

  Map<String, dynamic>? _getJsonMap(http.Response response) {
    logger.i('_getJsonMap_369');
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    return jsonMap;
  }
}
