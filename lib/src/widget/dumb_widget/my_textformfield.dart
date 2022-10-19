import 'package:flutter/material.dart';

import '../../config/theme.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    Key? key,
    this.labelText,
    this.hintText,
    this.obscureText,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNode,
    this.controller,
    this.maxLines = 1,
    this.onEditingComplete,
  }) : super(key: key);

  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final int maxLines;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onEditingComplete: onEditingComplete,
      maxLines: maxLines,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide(
            color: ThemeInfo.primary,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide(
            color: ThemeInfo.primary,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide(
            color: ThemeInfo.danger,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide(
            color: ThemeInfo.danger,
          ),
        ),
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: ThemeInfo.negroTexto),
      ),
      validator: validator,
    );
  }
}
