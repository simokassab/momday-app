import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/options_screen/options_screen.dart';
import 'package:momday_app/screens/reviews_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/styles/momday_styles.dart';
import 'package:momday_app/widgets/carousel/carousel.dart';
import 'package:momday_app/widgets/celebrity_button/celebrity_button.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';
import 'package:momday_app/widgets/momday_error/momday_error.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:momday_app/widgets/product_list/product.dart';
import 'package:momday_app/widgets/product_basic_info/product_basic_info2.dart';
import 'package:momday_app/widgets/selected_category_header/selected_category_header.dart';
import 'package:momday_app/widgets/star_rating/star_rating.dart';
//import 'package:video_player/video_player.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  ProductScreen({this.productId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductModel product;

//  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        ElegantMemoizedFutureBuilder(
          isFullPage: true,
          futureCallBack: () =>
              MomdayBackend().getProduct(productId: widget.productId),
          contentBuilder: (context, data) {
            this.product = ProductModel.fromDynamic(data);
            if (this.product == null)
              return ListView(children: [
                PageHeader(
                  title: tUpper(context, 'error'),
                ),
                MomdayError()
              ]);

            return _buildProductPage(context, this.product);
          },
        ),
      ],
    );
  }

  Widget _buildProductPage(context, ProductModel productData) {
    final isCelebrity = AppStateManager.of(context).account.isCelebrity;

    if (productData.video != null &&
        productData.video != '' &&
        !productData.images.contains(productData.video))
      productData.images.add(productData.video);

    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: EdgeInsets.all(8.0),
      children: <Widget>[
        productData.categoryId != null && productData.categoryId != ''
            ? Builder(
                builder: (context) {
                  return PageHeader(
                    title: tTitle(context, "home"),
                    title2: tTitle(context, "products"),
                    title3: productData.name,
                    // selectedCategoryId: productData.categoryId,
                    // categories: AppStateManager.of(context).categories,
                  );
                },
              )
            : Container(),
        Container(
          padding: EdgeInsets.only(bottom: 8.0),
          foregroundDecoration: BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: max(200.0, MediaQuery.of(context).size.width
                    // * 0.5 + 10.0
                    ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: productData.images != null
                          ? Carousel(
                              indicatorBgPadding: 8.0,
                              imageHeight: MediaQuery.of(context).size.width
                                  // * 0.5
                                  -
                                  50.0,
                              aspectRatio: 1.0,
                              boxFit: BoxFit.fill,
                              images: (productData.images
                                ..insert(0, productData.image)),
                              video: productData.video,
                              onItemTap: (index) {
                                //if(productData.images[index] == productData.video)
                                //_displayAlert(productData.video, false);
                              },
                            )
                          : Container(),
                    ),
                    // SizedBox(
                    //   width: 10.0,
                    // ),
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left:8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    ProductBasicInfo2(
                      product: productData,
                    ),
//                          productData.preloved == 0?
//                          Text(
//                              tTitle(context, 'new_item'),
//                              style: MomdayStyles.hint
//                          ) :Text(
//                              tTitle(context, 'preloved_item'),
//                              textAlign: TextAlign.start,
//                              style: MomdayStyles.hint
//                          ),
//                          (productData.condition != null && productData.condition != '')?
//                          Text(
//                              productData.condition,
//                              textAlign: TextAlign.start,
//                              style: MomdayStyles.hint
//                          ):Container(),
                  ],
                ),
              ),
              isCelebrity
                  ? SizedBox(
                      height: 48.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: CelebrityButton(
                              productId: widget.productId,
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
//              SizedBox(height: 8.0),
//              productData.charityId != null && AppStateManager.of(context).findCharity(productData.charityId ) != null?
//              Container(
//                  padding: const EdgeInsetsDirectional.only(start: 8.0),
//                  margin: EdgeInsets.only(top:10),
//                  child:Text(
//                    tSentence(context, "donation_msg_buyer"),
//                    textAlign: TextAlign.start,
//                    style: TextStyle(
//                        color: MomdayColors.MomdayGold ,
//                        fontSize: 16.0
//                    ),
//                  )
//              ):Container(),
              productData.attributes != null &&
                      productData.attributes.length > 0
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(start: 8, top: 8),
                      child: Text(
                        tTitle(context, 'product_attributes'),
                        style: MomdayStyles.ThickMediumStyle,
                      ),
                    )
                  : Container(),
              productData.attributes != null &&
                      productData.attributes.length > 0
                  ? this._productAttributes(productData.attributes)
                  : Container(),
              OptionsScreen(
                product: this.product,
              ),
              SizedBox(
                height: 8,
              ),
              productData.description != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: Text(
                            tTitle(context, 'description'),
                            style: MomdayStyles.hint,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DefaultTextStyle(
                            style: cancelArabicFontDelta(context),
                            child: Html(
                              data: HtmlUnescape()
                                  .convert(productData.description),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
        productData.preloved == 0
            ? Container(
                margin: EdgeInsets.only(top: 8),
                child: Reviews(
                  reviews: productData.reviews,
                  rating: productData.rating,
                  totalNumberOfReviews: productData.totalNumberOfReviews,
                  product: productData,
                ))
            : Container(),
        ElegantMemoizedFutureBuilder(
          loadingHeight: 100.0,
          fullError: false,
          futureCallBack: () => MomdayBackend()
              .getRelatedProducts(productId: productData.productId),
          contentBuilder: (context, data) {
            var relatedProducts = ProductModel.fromDynamicList(data);

            if (relatedProducts == null || relatedProducts.length == 0) {
              return Container();
            }

            List<Product> relatedGrid = [];
            for (int i = 0; i < relatedProducts.length; i++) {
              relatedGrid.add(Product(
                product: relatedProducts[i],
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/product/${relatedProducts[i].productId}');
                },
                index: i,
              ));
            }
            return Column(
              children: <Widget>[
                SizedBox(height: 8.0),
                Text(
                  tTitle(context, 'related_items'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: MomdayColors.MomdayGold,
                      fontWeight: FontWeight.w600,
                      fontSize: 30.0),
                ),
                SizedBox(
                  height: 8.0,
                ),
                GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 8.0),
                  crossAxisCount: 2,
                  childAspectRatio: 0.555,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  children: relatedGrid,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _productAttributes(productAttributes) {
    List<Widget> attributes = [];
    for (String attribute in productAttributes) {
      attributes.add(Text(attribute, style: MomdayStyles.hint));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: attributes,
      ),
    );
  }
//
//  Widget displayVideoAlert(){
//
//    return Container(
//      child:Center(
//          child:
//          videoController == null?
//          Text(
//              t(context, "loading_video")
//          )
//              :VideoPlayer(videoController)
//      ),
//      width: 300,
//      height: 300,
//    );
//  }
//
//  void _displayAlert(videoFile, bool playing) async {
//
//    showDialog<void>(
//      barrierDismissible: false,
//      context: context,
//      builder: (BuildContext alertContext) {
//        return AlertDialog(
//          content: displayVideoAlert(),
//          actions: <Widget>[
//            videoController != null ? FlatButton(
//              child: Text(tUpper(context, "close")),
//              onPressed: () {
//
//                if(playing && videoController != null) {
//                  videoController.pause();
//                  videoController = null;
//                  videoPlayerListener = null;
//                  Navigator.of(alertContext).pop();
//                }
//                Navigator.of(alertContext).pop();
//              },
//            ):Container()
//          ],
//        );
//      },
//    );
//
//    if(videoController == null)
//      await _startVideoPlayer(videoFile);
//  }
//
//  Future<void> _startVideoPlayer(videoFile) async {
//
//    videoController = VideoPlayerController.network(videoFile);
//
//    videoPlayerListener = () {
//      if (videoController != null && videoController.value.size != null) {
//        videoController.removeListener(videoPlayerListener);
//      }
//    };
//
//    videoController.addListener(videoPlayerListener);
//    await videoController.setLooping(true);
//    await videoController.initialize();
//
//    if (mounted) {
//      setState(() {
//
//      });
//    }
//
//    _displayAlert(videoFile, true);
//    await videoController.play();
//  }

  @override
  void deactivate() {
//    if(videoController != null) {
//      videoController.pause();
//      videoController = null;
//      videoPlayerListener = null;
//    }
    super.deactivate();
  }
}

class Reviews extends StatelessWidget {
  final int totalNumberOfReviews;
  final List<ReviewModel> reviews;
  final double rating;
  final ProductModel product;

  Reviews({this.reviews, this.totalNumberOfReviews, this.rating, this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.1),
      ),
      child: ListView(
          primary: false,
          shrinkWrap: true,
          children: [
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tTitle(context, 'customer_reviews'),
                    style: MomdayStyles.LightSubtitle,
                  ),
                  SizedBox(height: 2.0),
                  this.totalNumberOfReviews != null
                      ? Text(
                          tCount(context, 'review', this.totalNumberOfReviews),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12.0),
                        )
                      : Container(),
                ],
              ),
              subtitle: Row(
                children: <Widget>[
                  StarRating(
                    rating: this.rating,
                    readOnly: true,
                    color: Colors.black,
                  ),
                ],
              ),
              trailing: Icon(getLocalizedForwardArrowIcon(context)),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ReviewsScreen(
                    product: this.product,
                  );
                }));
              },
            ),
          ]
            ..addAll(this._getReviewsBoxChildren(context))
            ..addAll([
              Divider(),
              ListTile(
                title: Text(
                  tTitle(context, 'add_your_review'),
                  style: MomdayStyles.LightSubtitle,
                ),
                trailing: Icon(getLocalizedForwardArrowIcon(context)),
                onTap: () {
                  if (!AppStateManager.of(context).account.isLoggedIn) {
                    askForLogin(context, 'add_your_review');
                  } else {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ReviewsScreen(
                        product: this.product,
                        mode: ReviewMode.Write,
                      );
                    }));
                  }
                },
              )
            ])),
    );
  }

  List<Widget> _getReviewsBoxChildren(BuildContext context) {
    List<Widget> children = [];

    if (this.reviews.length > 0) {
      children.add(Divider());
      children.addAll(this.reviews.expand<Widget>((review) {
        return [
          ListTile(
            title: review.text != null
                ? Text(
                    review.text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: cancelArabicFontDelta(context),
                  )
                : Container(),
            trailing: Icon(getLocalizedForwardArrowIcon(context)),
            subtitle: Row(
              children: <Widget>[
                review.author != null
                    ? Text(
                        '- ' + review.author,
                        style: TextStyle(height: 1.5),
                      )
                    : Container(),
                review.rating != null
                    ? StarRating(
                        iconSize: 16.0,
                        readOnly: true,
                        rating: review.rating.toDouble())
                    : Container(),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ReviewsScreen(
                  product: this.product,
                  mode: ReviewMode.ViewOne,
                  currentReview: review,
                );
              }));
            },
          ),
          review != this.reviews.last ? Divider() : Container()
        ];
      }).toList());
    }

    return children;
  }
}
