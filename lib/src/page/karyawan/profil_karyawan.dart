import 'package:absensi_karyawan/src/models/user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../../config/theme.dart';
import '../../services/storage_service.dart';
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

    // dev.i("$url${userDataModel.image}");
  }

  @override
  Widget build(BuildContext context) {
    return BounceScrollerWidget(
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
                  color: ThemeInfo.myGrey2,
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
