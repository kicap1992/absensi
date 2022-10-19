import 'dart:async';
import 'dart:collection';

import 'package:absensi_karyawan/src/models/base_response.dart';
import 'package:absensi_karyawan/src/services/api_service.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';

import '../../config/theme.dart';
import '../../models/absensi_karyawan_model.dart';
import '../../models/jadwal_dinas_model.dart';
import '../../models/user_data_model.dart';
import '../../services/other_services.dart';
import '../../services/storage_service.dart';
import '../../widget/smart_widget/bounce_scroller.dart';

class AbsensiKaryawan extends StatefulWidget {
  const AbsensiKaryawan({
    Key? key,
  }) : super(key: key);

  @override
  State<AbsensiKaryawan> createState() => _AbsensiKaryawanState();
}

class _AbsensiKaryawanState extends State<AbsensiKaryawan> {
  final dev = Logger();
  final _storage = StorageService();
  UserDataModel? _userDataModel;
  late String formatted;
  LatLng? currentLocation;

  dynamic _statusnya;

  AbsensiKaryawanModel? absensiKaryawanModel;

  late JadwalDinasModel _jadwalDinasModel;

  bool buttonLoad = false;

  String stat = 'jam_masuk';

  final statValue = {
    "jam_masuk": "Masuk Kerja",
    "jam_istirehat": "Istirehat Kerja",
    "jam_masuk_kembali": "Kerja Kembali",
    "jam_pulang": "Pulang Kerja",
  };

  @override
  void initState() {
    super.initState();
    getDate();
    getUserData();
    getUserJadwalHarinIni();
  }

  void getDate() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    formatted = formatter.format(now);
    String today = DateFormat('EEEE').format(now);
    // dev.i(today);
    if (today == "Sunday" || today == "Saturday") {
      setState(() {
        String day = (today == "Sunday") ? "Minggu" : "Sabtu";
        _statusnya = {'stat': "Libur", 'ket': "Libur Hari $day"};
      });
    } else {
      await ApiServices.getTodayLiburAndPerjalanDinas(formatted);
      // await Future.delayed(Duration(seconds: 1));
      dynamic statusnya = await _storage.read('ada_perjalanan_dinas_libur');
      // dev.i(statusnya);
      setState(() {
        _statusnya = statusnya;
      });
    }

    List jadwalDinasList = await _storage.read('jadwalKerja');

    for (var data in jadwalDinasList) {
      JadwalDinasModel jadwalDinasModel = JadwalDinasModel.fromJson(data);
      String dayName = OtherServices.dayNameChanger(jadwalDinasModel.hari!);
      if (dayName == today) {
        setState(() {
          _jadwalDinasModel = jadwalDinasModel;
        });
      }
    }

    dev.i(_jadwalDinasModel.hari);
    // dev.i(_jadwalDinasModel.jamMasuk);
    // dev.i(_jadwalDinasModel.jamIstirehat);
    // dev.i(_jadwalDinasModel.jamMasukKembali);
    // dev.i(_jadwalDinasModel.jamPulang);
  }

  void getUserData() async {
    await ApiServices.getUserData();
    Map<String, dynamic> userData = await _storage.read('userData');

    setState(() {
      _userDataModel = UserDataModel.fromJson(userData);
    });
  }

  getUserJadwalHarinIni() async {
    BaseResponse? result = await ApiServices.getUserTodayAbsensi(formatted);

    if (result == null) {
      if (mounted) {
        return setState(() {
          info(
              "Tidak dapat terhubung ke server, Sila cek jaringan anda", false);
        });
      }
    }

    if (result!.status == false) {
      if (mounted) {
        return setState(() {
          info(
              "Tidak dapat terhubung ke server, Sila cek jaringan anda", false);
        });
      }
    }
    // dev.i(result.data);
    await _storage.write('runGPS', false);
    if (result.data != null) {
      // dev.i("sini dia");
      await _storage.write('runGPS', true);
      setState(() {
        absensiKaryawanModel = AbsensiKaryawanModel.fromJson(result.data);
        stat = 'jam_istirehat';

        if (absensiKaryawanModel!.jamIstirehat != null) {
          stat = "jam_masuk_kembali";
        }

        if (absensiKaryawanModel!.jamMasukKembali != null) {
          stat = "jam_pulang";
        }
      });

      if (absensiKaryawanModel!.jamIstirehat != null) {
        await _storage.write('runGPS', false);
      }

      if (absensiKaryawanModel!.jamMasukKembali != null) {
        await _storage.write('runGPS', true);
      }

      if (absensiKaryawanModel!.jamPulang != null) {
        await _storage.write('runGPS', false);
      }
    }
  }

  info(String? message, bool stat) async {
    await AnimatedSnackBar.rectangle(
      stat ? 'Info' : 'Error',
      message ?? 'Jaringan Bermasalah',
      type: stat ? AnimatedSnackBarType.success : AnimatedSnackBarType.error,
      brightness: Brightness.dark,
    ).show(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BounceScrollerWidget(
        children: [
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeaderTitle(dinas: _userDataModel?.dinas),
                const _LogoImage(),
                _KaryawanDetail(
                    nik: _userDataModel?.nik, nama: _userDataModel?.nama),
                _LaporanAbsensi(
                  tanggal: formatted,
                  statusnya: _statusnya,
                  absensiKaryawanModel: absensiKaryawanModel,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeInfo.primary,
        onPressed: () {
          if (absensiKaryawanModel != null) {
            if (absensiKaryawanModel!.jamPulang != null) {
              info("Anda Sudah Pulang Kerja, Silakan Istirehat", true);
            } else {
              _dialogAbsensi();
            }
          } else {
            _dialogAbsensi();
          }
        },
        child: const Icon(Icons.work_history_outlined),
      ),
    );
  }

  Future<void> _dialogAbsensi() async {
    if (_statusnya == null) return info("Jaringan Bermasalah", false);

    if (_statusnya != 'tiada') {
      return info(
          "Anda Sedang Dalam ${_statusnya['stat']}\n${_statusnya['ket']}",
          true);
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Form Absensi"),
                const SizedBox(
                  height: 10,
                ),
                _ThisGoogleMaps(
                  userDataModel: _userDataModel,
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeInfo.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      await EasyLoading.show(
                        status: "Absensi...",
                        maskType: EasyLoadingMaskType.black,
                      );
                      setState(() {
                        buttonLoad = false;
                      });

                      // await EasyLoading.dismiss();
                      await Future.delayed(const Duration(seconds: 1));

                      double? currentLocationStr1 =
                          await _storage.read("currentLocation1");
                      double? currentLocationStr2 =
                          await _storage.read("currentLocation2");

                      if (currentLocationStr1 == null) {
                        await EasyLoading.dismiss();
                        return await info("Sedang Mencari Lokasi Anda", false);
                      }

                      LatLng? currentLocationLatLng =
                          (currentLocationStr2 != null)
                              ? LatLng(currentLocationStr1, currentLocationStr2)
                              : null;
                      bool checkMe = OtherServices.checkIfInRadius(
                          currentLocationLatLng!,
                          LatLng(double.parse(_userDataModel!.lat!),
                              double.parse(_userDataModel!.lng!)));

                      setState(() {
                        buttonLoad = true;
                      });

                      if (!buttonLoad) return info("Still Loading", false);

                      if (!checkMe) {
                        return info(
                            "Anda Berada Di Luar Radius Lokasi Kantor Yang Ditetapkan",
                            false);
                      }

                      // dev.i("jalankan");
                      await absensiKerja(stat);

                      await ApiServices.postUserTodayAbsensi(formatted, stat);
                    },
                    child: _ThisDialogButton(statValue: statValue, stat: stat),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  popDialog() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  absensiKerja(String? stat) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        stopnya() async {
          await EasyLoading.dismiss();
        }

        stopnya();

        return AlertDialog(
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Absensi ${statValue[stat]} ?"),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await EasyLoading.show(
                          status: "Sedang Absensi...",
                          maskType: EasyLoadingMaskType.black,
                        );
                        popDialog();
                        await ApiServices.postUserTodayAbsensi(
                            formatted, stat!);
                        await getUserJadwalHarinIni();
                        await EasyLoading.dismiss();
                      },
                      child: const Text("Ya"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Tidak"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThisDialogButton extends StatelessWidget {
  const _ThisDialogButton({
    Key? key,
    required this.statValue,
    required this.stat,
  }) : super(key: key);

  final Map<String, String> statValue;
  final String? stat;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Absensi ${statValue[stat]}",
      style: const TextStyle(
        color: ThemeInfo.background,
        fontSize: 18,
      ),
    );
  }
}

class _ThisGoogleMaps extends StatefulWidget {
  const _ThisGoogleMaps({
    Key? key,
    UserDataModel? userDataModel,
  })  : _userDataModel = userDataModel,
        super(key: key);

  final UserDataModel? _userDataModel;

  @override
  State<_ThisGoogleMaps> createState() => _ThisGoogleMapsState();
}

class _ThisGoogleMapsState extends State<_ThisGoogleMaps> {
  final dev = Logger();
  final _storage = StorageService();

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-2.0702326775846314, 119.28682729516751),
    zoom: 15,
  );

  Location location = Location();

  final Set<Marker> _markers = HashSet<Marker>();
  final Set<Circle> _circles = HashSet<Circle>();
  late GoogleMapController mapController;
  // Completer<GoogleMapController> _controller = Completer();

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      // color: Colors.transparent,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          markers: _markers,
          circles: _circles,
          onMapCreated: _onMapCreated,
          // zoomControlsEnabled: false,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    Timer(const Duration(milliseconds: 1000), () async {
      // final GoogleMapController controller = await controller.future;
      // -4.007142395641209, 119.6295638910395

      // var dinasData = await _storage.read(key);
      LocationData locationData;
      while (true) {
        await _storage.write("currentLocation1", null);
        await _storage.write("currentLocation2", null);
        locationData = await location.getLocation();

        await _storage.write("currentLocation1", locationData.latitude);
        await _storage.write("currentLocation2", locationData.longitude);

        // dev.i(locationData.latitude);
        // dev.i(locationData.longitude);
        _markers.clear();
        _circles.clear();

        if (mounted) {
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(locationData.latitude!, locationData.longitude!),
                zoom: 17,
              ),
            ),
          );
          setState(() {
            _markers.add(Marker(
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              markerId: const MarkerId("ini markernya"),
              position: LatLng(locationData.latitude!, locationData.longitude!),
              infoWindow: const InfoWindow(
                title: "Posisi Sekarang",
              ),
            ));

            _circles.add(
              Circle(
                circleId: CircleId(widget._userDataModel!.idDinas!),
                center: LatLng(double.parse(widget._userDataModel!.lat!),
                    double.parse(widget._userDataModel!.lng!)),
                radius: double.parse(widget._userDataModel!.radius!),
                fillColor: Colors.blue.withOpacity(0.2),
                strokeWidth: 0,
              ),
            );
          });
        }

        await Future.delayed(const Duration(seconds: 10));
      }
    });
  }
}

class _LaporanAbsensi extends StatelessWidget {
  _LaporanAbsensi(
      {Key? key,
      required this.tanggal,
      this.statusnya,
      AbsensiKaryawanModel? absensiKaryawanModel})
      : _absensiKaryawanModel = absensiKaryawanModel,
        super(key: key);
  final dev = Logger();
  final String tanggal;
  final dynamic statusnya;

  final AbsensiKaryawanModel? _absensiKaryawanModel;

  @override
  Widget build(BuildContext context) {
    late String jamMasuk, jamPulang, status;
    // String? ket;
    // dev.i(statusnya);
    if (statusnya == null) {
      jamMasuk = "-";
      jamPulang = "-";
      status = "Tiada Jaringan";
    } else {
      if (statusnya == 'tiada') {
        if (_absensiKaryawanModel == null) {
          jamMasuk = "-";
          jamPulang = "-";
          status = "Belum Absen";
        } else {
          jamMasuk = _absensiKaryawanModel!.jamMasuk ?? "-";
          jamPulang = "-";
          status = "Sedang Kerja";
          if (_absensiKaryawanModel!.jamIstirehat != null) {
            status = "Sedang Istirehat";
          }
          if (_absensiKaryawanModel!.jamMasukKembali != null) {
            status = "Sedang Kerja";
          }
          if (_absensiKaryawanModel!.jamPulang != null) {
            jamPulang = _absensiKaryawanModel!.jamPulang ?? '-';
            status = "Pulang Kerja";
          }
        }
      } else {
        if (statusnya['stat'] == "Perjalanan Dinas") {
          jamMasuk = "-";
          jamPulang = "-";
          status = "Perjalanan Dinas";
          // ket = statusnya['ket'];
        }

        if (statusnya['stat'] == "Libur") {
          jamMasuk = "-";
          jamPulang = "-";
          status = "Libur";
          // ket = statusnya['ket'];
        }
      }
    }

    return Container(
      width: double.infinity,
      // height: 180,
      decoration: BoxDecoration(
        color: ThemeInfo.myGrey,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: ThemeInfo.myGrey2,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LaporanAbsensiChild(
              title: "Tanggal",
              value: tanggal,
            ),
            _LaporanAbsensiChild(
              title: "Jam Masuk",
              value: jamMasuk,
            ),
            _LaporanAbsensiChild(
              title: "Jam Keluar",
              value: jamPulang,
            ),
            _LaporanAbsensiChild(
              title: "Status",
              value: status,
            ),
            // if (ket != null)
            //   _LaporanAbsensiChild(
            //     title: "Keterangan",
            //     value: status,
            //   ),
          ],
        ),
      ),
    );
  }
}

class _LaporanAbsensiChild extends StatelessWidget {
  const _LaporanAbsensiChild({
    Key? key,
    required this.value,
    this.title,
  }) : super(key: key);

  final String value;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$title : ',
              style: const TextStyle(
                fontSize: 20,
                // fontWeight: FontWeight.bold,
                color: ThemeInfo.negroTexto,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeInfo.negroTexto,
            ),
          ),
        ],
      ),
    );
  }
}

class _KaryawanDetail extends StatelessWidget {
  const _KaryawanDetail({
    Key? key,
    this.nama,
    this.nik,
  }) : super(key: key);

  final String? nama;
  final String? nik;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 20,
      ),
      alignment: Alignment.center,
      child: Text(
        nama == null ? 'Loading..' : '$nama \n $nik',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Image.asset(
        'assets/logo_mamuju_tengah.png',
        height: 150,
        width: 150,
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    Key? key,
    this.dinas,
  }) : super(key: key);

  final String? dinas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
        right: MediaQuery.of(context).size.width * 0.03,
        left: MediaQuery.of(context).size.width * 0.03,
      ),
      alignment: Alignment.center,
      child: Text(
        dinas != null ? dinas!.toUpperCase() : "Loading..",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
