import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jurrek/Config.dart';

class Forgot extends StatefulWidget {
  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  TextEditingController _emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _emailController = new TextEditingController();
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
                      height: 210,
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
                  height: 20,
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
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "أدخل بريدك الألكتروني ",
                                      prefixIcon: Icon(Icons.alternate_email),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () async {
                                await _sendPasswordResetEmail(
                                    _emailController.text);
                                showAlert("يرجى الاطلاع على بريدك الإلكتروني");
                              },

                              //since this is only a UI app

                              child: Text(
                                'استعادة كلمة المرور',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.teal,
                              elevation: 4,
                              minWidth: 300,
                              height: 50,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "الرجوع الى الصفحة الرئيسية",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                // decoration: TextDecoration.underline
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _saving ?
                      Positioned(
                        // top:100,
                        // left: MediaQuery.of(context).size.width/2,

                        child: Center(
                          child: SpinKitCircle(
                            color: Colors.teal,
                            size: 100,
                          ),
                        ),
                      )
                    : Text(""),
                  ],
                ),
              ],
            )
          ],
        ),
        //       isLoading: _saving,progressIndicator: CircularProgressIndicator()),
      );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  showAlert(String task) async {
    Alert(
        context: context,
        title: task,
        image: Image.asset(
          "assets/login2.png",
          height: 120,
          width: 120,
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
}
