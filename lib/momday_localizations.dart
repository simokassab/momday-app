import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'langs/en.dart';
import 'langs/ar.dart';
import 'package:momday_app/momday_utils.dart';

String t(BuildContext context, String key) {
  return MomdayLocalizations.of(context).translate(key);
}

String tTitle(BuildContext context, String key) {
  return titlecase(MomdayLocalizations.of(context).translate(key));
}

String tSentence(BuildContext context, String key) {
  return sentencecase(MomdayLocalizations.of(context).translate(key));
}

String tUpper(BuildContext context, String key) {
  return MomdayLocalizations.of(context).translate(key).toUpperCase();
}

String tLower(BuildContext context, String key) {
  return MomdayLocalizations.of(context).translate(key).toLowerCase();
}

String tCount(BuildContext context, String key, int count, [bool useCompactFormat = false]) {
  Locale locale = Localizations.localeOf(context);
  String fullKey;

  if (locale.languageCode == 'en') {
    if (count == 1) {
      fullKey = key + '_single';
    } else {
      fullKey = key + '_plural';
    }
  } else if (locale.languageCode == 'ar') {
    if (count == 1) {
      fullKey = key + '_single';
    } else if (count == 0 || (count >= 2 && count <= 10)) {
      fullKey = key + '_plural';
    } else {
      fullKey = key + '_single';
    }
  }

  final stringCount = useCompactFormat?
    convertNumberToUserFriendly(count, locale.languageCode) : count.toString();

  return stringCount + ' ' + t(context, fullKey);
}

String titlecase(String string) {
  return string
    .split(' ')
    .map((word) => word == 'of' || word == 'to'? word : '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}')
    .join(' ');
}

String sentencecase(String string) {
  return string.substring(0, 1).toUpperCase() + string.substring(1).toLowerCase();
}

IconData getLocalizedForwardArrowIcon(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ar'? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right;
}

IconData getLocalizedBackwardArrowIcon(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ar'? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left;
}

class MomdayLocalizations {
  MomdayLocalizations(this.locale);

  final Locale locale;

  static MomdayLocalizations of(BuildContext context) {
    return Localizations.of<MomdayLocalizations>(context, MomdayLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': english,
    'ar': arabic
  };

  String translate(key) {
    return _localizedValues[locale.languageCode][key];
  }
}

class MomdayLocalizationsDelegate extends LocalizationsDelegate<MomdayLocalizations> {
  const MomdayLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<MomdayLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of MomdayLocalizations.
    return SynchronousFuture<MomdayLocalizations>(MomdayLocalizations(locale));
  }

  @override
  bool shouldReload(MomdayLocalizationsDelegate old) => false;
}