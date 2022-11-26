import 'package:absensi_karyawan/src/models/base_response.dart';
import 'package:absensi_karyawan/src/models/user_data_model.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widget/dumb_widget/my_textformfield.dart';
import '../../widget/smart_widget/bounce_scroller.dart';

class ProfilKaryawanPage extends StatefulWidget {
  const ProfilKaryawanPage({Key? key}) : super(key: key);

  @override
  State<ProfilKaryawanPage> createState() => _ProfilKaryawanPageState();
}

class _ProfilKaryawanPageState extends State<ProfilKaryawanPage> {
  final dev = Logger();
  final _storage = StorageService();

  UserDataModel? userDataModel;
  static final url = dotenv.env['URL'];

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _oldPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final bool _isOldPasswordVisible = false;
  final bool _isNewPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    var userData = await _storage.read("userData");
    // dev.i(userData);
    setState(() {
      userDataModel = UserDataModel.fromJson(userData);
    });

    dev.i("$url${userDataModel?.image}");
  }

  Future<void> _showPasswordEdit() async {
    // create dialog box
    // empty text field
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Ganti Password",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            // height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextFormField(
                    controller: _oldPasswordController,
                    focusNode: _oldPasswordFocusNode,
                    obscureText: !_isOldPasswordVisible,
                    labelText: "Password Lama",
                    hintText: "Password Lama",
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.visibility_off,
                      ),
                      onPressed: () {
                        null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  MyTextFormField(
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocusNode,
                    obscureText: !_isNewPasswordVisible,
                    labelText: "Password Baru",
                    hintText: "Password Baru",
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.visibility_off,
                      ),
                      onPressed: () {
                        null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  MyTextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    focusNode: _confirmPasswordFocusNode,
                    labelText: "Konfirmasi Password",
                    hintText: "Konfirmasi Password",
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.visibility_off,
                      ),
                      onPressed: () {
                        null;
                      },
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
              child: const Text('Ganti Password'),
              onPressed: () async {
                // if (_formKey.currentState!.validate()) {
                // unfocus all
                String passwordLama = _oldPasswordController.text;
                String passwordBaru = _newPasswordController.text;
                String konfirmasiPassword = _confirmPasswordController.text;
                FocusScope.of(context).unfocus();
                // dev.i("ganti password");
                if (passwordLama == "" ||
                    passwordBaru == "" ||
                    konfirmasiPassword == "") {
                  info('Error', 'Semua field harus diisi',
                      AnimatedSnackBarType.error);
                  // focus to first field
                  FocusScope.of(context).requestFocus(_oldPasswordFocusNode);

                  return;
                }

                if (passwordBaru != konfirmasiPassword) {
                  info(
                      'Error',
                      'Password baru dan konfirmasi password tidak sama',
                      AnimatedSnackBarType.error);
                  // focus to second field
                  FocusScope.of(context).requestFocus(_newPasswordFocusNode);

                  return;
                }

                BaseResponse? response = await ApiServices.gantiPassword(
                  passwordLama,
                  passwordBaru,
                );

                if (response == null) {
                  info('Error', 'Terjadi Kesalahan Jaringan',
                      AnimatedSnackBarType.error);
                  return;
                }

                if (response.status == false) {
                  info('Error', response.message, AnimatedSnackBarType.error);
                  return;
                }

                info('Sukses Ganti Password', response.message,
                    AnimatedSnackBarType.success);

                pop();

                // Navigator.of(context).pop();

                // if
              },
            ),
          ],
        );
      },
    );
  }

  void info(String message, String title, AnimatedSnackBarType type) {
    AnimatedSnackBar.rectangle(
      title,
      message,
      type: type,
      brightness: Brightness.dark,
    ).show(
      context,
    );
  }

  void pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BounceScrollerWidget(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: AssetImage('assets/loading.gif'),
                    fit: BoxFit.fitHeight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeInfo.myGrey2,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                // child: Image.network(
                //   "$url${userDataModel?.image}",
                //   errorBuilder: (context, error, stackTrace) {
                //     return Image.asset(
                //       'assets/profile_blank.png',
                //       fit: BoxFit.cover,
                //     );
                //   },
                // ),

                child: Center(
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        NetworkImage("$url${userDataModel?.image}", scale: 100),
                    onBackgroundImageError: (exception, stackTrace) {
                      return;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  userDataModel == null ? "loading.." : userDataModel!.nama!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeInfo.negroTexto,
                  ),
                ),
              ),
              _DetailParent(userDataModel: userDataModel),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPasswordEdit();
        },
        backgroundColor: ThemeInfo.primary,
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _DetailParent extends StatelessWidget {
  const _DetailParent({
    Key? key,
    required userDataModel,
  })  : _userDataModel = userDataModel,
        super(key: key);

  final UserDataModel? _userDataModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DetailChild(
          icon: Icons.person_pin,
          title: _userDataModel == null ? "loading.." : _userDataModel!.nik!,
        ),
        _DetailChild(
          icon: Icons.home_work_outlined,
          title:
              _userDataModel == null ? "loading.." : _userDataModel!.jabatan!,
        ),
        _DetailChild(
          icon: Icons.work,
          title:
              _userDataModel == null ? "loading.." : _userDataModel!.pangkat!,
        ),
        _DetailChild(
          icon: Icons.work,
          title: _userDataModel == null ? "loading.." : _userDataModel!.status!,
        ),
        _DetailChild(
          icon: Icons.add_reaction_outlined,
          title: _userDataModel == null
              ? "loading.."
              : _userDataModel!.tanggalLahir!,
        ),
        _DetailChild(
          icon: Icons.phone_android,
          title:
              _userDataModel == null ? "loading.." : _userDataModel!.noTelpon!,
        ),
        _DetailChild(
          icon: Icons.home_outlined,
          title: _userDataModel == null ? "loading.." : _userDataModel!.alamat!,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        )
      ],
    );
  }
}

class _DetailChild extends StatelessWidget {
  const _DetailChild({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: ThemeInfo.primary,
                  size: 40,
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 3,
                    // softWrap: false,
                    // overflow: TextOverflow.fade,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeInfo.myGrey2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
