import 'package:firebase_database/firebase_database.dart';

class Student {
  String _id;
  String _name;
  String _address;
  String _tel;
  String _photo;
  String _androidId;
  String _status;

  Student(this._id, this._name, this._tel, this._address, this._photo,
      this._androidId, this._status);

  Student.map(dynamic obj) {
    this._name = obj['DisplayName'];
    this._address = obj['address'];
    this._tel = obj['PhoneNumber'];
    this._photo = obj['photoUrl'];
    this._androidId = obj['androidId'];
    this._status = obj['status'];
  }

  String get id => _id;
  String get name => _name;
  String get address => _address;
  String get tel => _tel;
  String get photo => _photo;
  String get status => _status;
  String get androidId => _androidId;

  Student.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['DisplayName'];
    _address = snapshot.value['address'];
    _tel = snapshot.value['PhoneNumber'];
    _photo = snapshot.value['photoUrl'];
    _status = snapshot.value['status'];
    _androidId = snapshot.value['androidId'];
  }
}
