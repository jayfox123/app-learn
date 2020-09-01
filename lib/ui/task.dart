import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:jurrek/model/module.dart';

class Task extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TaskState();
}

final pendingtaskReference =
    FirebaseDatabase.instance.reference().child('module');

final ArchivetaskReference =
    FirebaseDatabase.instance.reference().child('module');
final pendingtaskDetailsReference = FirebaseDatabase.instance.reference();

class _TaskState extends State<Task> {
  var photoUrl = "https://huntpng.com/images250/business-person-icon-png-2.png";
  final studentReference =
      FirebaseDatabase.instance.reference().child('module');

  List<module> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;

  StreamSubscription<Event> _onArchiveAddedSubscription;
  StreamSubscription<Event> _onArchiveChangedSubscription;

  @override
  void initState() {
    super.initState();
    items = new List();

    _onStudentAddedSubscription =
        studentReference.onChildAdded.listen(_onStudentAdded);
    _onStudentChangedSubscription =
        studentReference.onChildChanged.listen(_onStudentUpdated);

    items = items.reversed.toList();
    print(items.length);

    _nameController = new TextEditingController();
  }

  bool _saving = true;

  File image;
  var key;
  TextEditingController _nameController;

  bool imageSelect = false;

  @override
  void dispose() {
    super.dispose();
    _onStudentAddedSubscription.cancel();
    _onStudentChangedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return 
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              unselectedLabelColor: Colors.amber,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blue[200]),
              tabs: [
                Tab(text: "المواد"),
                Tab(text: " اضافة مادة"),
              ],
            ),
            title: Text(
              'المواد',
              style: TextStyle(
                color: Colors.blue[400],
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
              Container(
                  padding: EdgeInsets.all(7.0),
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
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
                  )),
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
                                            hintText: "اسم المادة ",
                                            prefixIcon: Icon(Icons.book),
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
                                    pendingtaskReference.push().set({
                                      'name': _nameController.text,
                                      'photo': downloadUrl.toString(),
                                      'date': now
                                    }).then((_) {
                                      showAlert(_nameController.text);
                                    });

                                    // Navigator.pop(context);
                                  },
                                  //since this is only a UI app
                                  child: Text(
                                    'اضافة ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  color: Colors.amberAccent,
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

  void _deleteStudent(
      BuildContext context, module student, int position) async {
    await studentReference.child(student.id).remove().then((_) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToStudent(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Task()),
    );
  }

  void _createNewStudent(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Task()),
    );
  }

  Widget _buildCard(int position, String id, String name, String date,
      String photo, context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => Semestre()),
              // );
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3.0,
                        blurRadius: 5.0)
                  ],
                  color: Colors.white),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text(
                            name,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 3.0),
                      child: Container(
                          padding:
                              EdgeInsets.only(left: 6.0, right: 6.0, bottom: 0),
                          color: Color(0xFFEBEBEB),
                          height: 1.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        Icon(
                          Icons.edit,
                          color: Colors.green,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  showAlert(String task) async {
    Alert(
        context: context,
        title: "تم اضافة الاسدوس",
        desc: task,
        image: Image.asset("assets/jurrek.png"),
        buttons: [
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
