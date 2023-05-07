// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import '../../../loginscreen.dart';
// import './homescreen.dart';
// import './model/user.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:month_year_picker/month_year_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const KeyboardVisibilityProvider(
//         child: AuthCheck(),
//       ),
//       localizationsDelegates: const [
//         MonthYearPickerLocalizations.delegate,
//       ],
//     );
//   }
// }

// class AuthCheck extends StatefulWidget {
//   const AuthCheck({Key? key}) : super(key: key);

//   @override
//   _AuthCheckState createState() => _AuthCheckState();
// }

// class _AuthCheckState extends State<AuthCheck> {
//   bool userAvailable = false;
//   late SharedPreferences sharedPreferences;

//   @override
//   void initState() {
//     super.initState();

//     _getCurrentUser();
//   }

//   void _getCurrentUser() async {
//     sharedPreferences = await SharedPreferences.getInstance();

//     try {
//       if (sharedPreferences.getString('studentId') != null) {
//         setState(() {
//           User.studentId = sharedPreferences.getString('studentId')!;
//           userAvailable = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         userAvailable = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return userAvailable
//         ? HomeScreen(
//             user: null,
//           )
//         : const LoginScreen();
//   }
// }
