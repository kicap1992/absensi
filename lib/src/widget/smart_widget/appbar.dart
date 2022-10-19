import 'package:flutter/material.dart';

import '../../config/theme.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    Key? key,
    required this.header,
    required this.autoLeading,
  }) : super(key: key);

  final String header;
  final bool autoLeading;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        header,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.03,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: autoLeading,
      backgroundColor: ThemeInfo.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
    );
  }
}
