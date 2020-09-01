import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 120,
                  ),
                  Container(
                    height: 150.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(
                          image: AssetImage("assets/jurrek.png"),
                          fit: BoxFit.fill,
                          alignment: Alignment.topCenter),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        "Jurrek",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      SizedBox(
                        height: 80,
                      )
                    ],
                  )
                ],
              ),
              Text(
                "Jurrek © جميع الحقوق محفوظة",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87),
              )
            ],
          ),
        ),
      ),
    );
  }
}
