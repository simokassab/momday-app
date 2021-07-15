import 'package:flutter/material.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/styles/momday_colors.dart';
import '../../screens/main_screen.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String title2;
  final String title3;
  final Widget widgetTitle;
  final PopupMenuButton menuButton;

  PageHeader(
      {this.title,
      this.title2,
      this.title3,
      this.widgetTitle,
      this.menuButton});

  @override
  Widget build(BuildContext context) {
    var title = this.title != null
        ? Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  MainScreen.of(context).navigateToTab(
                    0,
                  );
                },
                child: Text(
                  tTitle(context, 'home'),
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "VAG",
                      fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                Icons.clear_rounded,
                color: MomdayColors.MomdayDarkBlue,
              ),
              Text(
                this.title,
                // textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: "VAG",
                    fontWeight: FontWeight.w500),
              ),
            ],
          )
        : widgetTitle;

    var title2 = this.title2 != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                this.title,
                // textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display3,
              ),
              Text(
                this.title2,
                // textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display3,
              ),
            ],
          )
        : widgetTitle;
    var title3 = this.title3 != null
        ? SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    MainScreen.of(context).navigateToTab(
                      0,
                    );
                  },
                  child: Text(
                    this.title,
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontFamily: "VAG",
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(
                  Icons.clear_rounded,
                  color: MomdayColors.MomdayDarkBlue,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    this.title2,
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontFamily: "VAG",
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(
                  Icons.clear_rounded,
                  color: MomdayColors.MomdayRed,
                ),
                Text(
                  this.title3,
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "VAG",
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
        )
        : widgetTitle;

    return Container(
      decoration: BoxDecoration(
          // color: MomdayColors.MomdayGray,
          ),
      child: Stack(
        children: <Widget>[
          Navigator.of(context).canPop()
              ? Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        getLocalizedBackwardArrowIcon(context),
                        size: 24.0,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: this.title3 != null
                ? title3
                : this.title2 != null
                    ? title2
                    : title,
          ),
          menuButton != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [menuButton])
              : Container(),
        ],
      ),
    );
  }
}

class PageHeader2 extends StatelessWidget {
  final String title;

  PageHeader2({this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: MomdayColors.MomdayGold, width: 3.0))),
      child: Stack(
        children: <Widget>[
          Navigator.of(context).canPop()
              ? Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        getLocalizedBackwardArrowIcon(context),
                        size: 24.0,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
