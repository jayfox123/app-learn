import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jurrek/GoogleSignApp.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'Config.dart';

// void main()async{
//   // var vs = await GetVersion.projectVersion;
//   // print( "$vs" );
// }
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = GoogleSignApp();
  bool load = true;
  @override
  void initState() {

    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user == null) {
        setState(() {
          load = false;
          _defaultHome = GoogleSignApp();
        });
      } else {
        setState(() {
          _defaultHome = HomePage();
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: Config().NameApp + " " + Config().SecendNameApp,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: Color(0xff9C58D2),
      ),
      home: _defaultHome,
    );
  }
}
