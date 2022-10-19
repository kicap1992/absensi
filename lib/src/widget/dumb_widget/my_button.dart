import 'package:flutter/material.dart';

import '../../config/theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeInfo.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: ThemeInfo.background,
          fontSize: 18,
        ),
      ),
    );
  }
}
