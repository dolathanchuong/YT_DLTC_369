import 'package:flutter/material.dart';

import '../../helpers/helpers_shared_helper.dart';
import '../../models/models_subscribed.dart';
import '../../widgets/widgets_channel_widget.dart';
import '../../widgets/widgets_loading.dart';

class SubscribedChannels extends StatefulWidget {
  const SubscribedChannels({super.key});

  @override
  State<SubscribedChannels> createState() => _SubscribedChannelsState();
}

class _SubscribedChannelsState extends State<SubscribedChannels> {
  SharedHelper sharedHelper = SharedHelper();
  List<Subscribed>? subscribedChannels;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sharedHelper.getSubscribedChannels(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loading();
          case ConnectionState.active:
            return loading();
          case ConnectionState.none:
            return const Text("Connection None");
          case ConnectionState.done:
            if (snapshot.hasData) {
              subscribedChannels = snapshot.data;
              if (subscribedChannels!.isNotEmpty) {
                return ListView.builder(
                  itemCount: subscribedChannels!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {},
                      child: channel(subscribedChannels![index]),
                    );
                  },
                );
              }
            }
            return const Center(
              child: Text(
                "OM AH HUM VAJA GURU PADME SIDI HUM",
                style: TextStyle(fontSize: 20, fontFamily: 'Cairo'),
              ),
            );
        }
      },
    );
  }

  Widget channel(Subscribed subscribed) {
    return ChannelWidget(
      id: subscribed.channelId,
      thumbnail: subscribed.avatar,
      title: subscribed.username,
      videoCount: '',
    );
  }
}
