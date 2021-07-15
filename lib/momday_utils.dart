import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:momday_app/momday_localizations.dart';

final RegExp emailRegExp = RegExp(
    r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
final RegExp phoneRegExp = RegExp(r'^[+]{0,1}[0-9]{1,}$');
final RegExp dobRegExp =
    RegExp(r'^([0-2][0-9]|(3)[0-1])([\/])(((0)[0-9])|((1)[0-2]))(\/)\d{4}$');

void askForLogin(BuildContext context, String action) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(
      tSentence(context, 'need_login') + tLower(context, action),
    ),
    action: SnackBarAction(
        label: tUpper(context, 'log_in'),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pushNamed('/login');
        }),
    duration: Duration(seconds: 3),
  ));
}

void showTextSnackBar(BuildContext context, String text) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: Duration(seconds: 3),
  ));
}

TextStyle cancelArabicFontDelta(BuildContext context) {
  return DefaultTextStyle.of(context).style.apply(
      fontSizeDelta:
          Localizations.localeOf(context).languageCode == 'ar' ? 8.0 : 0.0);
}

bool boolParse(String string) {
  return string.toLowerCase() == 'true';
}

Future<bool> showConfirmDialog(BuildContext context, String text) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text(text), actions: <Widget>[
          new FlatButton(
              child: Text(tUpper(context, 'cancel')),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          new FlatButton(
              child: Text(tUpper(context, 'remove')),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ]);
      });
}

InputDecoration getMomdayInputDecoration(String label) {
  return InputDecoration(
    
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
      ),
    ),
    focusColor: Colors.black,
    labelStyle: TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
      ),
    ),
    labelText: label,
    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
  );
}

// converts a date-time expression to a user-friendly expression, like "4h ago"
String convertDateToUserFriendly(DateTime date, String language) {
  // If from a different year, we put the full-date
  // If from same year, but not today and not yesterday, we put the date without year
  // If yesterday, we say "yesterday at "
  // If between 1 minute and 24 hours, we say "x amount ago"
  // If less than a minute ago, we say now

  // If not the same year, show the whole date
  if (date.year != DateTime.now().year) {
    return DateFormat.yMMMd(language).format(date);
  }

  // get the difference between now and the date
  final diff = DateTime.now().difference(date);

  // if not today and not yesterday, show the date but without year
  if (diff.inDays > 1) {
    return DateFormat.MMMd(language).format(date);
  }

  // if yesterday, show "yesterday at 05:00 PM" for example
  if (diff.inDays == 1) {
    final time = DateFormat.jm(language).format(date);

    final expression = {'en': 'yesterday at $time', 'ar': 'البارحة $time'};

    return expression[language];
  }

  // if less than a day ago, but more than a minute, say "4h35m ago" for example
  if (diff.inDays < 1 && diff.inMinutes >= 1) {
    final diffHours = diff.inHours;
    final diffMinutes = diff.inMinutes % 60;

    final words = {
      'hour': {'en': 'h', 'ar': 'س'},
      'minute': {'en': 'm', 'ar': 'د'},
    };

    var period = '';
    period += diffHours > 0
        ? NumberFormat('#0', language == 'ar' ? 'ar_EG' : 'en')
                .format(diffHours) +
            words['hour'][language]
        : '';
    period += diffMinutes > 0
        ? NumberFormat('#0', language == 'ar' ? 'ar_EG' : 'en')
                .format(diffMinutes) +
            words['minute'][language]
        : '';

    final expression = {'en': '$period ago', 'ar': 'منذ $period'};

    return expression[language];
  }

  // if less than a minute ago, show "Now"
  if (diff.inMinutes < 1) {
    final nowWord = {'en': 'Now', 'ar': 'الآن'};

    return nowWord[language];
  }

  return '';
}

String convertNumberToUserFriendly(num numberValue, String language) {
  final locale = language == 'ar' ? 'ar_EG' : language;

  return NumberFormat.compact(locale: locale).format(numberValue);
}
