import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/model/HomeModel.dart';
import 'package:jurrek/model/Student.dart';

import 'package:rflutter_alert/rflutter_alert.dart';

import 'edit_profile_user.dart';

class OrderPageAdmin extends StatefulWidget {
  @override
  _OrderPageAdminState createState() => _OrderPageAdminState();
}

class _OrderPageAdminState extends State<OrderPageAdmin> {
  _OrderPageAdminState();
  List<Student> items;
  List<Student> initial;
  List<Student> itemPending;
  List<Student> itemBlocked;

  var SemRef;
  var SemRefused;
  var SemPending;

  var mymap = {};
  var title = '';
  var body = "";
  var mytoken = '';
  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  SystemUiOverlayStyle _currentStyle = SystemUiOverlayStyle.light;
  void _changeColor() {
    setState(() {
      _currentStyle = SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
      );
    });
  }

  List<HomeModel> itemsCourse;

  int Number = 0;

  TextEditingController _nameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController();

    itemsCourse = List();
    items = List();
    initial = List();
    itemPending = List();
    itemBlocked = List();
    SemRef = FirebaseDatabase.instance.reference().child('users');
    SemRefused = FirebaseDatabase.instance
        .reference()
        .child('users')
        .orderByChild("status")
        .equalTo("2");

    SemPending = FirebaseDatabase.instance
        .reference()
        .child('users')
        .orderByChild("status")
        .equalTo("1");
    _onStudentAddedSubscription =
        SemRefused.onChildAdded.listen(_onStudentAddedBlocked);

    _onStudentAddedSubscription =
        SemPending.onChildAdded.listen(_onStudentPending);

    _onStudentAddedSubscription =
        SemRef.onChildAdded.listen(_onStudentAddedActive);
    // _onStudentChangedSubscription =
    //     SemRef.onChildChanged.listen(_onTransferUpdated);

    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var platform = InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called ${(msg)}");
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called ${(msg)}");
    }, onMessage: (Map<String, dynamic> msg) {
      print("onResume called ${(msg)}");
      mymap = msg;
      showNotification(msg);
    });

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("onIosSettingsRegistered");
    });
    firebaseMessaging.getToken().then((token) {
      mytoken = token;
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android =
        AndroidNotificationDetails("1", "channelName", "channelDescription");
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    int i = 0;
    msg.forEach((k, v) {
      v.forEach((f, t) {
        if (i == 0) {
          title = t;
        }
        i++;
        body = t;
      });
    });

    await flutterLocalNotificationsPlugin.show(0, "$title", "$body", platform);
  }

  String data = "";

  _onChanged(String value) {
    items = initial;
    setState(() {
      items = items
          .where((x) => x.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110.0),
          child: AppBar(
            automaticallyImplyLeading: false, // hides leading widget

            flexibleSpace: SizedBox(
              height: 80,
              width: 80,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              unselectedLabelColor: Colors.black87,
              indicator: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber, Colors.red]),
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey.withOpacity(0.2)),
              indicatorColor: Colors.black87,
              labelColor: Colors.black87,
              tabs: [
                Tab(text: "الناشطين"),
                // Tab(text: "قيد الانتظار"),
                Tab(text: "المحظورين"),
              ],
            ),
            title: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),

                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          "المستخدمين",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          // color: Colors.amberAccent,
                          height: 40.0,
                          width: 40.0,
                          child: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.arrowRight,
                                color: Colors.black54,
                                size: 20,
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .reference()
                        .child('users')
                        .orderByChild("status")
                        .equalTo("0")
                        .onValue,
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
                                        FontAwesomeIcons.user,
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
                                  "غير موجود",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ));
                        } else {
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Container(
                                  height: 60,
                                  child: TextField(
                                    onChanged: _onChanged,
                                    controller: _nameController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      hintText: ' Search  ',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.blue[50],
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(35.0)),
                                        borderSide: BorderSide(
                                            color: Colors.blue[50], width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(35.0)),
                                        borderSide:
                                            BorderSide(color: Colors.blue[50]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                        left: 4, right: 4, top: 4),
                                    itemCount: items.toList().length,
                                    itemBuilder: (context, position) {
                                      return Container(
                                        child: Card(
                                            elevation: 2,
                                            semanticContainer: true,
                                            color: Colors.white,
                                            child: buildcard(
                                                position,
                                                '${items[position].id}',
                                                '${items[position].name}',
                                                '${items[position].tel}',
                                                '${items[position].address}',
                                                '${items[position].status}',
                                                '${items[position].photo}',
                                                context)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      } else
                        return LinearProgressIndicator();
                    },
                  ),
                ),
              ],
            ),
            StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child('users')
                  .orderByChild("status")
                  .equalTo("2")
                  .onValue,
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
                                  FontAwesomeIcons.user,
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
                            "غير موجود",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ));
                  } else {
                    return Container(
                      color: Colors.white,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: 4, right: 4, top: 4),
                        itemCount: itemBlocked.toList().length,
                        itemBuilder: (context, position) {
                          return Container(
                            child: Card(
                                elevation: 2,
                                semanticContainer: true,
                                color: Colors.white,
                                child: builBlock(
                                    position,
                                    '${itemBlocked[position].id}',
                                    '${itemBlocked[position].name}',
                                    '${itemBlocked[position].tel}',
                                    '${itemBlocked[position].address}',
                                    '${itemBlocked[position].status}',
                                    '${itemBlocked[position].photo}',
                                    context)),
                          );
                        },
                      ),
                    );
                  }
                } else
                  return LinearProgressIndicator();
              },
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  List Course_Uid = List();
  Future getInformation(String uid) async {
    Course_Uid.clear();
    FirebaseDatabase.instance
        .reference()
        .child("activation")
        .child(uid)
        .once()
        .then((DataSnapshot snapshotact) {
      Map<dynamic, dynamic> valuesact = snapshotact.value;
      if (valuesact != null) {
        valuesact.forEach((keyact, valuesact) {
          setState(() {
            Course_Uid.add(keyact);
          });
        });
      }
    });
    await FirebaseDatabase.instance
        .reference()
        .child("colege")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null) {
        values.forEach((key, values) {
          if (this.mounted) {
            setState(() {
              bool subscribe = true;
              print(key);

              HomeModel p =
                  HomeModel(key, values["name"], values["photo"], subscribe);

              itemsCourse.add(p);
            });
          }
        });
      }
    });
  }

  _showModalBottomSheet(context) {
    showModalBottomSheet(
      elevation: 1,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: <Widget>[
                // for (var i = 0; i < itemsCourse.length; i++) ...[
                //   Text(itemsCourse[i].name)
                // ]
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.teal,
                  child: Center(
                      child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "اشتراكات : ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          Text(
                            "$displayName",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  )),
                ),
                SizedBox(
                  height: 25,
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: itemsCourse.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.grey[100],
                                blurRadius: 40.0,
                                offset: Offset(4, 4))
                          ]),
                          // elevation: 0,
                          child: _buildCourse(
                              position,
                              itemsCourse[position].id,
                              itemsCourse[position].name,
                              itemsCourse[position].photo,
                              itemsCourse[position].subscribe,
                              context),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ));
      },
    );
  }

  String displayName = "";

  Widget _buildCourse(int position, String id, String name, String photo,
      bool subscribe, context) {
    bool isEntered = true;
    Course_Uid.forEach((f) {
      if (id == f) {
        isEntered = false;
      }
    });
    return Padding(
      padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 4.0, right: 4.0),
      child: Column(
        children: <Widget>[
          Container(
            height: 140,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                      blurRadius: 8,
                      color: Colors.grey[300],
                      spreadRadius: 1,
                      offset: Offset(8, 8))
                ],
                image: DecorationImage(
                    image: NetworkImage(photo), fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5),
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                topRight: Radius.circular(5))),
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
          isEntered
              ? Padding(
                  padding: EdgeInsets.all(10),
                  child: MaterialButton(
                    onPressed: () async {
                      var now = formatDate(new DateTime.now(),
                          [yyyy, '-', mm, '-', dd, ', ', hh, ':', mm]);
                      await FirebaseDatabase.instance
                          .reference()
                          .child('activation')
                          .child(uid)
                          .child(id)
                          .set({
                        'id_course': id,
                      }).then((_) {
                        setState(() {
                          Course_Uid.add(id);
                        });
                      });
                    },
                    child: Text(
                      'تفعيل ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.teal,
                    elevation: 0,
                    minWidth: 100,
                    height: 30,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(10),
                  child: MaterialButton(
                    onPressed: () async {
                      var now = formatDate(new DateTime.now(),
                          [yyyy, '-', mm, '-', dd, ', ', hh, ':', mm]);
                      FirebaseDatabase.instance
                          .reference()
                          .child('activation')
                          .child(uid)
                          .child(id)
                          .remove();

                      setState(() {
                        Course_Uid.remove(id);
                      });
                    },
                    child: Text(
                      'الغاء ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.redAccent,
                    elevation: 0,
                    minWidth: 100,
                    height: 30,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String uid;
  Widget buildcard(int position, String id, String username, String tel,
      String address, String status, String photo, context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1, 4),
                            blurRadius: 5)
                      ],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(photo), fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            username,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            tel,
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            address,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /// [Review] Button
              buttonBlue(
                  txt: "حذف",
                  onTap: () {
                    FirebaseDatabase.instance
                        .reference()
                        .child("users")
                        .child(id)
                        .remove()
                        .then(
                      (value) {
                        print("Done User Deleted");
                      },
                    );
                  },
                  isRad: true),

              SizedBox(
                height: 10,
              ),
              buttonBlue(
                txt: "تعديل",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileUser(uid: id)));
                },
              ),
            ],
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /// [Review] Button
              buttonBlue(
                txt: "معاينة",
                onTap: () {
                  setState(() {
                    uid = id;
                    displayName = username;
                  });
                  itemsCourse.clear();

                  getInformation(uid);
                  _showModalBottomSheet(context);
                },
                isRad: true,
              ),

              SizedBox(
                height: 10,
              ),
              buttonBlue(
                  txt: "حظر",
                  onTap: () {
                    FirebaseDatabase.instance
                        .reference()
                        .child("users")
                        .child(id)
                        .update({
                      'status': "2",
                    });
                    items.removeAt(position);
                  },
                  isRad: false),
            ],
          ),
        ],
      ),
    );
  }

  // EditProfileUser
  Widget buttonBlue({String txt, Function onTap, bool isRad = false}) {
    return Container(
      width: 80,
      height: 25.0,
      child: RaisedButton(
        onPressed: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isRad == false
                ? LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 80.0, minHeight: 25.0),
            alignment: Alignment.center,
            child: Text(
              txt,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPending(int position, String id, String username, String tel,
      String address, String status, String photo, context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1, 4),
                          blurRadius: 5)
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(photo), fit: BoxFit.fill)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          username,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tel,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          address,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 80,
                height: 25.0,
                child: RaisedButton(
                  onPressed: () {
                    FirebaseDatabase.instance
                        .reference()
                        .child("users")
                        .child(id)
                        .update({
                      'status': "0",
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.green[300]],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 80.0, minHeight: 25.0),
                      alignment: Alignment.center,
                      child: Text(
                        "تفعيل",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 80,
                height: 25.0,
                child: RaisedButton(
                  onPressed: () {
                    FirebaseDatabase.instance
                        .reference()
                        .child("users")
                        .child(id)
                        .update({
                      'accept': "true",
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 80.0, minHeight: 25.0),
                      alignment: Alignment.center,
                      child: Text(
                        "حظر",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget builBlock(int position, String id, String username, String tel,
      String address, String status, String photo, context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1, 4),
                          blurRadius: 5)
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(photo), fit: BoxFit.fill)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          username,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tel,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          address,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 80,
                height: 25.0,
                child: RaisedButton(
                  onPressed: () {
                    FirebaseDatabase.instance
                        .reference()
                        .child("users")
                        .child(id)
                        .update({
                      'status': "0",
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 80.0, minHeight: 25.0),
                      alignment: Alignment.center,
                      child: Text(
                        "الغاء",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  ConfrimAlert(context, String desc) {
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
      titleStyle: TextStyle(color: Colors.black87, fontSize: 18),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: "$desc",
      content: Column(
        children: <Widget>[],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "موافق",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Colors.blue,
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  void _onTransferUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((transfer) => transfer.id == event.snapshot.key);

    if (this.mounted) {
      setState(() {
        var items;
        items[items.indexOf(oldStudentValue)] =
            new Student.fromSnapShot(event.snapshot);
      });
    }
  }

  int i = 0;

  void _onStudentAddedBlocked(Event event) {
    print(event.snapshot.value["status"]);

    if (event.snapshot.value["status"].toString() == "2") {
      setState(() {
        itemBlocked.add(new Student.fromSnapShot(event.snapshot));
      });
    }
  }

  void _onStudentAddedActive(Event event) {
    if (event.snapshot.value["status"] == "0") {
      setState(() {
        items.add(Student.fromSnapShot(event.snapshot));
        initial.add(Student.fromSnapShot(event.snapshot));
      });
    }
  }

  void _onStudentPending(Event event) {
    // if (event.snapshot.value["status"] == "1") {
    setState(() {
      itemPending.add(new Student.fromSnapShot(event.snapshot));
    });
    // }
  }
}
