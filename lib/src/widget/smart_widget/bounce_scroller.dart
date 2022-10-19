import 'package:flutter/material.dart';

class BounceScrollerWidget extends StatelessWidget {
  final List<Widget> children;
  const BounceScrollerWidget({Key? key, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.height * 0.03,
            right: MediaQuery.of(context).size.height * 0.03,
          ),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: children,
        ),
      ),
    );
  }
}
