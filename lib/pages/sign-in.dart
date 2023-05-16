import 'dart:async';
import 'package:attendancesystem/pages/attendance/services/location_service.dart';
import 'package:attendancesystem/locator.dart';
import 'package:attendancesystem/pages/models/user.model.dart';
import 'package:attendancesystem/pages/widgets/auth_button.dart';
import 'package:attendancesystem/pages/widgets/camera_detection_preview.dart';
import 'package:attendancesystem/pages/widgets/camera_header.dart';
import 'package:attendancesystem/pages/widgets/signin_form.dart';
import 'package:attendancesystem/pages/widgets/single_picture.dart';
import 'package:attendancesystem/services/camera.service.dart';
import 'package:attendancesystem/services/ml_service.dart';
import 'package:attendancesystem/services/face_detector_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final CameraService _cameraService = locator<CameraService>();
  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();
  final MLService _mlService = locator<MLService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;
  bool inCollege(User user) {
    double x1 = 30.26621033215036,
        y1 = 77.9901135901542,
        x2 = 30.27215150668715,
        y2 = 77.9967531714394;
    print("My location " + user.lat.toString() + " " + user.long.toString());
    if (x1 < user.lat && user.lat < x2 && y1 < user.long && user.long < y2)
      return true;
    return false;
  }

  void _startLocationService(User user) async {
    LocationService().initialize();

    LocationService().getLongitude().then((value) {
      setState(() {
        user.long = value!;
      });

      LocationService().getLatitude().then((value) {
        setState(() {
          user.lat = value!;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  Future _start() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    setState(() => _isInitializing = false);
    _frameFaces();
  }

  _frameFaces() async {
    bool processing = false;
    _cameraService.cameraController!
        .startImageStream((CameraImage image) async {
      if (processing) return; // prevents unnecessary overprocessing.
      processing = true;
      await _predictFacesFromImage(image: image);
      processing = false;
    });
  }

  Future<void> _predictFacesFromImage({@required CameraImage? image}) async {
    assert(image != null, 'Image is null');
    await _faceDetectorService.detectFacesFromImage(image!);
    if (_faceDetectorService.faceDetected) {
      _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
    }
    if (mounted) setState(() {});
  }

  Future<void> takePicture() async {
    if (_faceDetectorService.faceDetected) {
      await _cameraService.takePicture();
      setState(() => _isPictureTaken = true);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              const AlertDialog(content: Text('No face detected!')));
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    if (mounted) setState(() => _isPictureTaken = false);
    _start();
  }

  Future<void> onTap() async {
    await takePicture();
    if (_faceDetectorService.faceDetected) {
      User? user = await _mlService.predict();
      var bottomSheetController = scaffoldKey.currentState!
          .showBottomSheet((context) => signInSheet(user: user));
      bottomSheetController.closed.whenComplete(_reload);
    }
  }

  Widget getBodyWidget() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_isPictureTaken) {
      return SinglePicture(imagePath: _cameraService.imagePath!);
    }
    return CameraDetectionPreview();
  }

  @override
  Widget build(BuildContext context) {
    Widget header = CameraHeader("LOGIN", onBackPressed: _onBackPressed);
    Widget body = getBodyWidget();
    Widget? fab;
    if (!_isPictureTaken) fab = AuthButton(onTap: onTap);

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [body, header],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: fab,
    );
  }

  signInSheet({@required User? user}) {
    if (user == null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        child: const Text(
          'User not found 😞',
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      _startLocationService(user);
      if (inCollege(user) == true) {
        return SignInSheet(user: user);
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: const Text(
            'Your are not present in College 😞',
            style: TextStyle(fontSize: 20),
          ),
        );
      }
    }
  }
}
