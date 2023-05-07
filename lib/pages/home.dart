import 'package:attendancesystem/constants/constants.dart';
import 'package:attendancesystem/locator.dart';
import 'package:attendancesystem/pages/db/database_helper.dart';
import 'package:attendancesystem/pages/sign-in.dart';
import 'package:attendancesystem/pages/sign-up.dart';
import 'package:attendancesystem/services/camera.service.dart';
import 'package:attendancesystem/services/ml_service.dart';
import 'package:attendancesystem/services/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MLService _mlService = locator<MLService>();
  final FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  _initializeServices() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    setState(() => loading = false);
  }

  void _launchURL() async => await canLaunchUrl(Constants.githubURL as Uri)
      ? await launchUrl(Constants.githubURL as Uri)
      : throw 'Could not launch ${Constants.githubURL}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: PopupMenuButton<String>(
              child: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'Clear DB':
                    DatabaseHelper dataBaseHelper = DatabaseHelper.instance;
                    dataBaseHelper.deleteAll();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Clear DB'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: !loading
          ? SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Image(image: AssetImage('assets/logo.png')),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: const [
                            Text(
                              "ATTENDANCE MANAGEMENT SYSTEM",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "SIGN UP TO REGISTER YOUR FACE AND LOG IN TO OPEN THE ATTENDANCE MANAGEMENT",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignIn(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(color: Color(0xFF0F0BDB)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.login, color: Color(0xFF0F0BDB))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignUp(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF0F0BDB),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'SIGN UP',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.person_add, color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: const Divider(
                              thickness: 2,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
