import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/home_screen/home_screen_bloc.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/carousel/carousel.dart';
import 'package:momday_app/widgets/elegant_stream_builder/elegant_stream_builder.dart';
import 'package:momday_app/widgets/featured/featured.dart';
import 'package:momday_app/widgets/momday_card/momday_card.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';

import '../../styles/momday_colors.dart';

class _HomeUtils {
  static getSectionHeader({title, actionName, action}) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/two_lines.png'),
                  fit: BoxFit.fitHeight,
                  height: 16.0,
                ),
                Text(title,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0))
              ],
            ),
            InkWell(
              onTap: action,
              child: Text(
                actionName,
                style: TextStyle(
                    fontSize: 12.0,
                    color: MomdayColors.MomdayGold,
                    fontWeight: FontWeight.w300),
              ),
            )
          ],
        ),
        SizedBox(
          height: 2.0,
        ),
        Container(height: 2.0, color: MomdayColors.MomdayGold)
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final _bloc = HomeBloc();

  @override
  Widget build(BuildContext context) {
    this._bloc.init();
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocProvider<HomeBloc>(
            bloc: this._bloc,
            child: _HomeContent(),
          ),
        )
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElegantStreamBuilder(
      loadingHeight: MediaQuery.of(context).size.height * 0.8,
      stream: BlocProvider.of<HomeBloc>(context).dataStream,
      contentBuilder: (context, homeData) {
        return Column(
          children: <Widget>[
            Container(
              color: MomdayColors.MomdayGold,
              height: 10,
            ),
            SizedBox(
              height: 8.0,
            ),
            _FeaturedProducts(),
            SizedBox(
              height: 32.0,
            ),
            _FeaturedCelebrities(),
//            SizedBox(height: 32.0,),
//            _Activities(),
            SizedBox(
              height: 32.0,
            ),
            _FeaturedBrands(),
            SizedBox(
              height: 32.0,
            ),
            _FeaturedMomsayPosts()
          ],
        );
      },
    );
  }
}

class _Activities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          MainScreen.of(context).navigateToTab(3);
        },
        child: Stack(
          children: <Widget>[
            Image.asset('assets/images/activities.png'),
            Positioned(
              bottom: 0,
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  tUpper(context, 'activities'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MomdayColors.MomdayGold,
                      fontSize: 36.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FeaturedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return Material(
      elevation: 1.0,
      child: Featured(
        featuredProducts: bloc.homeData.featuredProducts,
        hasOverlay: true,
        indicatorPosition: IndicatorPosition.Inside,
        midAnnouncement: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FittedBox(
                child: Text(
                  tUpper(context, 'moms_best_daily_kit'),
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: MomdayColors.MomdayDarkBlue),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  tSentence(context, 'momday_description'),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontSize: 14.0, color: MomdayColors.MomdayDarkBlue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedBrands extends StatelessWidget {
  _FeaturedBrands();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final aspectRatio = 820.504 / 645.313;
      final height = width / aspectRatio;
      // sizes of photos
      final widthCenterTop = width * 0.5;
      final heightCenterTop = width * 0.5;
      final widthLeft = width * 0.5;
      final heightLeft = width * 0.5;
      final widthCenterBottom = width * 0.5;
      final heightCenterBottom = width * 0.5;
      final widthRight = width * 0.5;
      final heightRight = width * 0.5;
      // padding between photos
      final horizontalPadding = width * 0.0097501048136267; //padding of 8 pixel
      final verticalPadding = height * 0.0123970848255033; //padding of 8 pixel
      //Sizes of the Black Box with opacity
      final widthBlackBoxWithOp = width * 0.6118190770550783;
      final heightBlackBoxWithOp = height * 0.2401935184941261;
      //Sizes of the DoubleLines Picture
      final widthDoubleLinesPic = width * 0.0755633123056073;
      final heightDoubleLinesPic = height * 0.0712832377466439;
      final language = Localizations.localeOf(context).languageCode;

      //Padding
      final verticalPadOfTheBlackBox = height * 0.3244936953075484;
      final horizontalPaddOfTheBlackBox = width * 0.1943927147216833;
      final horizontalPaddOfTheDoubleLinesPic =
          width * 0.2132835427980851; //0.3193159326462759 or 0.2132835427980851
      final verticalPaddOfTheDoubleLinesPic =
          heightCenterTop - heightDoubleLinesPic;
      //Responsive Font Sizes
      final celebritiesFontSize = height * 0.0790314157625834;
      final viewallFontSize = height * 0.0480387036988252;
      final celebritiesWord = PositionedDirectional(
        child: InkWell(
          onTap: () => this._navigateToBrands(context),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/xbackground3.png"),
                fit: BoxFit.cover,
              ),
            ),
            width: width,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                tUpper(context, 'brands'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: celebritiesFontSize),
              ),
            ),
          ),
        ),
        start: 0, //set start and end to 0 to center
        end: 0,
        top: verticalPaddOfTheDoubleLinesPic -
            (language == 'ar' ? verticalPadding : 0.0),
      );

      final bloc = BlocProvider.of<HomeBloc>(context);
      List<dynamic> brands = bloc.homeData.featuredBrands;

      if (brands == null) brands = [];

      brands.shuffle();

      if (brands.length >= 3) brands = brands.sublist(0, 3);

      final images = brands
          .map((brand) => InkWell(
                onTap: () {
                  MainScreen.of(context).navigateToTab(
                      2, '/product-listing?brandId=${brand.brandId}');
                },
                child: MomdayNetworkImage(
                  imageUrl: brand.image,
                ),
              ))
          .toList();

      return Column(
        children: <Widget>[
          // _HomeUtils.getSectionHeader(
          //     title: tUpper(context, 'brands'),
          //     actionName: tUpper(context, 'shop_now'),
          //     action: () {
          //       MainScreen.of(context).navigateToTab(2, '/product-listing/');
          //     }),
          celebritiesWord,
          SizedBox(height: 8.0),
          GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              primary: false,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              children: images),
        ],
      );
    });
  }

  _navigateToBrands(context) {
    MainScreen.of(context).navigateToTab(
      2,
    );
  }
}

class _FeaturedMomsayPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final aspectRatio = 820.504 / 645.313;
      final height = width / aspectRatio;
      // sizes of photos
      final widthCenterTop = width * 0.5;
      final heightCenterTop = width * 0.5;
      final widthLeft = width * 0.5;
      final heightLeft = width * 0.5;
      final widthCenterBottom = width * 0.5;
      final heightCenterBottom = width * 0.5;
      final widthRight = width * 0.5;
      final heightRight = width * 0.5;
      // padding between photos
      final horizontalPadding = width * 0.0097501048136267; //padding of 8 pixel
      final verticalPadding = height * 0.0123970848255033; //padding of 8 pixel
      //Sizes of the Black Box with opacity
      final widthBlackBoxWithOp = width * 0.6118190770550783;
      final heightBlackBoxWithOp = height * 0.2401935184941261;
      //Sizes of the DoubleLines Picture
      final widthDoubleLinesPic = width * 0.0755633123056073;
      final heightDoubleLinesPic = height * 0.0712832377466439;

      //Padding
      final verticalPadOfTheBlackBox = height * 0.3244936953075484;
      final horizontalPaddOfTheBlackBox = width * 0.1943927147216833;
      final horizontalPaddOfTheDoubleLinesPic =
          width * 0.2132835427980851; //0.3193159326462759 or 0.2132835427980851
      final verticalPaddOfTheDoubleLinesPic =
          heightCenterTop - heightDoubleLinesPic;
      //Responsive Font Sizes
      final celebritiesFontSize = height * 0.0790314157625834;
      final viewallFontSize = height * 0.0480387036988252;
      final bloc = BlocProvider.of<HomeBloc>(context);
      final language = Localizations.localeOf(context).languageCode;

      final posts = bloc.homeData.featuredMomsayPosts;
      List<Widget> postWidgets = [];

      if (posts != null && posts.length > 0) {
        postWidgets = posts
            .map((post) => MomdayCard(
                  child: SizedBox(
                    height: 80.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 8.0,
                        ),
                        CircleAvatar(
                          backgroundImage:
// post.author.image == null ?
                              AssetImage("assets/images/no_image_author.png"),
//                        : CachedNetworkImageProvider(post.author.image),
                          backgroundColor: MomdayColors.MomdayGray,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              post.author.name != null
                                  ? Text(
                                      post.author.name.toUpperCase(),
                                      style: cancelArabicFontDelta(context)
                                          .copyWith(
                                              color: MomdayColors.MomdayRed,
                                              fontWeight: FontWeight.bold),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(post.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: cancelArabicFontDelta(context)
                                      .copyWith(fontWeight: FontWeight.w600))
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 8.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                convertDateToUserFriendly(
                                    post.date,
                                    Localizations.localeOf(context)
                                        .languageCode),
                                textAlign: TextAlign.end,
                                style: cancelArabicFontDelta(context).copyWith(
                                  color: MomdayColors.NoteGray,
                                ),
                              ),
                            ),
                            FlatButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                color: Colors.black,
                                colorBrightness: Brightness.dark,
                                onPressed: () {
                                  MainScreen.of(context).navigateToTab(
                                      4, '/momsay-post/${post.id}');
                                },
                                child: Text(
                                  tTitle(context, 'view_more'),
                                  style: TextStyle(fontSize: 12.0),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
            .toList();
      }
      final celebritiesWord = PositionedDirectional(
        child: InkWell(
          onTap: () => this._navigateToMomSay(context),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/xbackground2.png"),
                fit: BoxFit.cover,
              ),
            ),
            width: width,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                tUpper(context, 'momsay'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: celebritiesFontSize),
              ),
            ),
          ),
        ),
        start: 0, //set start and end to 0 to center
        end: 0,
        top: verticalPaddOfTheDoubleLinesPic -
            (language == 'ar' ? verticalPadding : 0.0),
      );
      return Column(
        children: <Widget>[
          celebritiesWord,
          // _HomeUtils.getSectionHeader(
          //     title: tUpper(context, 'momsay'),
          //     actionName: tUpper(context, 'view_all'),
          //     action: () {
          //       MainScreen.of(context).navigateToTab(4, '/momsay');
          //     }),

          SizedBox(
            height: 8.0,
          ),
          postWidgets.length > 0 ? Column(children: postWidgets) : Container(),
        ],
      );
    });
  }

  _navigateToMomSay(context) {
    MainScreen.of(context).navigateToTab(
      5,
    );
  }
}

class _FeaturedCelebrities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);
    List<CelebrityModel> featuredCelebrities =
        bloc.homeData.featuredCelebrities;

    if (featuredCelebrities != null)
      featuredCelebrities.shuffle();
    else
      featuredCelebrities = [];

    final language = Localizations.localeOf(context).languageCode;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final aspectRatio = 820.504 / 645.313;
      final height = width / aspectRatio;
      // sizes of photos
      final widthCenterTop = width * 0.5;
      final heightCenterTop = width * 0.5;
      final widthLeft = width * 0.5;
      final heightLeft = width * 0.5;
      final widthCenterBottom = width * 0.5;
      final heightCenterBottom = width * 0.5;
      final widthRight = width * 0.5;
      final heightRight = width * 0.5;
      // padding between photos
      final horizontalPadding = width * 0.0097501048136267; //padding of 8 pixel
      final verticalPadding = height * 0.0123970848255033; //padding of 8 pixel
      //Sizes of the Black Box with opacity
      final widthBlackBoxWithOp = width * 0.6118190770550783;
      final heightBlackBoxWithOp = height * 0.2401935184941261;
      //Sizes of the DoubleLines Picture
      final widthDoubleLinesPic = width * 0.0755633123056073;
      final heightDoubleLinesPic = height * 0.0712832377466439;

      //Padding
      final verticalPadOfTheBlackBox = height * 0.3244936953075484;
      final horizontalPaddOfTheBlackBox = width * 0.1943927147216833;
      final horizontalPaddOfTheDoubleLinesPic =
          width * 0.2132835427980851; //0.3193159326462759 or 0.2132835427980851
      final verticalPaddOfTheDoubleLinesPic =
          heightCenterTop - heightDoubleLinesPic;
      //Responsive Font Sizes
      final celebritiesFontSize = height * 0.0790314157625834;
      final viewallFontSize = height * 0.0480387036988252;

      final topCelebrity = PositionedDirectional(
        child: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => featuredCelebrities.length > 0
                    ? this._navigateToCelebrity(
                        context, featuredCelebrities[0].celebrityId)
                    : null,
                child: featuredCelebrities.length > 0
                    ? MomdayNetworkImage(
                        imageUrl: featuredCelebrities[0].squareImage,
                        width: widthCenterTop,
                        height: heightCenterTop,
                        color: Colors.grey,
                        colorBlendMode: BlendMode.color,
                      )
                    : Image(
                        height: heightCenterTop,
                        width: widthCenterTop,
                        image: AssetImage("assets/images/no_celebrity.png")),
              ),
              featuredCelebrities.length > 0
                  ? Container(
                      width: widthRight,
                      color: MomdayColors.LinkBlue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            featuredCelebrities[0].fullName.toUpperCase(),
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        start: widthLeft + horizontalPadding,
      );

      final leftCelebrity = PositionedDirectional(
        child: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => featuredCelebrities.length > 1
                    ? this._navigateToCelebrity(
                        context, featuredCelebrities[1].celebrityId)
                    : null,
                child: Container(
                  child: featuredCelebrities.length > 1
                      ? MomdayNetworkImage(
                          imageUrl: featuredCelebrities[1].squareImage,
                          width: widthLeft,
                          height: heightLeft,
                          color: Colors.grey,
                          colorBlendMode: BlendMode.color,
                        )
                      : Image(
                          height: heightLeft,
                          width: widthLeft,
                          image: AssetImage("assets/images/no_celebrity.png")),
                  foregroundDecoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.screen,
                    color: MomdayColors.MomdayGold.withOpacity(0.7),
                  ),
                ),
              ),
              featuredCelebrities.length > 1
                  ? Container(
                      width: widthRight,
                      color: MomdayColors.MomdayGold,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            featuredCelebrities[1].fullName.toUpperCase(),
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        top: heightCenterTop / 2,
      );

      final bottomCelebrity = PositionedDirectional(
        child: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => featuredCelebrities.length > 2
                    ? this._navigateToCelebrity(
                        context, featuredCelebrities[2].celebrityId)
                    : null,
                child: featuredCelebrities.length > 2
                    ? MomdayNetworkImage(
                        imageUrl: featuredCelebrities[2].portraitImage,
                        width: widthCenterBottom,
                        height: heightCenterBottom,
                        color: Colors.grey,
                        colorBlendMode: BlendMode.color,
                      )
                    : Image(
                        height: heightCenterBottom,
                        width: widthCenterBottom,
                        image: AssetImage("assets/images/no_celebrity.png")),
              ),
              featuredCelebrities.length > 2
                  ? Container(
                      width: widthRight,
                      color: MomdayColors.MomdayDarkGreen,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            featuredCelebrities[2].fullName.toUpperCase(),
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        start: widthLeft + horizontalPadding,
        top: heightCenterTop + verticalPadding,
      );

      final rightCelebrity = PositionedDirectional(
        child: Container(
          child: Material(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => featuredCelebrities.length > 3
                      ? this._navigateToCelebrity(
                          context, featuredCelebrities[3].celebrityId)
                      : null,
                  child: featuredCelebrities.length > 3
                      ? MomdayNetworkImage(
                          imageUrl: featuredCelebrities[3].squareImage,
                          width: widthRight,
                          height: heightRight,
                          color: Colors.grey,
                          colorBlendMode: BlendMode.color,
                        )
                      : Image(
                          height: heightRight,
                          width: widthRight,
                          image: AssetImage("assets/images/no_celebrity.png")),
                ),
                featuredCelebrities.length > 3
                    ? Container(
                        width: widthRight,
                        color: MomdayColors.GoogleRed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              featuredCelebrities[3].fullName.toUpperCase(),
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          foregroundDecoration: BoxDecoration(
            backgroundBlendMode: BlendMode.screen,
            color: MomdayColors.MomdayGold.withOpacity(0.7),
          ),
        ),
        top: heightCenterTop + verticalPadding,
        start: widthLeft + widthCenterBottom + horizontalPadding * 2,
      );

      final blackBox = PositionedDirectional(
        child: InkWell(
          onTap: () => this._navigateToCelebrities(context),
          child: Container(
            width: widthBlackBoxWithOp,
            height: heightBlackBoxWithOp,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        top: verticalPadOfTheBlackBox,
        start: horizontalPaddOfTheBlackBox,
      );

      final twoGoldLines = PositionedDirectional(
        child: Image.asset(
          'assets/images/two_lines.png',
          width: widthDoubleLinesPic,
          height: heightDoubleLinesPic,
        ),
        start: horizontalPaddOfTheDoubleLinesPic,
        top: verticalPaddOfTheDoubleLinesPic,
      );

      final celebritiesWord = PositionedDirectional(
        child: InkWell(
          onTap: () => this._navigateToCelebrities(context),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/xbackground4.png"),
                fit: BoxFit.cover,
              ),
            ),
            width: width,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                tUpper(context, 'celebrities'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: celebritiesFontSize),
              ),
            ),
          ),
        ),
        start: 0, //set start and end to 0 to center
        end: 0,
        top: verticalPaddOfTheDoubleLinesPic -
            (language == 'ar' ? verticalPadding : 0.0),
      );

      final horizontalGoldLine = PositionedDirectional(
        child: Container(
          width: width * 0.571599894698868,
          height: height * 0.0082130686968959,
          decoration: BoxDecoration(color: MomdayColors.MomdayGold),
        ),
        start: horizontalPaddOfTheDoubleLinesPic,
        top: height * 0.4706243326881684,
      );

      final viewAllWord = PositionedDirectional(
        child: InkWell(
          onTap: () => this._navigateToCelebrities(context),
          child: Container(
            child: Text(
              tUpper(context, 'view_all'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: viewallFontSize),
            ),
          ),
        ),
        start: 0,
        end: 0,
        top: height * 0.4957284294598125 -
            (language == 'ar' ? verticalPadding : 0.0),
      );

      return Container(
        width: width,
        child: Column(
          children: [
            celebritiesWord,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftCelebrity,
                rightCelebrity,
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topCelebrity,
                bottomCelebrity,
              ],
            ),
            // horizontalGoldLine,
            // Stack(
            //   children: <Widget>[
            //     topCelebrity,
            //     leftCelebrity,
            //     bottomCelebrity,
            //     rightCelebrity,
            //     blackBox,
            //     twoGoldLines,
            //     celebritiesWord,
            //     horizontalGoldLine,
            //     viewAllWord,
            //   ],
            // ),
          ],
        ),
      );
    });
  }

  _navigateToCelebrity(context, celebrityId) async {
    dynamic celeb = await MomdayBackend().getCelebrity(celebrityId);
    if (celeb["success"] != 1)
      _navigateToCelebrities(context);
    else
      MainScreen.of(context).navigateToTab(1, '/celebrity/$celebrityId');
  }

  _navigateToCelebrities(context) {
    MainScreen.of(context).navigateToTab(
      1,
    );
  }
}
