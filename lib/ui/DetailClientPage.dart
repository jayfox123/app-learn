import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/model/module.dart';
import 'package:jurrek/ui/ViewerPage.dart';
import 'package:jurrek/ui/player.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DetailClientPage extends StatefulWidget {
  String idCourse;
  String nameCourse;
  String nameSemestre;
  DetailClientPage(this.idCourse, this.nameSemestre, this.nameCourse);
  @override
  _DetailClientPageState createState() =>
      _DetailClientPageState(this.idCourse, this.nameSemestre, this.nameCourse);
}

class _DetailClientPageState extends State<DetailClientPage> {
  String idCourse;
  String nameCourse;
  String nameSemestre;
  _DetailClientPageState(this.idCourse, this.nameSemestre, this.nameCourse);

  var SemRef;

  List<module> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;

  @override
  void initState() {
    super.initState();
    getuser();
    items = new List();
    // pendingtaskReference.child(idModule);
    SemRef = FirebaseDatabase.instance
        .reference()
        .child('detail')
        .child(idCourse)
        .orderByChild("name");
    _onStudentAddedSubscription = SemRef.onChildAdded.listen(_onStudentAdded);

    _onStudentChangedSubscription =
        SemRef.onChildChanged.listen(_onTransferUpdated);
    _nameController = new TextEditingController();
    _videoController = new TextEditingController();
    _testController = new TextEditingController();
  }

  bool _saving = true;

  var key;
  var DisplayName;
  TextEditingController _nameController;
  TextEditingController _videoController;
  TextEditingController _testController;

  bool imageSelect = false;
  bool imageSelect2 = false;
  @override
  Widget build(BuildContext context) {
    SemRef = FirebaseDatabase.instance
        .reference()
        .child('detail')
        .child(idCourse)
        .orderByChild("name");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'رواد اكاديمي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60)),
                color: Colors.teal,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(30),
                              topLeft: Radius.circular(30))),
                      child: Text(
                        nameSemestre,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(30),
                              topLeft: Radius.circular(30))),
                      child: Text(
                        nameCourse,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: SemRef.onValue,
                builder: (context, snap) {
                  if (snap.hasData && !snap.hasError) {
                    if (snap.data.snapshot.value == null) {
                      return Center(
                          child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 60.0,
                              width: 60.0,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.bookReader,
                                    size: 36,
                                  ),
                                  onPressed: null),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: Colors.white,
                                    style: BorderStyle.solid,
                                    width: 1.0),
                              ),
                            ),
                            Text(
                              "ملفات الدرس غير موجودة",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ));
                    } else {
                      return ListView.builder(
                        padding:
                            EdgeInsets.only(bottom: 50, left: 15, right: 15),
                        itemCount: items.toList().reversed.length,
                        itemBuilder: (context, position) {
                          return Container(
                            child: Card(
                              elevation: 0,
                              semanticContainer: false,
                              color: Colors.grey[100],
                              child: _buildCard(
                                  position,
                                  items[position].id,
                                  items[position].name,
                                  items[position].date,
                                  items[position].photo,
                                  context),
                            ),
                          );
                        },
                      );
                    }
                  } else
                    return LinearProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Future getuser() async {
    await FirebaseAuth.instance.currentUser().then((user) {
      if (user.uid != null) {
        setState(() {
          uid = user.uid;
          user.reload();
        });
      }
    });
  }

  String uid = "";

  String Status = "0";
  Future<String> getInformation(String uid) async {
    await FirebaseDatabase.instance
        .reference()
        .child("users")
        .orderByChild("uid")
        .equalTo(uid)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        if (this.mounted) {
          setState(() {
            Status = values["status"];

            if (Status == "1") {
              showAlert("1", context);
            }
            if (Status == "2") {
              showAlert("2", context);
            }
          });
        }
      });
    });
    return Status;
  }

  showAlert(String Status, context) async {
    String info = "";
    if (Status == "1") {
      info = "حسابك غير مفعل";
    }
    if (Status == "2") {
      info = "تم حظر حسابك ";
    }

    var _style = AlertStyle(
        animationType: AnimationType.fromTop,
        descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        isCloseButton: false,
        backgroundColor: Colors.teal[50],
        titleStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold));
    Alert(
        style: _style,
        context: context,
        title: "تنبيه",
        desc: info,
        // image: Image.asset("assets/jurrek.png"),

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

  AlertStatus(String Status) {
    String info = "";
    if (Status == "1") {
      info = "حسابك غير مفعل";
    }
    if (Status == "2") {
      info = "تم حظر حسابك ";
    }
    var popup = BeautifulPopup(
      context: context,
      template: TemplateAuthentication,
    );

    popup.show(
      title: ' تنبيه',
      // barrierDismissible: true,
      content: Column(
        children: <Widget>[
          Center(
            child: Container(
              child: Text(
                info,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
      actions: [
        popup.button(
          label: 'إغلاق',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }

  Widget _buildCard(int position, String id, String name, String date,
      String photo, context) {
    position++;
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
      child: InkWell(
        onTap: () async {
          getInformation(uid).then((res) async {
            if (res == "0") {
              if (name.contains("ملف")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewerPage(name, photo)),
                );
                // await launch(photo);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => player(link:photo)),
                );
              }
            }
          });
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    name.contains("فيديو")
                        ? Container(
                            height: 45,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Colors.teal[50],
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Center(
                                child: Icon(
                              Icons.video_library,
                              color: Colors.redAccent,
                              size: 30,
                            )),
                          )
                        : Text(""),
                    name.contains("ملف")
                        ? Container(
                            height: 45,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                            ),
                          )
                        : Text("")
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

  void _onTransferUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((transfer) => transfer.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new module.fromSnapShot(event.snapshot);
    });
  }
}
