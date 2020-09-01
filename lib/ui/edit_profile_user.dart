// EditProfileUser
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jurrek/GoogleSignApp.dart';
import 'package:jurrek/model/subcription_model.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'OrderPageAdmin.dart';

class EditProfileUser extends StatefulWidget {
  final String uid;

  EditProfileUser({Key key, this.uid}) : super(key: key);
  @override
  _EditProfileUserState createState() => _EditProfileUserState();
}

class _EditProfileUserState extends State<EditProfileUser>
    with SingleTickerProviderStateMixin {
  String uid = "";
  String IdToken;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUid();
    getPhotoUrl(widget.uid);

    _nameController = TextEditingController();
    _pointsController = TextEditingController();
    _mobileController = TextEditingController();
    _adressController = TextEditingController();
  }

  // void testgetRoles() {
  //   FirebaseDatabase.instance
  //       .reference()
  //       .child("rolus")
  //       .child("${widget.uid}")
  //       .once()
  //       .then((DataSnapshot snapshot) {
  //         if( snapshot.value == null ){
  //             insertRoles("user");
  //         }else{
  //           return snapshot.value;
  //         }
  //   });
  // }

  bool imageSelect = false;
  final informationReference =
      FirebaseDatabase.instance.reference().child('users');
// WDXEDyBe6sQHyHdit8lRuV4VfFj2
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
  String autoFocus = "";
  String photoUrl = 'assets/images/as.png';
  getUid() async {
    getInformation(widget.uid);
  }

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.teal),
    );
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.teal),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "تعديل علي ملف العضو",
          style: TextStyle(color: Colors.teal),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 50),
                      Text(
                        'معلومات العضو',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      
                      buildPaddingTextField(),

                      /// Start Field Text Controller

                      _getActionButtons()
                    ],
                  ),
                  _saving
                      ? Positioned(
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
        ),
      ),
    );
  }

  
  
  // _rolesValueInsert(bool value) {
  //   if (value == true) {
  //     setState(() {
  //       active = value;
  //     });
  //     insertRoles("admin");
  //   } else {
  //     setState(() {
  //       active = value;
  //     });
  //     insertRoles("user");
  //   }
  // }


  // void insertRoles(String role) async {
  //   await FirebaseDatabase.instance
  //       .reference()
  //       .child("rolus")
  //       .child("${widget.uid}")
  //       .update({
  //     "rolus": "$role",
  //   });
  // }

  Padding buildPaddingTextField() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            'الإسم',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 45,
            padding: EdgeInsets.only(top: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.14), blurRadius: 10)
                ]),
            child: Center(
              child: TextField(
                textAlign: TextAlign.right,
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: "أدخل اسمك الكامل", border: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),

          /// Email Start
          Text(
            'البريد الإلكتروني',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 45,
            padding: EdgeInsets.only(top: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 10,
                )
              ],
            ),
            child: TextField(
              textAlign: TextAlign.right,
              controller: _adressController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "أدخل بريدك الإلكتروني",
              ),
            ),
          ),

          /// And tow Field [Country] And [Address]
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'الهاتف',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.35,
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.only(top: 20, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        controller: _mobileController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "أدخل رقم هاتفك",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //-------------------
              Column(
                children: [
                  Text(
                    'العنوان',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: size.width * 0.35,
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.only(top: 20, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        controller: _pointsController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "أدخل عنوانك",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(
            height: 30,
          ),
          // Text(
          //   "السماح للعضو بمشاهدة المشتركين معه في الفئاة",
          //   textDirection: TextDirection.rtl,
          //   style: TextStyle(
          //     fontSize: 16.0,
          //     fontWeight: FontWeight.w200,
          //   ),
          // ),
          // Directionality(
          //   textDirection: TextDirection.rtl,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
               
              
              
          //       //===============================================
          //       // active == false ? custombtn(Colors.blue , "Active", _rolesValueInsert(true)) : custombtn(Colors.red , "Close", _rolesValueInsert(false))
          //       //===============================================
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
  // Widget custombtn(Color color,String txt, Function onTap){
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 120,
  //       height: 50,
  //       decoration: BoxDecoration(
  //         color: color,
  //         borderRadius: BorderRadius.circular(5),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.teal.withOpacity(0.2),
  //             blurRadius: 4
  //           )
  //         ]
  //       ),
  //       child: Text(txt),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _nameController.clear();
    _pointsController.clear();
    _mobileController.clear();
    _adressController.clear();
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
        MaterialPageRoute(builder: (context) => OrderPageAdmin()),
        (Route<dynamic> route) => false);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ListViewStudent()),
    // );
  }

  uploadImage(String time, String fullImageName) async {
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uid)
        .update({'photoUrl': fullImageName}).then((value) {
      print("Done");
    }).catchError((e) {
      print(e);
    });

    setState(() {
      _saving = false;
      photoUrl = fullImageName;
    });
  }

  Future<String> getPhotoUrl(String uid) async {
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
            photoUrl = values["photoUrl"];
          });
          print("Image $photoUrl");
          return values["photoUrl"];
        }
      });
    } on PlatformException catch (error) {}
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
                      "حفظ التعديل",
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
