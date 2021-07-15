import 'package:flutter/material.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/styles/momday_colors.dart';

class MomdayError extends StatelessWidget {
  final double height;
  final Object error;
  final VoidCallback onTryAgain;
  final bool full;

  MomdayError({this.height, this.error, this.onTryAgain, this.full: true});

  @override
  Widget build(BuildContext context) {
    var mainPart = Stack(
      children: <Widget>[
        Positioned(
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
          top: 0.0,
          bottom: 0.0,
          child: Center(
              child: Image(
            image: AssetImage('assets/images/error_word.png'),
            fit: BoxFit.fill,
          )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 180.0,
              child: Image(
                image: AssetImage('assets/images/error_icon.png'),
              ),
            ),
          ],
        ),
      ],
    );

    var child;
    if (this.full) {
      child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            Image(
              image: AssetImage('assets/images/error_parallelogram.png'),
            ),
            SizedBox(height: 8.0),
            mainPart,
            SizedBox(height: 8.0),
            Text(
              tLower(context, 'error_occurred'),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            InkWell(
              child: Text(
                tUpper(context, 'try_again'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MomdayColors.MomdayGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: this.onTryAgain,
            ),
            SizedBox(height: 8.0),
            Text(
              tUpper(context, 'report_issue'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MomdayColors.MomdayGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.0),
            Image(
              image: AssetImage('assets/images/error_parallelogram.png'),
            ),
          ],
        ),
      );
    } else {
      child = mainPart;
    }

    if (this.height != null) {
      return SizedBox(
        height: this.height,
        child: child,
      );
    } else {
      return child;
    }
  }
}
