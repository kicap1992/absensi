import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../config/theme.dart';
import '../services/storage_service.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final dev = Logger();
  // String? _deviceId;
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    initPlatformState();
    // future 3 sec
    Future.delayed(const Duration(seconds: 4), () async {
      // await _storage.remove('userData');
      var checkUser = await _storage.read('userData');
      // dev.i(checkUser);
      if (checkUser == null) {
        goToLogin();
      } else {
        goToHomepage();
      }
      // Navigator.pushReplacementNamed(context, 'login');
    });
  }

  void getCurrentLocation() {
    // BackgroundLocation.getLocationUpdates((location) {
    //   dev.i('location: ${location.latitude}, ${location.longitude}');
    // });
  }

  void goToLogin() {
    Navigator.pushReplacementNamed(context, 'login');
  }

  void goToHomepage() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      'karyawan_index',
      arguments: false,
      (route) => false,
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }

    _storage.write('device_id', deviceId);

    // // If the widget was removed from the tree while the asynchronous platform
    // // message was in flight, we want to discard the reply rather than calling
    // // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _deviceId = deviceId;
    //   dev.i("deviceId->$_deviceId");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeInfo.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/logo_mamuju_tengah.png',
                width: 200,
                height: 200,
              ),
            ),
            const Positioned(
              bottom: 150,
              left: 15,
              right: 15,
              child: Center(
                child: Text(
                  'APLIKASI ABSENSI KARYAWAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Positioned(
              bottom: 10,
              left: 15,
              right: 15,
              child: Center(
                child: Text(
                  'Dinas Pariwisata Dan Kebudayaan\nKabupaten Mamuju Tengah\n\nAirlangga IT',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
