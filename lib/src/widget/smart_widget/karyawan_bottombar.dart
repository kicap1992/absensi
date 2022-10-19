import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../../config/theme.dart';

class KaryawanBottomBar extends StatelessWidget {
  const KaryawanBottomBar(
      {Key? key, required this.indexSelected, required this.onTap})
      : super(key: key);

  final int indexSelected;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      // cornerRadius: 10,
      initialActiveIndex: indexSelected,
      disableDefaultTabController: true,
      backgroundColor: ThemeInfo.primary,
      items: [
        TabItem(
          icon: Icon(
            Icons.list_alt_outlined,
            color: (indexSelected == 0) ? ThemeInfo.primary : ThemeInfo.myGrey,
          ),
          title: 'Laporan',
        ),
        TabItem(
          icon: Icon(
            Icons.calendar_month_outlined,
            color: (indexSelected == 1) ? ThemeInfo.primary : ThemeInfo.myGrey,
          ),
          title: 'Absensi',
        ),
        TabItem(
          icon: Icon(
            Icons.person_outline,
            color: (indexSelected == 2) ? ThemeInfo.primary : ThemeInfo.myGrey,
          ),
          title: 'Profil',
        ),
      ],
      elevation: 1,
      onTap: (int index) {
        onTap(index);
      },
    );
  }
}
