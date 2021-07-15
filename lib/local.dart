import 'package:flutter/material.dart';
import 'package:momday_app/config.dart';
import 'package:momday_app/momday_app.dart';

void main() {

  EnvironmentConfig.environment = Environment.LOCAL;

  return runApp(MomdayApp());
}
