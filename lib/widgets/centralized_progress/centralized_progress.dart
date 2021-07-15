import 'package:flutter/material.dart';

class CentralizedProgressIndicator extends StatelessWidget {

  final double height;

  CentralizedProgressIndicator({this.height});

  @override
  Widget build(BuildContext context) {

    var widget = Align(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );

    if (this.height != null) {
      return SizedBox(
        height: this.height,
        child: widget,
      );
    } else {
      return widget;
    }

  }
}
