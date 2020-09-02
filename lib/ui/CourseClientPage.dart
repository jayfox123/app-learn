import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jurrek/model/module.dart';
import 'package:jurrek/model/subcription_model.dart';
import 'package:jurrek/ui/DetailClientPage.dart';

class CourseClientPage extends StatefulWidget {
  String idSemestre;
  String nameSemestre;
  CourseClientPage(this.idSemestre, this.nameSemestre);
  @override
  _CourseClientPageState createState() =>
      _CourseClientPageState(this.idSemestre, this.nameSemestre);
}

class _CourseClientPageState extends State<CourseClientPage> {
  String idSemestre;
  String nameSemestre;
  _CourseClientPageState(this.idSemestre, this.nameSemestre);
  TextEditingController _nameController;

  var SemRef;

  List<module> items;

  StreamSubscription<Event> _onStudentAddedSubscription;
  StreamSubscription<Event> _onStudentChangedSubscription;
  List<UserX> allUserSub = [];

  @override
  void initState() {
    try {
      _initGetSubcripUsers();
      //   _initcurrentRole();
    } catch (r) {
      print("Shme" + r);
    }
    super.initState();
    _nameController = TextEditingController();
    items = List();
    SemRef =
        FirebaseDatabase.instance.reference().child('Course').child(idSemestre);
    _onStudentAddedSubscription = SemRef.onChildAdded.listen(_onStudentAdded);

    _onStudentChangedSubscription =
        SemRef.onChildChanged.listen(_onTransferUpdated);
  }

  /// =========================================================
  bool isAdmin = false;
  // void _initcurrentRole() {
  //    try{
  //      FirebaseAuth.instance.currentUser().then(
  //     (tokenUser) async {
  //       if (tokenUser != null) {
  //         testgetRoles(tokenUser);
  //       }
  //     },
  //   );
  //    }catch(i){
  //      print( "CCCC $i" );
  //    }
  // }

  // void testgetRoles(uid) {
  //   try{
  //     FirebaseDatabase.instance
  //       .reference()
  //       .child("rolus")
  //       .child("$uid")
  //       .once()
  //       .then(
  //     (DataSnapshot snapshot) {
  //       dynamic data = snapshot.value;
  //       if (data != null) {
  //         // setState(() {
  //         //   if (data["rolus"] == "admin") {
  //         //       isAdmin = true;
  //         //       print( data["rolus"] );

  //         //   } else {
  //         //     print( data["rolus"] );
  //         //     isAdmin = false;
  //         //   }
  //         // });
  //         print( "=====================||||||||||||||||||||||||======================");
  //         print( data );
  //       }
  //     },
  //   );
  //   }catch(y){
  //     print( "Test Get Roles" );
  //   }
  // }

  /// =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'رواد اكاديمي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: _showModalBottomSheet,
          ),
        ],
      ),
      body: StreamBuilder(
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
                            FontAwesomeIcons.bookReader,
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
                      "ليس لديك دروس",
                      style: TextStyle(
                          fontSize: 20, color: Colors.black87.withOpacity(0.5)),
                    ),
                  ],
                ),
              ));
            } else {
              return Container(
                color: Colors.grey[100],
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(60),
                            bottomLeft: Radius.circular(60)),
                        color: Colors.teal,
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(30),
                              topLeft: Radius.circular(30),
                            ),
                          ),
                          child: Text(
                            nameSemestre,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 20, right: 5, left: 5),
                        itemCount: items.toList().length,
                        itemBuilder: (context, position) {
                          return Container(
                            color: Colors.grey[100],
                            child: Card(
                              elevation: 0,
                              color: Colors.grey[100],
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
                      ),
                    ),
                  ],
                ),
              );
            }
          } else
            return LinearProgressIndicator();
        },
      ),
    );
  }

  void _initGetSubcripUsers() {
    getAllUsers().then((user) {
      for (var i in user) {
        getSubscripCourse(idSemestre, i.uid).then((value) {
          if (value == true) {
            getOneUser(i.uid).then((valueUser) {
             setState(() {
                allUserSub.add(valueUser);
             });
            });
          } else {
            print("Not Subscrip User");
          }
        });
      }
    });
  }

  Future<UserX> getOneUser(String uid) async {
    UserX userx;
    await FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(uid)
        .once()
        .then((DataSnapshot snapshot) {
      userx = UserX(
          displayName: snapshot.value["DisplayName"],
          uid: snapshot.value["uid"],
          photoUrl: snapshot.value["photoUrl"]);
    });
    return userx;
  }

  Future<bool> getSubscripCourse(String courseId, String userid) async {
    bool isFound;
    try {
      await FirebaseDatabase.instance
          .reference()
          .child("activation")
          .child(userid)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> osp = snapshot.value;
        for (var i in osp.keys) {
          if (i == courseId) {
            isFound = true;
            break;
          } else {
            isFound = false;
          }
        }
      });
      return isFound;
    } catch (e) {
      print("Enter UserId");
    }
  }

  Future<List<Users>> getAllUsers() async {
    List<Users> allUsers = [];
    await FirebaseDatabase.instance
        .reference()
        .child("users")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> valuesx = snapshot.value;
      valuesx.forEach((key, value) {
        allUsers.add(
          Users(
            uid: key,
          ),
        );
      });
    });
    return allUsers.toList();
  }

  Widget _buildCard(int position, String id, String name, String date,
      String photo, context) {
    position++;
    return Padding(
      padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 2.0, right: 2.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailClientPage(id, nameSemestre, name)),
          );
        },
        child: Container(
          height: double.infinity,
          constraints: BoxConstraints.expand(height: 50),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
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
                  width: 20,
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                      child: Text(
                    "$position",
                    style: TextStyle(fontSize: 18),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTransferUpdated(Event event) {
    var oldStudentValue =
        items.singleWhere((transfer) => transfer.id == event.snapshot.key);

    if (this.mounted) {
      setState(() {
        items[items.indexOf(oldStudentValue)] =
            new module.fromSnapShot(event.snapshot);
      });
    }
  }

  void _onStudentAdded(Event event) {
    setState(() {
      items.add(module.fromSnapShot(event.snapshot));
    });
  }

  _showModalBottomSheet() {
    return showModalBottomSheet(
      elevation: 1,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return containerCustom();
      },
    );
  }

  Future<UserX> _getSubcripUsers() {
    getAllUsers().then((user) async {
      for (var i in user) {
        await getSubscripCourse(idSemestre, i.uid).then((value) async {
          if (value == true) {
            await getOneUser(i.uid).then((valueUser) {
              // allUserSub.add(valueUser);
              return valueUser;
            });
          } else {
            print("Not Subscrip User");
          }
        });
      }
    });
  }

  Widget containerCustom() {
    return Container(
      height: 320,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.teal),
              child: Center(
                child: Text(
                  "المشتركين معك في الفئة",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            /// [List] Custom
            
                allUserSub.length <= 1 ? Container(
                  child: Center(
                    child: Text("جاري التحميل"),
                  )
                ) : Container(
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: allUserSub.length,
                      shrinkWrap: true,
                      itemBuilder: (context, int index) {
                        return _customSubcript(allUserSub[index]);
                      },
                    ),
                  )
                // : FutureBuilder<UserX>(
                //     future: _getSubcripUsers(),
                //     builder: (context, snapshot) {
                //       if (snapshot.hasError) {
                //         print(snapshot.error);
                //       }
                //       switch (snapshot.connectionState) {
                //         case ConnectionState.waiting:
                //           return Center(child: Text("جاري التحميل"));
                //         case ConnectionState.done:
                //         return Text(snapshot.data.displayName);
                //           // return Container(
                //           //     child: ListView.builder(
                //           //   physics: ClampingScrollPhysics(),
                //           //   itemCount: allUserSub.length,
                //           //   shrinkWrap: true,
                //           //   itemBuilder: (context, int index) {
                //           //     return _customSubcript(allUserSub[index]);
                //           //   },
                //           // )
                //         // );
                //       }
                //     },
                //   )
          ],
        ),
      ),
    );
  }

  Widget _customSubcript(UserX userInfo) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 8)
        ]),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.teal.withOpacity(0.2), blurRadius: 4),
                      ],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                            userInfo.photoUrl == null ? "" : userInfo.photoUrl),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    child: userInfo.photoUrl == null
                        ? Center(
                            child: Text(
                            "not Image",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ))
                        : Text(""),
                  ),
                  SizedBox(width: 15),
                  Text(
                    userInfo.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 15)
          ],
        ),
      ),
    );
  }
}
