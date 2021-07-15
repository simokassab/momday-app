import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_cache.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          PageHeader2(
            title: tTitle(context, 'advanced_settings'),
          ),
          SizedBox(height: 20.0,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  width: 2.0
                )
              ),
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  tTitle(context, 'clear_cache')
                ),
                onPressed: () async {
                  var confirmation = await showConfirmDialog(context, tSentence(context, 'confirm_clear_cache'));

                  if (confirmation == true) {
                    await MomdayCache().clearCache();
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  width: 2.0
                )
              ),
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  tTitle(context, 'clear_session_data')
                ),
                onPressed: () async {
                  var confirmation = await showConfirmDialog(context, tSentence(context, 'confirm_clear_session_data'));

                  if (confirmation == true) {
                    await AppStateManager.of(context).clearSessionData();
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 8.0,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tSentence(context, 'advanced_settings_warning')
            ),
          )
        ],
      ),
    );
  }
}
