import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jurrek/model/module.dart';

class StudentInformation extends StatefulWidget {
  final module student;
  StudentInformation(this.student);
  @override
  State<StatefulWidget> createState() => new _StudentInformationState();
}

final studentReference = FirebaseDatabase.instance.reference().child('student');

class _StudentInformationState extends State<StudentInformation> {
  String username;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    username = widget.student.name;
    print(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Information'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text(
              widget.student.name,
              style: TextStyle(fontSize: 16.0, color: Colors.deepPurpleAccent),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
            ),
            Text(
              widget.student.date,
              style: TextStyle(fontSize: 16.0, color: Colors.deepPurpleAccent),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
            ),
          ],
        ),
      ),
    );
  }
}
