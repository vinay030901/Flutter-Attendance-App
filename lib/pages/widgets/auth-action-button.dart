import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendancesystem/locator.dart';
import 'package:attendancesystem/pages/db/database_helper.dart';
import 'package:attendancesystem/pages/models/user.model.dart';
import 'package:attendancesystem/pages/profile.dart';
import 'package:attendancesystem/pages/widgets/app_button.dart';
import 'package:attendancesystem/services/camera.service.dart';
import 'package:attendancesystem/services/ml_service.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  const AuthActionButton(
      {Key? key,
      required this.onPressed,
      required this.isLogin,
      required this.reload})
      : super(key: key);
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User? predictedUser;

  Future _signUp(context) async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
      lat: 0.0,
      long: 0.0,
    );
    // await FirebaseFirestore.instance
    //     .collection("Student")
    //     .doc(snap.docs[0].id)
    //     .collection("Record")
    //     .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
    //     .update({
    //   'date': Timestamp.now(),
    //   'checkIn': checkIn,
    //   'checkOut': DateFormat('hh:mm').format(DateTime.now()),
    //   'checkInLocation': location,
    // });
    print("name: $user password: $password");
    final data = {
      "name": user,
      "password": password,
      "model_data": predictedData
    };
    await databaseHelper.insert(userToSave);
    _mlService.setPredictedData([]);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const MyHomePage()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (predictedUser!.password == password) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    predictedUser!.user,
                    imagePath: _cameraService.imagePath!,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.isLogin && predictedUser != null)
            Text(
              'Welcome back, ${predictedUser!.user}.',
              style: const TextStyle(fontSize: 20),
            )
          else
            widget.isLogin
                ? const Text(
                    'User not found 😞',
                    style: TextStyle(fontSize: 20),
                  )
                : Container(),
          Column(
            children: [
              !widget.isLogin
                  ? AppTextField(
                      controller: _userTextEditingController,
                      labelText: "Your Name",
                    )
                  : Container(),
              const SizedBox(height: 10),
              widget.isLogin && predictedUser == null
                  ? Container()
                  : AppTextField(
                      controller: _passwordTextEditingController,
                      labelText: "Password",
                      isPassword: true,
                    ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              widget.isLogin && predictedUser != null
                  ? AppButton(
                      text: 'LOGIN',
                      onPressed: () async {
                        _signIn(context);
                      },
                      icon: const Icon(
                        Icons.login,
                        color: Colors.white,
                      ),
                    )
                  : !widget.isLogin
                      ? AppButton(
                          text: 'SIGN UP',
                          onPressed: () async {
                            await _signUp(context);
                          },
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                        )
                      : Container(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
