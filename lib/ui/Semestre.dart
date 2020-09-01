import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jurrek/model/HomeModel.dart';
import 'package:jurrek/ui/CoursePage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Semestre extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SemestreState();
}

class _SemestreState extends State<Semestre>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  var SemRef;
  String uid = "";
  getUid() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      DisplayName = user.displayName;
    });
  }

  bool ModeNormal = true;
  List<HomeModel> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;
  String idcate;
  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 2);

    getUid();
    items =  List();
    SemRef = FirebaseDatabase.instance.reference().child('colege');
    _onStudentAddedSubscription = SemRef.onChildAdded.listen(_onStudentAdded);

    _onStudentChangedSubscription =
        SemRef.onChildChanged.listen(_onTransferUpdated);
    _nameController =  TextEditingController();
  }

  bool _saving = true;

  File image;
  var key;
  var DisplayName;
  TextEditingController _nameController;
  Color currentColor = Colors.white;
  void changeColor(Color color) {
    setState(() => currentColor = color);
  }

  bool imageSelect = false;

  picker() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);

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

  String nameState = "اضافة فئة";
  @override
  Widget build(BuildContext context) {
    SemRef = FirebaseDatabase.instance.reference().child('colege');
    return  
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            elevation: 0,
            bottom: TabBar(
              controller: _controller,

              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.tealAccent,
              labelStyle: TextStyle(
                  fontSize: 22,
                  // fontWeight: FontWeight.bold,
                  fontFamily: "Cairo"),
              unselectedLabelStyle: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                  fontFamily: "Cairo"),
              // indicator: BoxDecoration(
              //     borderRadius: BorderRadius.circular(50),
              //     color: Colors.amber[200]),
              tabs: [
                Tab(text: "الفئات"),
                Tab(text: nameState),
              ],
            ),
            title: Text(
              'الاقسام الرئيسية',
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
            controller: _controller,
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
                                    Icons.border_all,
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
                              "ليس لديك فئات",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ));
                    } else {
                      return GridView.builder(
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (BuildContext context, int position) {
                          return Container(
                            child: Container(
                              // elevation: 0,
                              // semanticContainer: false,
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
                          color: Colors.white,
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
                                        textAlign: TextAlign.right,
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "اسم الفئة ",
                                            suffixIcon: Icon(Icons.border_all),
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
                                          color: Colors.teal[100],
                                          width: 140,
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
                              // InkWell(
                              //   onTap: () {
                              //     showDialog(
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return AlertDialog(
                              //           elevation: 0,
                              //           titlePadding: const EdgeInsets.all(0.0),
                              //           contentPadding:
                              //               const EdgeInsets.all(0.0),
                              //           content: SingleChildScrollView(
                              //             child: MaterialPicker(
                              //               pickerColor: currentColor,
                              //               onColorChanged: changeColor,
                              //               enableLabel: true,
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     );
                              //   },
                              //   child: Container(
                              //     height: 100,
                              //     width: 100,
                              //     decoration: BoxDecoration(
                              //         image: DecorationImage(
                              //             image:
                              //                 AssetImage("assets/wheel.png"))),
                              //   ),
                              // ),
                              ModeNormal
                                  ? Padding(
                                      padding: EdgeInsets.all(15),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          int timestamp = new DateTime.now()
                                              .millisecondsSinceEpoch;
                                          StorageReference storageReference =
                                              FirebaseStorage.instance
                                                  .ref()
                                                  .child("img_" +
                                                      timestamp.toString() +
                                                      ".jpg");
                                          StorageUploadTask uploadTask =
                                              storageReference.put(image);
                                          StorageTaskSnapshot
                                              storageTaskSnapshot =
                                              await uploadTask.onComplete;
                                          String downloadUrl =
                                              await storageTaskSnapshot.ref
                                                  .getDownloadURL();

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
                                              .child("colege")
                                              .push()
                                              .set({
                                            'name': _nameController.text,
                                            'photo': downloadUrl.toString(),
                                            'color': currentColor
                                                .toString()
                                                .replaceAll("Color(", "")
                                                .replaceAll(")", ""),
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
                                        color: Colors.teal,
                                        elevation: 0,
                                        minWidth: 400,
                                        height: 50,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(2)),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(15),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              setState(() {
                                                image = null;
                                                currentColor = Colors.grey[100];
                                                _nameController.text = "";

                                                ModeNormal = true;
                                                idcate = "";
                                                nameState = "اضافة فئة";
                                              });
                                            },
                                            child: Text(
                                              'إالغاء ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            color: Colors.redAccent,
                                            elevation: 0,
                                            minWidth: 120,
                                            height: 50,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(15),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              int timestamp = new DateTime.now()
                                                  .millisecondsSinceEpoch;
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

                                              if (image == null ||
                                                  image == "") {
                                                FirebaseDatabase.instance
                                                    .reference()
                                                    .child('colege')
                                                    .child(idcate)
                                                    .update({
                                                  'name': _nameController.text,
                                                  'color': currentColor
                                                      .toString()
                                                      .replaceAll("Color(", "")
                                                      .replaceAll(")", ""),
                                                }).then((_) {
                                                  setState(() {
                                                    ModeNormal = true;
                                                  });
                                                });

                                                // 'photo': downloadUrl.toString(),
                                                // 'color': currentColor
                                                //     .toString()
                                                //     .replaceAll("Color(", "")
                                                //     .replaceAll(")", ""),
                                                //     .then((_) {
                                                //   setState(() {
                                                //     ModeNormal = true;
                                                //   });
                                                // });
                                              } else {
                                                StorageReference
                                                    storageReference =
                                                    FirebaseStorage.instance
                                                        .ref()
                                                        .child("img_" +
                                                            timestamp
                                                                .toString() +
                                                            ".jpg");
                                                StorageUploadTask uploadTask =
                                                    storageReference.put(image);
                                                StorageTaskSnapshot
                                                    storageTaskSnapshot =
                                                    await uploadTask.onComplete;
                                                String downloadUrl =
                                                    await storageTaskSnapshot
                                                        .ref
                                                        .getDownloadURL();

                                                FirebaseDatabase.instance
                                                    .reference()
                                                    .child("colege")
                                                    .child(idcate)
                                                    .update({
                                                  'name': _nameController.text,
                                                  'photo':
                                                      downloadUrl.toString(),
                                                  'color': currentColor
                                                      .toString()
                                                      .replaceAll("Color(", "")
                                                      .replaceAll(")", ""),
                                                }).then((_) {
                                                  setState(() {
                                                    ModeNormal = true;
                                                    nameState = "اضافة فئة";
                                                  });
                                                  showAlert(
                                                      _nameController.text);
                                                });
                                              }
                                            },
                                            child: Text(
                                              'تعديل ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            color: Colors.teal,
                                            elevation: 0,
                                            minWidth: 120,
                                            height: 50,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ],
                                    )
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
      items.add(new HomeModel.fromSnapShot(event.snapshot));
    });
  }

  void _onStudentUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((student) => student.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new HomeModel.fromSnapShot(event.snapshot);
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
                .child("colege")
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

  // void _FinTask(BuildContext context, HomeModel student, int position) async {
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
  Widget _buildCard(
      int position, String id, String name, String photo, context) {
    position++;
    return Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 8.0, left: 6.0, right: 6.0),
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
                  height: 130,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                          image: NetworkImage(photo), fit: BoxFit.fill)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(2)),
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontSize: 16,
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
                          _controller.animateTo(1);

                          setState(() {
                            nameState = "تعديل الفئة";

                            ModeNormal = false;
                            idcate = id;
                          });
                          // EditAlert(context, id);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    topLeft: Radius.circular(8))),
                            child: Icon(Icons.edit, color: Colors.white)),
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
                            child: Icon(Icons.cancel, color: Colors.white)),
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
          color: Colors.teal,
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

  // Widget _buildCard(int position, String id, String name, String date,
  //     String photo, context) {
  //   return Padding(
  //       padding:
  //           EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
  //       child: InkWell(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => CoursePage(id, name)),
  //             );
  //           },
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(15.0),
  //                 boxShadow: [
  //                   BoxShadow(
  //                       color: Colors.grey.withOpacity(0.3),
  //                       spreadRadius: 3.0,
  //                       blurRadius: 5.0)
  //                 ],
  //                 color: Colors.white),
  //             child: Column(
  //               children: [
  //                 Container(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: <Widget>[
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                           children: <Widget>[
  //                             Icon(
  //                               Icons.cancel,
  //                               color: Colors.red,
  //                             ),
  //                             SizedBox(
  //                               width: 7,
  //                             ),
  //                             Icon(
  //                               Icons.edit,
  //                               color: Colors.green,
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                       Container(
  //                         child: Text(
  //                           name,
  //                           style: TextStyle(fontSize: 24),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Padding(
  //                     padding: EdgeInsets.only(top: 3.0),
  //                     child: Container(
  //                         padding:
  //                             EdgeInsets.only(left: 6.0, right: 6.0, bottom: 0),
  //                         color: Color(0xFFEBEBEB),
  //                         height: 1.0)),
  //               ],
  //             ),
  //           )));
  // }

  void _onTransferUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((transfer) => transfer.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldStudentValue)] =
          new HomeModel.fromSnapShot(event.snapshot);
    });
  }

  showAlert(String task) async {
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
        side: BorderSide(
          color: Colors.teal,
        ),
      ),
      titleStyle: TextStyle(color: Colors.black87, fontSize: 20),
    );
    Alert(
        context: context,
        style: alertStyle,
        title: "تمت العملية بنجاح",
        desc: task,
        buttons: [
          DialogButton(
            color: Colors.teal,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(
              "موافق",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
