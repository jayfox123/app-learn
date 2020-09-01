import 'package:firebase_database/firebase_database.dart';

class module {
  String _id;
  String _name;
  String _date;

  String _url;

  module(this._id, this._name, this._date, this._url);

  module.map(dynamic obj) {
    this._name = obj['name'];
    this._date = obj['date'];
    this._url = obj['url'];
  }

  String get id => _id;
  String get name => _name;
  String get date => _date;

  String get photo => _url;

  module.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
    _date = snapshot.value['date'];

    _url = snapshot.value['url'];
  }
}
