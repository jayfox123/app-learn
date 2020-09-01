import 'dart:async';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/model/module.dart';
import 'package:jurrek/ui/ViewerPage.dart';
import 'package:jurrek/ui/player.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DetailPage extends StatefulWidget {
  String idCourse;
  String nameCourse;
  String nameSemestre;

  DetailPage(this.idCourse, this.nameSemestre, this.nameCourse);
  @override
  _DetailPageState createState() =>
      _DetailPageState(this.idCourse, this.nameSemestre, this.nameCourse);
}

class _DetailPageState extends State<DetailPage> {
  String idCourse;
  String nameSemestre;
  String nameCourse;

  _DetailPageState(this.idCourse, this.nameSemestre, this.nameCourse);

  var SemRef;

  List<module> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;

  @override
  void initState() {
    super.initState();

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
    _urlController = new TextEditingController();
    _videoController = new TextEditingController();
    _testController = new TextEditingController();
  }

  bool _saving = true;
  double _progess = 0;
  File image;
  File image2;
  File image3;
  var key;
  var DisplayName;
  TextEditingController _nameController;
  TextEditingController _urlController;
  TextEditingController _videoController;
  TextEditingController _testController;

  bool imageSelect = false;
  bool imageSelect2 = false;

  bool loadingCours = false;
  bool loadingTest = false;
  bool loadingSolution = false;
  picker() async {
    File img = await FilePicker.getFile(type: FileType.video);

    // await FilePicker.getFile();

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
      var fullImageName = 'images/$time' + '.mp4';

      // if (this.mounted) {
      setState(() {
        imageSelect = true;
      });
      // }
    }
  }

  picker2() async {
    File img2 =
        await FilePicker.getFile(type: FileType.custom,);

    // if (this.mounted) {
    if (img2 != null) {
      setState(() {
        _saving = true;
      });
      // }
      image2 = img2;
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

  picker3() async {
    File img2 =
        await FilePicker.getFile(type: FileType.custom);

    // if (this.mounted) {
    if (img2 != null) {
      setState(() {
        _saving = true;
      });
      // }
      image3 = img2;
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
    SemRef = FirebaseDatabase.instance
        .reference()
        .child('detail')
        .child(idCourse)
        .orderByChild("name");
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
                Tab(text: "المرفقات"),
                Tab(text: " اضافة مرفق"),
              ],
            ),
            title: Text(
              'تفاصيل الدرس ',
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
              Container(
                color: Colors.teal[50],
                child: Column(
                  children: <Widget>[
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
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                          color:
                                              Colors.black87.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ));
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.only(
                                    bottom: 50, left: 15, right: 15),
                                itemCount: items.toList().reversed.length,
                                itemBuilder: (context, position) {
                                  return Container(
                                    child: Card(
                                      elevation: 0,
                                      semanticContainer: false,
                                      color: Colors.teal[50],
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      " اختيار فيديو الدرس",
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        InkWell(
                                            onTap: () {
                                              picker();
                                            },
                                            child: Container(
                                                color: Colors.grey[100],
                                                width: 130,
                                                height: 150,
                                                child: image == null
                                                    ? Icon(
                                                        Icons.add,
                                                        size: 38,
                                                      )
                                                    : Icon(
                                                        Icons.video_library,
                                                        size: 130,
                                                        color: Colors.teal,
                                                      ))),
                                        image != null
                                            ? Positioned(
                                                right: -10,
                                                top: -10,
                                                child: IconButton(
                                                  icon: Icon(Icons.cancel),
                                                  color: Colors.teal,
                                                  onPressed: () {
                                                    setState(() {
                                                      image = null;
                                                    });
                                                  },
                                                ))
                                            : Text("")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                " او ",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  controller: _urlController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: " رابط الفيديو ",
                                      prefixIcon: Icon(Icons.link),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              loadingCours
                                  ? Column(
                                      children: <Widget>[
                                        CircularProgressIndicator(
                                          value: _progess / 100,
                                        ),
                                        Text("$_progess %")
                                      ],
                                    )
                                  : Padding(
                                      padding: EdgeInsets.all(15),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          String downloadUrl;
                                          if (_urlController.text == "") {
                                            setState(() {
                                              loadingCours = true;
                                            });

                                            int timestamp = new DateTime.now()
                                                .millisecondsSinceEpoch;
                                            StorageReference storageReference =
                                                FirebaseStorage.instance
                                                    .ref()
                                                    .child("mp4" +
                                                        timestamp.toString() +
                                                        ".mp4");
                                            StorageUploadTask uploadTask =
                                                storageReference.put(image);
                                            uploadTask
                                              ..events.listen((event) {
                                                setState(() {
                                                  _progess = double.parse((100 *
                                                          event.snapshot
                                                              .bytesTransferred
                                                              .toDouble() /
                                                          event.snapshot
                                                              .totalByteCount
                                                              .toDouble())
                                                      .toStringAsFixed(2));
                                                });
                                              }).onError((error) {});
                                            StorageTaskSnapshot
                                                storageTaskSnapshot =
                                                await uploadTask.onComplete;
                                            downloadUrl =
                                                await storageTaskSnapshot.ref
                                                    .getDownloadURL();
                                          } else {
                                            downloadUrl = _urlController.text;
                                          }
                                          var now = formatDate(
                                              new DateTime.now(), [
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
                                              .child('detail')
                                              .child(idCourse)
                                              .push()
                                              .set({
                                            'name': " فيديو الدرس ",
                                            'url': downloadUrl.toString(),
                                            'date': now
                                          }).then((_) {
                                            ConfrimAlert();

                                            setState(() {
                                              loadingCours = false;
                                            });
                                          });
                                        },
                                        child: Text(
                                          ' اضافة الفيديو',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        color: Colors.teal,
                                        elevation: 0,
                                        minWidth: 100,
                                        height: 40,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "اختيار ملف الدرس",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold),
                              ),
                              Stack(
                                children: <Widget>[
                                  InkWell(
                                      onTap: () {
                                        picker3();
                                      },
                                      child: Container(
                                          color: Colors.grey[100],
                                          width: 130,
                                          height: 150,
                                          child: image3 == null
                                              ? Icon(
                                                  Icons.add,
                                                  size: 38,
                                                )
                                              : Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 130,
                                                  color: Colors.red,
                                                ))),
                                  image3 != null
                                      ? Positioned(
                                          right: -10,
                                          top: -10,
                                          child: IconButton(
                                            icon: Icon(Icons.cancel),
                                            color: Colors.teal,
                                            onPressed: () {
                                              setState(() {
                                                image3 = null;
                                              });
                                            },
                                          ))
                                      : Text("")
                                ],
                              ),
                              loadingSolution
                                  ? CircularProgressIndicator()
                                  : Padding(
                                      padding: EdgeInsets.all(15),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          setState(() {
                                            loadingSolution = true;
                                          });
                                          int timestamp = new DateTime.now()
                                              .millisecondsSinceEpoch;
                                          StorageReference storageReference =
                                              FirebaseStorage.instance
                                                  .ref()
                                                  .child("pdf" +
                                                      timestamp.toString() +
                                                      ".pdf");
                                          StorageUploadTask uploadTask =
                                              storageReference.put(image3);
                                          StorageTaskSnapshot
                                              storageTaskSnapshot =
                                              await uploadTask.onComplete;
                                          String downloadUrl =
                                              await storageTaskSnapshot.ref
                                                  .getDownloadURL();
                                          ConfrimAlert();
                                          var now = formatDate(
                                              new DateTime.now(), [
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
                                              .child('detail')
                                              .child(idCourse)
                                              .push()
                                              .set({
                                            'name': "ملف الدرس ",
                                            'url': downloadUrl.toString(),
                                            'date': now
                                          }).then((_) {
                                            setState(() {
                                              loadingSolution = false;
                                            });
                                            // showAlert(_nameController.text);
                                          });
                                        },
                                        child: Text(
                                          'اضافة الملف ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        color: Colors.teal,
                                        elevation: 0,
                                        minWidth: 100,
                                        height: 40,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
  // Future _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Widget _buildCard(int position, String id, String name, String date,
      String photo, context) {
    position++;
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: InkWell(
            onTap: () async {
              if (name.contains("ملف")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewerPage(name, photo)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => player(photo)),
                );
              }
            },
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          FirebaseDatabase.instance
                              .reference()
                              .child("detail")
                              .child(idCourse)
                              .child(id)
                              .remove();
                          position--;
                          _deleteStudent(context, position);
                          String filePath = photo.replaceAll(
                              new RegExp(
                                  r'https://firebasestorage.googleapis.com/v0/b/education-aa85a.appspot.com/o/'),
                              '');

                          filePath =
                              filePath.replaceAll(new RegExp(r'%2F'), '/');

                          filePath =
                              filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
                          FirebaseStorage.instance
                              .ref()
                              .child(filePath)
                              .delete()
                              .then((_) {});
                        },
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                        name.contains("معاينة الدرس ") ||
                            name.contains("التمرين") ||
                            name.contains("الحل") ?
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.teal[50],
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Center(
                                child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.redAccent,
                              size: 40,
                            )),
                          )
                        : Text(""),
                        name.contains("يوتيوب") ?
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.teal[50],
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Center(
                                child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.redAccent,
                              size: 40,
                            )),
                          )
                        : Text(""),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  void _deleteStudent(BuildContext context, int position) async {
    setState(() {
      items.removeAt(position);
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

  showAlert(context) async {
    Alert(context: context, title: "تم اضافة المادة", buttons: [
      DialogButton(
        color: Colors.teal,
        onPressed: () => Navigator.pop(context),
        child: Text(
          "تم اضافة الرفق بنجاح",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ]).show();
  }

  ConfrimAlert() {
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
      title: "تم اضافة المرفق بنجاح",
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
