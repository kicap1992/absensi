import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';

import '../../services/api_service.dart';
import '../../services/location_services.dart';
import '../../widget/smart_widget/appbar.dart';
import '../../widget/smart_widget/karyawan_bottombar.dart';
import 'absensi_karyawan.dart';
import 'profil_karyawan.dart';
import 'upload_laporan_page.dart';

class KaryawanIndexPage extends StatefulWidget {
  const KaryawanIndexPage({Key? key}) : super(key: key);

  @override
  State<KaryawanIndexPage> createState() => _KaryawanIndexPageState();
}

class _KaryawanIndexPageState extends State<KaryawanIndexPage> {
  final dev = Logger();
  int _indexSelected = 1;
  // late String formatted;

  final List<String> _headerName = [
    'Halaman Laporan',
    'Halaman Absensi',
    'Halaman Profil',
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      var args = ModalRoute.of(context)?.settings.arguments;
      if (args == true) {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return const ThisFirstDialog();
          },
        );
      }
    });

    // getLoc().listen((event) async {});
    // getLoc().listen((event) async {});
    _getLoc();
  }

  void getDate() {}

  _getLoc() async {
    // final DateTime now = DateTime.now();
    // final DateFormat formatter = DateFormat('yyyy-MM-dd');
    // String formatted = formatter.format(now);
    // await ApiServices.getUserData();

    await ApiServices.getJadwalDinas();

    // dev.i(user);
    // dev.i(jadwal);
    await getLoc();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Keluar Dari Aplikasi Absensi?'),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Ya'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Tidak'),
                ),
              ],
            );
          },
        );
        return shouldPop!;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.07),
          child: AppBarWidget(
            header: _headerName[_indexSelected],
            autoLeading: false,
          ),
        ),
        body: tabWidget(context),
        bottomNavigationBar: KaryawanBottomBar(
          indexSelected: _indexSelected,
          onTap: (index) {
            setState(() {
              _indexSelected = index;
            });
          },
        ),
      ),
    );
  }

  tabWidget(BuildContext context) {
    switch (_indexSelected) {
      case 0:
        return const UploadLaporanKaryawan();
      case 1:
        return const AbsensiKaryawan();
      case 2:
        return const ProfilKaryawanPage();
    }
  }
}

class ThisFirstDialog extends StatelessWidget {
  const ThisFirstDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Info'),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text(
              'Perangkat ini telah terdaftar dalam sistem untuk menjadi perangkat absensi kedisiplinan anda. Untuk menukar perangkar, sila infokan admin bersangkutan',
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
