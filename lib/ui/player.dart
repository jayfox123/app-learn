import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class player extends StatefulWidget {
  String link;
  player(this.link);

  @override
  _playerState createState() {
    return _playerState(this.link);
  }
}

class _playerState extends State<player> {
  _playerState(this.link);
  String link;

  IjkMediaController controller = IjkMediaController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    print(link);
    controller.setNetworkDataSource(
      link, autoPlay: true,
      // headers: headers
    );
    controller.needChangeSpeed = true;

    controller.autoRotate = true;
  }

  Widget buildIjkPlayer() {
    return Container(
      height: 600,
      child: IjkPlayer(
        mediaController: controller,
      ),
    );
  }

  bool startedPlaying = false;

  @override
  Widget build(BuildContext context) {
    return buildIjkPlayer();
  }
}
