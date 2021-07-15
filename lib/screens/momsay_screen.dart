import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/featured/featured.dart';
import 'package:momday_app/widgets/momday_card/momday_card.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:html/parser.dart';

class MomsayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).padding,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: MainScreen.of(context).getMomdayBar()),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverToBoxAdapter(
              child: PageHeader(
                title: tUpper(context, 'momsay'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Text(
                    tTitle(context, 'featured_items'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Featured(
                    hasOverlay: true,
                    height: 0.5,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0),
            sliver: _MomsaySummaries(),
          ),
        ],
      ),
    );
  }
}

class _MomsaySummaries extends StatelessWidget {
  static const int PAGE_SIZE = 10;

  _MomsaySummaries();

  @override
  Widget build(BuildContext context) {
    return PagewiseSliverList(
      pageSize: PAGE_SIZE,
      itemBuilder: this._summaryBuilder,
      pageFuture: this._pageFuture,
    );
  }

  Future<List<MomsayPostSummaryModel>> _pageFuture(pageIndex) async {
    final posts = await MomdayBackend()
        .getMomsayPostSummaries(pageNumber: pageIndex, limit: PAGE_SIZE);

    return MomsayPostSummaryModel.fromDynamicList(posts);
  }

  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);

    String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  Widget _summaryBuilder(context, summary, index) {
    return Padding(
        padding: EdgeInsetsDirectional.only(bottom: 8.0),
        child: MomdayCard(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/no_image_author.png"),
//                        backgroundImage: CachedNetworkImageProvider(summary.author.image),
                          backgroundColor: MomdayColors.MomdayGray,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        summary.author.name != null
                            ? Text(
                                summary.author.name.toUpperCase(),
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: MomdayColors.MomdayGold,
                                    fontSize: 20.0),
                              )
                            : Container()
                      ],
                    ),
                    Text(
                      convertDateToUserFriendly(summary.date,
                          Localizations.localeOf(context).languageCode),
                      textAlign: TextAlign.end,
                      style: cancelArabicFontDelta(context).copyWith(
                        color: MomdayColors.NoteGray,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                SizedBox(
                  height: 140.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    summary.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2.0,
                                  ),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final maxLines =
                                            (constraints.maxHeight /
                                                    Theme.of(context)
                                                        .textTheme
                                                        .body1
                                                        .fontSize)
                                                .floor();
                                        return DefaultTextStyle(
                                          style: cancelArabicFontDelta(context),
                                          maxLines: maxLines,
                                          child: Html(
                                            data: _parseHtmlString(
                                                summary.description),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 8.0),
                              child: Container(
                                height: 1.0,
                                color: MomdayColors.MomdayGray,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      MomdayNetworkImage(
                        imageUrl: summary.image,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Icon(
                          Icons.thumb_up,
                          color: MomdayColors.MomdayGray,
                        ),
                        Text(
                          convertNumberToUserFriendly(summary.likes,
                              Localizations.localeOf(context).languageCode),
                          style: TextStyle(
                              fontSize: 8.0, color: MomdayColors.NoteGray),
                        )
                      ],
                    ),
                    RaisedButton(
                      color: Colors.black,
                      colorBrightness: Brightness.dark,
                      child: Text(
                        tTitle(context, 'read_full_article'),
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(fontSize: 12.0),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/momsay-post/${summary.id}');
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
