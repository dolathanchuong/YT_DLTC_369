import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../api/api_youtube.dart';
import '../../models/models_channel_data.dart';
import 'channel_body.dart';

class ChannelPage extends StatefulWidget {
  final dynamic id;
  final dynamic title;

  const ChannelPage({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  ChannelPageState createState() => ChannelPageState();
}

class ChannelPageState extends State<ChannelPage> {
  YoutubeApi youtubeApi = YoutubeApi();
  ChannelData? channelData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LineIcons.rss, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LineIcons.share, color: Colors.white),
          )
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder(
        future: youtubeApi.fetchChannelData(widget.id),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return _loading();
            case ConnectionState.active:
              return _loading();
            case ConnectionState.none:
              return const Center(child: Text("Connection None"));
            case ConnectionState.done:
              if (snapshot.error != null) {
                return Center(
                    child: Center(child: Text(snapshot.stackTrace.toString())));
              } else {
                if (snapshot.hasData) {
                  return Body(
                    channelData: snapshot.data,
                    title: widget.title,
                    youtubeApi: youtubeApi,
                    channelId: widget.id,
                  );
                } else {
                  return const Center(child: SizedBox(child: Text("No data")));
                }
              }
          }
        },
      ),
    );
  }

  Widget _loading() {
    return const SizedBox.expand(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<bool> _refresh() async {
    setState(() {});
    return true;
  }
}
