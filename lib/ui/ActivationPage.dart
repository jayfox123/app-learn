import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jurrek/GoogleSignApp.dart';
import 'package:jurrek/ProfilePage.dart';
import 'package:jurrek/model/HomeModel.dart';
import 'package:jurrek/ui/AboutPage.dart';
import 'package:jurrek/ui/CourseClientPage.dart';
import 'package:jurrek/ui/OrderPageAdmin.dart';
import 'package:jurrek/ui/Semestre.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ActivationPage extends StatefulWidget {
  String name;
  String id;
  ActivationPage(this.name, this.id);
  @override
  _ActivationPageState createState() =>
      _ActivationPageState(this.name, this.id);
}

class _ActivationPageState extends State<ActivationPage>
    with SingleTickerProviderStateMixin {
  String name;
  String id;
  _ActivationPageState(this.name, this.id);

  ////////////////////////////
  ///
  final studentReference =
      FirebaseDatabase.instance.reference().child('colege');
  List<HomeModel> items;

  int currentIndex = 0;
  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;
  TextEditingController _nameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = new TabController(length: 4, vsync: this);
    getPhotoUrl().then((res) {
      initPlatformState();
    });

    items = new List();

    _onStudentAddedSubscription =
        studentReference.onChildAdded.listen(_onStudentAdded);
    _onStudentChangedSubscription =
        studentReference.onChildChanged.listen(_onStudentUpdated);
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      print(deviceData["androidId"]);
      getInformation(uid, deviceData["androidId"]);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
    };
  }

  String uid = "";

  String Status = "0";
  Future<String> getInformation(String uid, String androidId) async {
    await FirebaseDatabase.instance
        .reference()
        .child("users")
        .orderByChild("uid")
        .equalTo(uid)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        if (values != null) {
          if (this.mounted) {
            print("values --------------  " + values["android_id"]);
            setState(() {
              if (values["android_id"] != androidId) {
                showAlert(values["android_id"], context);
                Exit();
              }
            });
          }
        }
      });
    });
    return Status;
  }

  si() {
    exit(0);
  }

  Exit() {
    FirebaseAuth.instance.signOut();

    Future.delayed(Duration(seconds: 4), si);
  }

  showAlert(String Status, context) async {
    String info = "لا تستطيع استخدام التطبيق من جهاز مختلف";

    var _style = AlertStyle(
        animationType: AnimationType.fromTop,
        descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        isCloseButton: false,
        backgroundColor: Colors.grey[300],
        titleStyle:
            TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold));
    Alert(
        style: _style,
        context: context,
        title: "تنبيه",
        desc: info,
        type: AlertType.error,
        buttons: [
          DialogButton(
            color: Colors.grey[300],
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              "موافق",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  TabController controller;
  String photoUrl = "";
  Future<String> getPhotoUrl() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.photoUrl != null) {
      setState(() {
        photoUrl = user.photoUrl;
        uid = user.uid;
      });
    }
    return user.photoUrl;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.blue),
    );
    return Scaffold(
        appBar: AppBar(
          // centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: photoUrl != ""
                    ? Container(
                        height: 45.0,
                        width: 45.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(photoUrl), fit: BoxFit.cover),
                          // color: Colors.grey,
                        ),
                      )
                    : Container(
                        height: 33.0,
                        width: 33.0,
                        child: Icon(
                          Icons.person,
                          size: 30,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,

                          // color: Colors.grey,
                        ),
                      ),
              ),
              Text(
                'رواد اكاديمي',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text("")
            ],
          ),
        ),
        body: Container(
            color: Colors.white,
            // padding: EdgeInsets.all(7.0),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(100),
                              bottomLeft: Radius.circular(100))),
                      child: Text("name"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.17,
                    ),
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20.0,
                                offset: Offset(0, 10))
                          ]),
                          // elevation: 0,
                          child: _buildCard(
                              position,
                              items[position].id,
                              items[position].name,
                              items[position].photo,
                              context),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            tooltip: "اضافة اعلان",
            autofocus: true,
            backgroundColor: Colors.teal,
            child: Icon(
              Icons.add,
              color: Colors.white,
              semanticLabel: "اضافة اعلان",
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Semestre()),
              );
            }),
        bottomNavigationBar: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BottomAppBar(
                  elevation: 1,
                  color: Colors.teal[200],
                  shape: CircularNotchedRectangle(),
                  child: Container(
                    height: 56,
                  )),
            ],
          ),
        ),
      );
  }

  Widget _buildCard(
      int position, String id, String name, String photo, context) {
    print(photo);
    return Padding(
        padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 4.0, right: 4.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CourseClientPage(id, name)),
            );
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                      blurRadius: 8,
                      color: Colors.grey[300],
                      spreadRadius: 1,
                      offset: Offset(8, 8))
                ],
                image: DecorationImage(
                    image: NetworkImage(photo), fit: BoxFit.fill)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5),
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                topRight: Radius.circular(5))),
                        child: Text(
                          name,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _onStudentAdded(Event event) {
    setState(() {
      items.add(new HomeModel.fromSnapShot(event.snapshot));
    });
  }

  void _onStudentUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((student) => student.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new HomeModel.fromSnapShot(event.snapshot);
    });
  }
}
