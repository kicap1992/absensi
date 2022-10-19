import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class OtherServices {
  static final dev = Logger();
  static Future<void> cekAndDelete() async {
    final appStorage = await getTemporaryDirectory();
    // // if (appStorage.existsSync()) {
    final fileList = appStorage.listSync();
    dev.i("${fileList}ini file list");
    if (fileList.isNotEmpty) {
      dev.i("ada file");
      // print(fileList);
      for (var i = 0; i < fileList.length; i++) {
        final file = fileList[i];
        dev.i(file.path);
        if (file.toString().contains(".jpg") ||
            file.toString().contains(".png") ||
            file.toString().contains(".jpeg") ||
            file.toString().contains(".JPG") ||
            file.toString().contains(".PNG") ||
            file.toString().contains(".JPEG")) {
          dev.i("delete");
          await file.delete(recursive: true);
        }
      }
    } else {
      dev.i("tidak ada file");
      // print(fileList);
    }
  }

  static String? dateFormater(String date, String stat) {
    String? thisReturn;

    if (stat == "date") {
      thisReturn = date.split(" ")[0];
    } else if (stat == "time") {
      thisReturn = date.split(" ")[1];
    }
    return thisReturn;
  }

  static String dayNameChanger(String day) {
    const dayMap = {
      "senin": "Monday",
      "selasa": "Tuesday",
      "rabu": "Wednesday",
      "kamis": "Thursday",
      "jumat": "Friday",
      "sabtu": "Saturday",
      "minggu": "Sunday",
    };
    String dayName = dayMap[day]!;

    return dayName;
  }

  static dynamic checkIfInRadius(
      LatLng currentLocation, LatLng centerLocation) {
    double ky = 40000 / 360;
    const double pi = 3.1415926535897932;
    double kx = cos(pi * centerLocation.latitude / 180.0) * ky;
    double first = centerLocation.longitude - currentLocation.longitude;
    double sec = centerLocation.latitude - currentLocation.latitude;
    double dx = first.abs() * kx;
    double dy = sec.abs() * ky;
    return sqrt(dx * dx + dy * dy) <= 0.1;
  }
}
