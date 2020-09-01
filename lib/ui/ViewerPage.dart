import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_admob/firebase_admob.dart';

class ViewerPage extends StatefulWidget {
  String path;
  String name;
  ViewerPage(this.name, this.path);
  @override
  _ViewerPageState createState() => _ViewerPageState(this.name, this.path);
}

class _ViewerPageState extends State<ViewerPage> {
  String path;
  String name;
  _ViewerPageState(this.name, this.path);

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>[
        'foo',
        'bar',
        'chat',
        'sad',
        'education',
        'happy',
        'social'
      ],
      childDirected: true);
  RewardedVideoAd rewardvideoAd;

  bool loading = true;
  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance.initialize(
        appId: "ca-app-pub-1221290755955623~7539228144",
        analyticsEnabled: true);
    ///////////////////////////
    ///////////////////////////
    ///////////////////////////
    // RewardedVideoAd.instance.load(
    //     adUnitId: "ca-app-pub-1221290755955623/4063017563",
    //     targetingInfo: targetingInfo);
    // RewardedVideoAd.instance.listener =
    //     (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
    //   print("RewardedVideoAd event $event");
    //   if (event == RewardedVideoAdEvent.loaded) {
    //     RewardedVideoAd.instance.show();
    //   }
    // };

    createFileOfPdfUrl().then((f) {
      setState(() {
        path = f.path;
        print(path);
        loading = false;
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    // https://firebasestorage.googleapis.com/v0/b/education-aa85a.appspot.com/o/$name_1588430801208.pdf?alt=media&token=3c6a72e3-da41-4dd0-a158-a8136bf3863f
    final testname = path.substring(
        path.lastIndexOf("pdf") - 18, path.lastIndexOf("pdf") + 3);

    print(testname);
    final url = path;
    // final filename = url.substring(url.lastIndexOf("/") + 1);
    final filename = "test.pdf";
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Widget Funloding() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black87),
    );
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.teal[300],
        title: Text(
          name,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black87),
    );
    return loading
        ? Funloding()
        : PDFViewerScaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              backgroundColor: Colors.teal,
              title: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
              ],
            ),
            path: path);
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Document"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        path: pathPDF);
  }
}
