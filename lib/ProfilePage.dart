import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jurrek/GoogleSignApp.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String uid = "";
  String IdToken;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUid();
    getPhotoUrl();
    // getInformation("uid");

    _nameController = TextEditingController();
    _pointsController = TextEditingController();
    _mobileController = TextEditingController();
    _adressController = TextEditingController();
  }

  bool imageSelect = false;
  final informationReference =  FirebaseDatabase.instance.reference().child('users');
  File image;
  picker() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    // File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() {
        _saving = true;
      });
      image = img;
      // var now = DateTime.now().toString();
      // String time = now;
      // time = time.trim().replaceAll(":", "").replaceAll(" ", "");
      // var fullImageName = 'images/$time' + '.jpg';

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child("img_" + timestamp.toString() + ".jpg");
      StorageUploadTask uploadTask = storageReference.putFile(image);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      uploadImage(downloadUrl, downloadUrl);
      setState(() {
        imageSelect = true;
      });
    }
  }

  String DisplayName = "";
  getInformation(String uid) {
    try {
      FirebaseDatabase.instance
          .reference()
          .child("users")
          .orderByChild("uid")
          .equalTo(uid)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        if (values != null) {
          values.forEach((key, values) {
            _mobileController.text = values["PhoneNumber"];
            _pointsController.text = values["address"];
            _adressController.text = values["email"];
            _nameController.text = values["DisplayName"];
          });
        }
      });
    } on PlatformException catch (error) {}
  }

  TextEditingController _nameController;
  TextEditingController _pointsController;
  TextEditingController _mobileController;
  TextEditingController _adressController;
  String photoUrl = 'assets/images/as.png';
  getUid() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      DisplayName = user.displayName;
      print(uid);
      getInformation(uid);
    });
  }

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.teal),
    );
    return Scaffold(
          body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 250.0,
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  if (_adressController.text == "" ||
                                      _mobileController.text == "" ||
                                      _pointsController.text == "") {
                                    SuccessAlert(context);
                                  } else {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                        (Route<dynamic> route) => false);
                                  }
                                },
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      color: Colors.black,
                                      onPressed: () {
                                        if (_adressController.text == "" ||
                                            _mobileController.text == "" ||
                                            _pointsController.text == "") {
                                          SuccessAlert(context);
                                        } else {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomePage()),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        }
                                      },
                                      icon: Icon(Icons.arrow_back),
                                    ),
                                    Text(
                                      "ابدأ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Text('الملف الشخصي  ',
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colors.black)),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child:
                                Stack(fit: StackFit.loose, children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // if (imageSelect) ...[
                                  //   Container(
                                  //     width: 140.0,
                                  //     height: 140.0,
                                  //     child: CircleAvatar(
                                  //       radius: 20,
                                  //       backgroundColor: Colors.white,
                                  //       child: image == null
                                  //           ? Text('No Image')
                                  //           : Image.file(image),
                                  //     ),
                                  //   ),
                                  // ],

                                  !imageSelect &&
                                          photoUrl.contains('assets') &&
                                          image == null
                                      ? Container(
                                          width: 140.0,
                                          height: 140.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: ExactAssetImage(photoUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Text(""),
                                  !photoUrl.contains('assets')
                                      ? Container(
                                          width: 140.0,
                                          height: 140.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(photoUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Text("")
                                ],
                              ),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: 90.0, right: 100.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 25.0,
                                        child: IconButton(
                                          color: Colors.white,
                                          onPressed: picker,
                                          icon: Icon(Icons.camera_alt),
                                        ),
                                      )
                                    ],
                                  )),
                            ]),
                          )
                        ],
                      ),
                    ),
                    Container(
                        child: RaisedButton(
                      child: Text("تسجيل الخروج"),
                      textColor: Colors.white,
                      color: Colors.teal,
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleSignApp()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    )),
                    Container(
                      color: Color(0xffFFFFFF),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'المعلومات الشخصية',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'الإسم الكامل',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        textAlign: TextAlign.right,
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          hintText: "أدخل اسمك الكامل",
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'البريد الإلكتروني',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        textAlign: TextAlign.right,
                                        controller: _adressController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            hintText: "أدخل بريدك الإلكتروني"),
                                      ),
                                      flex: 2,
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '            الهاتف',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '             العنوان',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.phone,
                                            controller: _mobileController,
                                            decoration: const InputDecoration(
                                                hintText: "أدخل رقم هاتفك"),
                                          )),
                                      flex: 2,
                                    ),
                                    Flexible(
                                      child: Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            controller: _pointsController,
                                            decoration: const InputDecoration(
                                                hintText: "أدخل عنوانك"),
                                          )),
                                      flex: 2,
                                    ),
                                  ],
                                )),
                            _getActionButtons(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                _saving ?
                  Positioned(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
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
        ),
      ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  addUser(String name, String mobile, String photoUrl, String email,
      String adresse) {
    setState(() {
      _saving = true;
    });
    var now = DateTime.now().toString();
    String time = now;
    time = time.trim().replaceAll(":", "").replaceAll(" ", "");

    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uid)
        .update(
            {'DisplayName': name, 'PhoneNumber': mobile, 'address': adresse})
        .then((value) {})
        .catchError((e) {
          print(e);
        });
    FirebaseAuth.instance.currentUser().then((val) {
      UserUpdateInfo updateUser = UserUpdateInfo();
      updateUser.displayName = name;
      val.updateProfile(updateUser);
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ListViewStudent()),
    // );
  }

  uploadImage(String time, String fullImageName) async {
    FirebaseAuth.instance.currentUser().then((val) {
      UserUpdateInfo updateUser = UserUpdateInfo();
      updateUser.photoUrl = fullImageName;
      val.updateProfile(updateUser);
      val.reload();
    }).then((res) {
      // getPhotoUrl();
    });

    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uid)
        .update({'photoUrl': fullImageName})
        .then((value) {})
        .catchError((e) {
          print(e);
        });

    setState(() {
      _saving = false;
      photoUrl = fullImageName;
    });
  }

  Future<String> getPhotoUrl() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.photoUrl != null) {
      setState(() {
        photoUrl = user.photoUrl;
        print(photoUrl);
      });
    }
    return user.photoUrl;
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 20.0, left: 20),
              child: Container(
                  height: 40,
                  child: RaisedButton(
                    child: Text(
                      "حفظ المعلومات",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    textColor: Colors.white,
                    color: Colors.teal,
                    onPressed: () {
                      if (_adressController.text == "" ||
                          _mobileController.text == "" ||
                          _pointsController.text == "") {
                        SuccessAlert(context);
                      } else {
                        setState(() {
                          _saving = true;
                          imageSelect = false;
                        });
                        addUser(
                            _nameController.text,
                            _mobileController.text,
                            photoUrl,
                            _adressController.text,
                            _pointsController.text);
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 3,
          ),
        ],
      ),
    );
  }

  SuccessAlert(context) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      titleStyle: TextStyle(color: Colors.black87, fontSize: 20),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: "يرجى اكمال معلوماتك الشخصية قبل البدء",
      content: Column(
        children: <Widget>[],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "موافق",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Colors.teal,
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }
}
