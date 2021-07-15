import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';
import 'package:momday_app/widgets/momday_error/momday_error.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:momday_app/widgets/product_list/product_list.dart';
import 'package:momday_app/widgets/product_list/product_list_bloc.dart';

class CelebrityScreen extends StatelessWidget {
  final String celebrityId;

  CelebrityScreen({this.celebrityId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElegantMemoizedFutureBuilder(
            isFullPage: true,
            futureCallBack: () =>
                MomdayBackend().getCelebrity(this.celebrityId),
            contentBuilder: (_, data) {
              var celebrityInfo = CelebrityModel.fromDynamic(data['data']);
              if (celebrityInfo == null) return MomdayError();
              return ListView(
                primary: false,
                shrinkWrap: true,
                children: <Widget>[
                  celebrityInfo.fullName != null
                      ? PageHeader(
                          title: tTitle(context, 'home'),
                          title2: tTitle(context, 'celebrities'),
                          title3: celebrityInfo.fullName,
                        )
                      : Container(),
                  this._celebrityBasicInfo(_, celebrityInfo),
                  BlocProvider<ProductListBloc>(
                    bloc: ProductListBloc(celebrityId: this.celebrityId),
                    child: ProductList(
                      independentlyScrollable: false,
                      onProductTap: (productId) {
                        Navigator.of(context).pushNamed('/product/$productId');
                      },
                      type: "new",
                    ),
                  )
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _celebrityBasicInfo(BuildContext context, CelebrityModel celebrity) {
    return Column(
      children: [
        Container(
          color: MomdayColors.MomdayGold,
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            celebrity.portraitImage != null
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: AspectRatio(
                      aspectRatio: 0.674,
                      child: MomdayNetworkImage(
                        imageUrl: celebrity.portraitImage,
                      ),
                    ),
                  )
                : Container(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Image(
                    //   image: AssetImage('assets/images/two_lines.png'),
                    //   fit: BoxFit.fitHeight,
                    //   height: 16.0,
                    // ),
                    celebrity.fullName != null
                        ? Text(
                            celebrity.fullName.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20.0),
                          )
                        : Container()
                  ],
                ),
                celebrity.description != null
                    ? Container(
                        padding: EdgeInsets.all(8.0),
                        color: MomdayColors.MomdayGray,
                        width: MediaQuery.of(context).size.width * 0.88 * 0.6,
                        child: AspectRatio(
                          aspectRatio: 1.53,
                          child: SingleChildScrollView(
                            child: DefaultTextStyle(
                              style: cancelArabicFontDelta(context).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              child: Html(
                                data: celebrity.description,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            )
          ],
        ),
        Container(
          color: MomdayColors.MomdayGold,
          height: 10,
        ),
      ],
    );
  }
}
