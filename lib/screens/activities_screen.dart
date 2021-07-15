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

class ActivitiesScreen extends StatelessWidget {
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
                title: tUpper(context, 'activities'),
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
            padding: const EdgeInsetsDirectional.only(top: 10.0, start: 10.0),
            sliver: _ActivitiesSummaries(),
          ),
        ],
      ),
    );
  }
}

class _ActivitiesSummaries extends StatelessWidget {
  static const int PAGE_SIZE = 10;

  _ActivitiesSummaries();

  @override
  Widget build(BuildContext context) {
    return PagewiseSliverList(
      pageSize: PAGE_SIZE,
      itemBuilder: this._summaryBuilder,
      pageFuture: this._pageFuture,
    );
  }

  Future<List<ActivitySummaryModel>> _pageFuture(pageIndex) async {
    final posts = await MomdayBackend()
        .getActivitiesSummaries(pageNumber: pageIndex, limit: PAGE_SIZE);

    return ActivitySummaryModel.fromDynamicList(posts);
  }

  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);

    String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  Widget _summaryBuilder(context, activity, index) {
    return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 8.0),
        child: MomdayCard(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 180.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DefaultTextStyle(
                              style: cancelArabicFontDelta(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: MomdayColors.MomdayGold,
                                  fontSize: 20.0),
                              child: Text(
                                activity.title,
                                maxLines: 1,
                                style: TextStyle(color: MomdayColors.MomdayGold),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final maxLines = (constraints.maxHeight /
                                          Theme.of(context)
                                              .textTheme
                                              .body1
                                              .fontSize)
                                      .floor();
                                  return DefaultTextStyle(
                                    maxLines: maxLines,
                                    style: cancelArabicFontDelta(context),
                                    child: Html(
                                      data: _parseHtmlString(
                                          activity.description),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: MomdayColors.NoteGray,
                              size: 18.0,
                            ),
                            Expanded(
                              child: DefaultTextStyle(
                                style: cancelArabicFontDelta(context),
                                child: Text(
                                  activity.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: MomdayColors.LocationGray),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                Column(
                  children: <Widget>[
                    MomdayNetworkImage(
                      imageUrl: activity.image,
                      height: 140.0,
                      width: 140.0,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 140.0,
                        child: RaisedButton(
                          color: Colors.black,
                          colorBrightness: Brightness.dark,
                          child: Text(
                            tTitle(context, 'view_details'),
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(fontSize: 12.0),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/activity/${activity.id}');
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
