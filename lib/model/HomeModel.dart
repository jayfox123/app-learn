import 'package:firebase_database/firebase_database.dart';

class HomeModel {
  String _id;
  String _name;

  String _url;
  bool _subscribe;

  HomeModel(this._id, this._name, this._url, this._subscribe);

  HomeModel.map(dynamic obj) {
    this._name = obj['name'];
    this._url = obj['photo'];
    this._subscribe = obj['subscribe'];
  }

  String get id => _id;
  String get name => _name;

  String get photo => _url;
  bool get subscribe => _subscribe;

  HomeModel.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];

    _url = snapshot.value['photo'];
    _subscribe = snapshot.value['subscribe'];
  }
}
