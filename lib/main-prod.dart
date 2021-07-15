import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/config.dart';
import 'package:momday_app/momday_app.dart';

void main() {

  EnvironmentConfig.environment = Environment.PRODUCTION;

  return runApp(
    AppStateManager(
      child: const MomdayApp(),
    )
  );
}
