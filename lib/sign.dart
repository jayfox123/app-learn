import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:jurrek/ProfilePage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'Config.dart';

class Sign extends StatefulWidget {
  @override
  _SignState createState() => _SignState();
}

class _SignState extends State<Sign> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _saving = false;

  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';
  TextEditingController _fullnameController;
  TextEditingController _nameController;
  TextEditingController _passController;
  TextEditingController _phoneController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _fullnameController = TextEditingController();
    _nameController = TextEditingController();
    _passController = TextEditingController();
    _phoneController = TextEditingController();
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      print(deviceData["androidId"]);
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

  @override
  Widget build(BuildContext context) {
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
                          image: DecorationImage(
                              image: AssetImage("assets/login2.png"),
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.bottomCenter)),
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
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: _fullnameController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "الإسم الكامل",
                                      suffixIcon: Icon(Icons.person_outline),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: _nameController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "البريد الإلكتروني ",
                                      suffixIcon: Icon(Icons.alternate_email),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "الهاتف",
                                      suffixIcon: Icon(Icons.call),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: _passController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "كلمة المرور",
                                      suffixIcon: Icon(Icons.lock_outline),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
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
                            onPressed: () {
                              setState(() {
                                _saving = true;
                              });
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _nameController.text,
                                      password: _passController.text)
                                  .then((singedUser) {
                                addNewUser(singedUser);
                                insertRoles(singedUser);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              }).catchError((error) {
                                setState(() {
                                  _saving = true;

                                  print(error.toString());
                                  showAlert(error.toString());
                                });
                                print(error);
                              });
                            },

                            //since this is only a UI app

                            child: Text(
                              'انشاء حساب',
                              style: TextStyle(
                                color: Colors.white,
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
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            " هل لديك حساب مسبقا ؟",
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
                          child: Center(
                            child: SpinKitCircle(
                              color: Colors.teal,
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
      //       isLoading: _saving,progressIndicator: CircularProgressIndicator()),
    );
  }

  showAlert(String task) async {
    Alert(
        context: context,
        title: "",
        desc: task,
        image: Image.asset("assets/login2.png"),
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

  addNewUser(user) {
    FirebaseAuth.instance.currentUser().then((val) {
      UserUpdateInfo updateUser = UserUpdateInfo();
      updateUser.displayName = _fullnameController.text;
      val.updateProfile(updateUser);
    });

    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(user.uid)
        .set({
          'DisplayName': _fullnameController.text,
          'PhoneNumber': _phoneController.text,
          'address': "",
          'photoUrl':
              "https://cdn.iconscout.com/icon/free/png-512/avatar-380-456332.png",
          'email': user.email,
          'status': "0",
          'android_id': _deviceData["androidId"],
          'uid': user.uid
        })
        .then((value) {})
        .catchError((e) {
          print(e);
        });
  }

  void insertRoles(FirebaseUser user) async {
    await FirebaseDatabase.instance
        .reference()
        .child("rolus")
        .child("${user.uid}")
        .set({
      "rolus": "user",
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
