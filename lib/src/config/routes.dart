import 'package:flutter/material.dart';

import '../page/karyawan/karyawan_index.dart';
import '../page/login_page.dart';
import '../page/splash_screen_page.dart';

class RoutesApp {
  static getRoutes() {
    return {
      'splash': (BuildContext context) => const SplashScreenPage(),
      'login': (BuildContext context) => const LoginPage(),
      'karyawan_index': (BuildContext context) => const KaryawanIndexPage(),
    };
  }
}
