import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/ui/HomePage.dart';
import 'package:share/share.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'اتصل بنا',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 150,
              width: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage("assets/login2.png"),
                      fit: BoxFit.fill)),
            ),
            Text(
              "رواد اكاديمي",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  " أكاديمية سعودية تهتم بالمجال التعليمي  تختص بالمعلمين والمعلمات والطلاب والطالبات والباحثين عن التميز ، حقائب ، دورات ، فيديوهات تعليمية والكثير من المزايا ",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 10,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.call),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "0592972744",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.call),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "0580203676",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;

      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
      if (index == 1) {
        Share.share(
            'Download from google play  https://play.google.com/store/apps/details?id=com.education.level_one',
            subject: 'Maths 1ere college AR');
      }
    });
  }
}
