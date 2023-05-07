import 'package:flutter/material.dart';
import 'package:attendancesystem/pages/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String regularity = "Can't found";
  int numDocuments = -1;
  void _getRecord() async {
    print("get record function called");
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Student")
        .where('user', isEqualTo: widget.user.user)
        .get();

    CollectionReference datesCollection = FirebaseFirestore.instance
        .collection("Student")
        .doc(snap.docs[0].id)
        .collection("Record");
    var alldocs = await datesCollection.get();
    var firstDoc = alldocs.docs.first.id;
    var lastDoc = alldocs.docs.last.id;
    // late DocumentSnapshot firstDoc;
    // late DocumentSnapshot lastDoc;
    // datesCollection
    //     .orderBy(FieldPath.documentId)
    //     .limit(1)
    //     .get()
    //     .then((querySnapshot) {
    //   firstDoc = querySnapshot.docs.first;
    // });
    // datesCollection
    //     .orderBy(FieldPath.documentId, descending: true)
    //     .limit(1)
    //     .get()
    //     .then((querySnapshot) {
    //   lastDoc = querySnapshot.docs.first;
    // });
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final firstDate = dateFormat.parse(firstDoc);
    final lastDate = dateFormat.parse(lastDoc);
    int numDays = lastDate.difference(firstDate).inDays;
    print(firstDate);
    print(lastDate);
    final QuerySnapshot snapshot = await datesCollection.get();
    numDocuments = snapshot.size;
    print("num of days: $numDocuments");
    print("num days: $numDays");
    setState(() {
      regularity = "Can't Find";
    });
    if (numDays / 2 < numDocuments) {
      setState(() {
        regularity = "Regular";
      });
    } else {
      setState(() {
        regularity = "Irregular";
      });
    }
  }

  @override
  void initState() {
    _getRecord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getRecord();
    print("regularity in build function: $regularity");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Center(
          child: Text('Profile Page'),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purple.shade300],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.5, 0.9],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.purple.shade300,
                      minRadius: 35.0,
                      child: const Icon(
                        Icons.call,
                        size: 30.0,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white70,
                      minRadius: 60.0,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.purple.shade300,
                      minRadius: 35.0,
                      child: const Icon(
                        Icons.message,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.user.user,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  regularity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
