import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jurrek/model/module.dart';
import 'package:jurrek/ui/AboutPage.dart';
import 'package:jurrek/ui/CourseClientPage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class ColegePage extends StatefulWidget {
  @override
  _ColegePageState createState() => _ColegePageState();
}

class _ColegePageState extends State<ColegePage>
    with SingleTickerProviderStateMixin {
  final studentReference =
      FirebaseDatabase.instance.reference().child('colege');
  List<module> items;

  int currentIndex = 0;
  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;
  TextEditingController _nameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = new TabController(length: 4, vsync: this);

    items = new List();

    _onStudentAddedSubscription =
        studentReference.onChildAdded.listen(_onStudentAdded);
    _onStudentChangedSubscription =
        studentReference.onChildChanged.listen(_onStudentUpdated);
  }

  TabController controller;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.blue[300]),
    );
    return  
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue[300],
          elevation: 0,
          title: Text(
            'Maths 1ere collège AR',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            color: Colors.white,
            padding: EdgeInsets.all(7.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/jurrek.png"),
                          fit: BoxFit.fitWidth),
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10)),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (BuildContext context, int position) {
                      return Card(
                        elevation: 0,
                        child: _buildCard(
                            position,
                            items[position].id,
                            items[position].name,
                            items[position].date,
                            items[position].photo,
                            context),
                      );
                    },
                  ),
                ),
              ],
            )),
      );
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;

      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
      }
      if (index == 1) {
        Share.share(
            'Download from google play  https://play.google.com/store/apps/details?id=com.education.level_one',
            subject: 'Maths 1ere college AR');
      }
    });
  }

  Widget _buildCard(int position, String id, String name, String date,
      String photo, context) {
    if (position == 0) {
      return Padding(
          padding:
              EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CourseClientPage(id, name)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //       color: Colors.green.withOpacity(0.3),
                    //       spreadRadius: 3.0,
                    //       blurRadius: 5.0)
                    // ],
                    color: Colors.green[100]),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/book.png"))),
                          ),
                        ],
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                child: Container(
                                  color: Colors.green[300],
                                  height: 1,
                                ),
                                padding: EdgeInsets.only(left: 10, right: 10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.green[300],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "تصفح",
                                  style: TextStyle(
                                      color: Colors.green[300],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )));
    } else {
      return Padding(
          padding:
              EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CourseClientPage(id, name)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //       color: Colors.grey.withOpacity(0.3),
                    //       spreadRadius: 3.0,
                    //       blurRadius: 5.0)
                    // ],
                    color: Colors.red[100]),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/book.png"))),
                          ),
                        ],
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                child: Container(
                                  color: Colors.red[300],
                                  height: 1,
                                ),
                                padding: EdgeInsets.only(left: 10, right: 10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.red[300],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "تصفح",
                                  style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )));
    }
  }

  void _onStudentAdded(Event event) {
    setState(() {
      items.add(new module.fromSnapShot(event.snapshot));
    });
  }

  void _onStudentUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((student) => student.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new module.fromSnapShot(event.snapshot);
    });
  }

  showAlert(context) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.amber[400],
      ),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: "تعديل الإسم",
      content: Column(
        children: <Widget>[
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            showCursor: true,
            decoration: InputDecoration(
              enabled: true,
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "تأكيد",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {},
          color: Colors.amber,
          radius: BorderRadius.circular(0.0),
        ),
        DialogButton(
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Colors.grey,
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }
}
