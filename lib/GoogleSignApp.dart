import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:jurrek/ProfilePage.dart';
import 'package:jurrek/sign.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'package:jurrek/ui/forgot.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'Config.dart';

class GoogleSignApp extends StatefulWidget {
  @override
  _GoogleSignAppState createState() => _GoogleSignAppState();
}

class _GoogleSignAppState extends State<GoogleSignApp> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _saving = false;
  var too = 0;

  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';
  TextEditingController _nameController;
  TextEditingController _passController;
  bool isLoading = true;
  bool isHidden = true;
  Icon iu;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    setState(() {
      iu = Icon(
        Icons.visibility_off,
      );
    });
    //http://superxpro.com:8000/get.php?username=mc3648&password=Mh5324321&type=m3u_plus&output=ts
    _nameController = TextEditingController();
    _passController = TextEditingController();

    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var platform = InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called ${(msg)}");
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called ${(msg)}");
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
      update(token);
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android =
        AndroidNotificationDetails("1", "channelName", "channelDescription");
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);

    msg.forEach((k, v) {
      title = k;
      body = v;

      setState(() {});
    });

    await flutterLocalNotificationsPlugin.show(
        0, "${msg.keys}", "${msg.values}", platform);
  }

  update(String token) {
    // DatabaseReference databaseReference = new FirebaseDatabase().reference();
    // databaseReference.child('tokens/$token').set({"token": token});
    // mytoken = token;
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.teal),
    );
    return Scaffold(
        backgroundColor: Color(0xFFFCFAF8),
        body: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 180,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 180.0,
                        width: 180.0,
                        decoration: BoxDecoration(
                          // color: Color.fromRGBO(223, 145, 37, 1),
                          // borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                            image: AssetImage("assets/login2.png"),
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Config().NameApp + "" + Config().SecendNameApp,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Config().PrimaryColor,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(143, 148, 251, .2),
                                      blurRadius: 20.0,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[100],
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    controller: _nameController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "البريد الإلكتروني",
                                      suffixIcon: Icon(Icons.alternate_email),
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    obscureText: isHidden,
                                    controller: _passController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "كلمة المرور",
                                      suffixIcon: Icon(Icons.lock_outline),
                                      prefixIcon: InkWell(
                                        onTap: () {
                                          // printy();
                                          toogle();
                                        },
                                        child: iu,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () async {
                                setState(() {
                                  _saving = true;
                                });

                                FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: _nameController.text,
                                        password: _passController.text)
                                    .then((FirebaseUser user) {
                                  setState(() {
                                    _saving = false;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()),
                                  );
                                }).catchError((e) {
                                  setState(() {
                                    _saving = false;
                                  });
                                  showAlert(e.toString());

                                  print(e);
                                });
                              },
                              child: Text(
                                'تسجيل الدخول ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Config().PrimaryColor,
                              elevation: 4,
                              minWidth: 300,
                              height: 50,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () =>
                                  // FirebaseAuth.instance
                                  //     .createUserWithEmailAndPassword(
                                  //         email: _nameController.text,
                                  //         password: _passController.text)
                                  //     .then((singedUser) {
                                  //   addNewUser(singedUser);
                                  Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Sign()),
                              ),
                              // }).catchError((e) {
                              //   print(e);
                              // }),
                              //since this is only a UI app

                              child: Text(
                                'انشاء حساب',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.white,
                              elevation: 4,
                              minWidth: 300,
                              height: 50,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              // _signIn(context);
                              // FirebaseAuth.instance.signOut();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Forgot()),
                              );
                            },
                            child: Text(
                              " نسيت كلمة المرور ؟",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _saving
                        ? Positioned(
                            // top:100,
                            // left: MediaQuery.of(context).size.width/2,

                            child: Center(
                              child: SpinKitCircle(
                                color: Config().PrimaryColor,
                                size: 100,
                              ),
                            ),
                          )
                        : Text("")
                  ],
                ),
              ],
            )
          ],
        ),
      );
  }

  showAlert(String task) async {
    Alert(
        context: context,
        title: "",
        content: Column(
          children: <Widget>[
            Text(
              task,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.teal,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "موافق",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  toogle() {
    print(too);
    if (too == 1) {
      setState(() {
        too = 0;
        isHidden = false;
        iu = Icon(Icons.remove_red_eye);
      });
    } else if (too == 0) {
      setState(() {
        too = 1;
        isHidden = true;
        iu = Icon(Icons.visibility_off);
      });
    }
  }

  addNewUser(user) {
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(user.uid)
        .set({
          'DisplayName': "مستخدم",
          'PhoneNumber': "",
          'photoUrl': "",
          'email': user.email,
          'uid': user.uid
        })
        .then((value) {})
        .catchError((e) {
          print(e);
        });
  }
}

class UserDetails {
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final String userEmail;
  final List<ProviderDetails> providerData;

  UserDetails(this.providerDetails, this.userName, this.photoUrl,
      this.userEmail, this.providerData);
}

class ProviderDetails {
  ProviderDetails(this.providerDetails);
  final String providerDetails;
}
