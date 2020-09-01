import 'dart:async';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/model/module.dart';
import 'package:jurrek/ui/DetailPage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CoursePage extends StatefulWidget {
  String idSemestre;
  String nameSemestre;
  CoursePage(this.idSemestre, this.nameSemestre);
  @override
  _CoursePageState createState() =>
      _CoursePageState(this.idSemestre, this.nameSemestre);
}

class _CoursePageState extends State<CoursePage> {
  String idSemestre;
  String nameSemestre;

  _CoursePageState(this.idSemestre, this.nameSemestre);

  var SemRef;

  List<module> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;

  @override
  void initState() {
    super.initState();

    print(idSemestre);
    items = new List();
    // pendingtaskReference.child(idModule);
    SemRef =
        FirebaseDatabase.instance.reference().child('Course').child(idSemestre);
    _onStudentAddedSubscription = SemRef.onChildAdded.listen(_onStudentAdded);

    _onStudentChangedSubscription =
        SemRef.onChildChanged.listen(_onTransferUpdated);
    _nameController = new TextEditingController();
  }

  bool _saving = true;

  File image;
  var key;
  var DisplayName;
  TextEditingController _nameController;

  bool imageSelect = false;

  picker() async {
    File img = await FilePicker.getFile();

    // if (this.mounted) {
    if (img != null) {
      setState(() {
        _saving = true;
      });
      // }
      image = img;
      var now = new DateTime.now().toString();
      String time = now;
      time = time.trim().replaceAll(":", "").replaceAll(" ", "");
      var fullImageName = 'images/$time' + '.jpg';

      // if (this.mounted) {
      setState(() {
        imageSelect = true;
      });
      // }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _onStudentAddedSubscription.cancel();
    _onStudentChangedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    SemRef =
        FirebaseDatabase.instance.reference().child('Course').child(idSemestre);
    return   
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            elevation: 0,
            bottom: TabBar(
              labelColor: Colors.white,
              labelStyle: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontFamily: "Cairo"),
              unselectedLabelStyle:
                  TextStyle(fontSize: 20, fontFamily: "Cairo"),
              unselectedLabelColor: Colors.black,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.teal),
              tabs: [
                Tab(text: "الدرس"),
                Tab(text: " اضافة درس"),
              ],
            ),
            title: Text(
              'معلومات الدرس ',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              IconButton(
                color: Colors.black,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          body: TabBarView(
            children: [
              StreamBuilder(
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
                              // color: Colors.amberAccent,
                              height: 60.0,
                              width: 60.0,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.bookReader,
                                    size: 40,
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
                              "ليس لديك دروس",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ));
                    } else {
                      return Container(
                        color: Colors.grey[100],
                        child: Column(
                          children: <Widget>[
                            // Container(
                            //   height: 80,
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.only(
                            //         bottomRight: Radius.circular(30),
                            //         bottomLeft: Radius.circular(30)),
                            //     color: Colors.teal,
                            //   ),
                            //   child: Center(
                            //     child: Container(
                            //       padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                            //       decoration: BoxDecoration(
                            //           color: Colors.white.withOpacity(0.1),
                            //           borderRadius: BorderRadius.only(
                            //               bottomRight: Radius.circular(30),
                            //               topLeft: Radius.circular(30))),
                            //       child: Text(
                            //         nameSemestre,
                            //         style: TextStyle(
                            //             color: Colors.white, fontSize: 20),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                    bottom: 60, right: 15, left: 15),
                                itemCount: items.toList().length,
                                itemBuilder: (context, position) {
                                  return Container(
                                    color: Colors.grey[100],
                                    child: Card(
                                      elevation: 0,
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
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else
                    return LinearProgressIndicator();
                },
              ),

              // Container(
              //     padding: EdgeInsets.all(7.0),
              //     child: GridView.builder(
              //       itemCount: items.length,
              //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 1,
              //         childAspectRatio: 0.6,
              //       ),
              //       itemBuilder: (BuildContext context, int position) {
              //         return Card(
              //           elevation: 0,
              //           child: _buildCard(
              //               position,
              //               items[position].name,
              //               items[position].name,
              //               items[position].date,
              //               items[position].photo,
              //               context),
              //         );
              //       },
              //     )),
              ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[100]))),
                                      child: TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "اسم الدرس ",
                                            prefixIcon: Icon(Icons.border_all),
                                            hintStyle: TextStyle(
                                                color: Colors.grey[400])),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: MaterialButton(
                                  onPressed: () async {
                                    var now = formatDate(new DateTime.now(), [
                                      yyyy,
                                      '-',
                                      mm,
                                      '-',
                                      dd,
                                      ', ',
                                      hh,
                                      ':',
                                      mm
                                    ]);
                                    FirebaseDatabase.instance
                                        .reference()
                                        .child('Course')
                                        .child(idSemestre)
                                        .push()
                                        .set({
                                      'name': _nameController.text,
                                      'url': _nameController.text,
                                      'date': now
                                    }).then((_) {
                                      // showAlert(_nameController.text);
                                    });
                                  },
                                  child: Text(
                                    'اضافة ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  color: Colors.teal,
                                  elevation: 0,
                                  minWidth: 400,
                                  height: 50,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );
  }

  void _onStudentAdded(Event event) {
    if (this.mounted) {
      setState(() {
        items.add(new module.fromSnapShot(event.snapshot));
      });
    }
  }

  void _onStudentUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((student) => student.id == event.snapshot.key);

    if (this.mounted) {
      setState(() {
        items[items.indexOf(oldStudentValue)] =
            new module.fromSnapShot(event.snapshot);
      });
    }
  }

  // void _FinTask(BuildContext context, module student, int position) async {
  //   var now = formatDate(
  //       new DateTime.now(), [yyyy, '-', mm, '-', dd, ', ', hh, ':', mm]);
  //   ArchivetaskReference.push().set({
  //     'name': student.name,
  //     'photo': student.photo,
  //     'datestart': student.date,
  //     'dateend': now
  //   }).then((_) {
  //     showAlert(student.name);
  //   });

  //   // Navigator.pop(context);

  //   await studentReference.child(student.id).remove().then((res) {
  //     setState(() {
  //       items.removeAt(position);
  //     });
  //   });
  // }

  uploadImage(String time, String fullImageName) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child(fullImageName);
    final StorageUploadTask task = ref.putFile(image);
    await task.onComplete;
    setState(() {
      _saving = false;
    });
  }

  void _navigateToStudent(BuildContext context) async {
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => Semestre()),
    // );
  }

  void _createNewStudent(BuildContext context) async {
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => Semestre()),
    // );
  }

  Widget _buildCard(int position, String id, String name, String date,
      String photo, context) {
    position++;
    return Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 2.0, right: 2.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailPage(id, nameSemestre, name)),
              );
            },
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.teal[50],
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Center(
                                  child: Text(
                                "$position",
                                style: TextStyle(fontSize: 18),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: 4,
                      ),
                      InkWell(
                        onTap: () {
                          ConfrimAlert(context, id, position);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(
                              "حذف",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          EditAlert(context, id);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(
                              "تعديل",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }

  void _onTransferUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((transfer) => transfer.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new module.fromSnapShot(event.snapshot);
    });
  }

  EditAlert(context, String id) {
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
      title: "تعديل الإسم",
      content: Column(
        children: <Widget>[
          TextField(
            controller: _nameController,
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
          onPressed: () {
            FirebaseDatabase.instance
                .reference()
                .child("Course")
                .child(idSemestre)
                .child(id)
                .update({'name': _nameController.text});
            Navigator.of(context, rootNavigator: true).pop();
            _nameController.text = "";
          },
          color: Colors.teal,
          radius: BorderRadius.circular(0.0),
        ),
        DialogButton(
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Colors.grey[200],
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  ConfrimAlert(context, String id, int position) {
    position--;
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
      title: "هل انت متاكد من الحذف ",
      content: Column(
        children: <Widget>[],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "تأكيد",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            FirebaseDatabase.instance
                .reference()
                .child("Course")
                .child(idSemestre)
                .child(id)
                .remove();
            setState(() {
              items.removeAt(position);
            });
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Colors.teal,
          radius: BorderRadius.circular(0.0),
        ),
        DialogButton(
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Colors.grey[200],
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  showAlert(String task, context) async {
    Alert(context: context, title: "تم اضافة المادة", desc: task, buttons: [
      DialogButton(
        color: Colors.amberAccent,
        onPressed: () => Navigator.pop(context),
        child: Text(
          "موافق",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ]).show();
  }
}
