import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../config/theme.dart';
import '../../models/base_response.dart';
import '../../models/laporan_model.dart';
import '../../services/api_service.dart';
import '../../services/other_services.dart';
import '../../widget/dumb_widget/my_textformfield.dart';
import '../../widget/smart_widget/bounce_scroller.dart';

class UploadLaporanKaryawan extends StatefulWidget {
  const UploadLaporanKaryawan({Key? key}) : super(key: key);

  @override
  State<UploadLaporanKaryawan> createState() => UploadLaporanKaryawanState();
  static UploadLaporanKaryawanState? of(BuildContext context) =>
      context.findAncestorStateOfType<UploadLaporanKaryawanState>();
}

class UploadLaporanKaryawanState extends State<UploadLaporanKaryawan> {
  final dev = Logger();
  final String? url = dotenv.env['URL'];

  late TextEditingController _namaLaporanController;
  late TextEditingController _ketLaporanController;
  late FocusNode _namaLaporanFocusNode;
  late FocusNode _ketLaporanFocusNode;

  // table pagination and search
  int _loadLaporan = 0;
  List<LaporanData>? _listLaporanData;
  int _pageNumber = 1;
  int? _pageAll;
  int? _countAll;
  // String _search = '';
  late TextEditingController _searchLaporanController;

  @override
  void initState() {
    super.initState();
    _namaLaporanController = TextEditingController();
    _ketLaporanController = TextEditingController();
    _namaLaporanFocusNode = FocusNode();
    _ketLaporanFocusNode = FocusNode();
    _searchLaporanController = TextEditingController();
    _searchLaporanController.text = '';
    getAllLaporan(1, _searchLaporanController.text);
  }

  void getAllLaporan(int page, String search) async {
    setState(() {
      _loadLaporan = 0;
    });
    BaseResponse? response = await ApiServices.getLaporan(page, search);
    // dev.i(response?.data);

    if (response == null) {
      setState(() {
        _loadLaporan = 3;
      });
      return;
    }

    if (response.status == false) {
      setState(() {
        _loadLaporan = 2;
      });
    }

    LaporanModel laporanModel = LaporanModel.fromJson(response.data);
    // dev.i(laporanModel.data);

    setState(() {
      _listLaporanData = laporanModel.data;
      _loadLaporan = 1;
      _pageNumber = page;
      _pageAll = laporanModel.allPage;
      _countAll = laporanModel.countAll;
    });

    // await Future.delayed(Duration(seconds: 3));

    // if (!mounted) return;
    // setState(() {
    //   _loadLaporan = 1;
    // });
  }

  bool _hasFoto = false; // if has foto
  String? _imgPath; // path to foto
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // file to foto
  Uint8List? imagebytes;

  Future<void> onImageButtonPressed() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      _imageFile = pickedFile;

      final file = File(_imageFile!.path);
      if (file.existsSync()) {
        final Uint8List bytes = await file.readAsBytes();
        setState(() {
          _imgPath = _imageFile!.path.toString();
          imagebytes = bytes;
          _hasFoto = true;
        });
        popDialog();
        _showTambahLaporan();
      }
    } catch (e) {
      dev.e(e);
    }
  }

  popDialog() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  void info(String message, String stat, String title) {
    AnimatedSnackBar.rectangle(
      title,
      message,
      type: stat == 'warning'
          ? AnimatedSnackBarType.warning
          : stat == 'success'
              ? AnimatedSnackBarType.success
              : AnimatedSnackBarType.error,
      brightness: Brightness.dark,
    ).show(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 75,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                BounceScrollerWidget(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_loadLaporan == 0)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (_loadLaporan == 1)
                          _LaporanList(
                            listLaporanData: _listLaporanData,
                            dev: dev,
                            pageNumber: _pageNumber,
                            pageAll: _pageAll,
                            countAll: _countAll,
                            serverUrl: url,
                          )
                        else if (_loadLaporan == 2)
                          const Center(
                            child: Text(
                              "Gagal Load Laporan\nServer Mungkin Bermasalah",
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (_loadLaporan == 3)
                          const Center(
                            child: Text(
                              "Gagal Load Laporan\nJaringan Mungkin Bermasalah",
                              textAlign: TextAlign.center,
                            ),
                          )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: MyTextFormField(
                controller: _searchLaporanController,
                onEditingComplete: () {
                  // dev.i("editing complete");
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _pageNumber = 1;
                  });

                  getAllLaporan(1, _searchLaporanController.text);
                },
                // suffixIcon: Icon(
                //   Icons.list_alt_outlined,
                //   color: ThemeInfo.myGrey,
                // ),
                labelText: "Cari Laporan",
                hintText: "Cari Laporan",
                prefixIcon: const Icon(
                  Icons.search,
                  color: ThemeInfo.myGrey2,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeInfo.primary,
        onPressed: () {
          FocusScope.of(context).unfocus();
          OtherServices.cekAndDelete();
          setState(() {
            _hasFoto = false;
            _imgPath = null;
          });
          _showTambahLaporan();
        },
        child: const Icon(Icons.post_add_outlined),
      ),
    );
  }

  Future<void> _showTambahLaporan() async {
    // create dialog box
    _searchLaporanController.text = '';
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Form Laporan"),
          content: SizedBox(
            // height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => dev.i("sentuh gambar"),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 199, 214, 234),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 104, 164, 164),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          // put icon on rigth bottom corner
                          alignment: Alignment.center,
                          children: [
                            FotoWidget(
                              hasFoto: _hasFoto,
                              imagebytes: imagebytes,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  dev.i("sentuh untuk tambah gambar");
                                  onImageButtonPressed();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 4, 103, 103),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  MyTextFormField(
                    controller: _namaLaporanController,
                    focusNode: _namaLaporanFocusNode,
                    labelText: "Nama Laporan",
                    hintText: "Nama Laporan",
                    prefixIcon: const Icon(
                      Icons.title,
                      color: ThemeInfo.myGrey,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  MyTextFormField(
                    controller: _ketLaporanController,
                    focusNode: _ketLaporanFocusNode,
                    labelText: "Keterangan",
                    hintText: "Keterangan",
                    maxLines: 4,
                    prefixIcon: const Icon(
                      Icons.description,
                      color: ThemeInfo.myGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batalkan'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Upload Laporan'),
              onPressed: () {
                // if (_formKey.currentState!.validate()) {
                // unfocus all
                FocusScope.of(context).unfocus();

                if (_namaLaporanController.text == '') {
                  info('Nama Laporan Harus Terisi', 'warning', 'Info');
                  _namaLaporanFocusNode.requestFocus();
                  return;
                }

                if (_ketLaporanController.text == '') {
                  info('Keterangan Laporan Harus Terisi', 'warning', 'Info');
                  _ketLaporanFocusNode.requestFocus();
                  return;
                }
                beforeUploadDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void beforeUploadDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Upload Laporan?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Batalkan'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Upload Laporan'),
              onPressed: () {
                popDialog();
                uploadLaporan();
              },
            ),
          ],
        );
      },
    );
  }

  void uploadLaporan() async {
    await EasyLoading.show(
      status: "Upload Laporan...",
      maskType: EasyLoadingMaskType.black,
    );

    BaseResponse? response = await ApiServices.uploadLaporan(
        _imgPath, _namaLaporanController.text, _ketLaporanController.text);
    // await Future.delayed(const Duration(milliseconds: 2000));

    await EasyLoading.dismiss();

    if (response == null) {
      return info('Jaringan Bermasalah', 'error', 'Error');
    }

    if (response.status == false) {
      return info(response.message, 'error', 'Error');
    }
    _namaLaporanController.text = '';
    _ketLaporanController.text = '';
    popDialog();
    info(response.message, 'success', 'Sukses Upload Laporan');

    // load kembali tabel
    setState(() {
      _pageNumber = 1;
    });
    getAllLaporan(1, '');
  }

  void setPageNumber(int newPageNumber) {
    setState(() {
      _pageNumber = newPageNumber;
    });
    getAllLaporan(_pageNumber, _searchLaporanController.text);
  }
}

class _LaporanList extends StatelessWidget {
  const _LaporanList({
    Key? key,
    required List<LaporanData>? listLaporanData,
    required this.dev,
    required int pageNumber,
    required int? pageAll,
    required int? countAll,
    String? serverUrl,
  })  : _listLaporanData = listLaporanData,
        _pageNumber = pageNumber,
        _pageAll = pageAll,
        _countAll = countAll,
        _serverUrl = serverUrl,
        super(key: key);

  final List<LaporanData>? _listLaporanData;
  final Logger dev;
  final int _pageNumber;
  final int? _pageAll;
  final int? _countAll;
  final String? _serverUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: _countAll! > 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var data in _listLaporanData!)
                  Column(
                    children: [
                      _LaporanChild(
                        dev: dev,
                        data: data,
                        serverUrl: _serverUrl,
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _pageNumber == 1
                            ? ThemeInfo.myGrey
                            : ThemeInfo.primary,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: ThemeInfo.myGrey2,
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_pageNumber == 1) return;
                          // dev.i("Page previous");
                          int newPageNumber = _pageNumber - 1;
                          UploadLaporanKaryawan.of(context)!
                              .setPageNumber(newPageNumber);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: ThemeInfo.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ThemeInfo.myGrey2,
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(_pageNumber.toString()),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _pageNumber == _pageAll
                            ? ThemeInfo.myGrey
                            : ThemeInfo.primary,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: ThemeInfo.myGrey2,
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_pageNumber == _pageAll) return;
                          // dev.i("Page next");
                          int newPageNumber = _pageNumber + 1;
                          UploadLaporanKaryawan.of(context)!
                              .setPageNumber(newPageNumber);
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text("$_countAll Laporan")
              ],
            )
          : const Text("Tiada Laporan Yang Diupload Oleh Anda"),
    );
  }
}

class FotoWidget extends StatelessWidget {
  const FotoWidget({
    Key? key,
    required this.hasFoto,
    this.imagebytes,
  }) : super(key: key);

  final bool hasFoto;
  final Uint8List? imagebytes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (hasFoto)
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/loading.gif',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: MemoryImage(
                      imagebytes!,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            )
          : const Icon(Icons.add,
              color: Color.fromARGB(255, 2, 72, 72), size: 22),
    );
  }
}

class _LaporanChild extends StatelessWidget {
  const _LaporanChild({
    Key? key,
    required this.data,
    required this.dev,
    String? serverUrl,
  })  : _serverUrl = serverUrl,
        super(key: key);

  final LaporanData data;
  final Logger dev;
  final String? _serverUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: double.infinity,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.createdAt != null
                        ? OtherServices.dateFormater(data.createdAt!, 'date')!
                        : "",
                    style: const TextStyle(
                      color: ThemeInfo.negroTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data.createdAt != null
                        ? OtherServices.dateFormater(data.createdAt!, 'time')!
                        : "",
                    style: const TextStyle(
                      color: ThemeInfo.negroTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.namaLaporan ?? '',
                    style: const TextStyle(
                      color: ThemeInfo.negroTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // lorem ipsum dolor sit amet consectetur adipisicing elit.
                    data.ketLaporan ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      color: ThemeInfo.negroTexto,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: ThemeInfo.readFile,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeInfo.myGrey2,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    // dev.i("heheheh");
                    showLaporan(context);
                  },
                  icon: const Icon(Icons.read_more_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLaporan(BuildContext context) {
    // dev.i("sini show laporan");
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            // height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (data.image != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          _serverUrl! + data.image!,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  Text(
                    data.namaLaporan!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    data.ketLaporan!,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
