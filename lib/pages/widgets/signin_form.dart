import 'package:attendancesystem/locator.dart';
import 'package:attendancesystem/pages/models/user.model.dart';
// import 'package:attendancesystem/pages/profile.dart';
import 'package:attendancesystem/pages/widgets/app_button.dart';
import 'package:attendancesystem/pages/widgets/app_text_field.dart';
import 'package:attendancesystem/services/camera.service.dart';
// import '../attendance/todayscreen.dart';
// import '../attendance/loginscreen.dart';
import '../attendance/homescreen.dart';

import 'package:flutter/material.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet({Key? key, required this.user}) : super(key: key);
  final User user;

  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(
                    user: user,
                    // imagePath: _cameraService.imagePath!,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Welcome back, ${user.user}.',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Please enter your password',
            style: TextStyle(fontSize: 20),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              AppTextField(
                controller: _passwordController,
                labelText: "Password",
                isPassword: true,
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              AppButton(
                text: 'LOGIN',
                onPressed: () async {
                  _signIn(context, user);
                },
                icon: const Icon(
                  Icons.login,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
