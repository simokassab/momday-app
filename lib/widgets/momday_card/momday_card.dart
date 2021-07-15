import 'package:flutter/material.dart';

class MomdayCard extends StatelessWidget {

  final Widget child;

  MomdayCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0))
        ),
        child: child,

      ),
    );
  }
}
