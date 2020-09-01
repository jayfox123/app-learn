import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/ui/CoursePage.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:jurrek/model/module.dart';

class ColegeAdmin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ColegeAdminState();
}

class _ColegeAdminState extends State<ColegeAdmin> {
  var SemRef;

  List<module> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;

  @override
  void initState() {
    super.initState();

    items = List();
    // pendingtaskReference.child(idModule);
    SemRef = FirebaseDatabase.instance.reference().child('colege');
    _onStudentAddedSubscription = SemRef.onChildAdded.listen(_onStudentAdded);

    _onStudentChangedSubscription =
        SemRef.onChildChanged.listen(_onTransferUpdated);
    _nameController = TextEditingController();
  }

  bool _saving = true;

  File image;
  var key;
  var DisplayName;
  TextEditingController _nameController;

  bool imageSelect = false;

  @override
  void dispose() {
    super.dispose();
    _onStudentAddedSubscription.cancel();
    _onStudentChangedSubscription.cancel();
  }

  picker() async {
    File img = await FilePicker.getFile(type: FileType.image );

    // if (this.mounted) {
    if (img != null) {
      setState(() {
        _saving = true;
      });
      // }
      image = img;
      var now = DateTime.now().toString();
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
  Widget build(BuildContext context) {
    SemRef = FirebaseDatabase.instance.reference().child('colege');
    return 
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              unselectedLabelColor: Colors.blue,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blue[200]),
              tabs: [
                Tab(text: "المدرسة"),
                Tab(text: " اضافة مدرسة"),
              ],
            ),
            title: Text(
              'معلومات المدرسة',
              style: TextStyle(
                color: Colors.black,
              ),
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
                                    FontAwesomeIcons.book,
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
                              "ليس لديك فصول",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ));
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 60),
                        itemCount: items.toList().length,
                        itemBuilder: (context, position) {
                          return Container(
                            child: Card(
                              elevation: 0,
                              semanticContainer: false,
                              color: Colors.white,
                              child: _buildCard(
                                  position,
                                  items[position].id,
                                  items[position].name,
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
                                            hintText: "اسم الاسدوس ",
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
                              Stack(
                                children: <Widget>[
                                  InkWell(
                                      onTap: () {
                                        picker();
                                      },
                                      child: Container(
                                          color: Colors.grey[100],
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          height: 140,
                                          child: image == null
                                              ? Icon(
                                                  Icons.add,
                                                  size: 38,
                                                )
                                              : Image.file(image))),
                                  image != null
                                      ? Positioned(
                                          right: -10,
                                          top: -10,
                                          child: IconButton(
                                            icon: Icon(Icons.cancel),
                                            color: Colors.grey,
                                            onPressed: () {
                                              setState(() {
                                                image = null;
                                              });
                                            },
                                          ))
                                      : Text("")
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: MaterialButton(
                                  onPressed: () async {
                                    int timestamp = new DateTime.now()
                                        .millisecondsSinceEpoch;
                                    StorageReference storageReference =
                                        FirebaseStorage.instance.ref().child(
                                            "img_" +
                                                timestamp.toString() +
                                                ".jpg");
                                    StorageUploadTask uploadTask =
                                        storageReference.put(image);
                                    StorageTaskSnapshot storageTaskSnapshot =
                                        await uploadTask.onComplete;
                                    String downloadUrl =
                                        await storageTaskSnapshot.ref
                                            .getDownloadURL();

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
                                        .child("colege")
                                        .push()
                                        .set({
                                      'name': _nameController.text,
                                      'url': downloadUrl.toString(),
                                    }).then((_) {
                                      image = null;
                                      showAlert(_nameController.text);
                                    });
                                  },
                                  child: Text(
                                    'اضافة ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  color: Colors.blue,
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

  ConfrimAlert(context, String id, int position) {
    position--;
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
        side: BorderSide(
          color: Colors.blue,
        ),
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
                .child("colege")
                .child(id)
                .remove();
            setState(() {
              items.removeAt(position);
            });
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Colors.blueAccent,
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
    //   MaterialPageRoute(builder: (context) => ColegeAdmin()),
    // );
  }

  void _createNewStudent(BuildContext context) async {
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ColegeAdmin()),
    // );
  }
  Widget _buildCard(
      int position, String id, String name, String photo, context) {
    return Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CoursePage(id, name)),
              );
            },
            child: Column(
              children: <Widget>[
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[100],
                      image: DecorationImage(
                          image: NetworkImage(photo), fit: BoxFit.fill)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      topRight: Radius.circular(30))),
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          _nameController.text = name;

                          // EditAlert(context, id);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    topLeft: Radius.circular(8))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "تعديل",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Icon(Icons.edit, color: Colors.white)
                              ],
                            )),
                      ),
                    )),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          ConfrimAlert(context, id, position);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "حذف",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Icon(Icons.cancel, color: Colors.white)
                              ],
                            )),
                      ),
                    ))
                  ],
                )
              ],
            )));
  }

  EditAlert(context, String id) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
        side: BorderSide(
          color: Colors.blue,
        ),
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
                .child("colege")
                .child(id)
                .update({'name': _nameController.text});
            Navigator.of(context, rootNavigator: true).pop();
            _nameController.text = "";
          },
          color: Colors.blueAccent,
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

  void _onTransferUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((transfer) => transfer.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new module.fromSnapShot(event.snapshot);
    });
  }

  showAlert(String task) async {
    Alert(
        context: context,
        title: "تم اضافة المدرسة",
        desc: task,
        image: Image.asset("assets/jurrek.png"),
        buttons: [
          DialogButton(
            color: Colors.blue,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "موافق",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
