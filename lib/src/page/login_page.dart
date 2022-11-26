import 'dart:convert';

import 'package:absensi_karyawan/src/models/base_response.dart';
import 'package:absensi_karyawan/src/services/api_service.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage_service.dart';
import '../widget/dumb_widget/my_button.dart';
import '../widget/dumb_widget/my_textformfield.dart';
import '../widget/smart_widget/appbar.dart';
import '../widget/smart_widget/bounce_scroller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
  // static _LoginPageState? of(BuildContext context) =>
  //     context.findAncestorStateOfType<_LoginPageState>();
}

class _LoginPageState extends State<LoginPage> {
  final _storage = StorageService();
  final dev = Logger();
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  SharedPreferences? _sharedPreferences;

  bool _showPassword = false;
  late TextEditingController _nikController;
  late TextEditingController _passwordController;
  late FocusNode _nikFocusNode;
  late FocusNode _passwordFocusNode;

  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _nikFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    baca();
  }

  void baca() async {
    String? ini = await _storage.read('device_id');
    _sharedPreferences = await _prefs;
    dev.i(ini);
  }

  Future<void> _dialogLogin() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Perangkat ini akan menjadi perangkat absensi disiplin anda, anda tidak dapat login ke perangkat lain untuk absensi kedisiplinan kecuali login di perangkat ini.',
                  textAlign: TextAlign.justify,
                ),
                Text(
                  "Infokan admin bersangkutan jika ingin menukar perangkat anda.",
                  textAlign: TextAlign.justify,
                ),
                Text("Anda yakin untuk login ?")
              ],
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
              child: const Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                loginUser();
              },
            ),
          ],
        );
      },
    );
  }

  void loginUser() async {
    String nik = _nikController.text;
    String password = _passwordController.text;

    await EasyLoading.show(
      status: "Login...",
      maskType: EasyLoadingMaskType.black,
    );
    BaseResponse? response = await ApiServices.login(nik, password);

    await EasyLoading.dismiss();

    if (response == null) {
      return info(null, false);
    }

    if (response.status == false) {
      // if (mounted) {
      _nikFocusNode.requestFocus();
      return info(response.message, false);
      // }
    }
    // dev.i(response.firstTime);
    await _storage.write('userData', response.data);
    _sharedPreferences!.setString('userData', jsonEncode(response.data));

    info(response.message, true);
    bool firstTime = false;

    if (response.firstTime == true) {
      firstTime = true;
    }
    toHomepage(firstTime);
  }

  void info(String? message, bool stat) {
    AnimatedSnackBar.rectangle(
      stat ? 'Sukses Login' : 'Error',
      message ?? 'Jaringan Bermasalah',
      type: stat ? AnimatedSnackBarType.success : AnimatedSnackBarType.error,
      brightness: Brightness.dark,
    ).show(
      context,
    );
  }

  void toHomepage(bool firstTime) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      'karyawan_index',
      arguments: firstTime,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.07),
        child: const AppBarWidget(
          header: 'HALAMAN LOGIN',
          autoLeading: false,
        ),
      ),
      body: Form(
        key: _formKey,
        child: BounceScrollerWidget(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.05,
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Image.asset(
                'assets/logo_mamuju_tengah.png',
                height: 150,
                width: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Masukkan NIK',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextFormField(
                    controller: _nikController,
                    focusNode: _nikFocusNode,
                    labelText: 'NIK',
                    hintText: 'Masukkan NIK',
                    validator: (value) {
                      if (value!.isEmpty) {
                        // focus to nik
                        _nikFocusNode.requestFocus();
                        return 'NIK tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Masukkan Password',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    labelText: 'Password',
                    hintText: 'Masukkan Password',
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        // focus to password
                        _passwordFocusNode.requestFocus();
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.03,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: MyButton(
                  text: 'Login',
                  onPressed: () {
                    // dev.log("sini login");
                    if (_formKey.currentState!.validate()) {
                      // unfocus all
                      FocusScope.of(context).unfocus();
                      dev.i("sini login");

                      _dialogLogin();

                      // Navigator.pushNamedAndRemoveUntil(
                      //     context, 'karyawan_index', (route) => false);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
