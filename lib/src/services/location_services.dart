import 'dart:async';

import 'package:absensi_karyawan/src/services/api_service.dart';
import 'package:absensi_karyawan/src/services/storage_service.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';

Location location = Location();
final dev = Logger();
final storage = StorageService();
// Stream<void> getLoc() async* {
Future<void> getLoc() async {
  // bool checkIfRunGps = await storage.read('runGPS');
  // dev.i("heheh");
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  // ignore: unused_local_variable
  LocationData locationData;
  // await location.isBackgroundModeEnabled();
  // await location.enableBackgroundMode();
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  location.changeSettings(
      accuracy: LocationAccuracy.high, interval: 10000, distanceFilter: 3);

  // locationData = await location.getLocation();

  while (true) {
    bool checkIfRunGps = await storage.read('runGPS');
    // dev.i("ini check if gps $checkIfRunGps");

    if (checkIfRunGps) {
      locationData = await location.getLocation();
      // dev.i("ini location sekarang ${locationData.}");
      await ApiServices.sendMyLocation(
          locationData.latitude.toString(), locationData.longitude.toString());
    }

    await Future.delayed(const Duration(seconds: 10));
  }

  // if (checkIfRunGps) {
  //   dev.i("ini location sekarang $locationData");
  // }

  // location.onLocationChanged.listen((LocationData currentLocation) async {
  //   bool checkIfRunGps1 = await storage.read('runGPS');
  //   if (checkIfRunGps1) {
  //     dev.i("ini location sekarang $locationData");
  //   }
  // });
  // return;
  // dev.i("ini location sekarang $locationData");
}

// import 'package:geolocator/geolocator.dart';
// import 'package:logger/logger.dart';

// final dev = Logger();

// Future<Position> determinePosition() async {
//   //
//   late LocationSettings locationSettings;
//   locationSettings = const LocationSettings(
//     accuracy: LocationAccuracy.low,
//     distanceFilter: 5,
//     // timeLimit: Duration(seconds: 10),
//   );
//   bool serviceEnabled;
//   LocationPermission permission;
//   locationSettings;

//   // Test if location services are enabled.
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//     return Future.error('Location services are disabled.');
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Permissions are denied, next time you could try
//       // requesting permissions again (this is also where
//       // Android's shouldShowRequestPermissionRationale
//       // returned true. According to Android guidelines
//       // your App should show an explanatory UI now.
//       return Future.error('Location permissions are denied');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     // Permissions are denied forever, handle appropriately.
//     return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.');
//   }

//   // When we reach here, permissions are granted and we can
//   // continue accessing the position of the device.
//   var thisLocation = await Geolocator.getCurrentPosition();

//   // var position = await determinePosition();
//   // String positionString = thisLocation.toString();
//   // BaseResponse? result = await ApiServices.percobaan(positionString);
//   // result;
//   // dev.i(thisLocation);
//   String positionString = thisLocation.toString();
//   dev.i("this is the position $positionString");
//   // await ApiServices.percobaan(positionString);
//   return thisLocation;
// }

// final dev = Logger();

// void settingGPS() {
//   late LocationSettings locationSettings;

//   if (defaultTargetPlatform == TargetPlatform.android) {
//     locationSettings = AndroidSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 3,
//         forceLocationManager: true,
//         intervalDuration: const Duration(seconds: 15),
//         //(Optional) Set foreground notification config to keep the app alive
//         //when going to the background
//         foregroundNotificationConfig: const ForegroundNotificationConfig(
//           notificationText:
//               "Example app will continue to receive your location even when you aren't using it",
//           notificationTitle: "Running in Background",
//           enableWakeLock: true,
//         ));
//   } else if (defaultTargetPlatform == TargetPlatform.iOS ||
//       defaultTargetPlatform == TargetPlatform.macOS) {
//     locationSettings = AppleSettings(
//       accuracy: LocationAccuracy.high,
//       activityType: ActivityType.fitness,
//       distanceFilter: 5,
//       pauseLocationUpdatesAutomatically: true,
//       // Only set to true if our app will be started up in the background.
//       showBackgroundLocationIndicator: false,
//     );
//   } else {
//     locationSettings = const LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 5,
//     );
//   }
//   locationSettings;
//   StreamSubscription<Position> positionStream =
//       Geolocator.getPositionStream(locationSettings: locationSettings)
//           .listen((Position? position) async {
//     dev.i(position == null
//         ? 'Unknown'
//         : '${position.latitude.toString()}, ${position.longitude.toString()}');

//     String positionString = position.toString();
//     await ApiServices.percobaan(positionString);
//   });

//   positionStream;
// }

// StreamSubscription<Position>? _positionStreamSubscription;
// final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

// void toggleListening() {
//   if (_positionStreamSubscription == null) {
//     final positionStream = _geolocatorPlatform.getPositionStream();
//     _positionStreamSubscription = positionStream.handleError((error) {
//       _positionStreamSubscription?.cancel();
//       _positionStreamSubscription = null;
//     }).listen((position) {
//       dev.i(position);
//     });
//   }
// }
// import 'package:location/location.dart';
// import 'package:logger/logger.dart';

// import 'api_service.dart';

// final dev = Logger();
// void getTheLocation() async {
//   final location = await getLocation();
//   dev.i("Location: ${location.latitude}, ${location.longitude}");
//   String positionString = location.latitude.toString();
//   await ApiServices.percobaan(positionString);
// }
