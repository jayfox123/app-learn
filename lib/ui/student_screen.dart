import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jurrek/model/module.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:date_format/date_format.dart';

class StudentScreen extends StatefulWidget {
  final module student;
  StudentScreen(this.student);
  @override
  State<StatefulWidget> createState() => new _StudentScreenState();
}

final studentReference = FirebaseDatabase.instance.reference().child('student');

class _StudentScreenState extends State<StudentScreen> {
  File image;
  var key;
  TextEditingController _nameController;

  TextEditingController _prixController;
  TextEditingController _descriptionController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = new TextEditingController(text: widget.student.name);

    _prixController = new TextEditingController(text: widget.student.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Student DB'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
//        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TextField(
              style: TextStyle(fontSize: 16.0, color: Colors.deepPurpleAccent),
              controller: _nameController,
              decoration:
                  InputDecoration(icon: Icon(Icons.person), labelText: 'Name'),
            ),
//            Padding(padding: EdgeInsets.only(top: 8.0),),
            TextField(
              style: TextStyle(fontSize: 16.0, color: Colors.deepPurpleAccent),
              controller: _prixController,
              decoration: InputDecoration(
                  icon: Icon(Icons.monetization_on), labelText: 'prix'),
            ),
            TextField(
              style: TextStyle(fontSize: 16.0, color: Colors.deepPurpleAccent),
              controller: _descriptionController,
              decoration: InputDecoration(
                  icon: Icon(Icons.description), labelText: 'Description'),
            ),

//            Padding(padding: EdgeInsets.only(top: 8.0),),
            Container(
              height: 250,
              width: 250,
              child: Center(
                child: image == null ? Text('No Image') : Image.file(image),
              ),
            ),

            FlatButton(
              child: (widget.student.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.student.id != null) {
                  studentReference.child(widget.student.id).set({
                    'name': _nameController.text,
                    'department': _prixController.text,
                    'description': _descriptionController.text
                  }).then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  var now =
                      formatDate(new DateTime.now(), [yyyy, '-', mm, '-', dd]);
                  var fullImageName =
                      'images/${_nameController.text}-$now' + '.jpg';
                  var fullImageName2 =
                      'images%2F${_nameController.text}-$now' + '.jpg';

                  final StorageReference ref =
                      FirebaseStorage.instance.ref().child(fullImageName);
                  final StorageUploadTask task = ref.putFile(image);
                  var part1 =
                      'https://firebasestorage.googleapis.com/v0/b/finaltest-b5f7e.appspot.com/o/';

                  var fullPathImage = part1 + fullImageName2;
                  key = studentReference.push().set({
                    'name': _nameController.text,
                    'prix': _prixController.text,
                    'description': _descriptionController.text,
                    'productImage': '$fullPathImage'
                  }).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
