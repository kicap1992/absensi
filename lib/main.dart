import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:absensi_karyawan/src/models/jadwal_dinas_model.dart';
import 'package:absensi_karyawan/src/services/notification_services.dart';
// import 'package:background_location/background_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/config/routes.dart';
import 'src/config/theme.dart';
import 'src/provider/login_provider.dart';
import 'src/services/other_services.dart';
import 'src/services/storage_service.dart';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// import 'package:socket_io_client/socket_io_client.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final dev = Logger();
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await GetStorage.init();
  // await _startBackgroundLocation();
  await dotenv.load(fileName: ".env");
  StorageService storage = StorageService();
  await storage.init();

  await _configureLocalTimeZone();
  await NotificationServices.init();
  await initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: IOSInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      // notificationChannelId: 'my_foreground',
      // initialNotificationTitle: 'AWESOME SERVICE',
      // initialNotificationContent: 'Initializing',
      // foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.reload();
  // final log = preferences.getStringList('log') ?? <String>[];
  // log.add(DateTime.now().toIso8601String());
  // await preferences.setStringList('log', log);

  return true;
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // final storage = StorageService();
  // var jadwalKerja = await storage.read('jadwalKerja');

  String? jadwalKerja;
  List? jadwalKerjaList;
  String? userData;
  Map? userDataMap;

  final SharedPreferences prefs = await _prefs;

  jadwalKerja = prefs.getString('jadwalKerja');
  userData = prefs.getString('userData');

  // dev.i(userData);

  if (jadwalKerja != null) {
    jadwalKerjaList = jsonDecode(jadwalKerja);
    // dev.i(jadwalKerjaList);
  }

  if (userData != null) {
    userDataMap = jsonDecode(userData);
    // dev.i(userDataMap);
  }

  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 60), (timer) async {
    if (userDataMap == null) return;
    if (jadwalKerjaList == null) return;
    final DateTime now = DateTime.now();
    // get the now time
    final DateFormat formatter = DateFormat('HH:mm:ss');
    var formatted = formatter.format(now);
    // get the overall seconds from formatted time
    int seconds = int.parse(formatted.split(':')[0]) * 3600 +
        int.parse(formatted.split(':')[1]) * 60 +
        int.parse(formatted.split(':')[2]);

    // change formatted to time
    dev.i(seconds);
    // get the time now

    String today = DateFormat('EEEE').format(now);
    // dev.i(today);
    // String dayName = OtherServices.dayNameChanger(jadwalDinasModel.hari!);
    if (today != "Sunday" || today == "Saturday") return;
    for (var data in jadwalKerjaList) {
      JadwalDinasModel jadwalDinasModel = JadwalDinasModel.fromJson(data);
      String dayName = OtherServices.dayNameChanger(jadwalDinasModel.hari!);
      // dev.i(dayName);

      if (dayName == today) {
        // create a dateFormat from jadwalDinasModel.jamMasuk
        var jamMasuk = formatter.parse(jadwalDinasModel.jamMasuk!);
        var jamPulang = formatter.parse(jadwalDinasModel.jamPulang!);
        // fet only the time
        // minus 30 minutes from jamMasukOnlyTime
        // and plus 30 minutes from jamPulangOnlyTime
        var jamMasukMinus30 = jamMasuk.subtract(const Duration(minutes: 30));
        var jamPulangPlus30 = jamPulang.add(const Duration(minutes: 30));

        var jamMasukOnlyTime = formatter.format(jamMasukMinus30);
        var jamPulangOnlyTime = formatter.format(jamPulangPlus30);

        // get the overall seconds from jamMasukOnlyTime and jamPulangOnlyTime
        int secondsJamMasuk = int.parse(jamMasukOnlyTime.split(':')[0]) * 3600 +
            int.parse(jamMasukOnlyTime.split(':')[1]) * 60 +
            int.parse(jamMasukOnlyTime.split(':')[2]);

        int secondsJamPulang =
            int.parse(jamPulangOnlyTime.split(':')[0]) * 3600 +
                int.parse(jamPulangOnlyTime.split(':')[1]) * 60 +
                int.parse(jamPulangOnlyTime.split(':')[2]);

        // if seconds is between jamMasukOnlyTimeSeconds and jamPulangOnlyTimeSeconds
        // then show notification
        if (seconds >= secondsJamMasuk && seconds <= secondsJamPulang) {
          dev.i("jalankan");
        } else {
          // dev.i("tidak jalankan");
          // stop service
          service.stopSelf();
        }
      }
    }

    // const platform = MethodChannel('example.com/channel');
    // int random;
    // try {
    //   random = await platform.invokeMethod('getRandomNumber');
    // } on PlatformException catch (e) {
    //   random = 0;
    // }
    // BackgroundLocation().getCurrentLocation().then((location) {
    //   dev.i('Location: ${location.latitude}, ${location.longitude}');
    //   // NotificationServices.showNotification(
    //   //   id: 1,
    //   //   title: 'Percobaan 2',
    //   //   body: 'Location: ${location.latitude}, ${location.longitude}',
    //   //   payload: 'Percobaan 2',
    //   // );
    // });
    // if (service is AndroidServiceInstance) {
    //   // if (await service.isForegroundService()) {
    //   /// OPTIONAL for use custom notification
    //   /// the notification id must be equals with AndroidConfiguration when you call configure() method.
    //   flutterLocalNotificationsPlugin.show(
    //     888,
    //     'COOL SERVICE',
    //     'Awesome ${DateTime.now()}',
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'my_foreground',
    //         'MY FOREGROUND SERVICE',
    //         icon: 'ic_bg_service_small',
    //         ongoing: true,
    //       ),
    //     ),
    //   );

    //   // if you don't using custom notification, uncomment this
    //   // service.setForegroundNotificationInfo(
    //   //   title: "My App Service",
    //   //   content: "Updated at ${DateTime.now()}",
    //   // );
    //   // }
    // }

    /// you can see this log in logcat
    // dev.i('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    // final deviceInfo = DeviceInfoPlugin();
    // String? device;
    // if (Platform.isAndroid) {
    //   // final androidInfo = await deviceInfo.androidInfo;
    //   // device = androidInfo.model;
    // }

    // if (Platform.isIOS) {
    //   // final iosInfo = await deviceInfo.iosInfo;
    //   // device = iosInfo.model;
    // }

    service.invoke(
      'update',
      {
        // "current_date": DateTime.now().toIso8601String(),
        // "device": device,
      },
    );
  });
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  try {
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));
  }

  // final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  // tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: ThemeInfo.primary,
        statusBarColor: ThemeInfo.primary,
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>(
          create: (_) => LoginProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Absensi Karyawan',
        initialRoute: 'splash',
        // initialRoute:'prueba',
        theme: ThemeInfo.getTheme(),
        routes: RoutesApp.getRoutes(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
