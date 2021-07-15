import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/activity_screen/activity_bloc.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/elegant_stream_builder/elegant_stream_builder.dart';
import 'package:momday_app/widgets/momday_card/momday_card.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityScreen extends StatefulWidget {
  final String activityId;

  ActivityScreen({this.activityId});

  @override
  ActivityScreenState createState() {
    return new ActivityScreenState();
  }
}

class ActivityScreenState extends State<ActivityScreen> {
  ActivityBloc _bloc;

  @override
  void initState() {
    super.initState();
    this._bloc = ActivityBloc(activityId: widget.activityId);
    this._bloc.init();
  }

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
                title: tUpper(context, 'activities'),
              ),
              SizedBox(height: 24.0),
              BlocProvider(
                bloc: this._bloc,
                child: _Activity(),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _Activity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElegantStreamBuilder<ActivityModel>(
      loadingHeight: MediaQuery.of(context).size.height * 0.8,
      stream: BlocProvider.of<ActivityBloc>(context).dataStream,
      contentBuilder: (context, activityData) {
        return Column(
          children: <Widget>[
            MomdayCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          activityData.title,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: MomdayColors.MomdayGold),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          tUpper(context, 'description'),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        DefaultTextStyle(
                          style: cancelArabicFontDelta(context),
                          child: Html(
                              data: activityData.description,
                              onLinkTap: (link) {
                                Navigator.of(context, rootNavigator: true)
                                    .push(MaterialPageRoute(
                                        builder: (_) => WebviewScaffold(
                                              url: link,
                                              appBar: AppBar(
                                                backgroundColor: Colors.white,
                                                iconTheme: IconThemeData(
                                                    color: MomdayColors
                                                        .Momdaypink),
                                              ),
                                            )));
                              }),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: MomdayColors.ActivityContact,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          tTitle(context, 'contact_us'),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          textBaseline: TextBaseline.ideographic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 16.0,
                            ),
                            LimitedBox(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                activityData.location,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            activityData.phone != null
                                ? _getContactButton(context, Icons.phone,
                                    'tel:///${activityData.phone}')
                                : Container(),
                            activityData.email != null
                                ? _getContactButton(context, Icons.mail_outline,
                                    'mailto:${activityData.email}')
                                : Container(),
                            activityData.website != null
                                ? _getContactButton(context, Icons.language,
                                    activityData.website, true)
                                : Container()
                          ],
                        )
                      ],
                    ),
                  )
                ])),
          ],
        );
      },
    );
  }

  Widget _getContactButton(BuildContext context, IconData icon, String url,
      [bool isWeb = false]) {
    return RawMaterialButton(
      onPressed: () async {
        if (isWeb) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WebviewScaffold(
                    url: url,
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: MomdayColors.MomdayGold),
                    ),
                  )));
          return;
        }

        if (await canLaunch(url)) launch(url);
      },
      child: Icon(
        icon,
        size: 28.0,
      ),
      shape: CircleBorder(
          side: BorderSide(
        width: 1,
      )),
      padding: const EdgeInsets.all(12.0),
      fillColor: Colors.transparent,
      elevation: 0.0,
    );
  }
}
