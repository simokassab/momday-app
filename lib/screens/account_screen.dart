import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/address_list_screen.dart';
import 'package:momday_app/screens/advanced_settings_screen.dart';
import 'package:momday_app/screens/profile_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!AppStateManager.of(context).account.isLoggedIn) {
      return Container();
    }

    final accountTileStyle =
        TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MomdayColors.MomdayGold,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(
              getLocalizedBackwardArrowIcon(context),
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: MomdayColors.MomdayGold,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left:10),
            child: Text(
              tTitle(context, 'welcome_to_momday') + '!',
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 30),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left:10,top:12),
            child: Text(
              AppStateManager.of(context).account.fullName,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                  color: Colors.black,
                  decoration: null),
            ),
          ),

          SizedBox(
            height: 20.0,
          ),
          Container(height: 30.0, color: MomdayColors.MomdayGray),
          ListTile(
            title: Text(tUpper(context, 'my_profile'), style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PorfileScreen()));
            },
          ),
          ListTile(
            title:
                Text(tUpper(context, 'my_addresses'), style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddressListScreen()));
            },
          ),
//          ListTile(
//            title: Text(
//                tUpper(context, 'location'),
//                style: accountTileStyle
//            ),
//            subtitle: Builder(
//              builder: (context) {
//                return Text(
//                  'Lebanon (USD \$)',
//                  style: cancelArabicFontDelta(context),
//                );
//              }
//            ),
//            trailing: Icon(getLocalizedForwardArrowIcon(context)),
//          ),
//          ListTile(
//            title: Text(
//                tUpper(context, 'notifications'),
//                style: accountTileStyle
//            ),
//            trailing: Builder(
//              builder: (context) {
//                return Switch(
//                  activeColor: MomdayColors.MomdayGold ,
//                  inactiveTrackColor: MomdayColors.MomdayGray,
//                  value: AppStateManager.of(context).notificationsEnabled,
//                  onChanged: (newValue) {
//                    AppStateManager.of(context).notificationsEnabled = newValue;
//                  },
//                );
//              },
//            ),
//          ),
          ListTile(
            title: Text(tUpper(context, 'advanced_settings'),
                style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AdvancedSettingsScreen()));
            },
          ),
          Container(
            height: 30.0,
            color: MomdayColors.MomdayGray,
          ),
          ListTile(
            title: Text(tUpper(context, 'privacy_policy'),
                style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
          ),
          ListTile(
            title: Text(tUpper(context, 'terms_of_service'),
                style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
          ),
          ListTile(
            title: Text(tUpper(context, 'faq'), style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
          ),
          ListTile(
            title: Text(tUpper(context, 'contact_us'), style: accountTileStyle),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
          ),
          Container(height: 30.0, color: MomdayColors.MomdayGray),
          Builder(
            builder: (context) {
              return ListTile(
                title:
                    Text(tUpper(context, 'log_out'), style: accountTileStyle),
                trailing: Icon(getLocalizedForwardArrowIcon(context)),
                onTap: () async {
                  var response = await AppStateManager.of(context).logout();

                  if (response == 'success') {
                    Navigator.of(context).pop();
                  } else {
                    showTextSnackBar(context, response);
                  }
                },
              );
            },
          ),
          Container(color: MomdayColors.MomdayGray),
        ],
      ),
    );
  }
}
