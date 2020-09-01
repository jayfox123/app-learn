import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jurrek/GoogleSignApp.dart';
import 'package:jurrek/ProfilePage.dart';
import 'package:jurrek/model/HomeModel.dart';
import 'package:jurrek/ui/AboutPage.dart';
import 'package:jurrek/ui/CourseClientPage.dart';
import 'package:jurrek/ui/OrderPageAdmin.dart';
import 'package:jurrek/ui/Semestre.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final studentReference =
      FirebaseDatabase.instance.reference().child('colege');
  List<HomeModel> items;
  List<HomeModel> initial;

  int currentIndex = 0;
  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;
  TextEditingController _nameController;

  var mymap = {};
  var title = '';
  var body = '';
  var mytoken = '';

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      if (user == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => GoogleSignApp()));
      }
    });

    getPhotoUrl().then((res) {
      initPlatformState();
    });

    items = List();
    initial = List();

    _onStudentAddedSubscription =
        studentReference.onChildAdded.listen(_onStudentAdded);
    _onStudentChangedSubscription =
        studentReference.onChildChanged.listen(_onStudentUpdated);

    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var platform = InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called ${(msg)}");
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called ");
    }, onMessage: (Map<String, dynamic> msg) {
      print("onResume called ${(msg)}");
      mymap = msg;
      showNotification(msg);
    });

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("onIosSettingsRegistered");
    });
    firebaseMessaging.getToken().then((token) {
      mytoken = token;
      // update(token);
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android =
        AndroidNotificationDetails("1", "channelName", "channelDescription");
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    int i = 0;
    msg.forEach((k, v) {
      v.forEach((f, t) {
        if (i == 0) {
          title = t;
        }
        i++;
        body = t;
        print("v   body   $t");
      });
    });

    await flutterLocalNotificationsPlugin.show(0, "$title", "$body", platform);
  }

  update(String token) {
    DatabaseReference databaseReference = FirebaseDatabase().reference();
    databaseReference.child('admintokens/$token').set({"token": token});
    mytoken = token;
    setState(() {});
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
      if (values != null) {
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
      }
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
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold));
    Alert(
        style: _style,
        context: context,
        title: "تنبيه",
        desc: info,
        type: AlertType.error,
        buttons: [
          DialogButton(
            color: Colors.teal,
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

  SubscriptionAlert(String Status, context) async {
    var _style = AlertStyle(
        animationType: AnimationType.fromTop,
        descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        isCloseButton: false,
        // backgroundColor: Colors.grey[300],
        titleStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold));
    Alert(
        style: _style,
        context: context,
        title: "تنبيه",
        desc: Status,
        type: AlertType.error,
        buttons: [
          DialogButton(
            color: Colors.teal,
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

  Future getPhotoUrl() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      uid = user.uid;
      if (user.photoUrl != null) {
        photoUrl = user.photoUrl;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
  }

  _onChanged(String value) {
    items = initial;
    setState(() {
      items = items
          .where((x) => x.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Widget _endDrawer() {
    return Drawer(
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.teal,
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1), BlendMode.dstATop),
              image: AssetImage("assets/background-png.png"),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                photoUrl != ""
                    ? Container(
                        height: 110.0,
                        width: 110.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(photoUrl), fit: BoxFit.cover),
                          // color: Colors.grey,
                        ),
                      )
                    : Container(
                        height: 100.0,
                        width: 100.0,
                        child:
                            Icon(Icons.person, size: 60, color: Colors.white),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                          // color: Colors.grey,
                        ),
                      ),

                SizedBox(
                  height: 50,
                ),

                customListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  txt: "الرئيسية",
                  icon: Icon(Icons.home, color: Colors.white),
                ),

                Divider(color: Colors.white),

                /// Button C Panal
                customListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderPageAdmin()),
                    );
                  },
                  txt: "لوحة التحكم",
                  icon: Icon(Icons.dashboard, color: Colors.white),
                ),

                Divider(color: Colors.white),

                customListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  txt: "الملف الشخصي",
                  icon: Icon(Icons.person, color: Colors.white),
                ),

                Divider(color: Colors.white),

                customListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutPage()),
                    );
                  },
                  txt: "اتصل بنا",
                  icon: Icon( Icons.account_balance , color: Colors.white,)
                ),

                Divider(color: Colors.white),

                customListTile(
                  txt:"مشاركة التطبيق",
                  icon: Icon(Icons.share, color: Colors.white),
                ),
                
                Divider(color: Colors.white),

                customListTile(
                  txt: "تسجيل الخروج",
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GoogleSignApp()),
                    );
                  }
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customListTile({String txt , Function onTap, Icon icon}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            txt,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(
            width: 10,
          ),
          icon
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      // centerTitle: true,
      backgroundColor: Colors.teal,
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text("")
        ],
      ),
    );
  }

  Widget _floatingactionbutton() {
    return FloatingActionButton(
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
        });
  }

  Widget _bottomNavigationBar() {
    return SizedBox(
      height: 58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          BottomAppBar(
              elevation: 1,
              color: Colors.teal,
              shape: CircularNotchedRectangle(),
              child: Container(
                height: 56,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.teal),
    );
    return Scaffold(
      endDrawer: _endDrawer(),
      appBar: _appBar(),
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
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(100),
                          bottomLeft: Radius.circular(100))),
                ),
                Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 35.0, right: 35.0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          // color: Colors.white,
                          // borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20.0,
                                offset: Offset(0, 10))
                          ]),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          onChanged: _onChanged,
                          textAlign: TextAlign.right,
                          controller: _nameController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10.0),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            hintText: ' بحث  ',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
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
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      // elevation: 0,
                      child: _buildCard(position, items[position].id,
                          items[position].name, items[position].photo, context),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _floatingactionbutton(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  List Course_Uid = List();
  Future<bool> Subscribed(String id) async {
    print(uid);
    bool subs = false;
    Course_Uid.clear();
    await FirebaseDatabase.instance
        .reference()
        .child("activation")
        .child(uid)
        .once()
        .then((DataSnapshot snapshotact) {
      Map<dynamic, dynamic> valuesact = snapshotact.value;
      if (valuesact != null) {
        valuesact.forEach((keyact, valuesact) {
          if (id == keyact) {
            setState(() {
              subs = true;
            });
          }
        });
      }
    });
    return subs;
  }

  Widget _buildCard(
      int position, String id, String name, String photo, context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 4.0, right: 4.0),
      child: InkWell(
        onTap: () {
          Subscribed(id).then((res) {
            if (res == true) {
              print("Ahmed $name Id $id");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CourseClientPage(id, name)),
              );
            } else {
              SubscriptionAlert("انت غير مشترك في هذا المساق  ", context);
            }
          });
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                  blurRadius: 8,
                  color: Colors.grey,
                  spreadRadius: 1,
                  offset: Offset(2, 4))
            ],
            image: DecorationImage(
              image: NetworkImage(photo),
              fit: BoxFit.fill,
            ),
          ),
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
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStudentAdded(Event event) {
    setState(() {
      print(event.snapshot.value);
      items.add(new HomeModel.fromSnapShot(event.snapshot));
      initial.add(new HomeModel.fromSnapShot(event.snapshot));
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
