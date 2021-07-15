import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class MomsayAuthorBio extends StatelessWidget {
  final MomsayAuthorModel author;

  MomsayAuthorBio({this.author});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              PageHeader(
                title: tUpper(context, 'momsay'),
              ),
              SizedBox(
                height: 24.0,
              ),
              CircleAvatar(
                backgroundImage:
//                this.author.image != null ? CachedNetworkImageProvider(this.author.image):
                    AssetImage("assets/images/no_image_author.png"),
                backgroundColor: MomdayColors.MomdayGray,
                radius: 40.0,
              ),
              SizedBox(
                height: 12.0,
              ),
              author.name != null
                  ? Text(
                      this.author.name.toUpperCase(),
                      style: TextStyle(
                          color: MomdayColors.MomdayGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    )
                  : Container(),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/two_lines.png'),
                          fit: BoxFit.fitHeight,
                          height: 16.0,
                        ),
                        Text(tUpper(context, 'biography'),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16.0)),
                      ],
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Container(height: 1.0, color: MomdayColors.MomdayGold),
                    SizedBox(
                      height: 12.0,
                    ),
                    author.biography != null
                        ? DefaultTextStyle(
                            style: cancelArabicFontDelta(context),
                            child: Html(data: author.biography),
                          )
                        : Container()
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
