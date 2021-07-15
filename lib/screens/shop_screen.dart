import 'package:flutter/material.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/widgets/featured/featured.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class ShopScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PageHeader(
                title: tTitle(context, 'featured_items'),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.0,),
                    Featured(),
                    SizedBox(height: 30.0),
                    Row (
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        this._actionButton(context, 'new'),
                        SizedBox(width: 8.0,),
                        this._actionButton(context, 'preloved')
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String type) {
    return Expanded (
        child: FlatButton (
          padding: EdgeInsets.symmetric(vertical: 8.0),
          color: MomdayColors.MomdayGray,
          child: Column(
            verticalDirection: Localizations.localeOf(context).languageCode == 'ar'? VerticalDirection.up : VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                tTitle(context, type),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 30.0
                ),
              ),
              Text(
                tTitle(context, 'items'),
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 30.0
                ),
              )
            ],
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/category-listing/$type');
          },
        )
    );
  }
}