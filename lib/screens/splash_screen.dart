import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60.0),
      decoration: BoxDecoration(color: Color.fromRGBO(255, 204, 51, 1.0)
          //FDC334
          ),
      child: Image(
        image: AssetImage('assets/images/logo_new.png'),
      ),
    );
  }
}
