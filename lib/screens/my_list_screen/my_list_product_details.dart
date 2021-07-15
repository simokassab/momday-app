//import 'dart:math';
//
//import 'package:flutter/material.dart';
//import 'package:flutter_html/flutter_html.dart';
//import 'package:momday_app/app_state_manager.dart';
//import 'package:momday_app/backend_helpers/momday_backend.dart';
//import 'package:momday_app/models/models.dart';
//import 'package:momday_app/momday_localizations.dart';
//import 'package:momday_app/momday_utils.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager.dart';
//import 'package:momday_app/styles/momday_colors.dart';
//import 'package:momday_app/widgets/carousel/carousel.dart';
//import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';
//import 'package:momday_app/widgets/momday_error/momday_error.dart';
//import 'package:momday_app/widgets/page_header/page_header.dart';
////import 'package:video_player/video_player.dart';
//
//class MyListProductDetails extends StatefulWidget {
//
//  final String productId;
//
//  MyListProductDetails({this.productId});
//
//  @override
//  MyListProductDetailsState createState() {
//    return new MyListProductDetailsState();
//  }
//}
//
//class MyListProductDetailsState extends State<MyListProductDetails> {
//
//  List<BrandModel> brands;
//  List<CharityModel> charities;
//
//  MyListProductModel product;
////  VideoPlayerController videoController;
//
//  VoidCallback videoPlayerListener;
//
//  @override
//  Widget build(BuildContext context) {
//
//    return ElegantMemoizedFutureBuilder(
//          isFullPage: true,
//          futureCallBack: () =>
//              MomdayBackend().getMyListProduct(
//                  productId: widget.productId
//              ),
//          contentBuilder: (context, data) {
//            this.product = MyListProductModel.fromDynamic(data);
//            return ListView(
//                children: <Widget>[
//                  PageHeader(title: tUpper(context, 'my_list'), menuButton: setMenuButton()),
//                  this.product != null? myItemDetails(): MomdayError()
//                ]
//            );
//            },
//    );
//  }
//
//  setMenuButton(){
//
//    if(this.product == null || this.product.status == null)
//      return null;
//
//    List<PopupMenuItem<String>> items = [];
//
//    if (this.product.status != 'sold'){
//      items.add(
//          PopupMenuItem<String>(
//            value: tUpper(context, 'edit'),
//            child: Text(tUpper(context, 'edit')),
//          )
//      );
//    }
//
//    if(this.product.status == 'inactive' || this.product.status == 'rejected'){
//      items.add(
//          PopupMenuItem<String>(
//            value: tUpper(context, 'activate'),
//            child: Text(tUpper(context, 'activate')),
//          )
//      );
//    }
//
//    if (this.product.status == "pending" || this.product.status == "active"){
//      items.add(
//          PopupMenuItem<String>(
//            value: tUpper(context, 'deactivate'),
//            child: Text(tUpper(context, 'deactivate')),
//          )
//      );
//    }
//
//    items.add(
//        PopupMenuItem<String>(
//          value: tUpper(context, 'delete'),
//          child: Text(tUpper(context, 'delete')),
//        )
//    );
//
//    return PopupMenuButton<String>(
//      onSelected: (String item) {
//        if(item == tUpper(context, 'activate'))
//          this.editItem();
//        else if(item == tUpper(context, 'deactivate'))
//          this.alertDeactivate();
//        else if(item == tUpper(context, 'delete'))
//          this.alertDelete();
//        else if(item == tUpper(context, 'edit'))
//          this.editItem();
//      },
//      itemBuilder: (BuildContext context) => items,
//    );
//  }
//
//  editItem(){
//
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) =>
//                Container(
//                    color: Colors.white,
//                    child: MyListProductManager(product: this.product,)
//                )
//        )
//    );
//  }
//
//  alertDeactivate() {
//
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: new Text(tSentence(context, "deactivate_myitem")),
//          content: new Text(tSentence(context, "deactivate_myitem_confirm")),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text(tSentence(context, "deactivate")),
//              onPressed: () => deactivateProduct(context)
//            ),
//            new FlatButton(
//              child: new Text(tSentence(context, "cancel")),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            )
//          ],
//        );
//      },
//    );
//  }
//
//  deactivateProduct(alertContext) async{
//
//    dynamic response = await MomdayBackend().deactivateProduct(this.product.id);
//
//    if(response['success'] == 1) {
//      showTextSnackBar(context, 'item successfully deactivated');
//      Navigator.of(context).pop();
//      Navigator.of(context).pushNamed('/my-list');
//    }
//
//    else if(response['error'] != null) {
//      showTextSnackBar(context, response['error']);
//    }
//
//    else{
//      showTextSnackBar(context, 'error deactivating product');
//    }
//
//    Navigator.of(alertContext).pop();
//  }
//
//  alertDelete() {
//
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: new Text(tSentence(context, "delete_myitem")),
//          content: new Text(tSentence(context, "delete_myitem_confirm")),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text(tSentence(context, "delete")),
//              onPressed: () => deleteProduct(context)
//            ),
//            new FlatButton(
//              child: new Text(tSentence(context, "cancel")),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            )
//          ],
//        );
//      },
//    );
//  }
//
//  deleteProduct(alertContext) async{
//
//    dynamic response = await MomdayBackend().deleteProduct(this.product.id);
//
//    if(response['success'] == 1) {
//      showTextSnackBar(context, 'item successfully deleted');
//      Navigator.of(context).pop();
//      Navigator.of(context).pushNamed('/my-list');
//    }
//
//    else if(response['error'] != null) {
//      setState(() {
//        showTextSnackBar(context, response['error']);
//      });
//    }
//
//    else{
//      setState(() {
//        showTextSnackBar(context, 'error deleting product');
//      });
//    }
//
//    Navigator.of(alertContext).pop();
//
//  }
//  Widget myItemDetails() {
//
//    if(this.product.thumbnail != null && !this.product.images.contains(this.product.thumbnail))
//      this.product.images.add(this.product.thumbnail);
//
//    if(this.product.video != null && !this.product.images.contains(this.product.video))
//      this.product.images.add(this.product.video);
//
//    return Padding(
//      padding: const EdgeInsets.all(8.0),
//      child: Container(
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            children: <Widget>[
//              SizedBox(
//                height: max(200.0, MediaQuery.of(context).size.width * 0.5 + 8.0),
//                child: Row(
//                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: Carousel(
//                        indicatorBgPadding: 8.0,
//                        imageHeight: MediaQuery.of(context).size.width * 0.5 - 32.0,
//                        aspectRatio: 1.0,
//                        boxFit: BoxFit.fill,
//                        images: (this.product.images),
//                        video:this.product.video,
//                        onItemTap: (index) {
////                          if(this.product.images[index] == this.product.video)
////                            _displayAlert(this.product.video);
//                        },
//                      ),
//                    ),
//                    Expanded(
//                      child: Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Column(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            SizedBox(height: 0.1),  // just to prevent from stretching to the top
//                        Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: [
//                              Text(
//                                this.product.name,
//                                textAlign: TextAlign.start,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold,
//                                    color: Colors.black,
//                                    fontSize: 20.0
//                                ),
//                              ),
//                              Container(
//                                margin: EdgeInsets.only(top:10),
//                                child: Row(
//                                  children: <Widget>[
//                                    this.product.status != null?
//                                    Text(
//                                        tSentence(context, this.product.status),
//                                        style: TextStyle(
//                                            fontSize: 16.0
//                                        )
//                                    ):Container(),
//                                    this.product.adminRemark != null && this.product.adminRemark != ''?
//                                    GestureDetector(
//                                      onTap: () {
//                                        showDialog<void>(
//                                          context: context,
//                                          builder: (BuildContext context) {
//                                            return AlertDialog(
//                                              content: SingleChildScrollView(
//                                                child: ListBody(
//                                                  children: <Widget>[
//                                                    Text(this.product.adminRemark)
//                                                  ],
//                                                ),
//                                              ),
//                                                actions: <Widget>[
//                                                  new FlatButton(
//                                                      child: Text(tUpper(context, 'ok')),
//                                                      onPressed: () {
//                                                        Navigator.pop(context, true);
//                                                      }
//                                                  )
//                                                ]
//                                            );
//                                          },
//                                        );
//                                      },
//                                      child: Text(
//                                          " " + tTitle(context, "view_remark"),
//                                          style: TextStyle(
//                                            fontSize: 16.0,
//                                            color: MomdayColors.MomdayGold
//                                          )
//                                      )
//                                    ):Container(),
//                                  ],
//                                ),
//                              ),
//                              Container(
//                                margin: EdgeInsets.only(top:10),
//                                child: Text(
//                                  "${this.product.price}\$",
//                                  textAlign: TextAlign.start,
//                                  style: TextStyle(
//                                      fontSize: 20.0
//                                  ),
//                                ),
//                              ),
//                              this.product.charityId != null && this.product.charityId != ''?
//                              Container(
//                                margin: EdgeInsets.only(top:10),
//                                child: Text(
//                                  "${tTitle(context, 'donate_to')} ${AppStateManager.of(context).findCharity(this.product.charityId).name}",
//                                  textAlign: TextAlign.start,
//                                  maxLines: 3,
//                                  style: TextStyle(
//                                      fontWeight: FontWeight.w600,
//                                      fontSize: 20.0
//                                  ),
//                                ),
//                              ):Container(),
//                            ]
//                        ),
//                          ],
//                        ),
//                      ),
//                    )
//                  ],
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                        tTitle(context, 'condition'),
//                        style: cancelArabicFontDelta(context).copyWith(
//                            fontWeight: FontWeight.w300,
//                            fontSize: 20.0,
//                            color: Colors.black.withOpacity(0.58)
//                        ),
//                      ),
//                    ),
//                    product.condition != null?
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(product.condition,
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 16.0,
//                              color: Colors.black
//                          )
//                      ),
//                    ):Container(),
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                          tTitle(context, 'brand'),
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 20.0,
//                              color: Colors.black.withOpacity(0.58)
//                          )
//                      ),
//                    ),
//                    AppStateManager.of(context).findBrand(this.product.brandId) != null?
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(AppStateManager.of(context).findBrand(this.product.brandId).name,
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 16.0,
//                              color: Colors.black
//                          )
//                      ),
//                    ):Container(),
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                          tTitle(context, 'color'),
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 20.0,
//                              color: Colors.black.withOpacity(0.58)
//                          )
//                      ),
//                    ),
//                    this.product.color != null && this.product.color != ''?
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                          this.product.color,
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 16.0,
//                              color: Colors.black
//                          )
//                      ),
//                    ):Container(),
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                          tTitle(context, 'size'),
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 20.0,
//                              color: Colors.black.withOpacity(0.58)
//                          )
//                      ),
//                    ),
//                    this.product.size != null && this.product.size != ''?
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                          this.product.size,
//                          style: cancelArabicFontDelta(context).copyWith(
//                              fontWeight: FontWeight.w300,
//                              fontSize: 16.0,
//                              color: Colors.black
//                          )
//                      ),
//                    ):Container(),
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: Text(
//                          tTitle(context, 'description'),
//                          style: cancelArabicFontDelta(context).copyWith(fontWeight: FontWeight.w300,
//                              fontSize: 20.0,
//                              color: Colors.black.withOpacity(0.58))
//                      ),
//                    ),
//                    Container(
//                      margin: EdgeInsets.only(top:10),
//                      child: DefaultTextStyle(
//                        style: cancelArabicFontDelta(context).copyWith(
//                            fontWeight: FontWeight.w300,
//                            fontSize: 16.0,
//                          ),
//                        child: Html(
//                          data: this.product.description,
//                        )
//                      )
//                    ),
//                  ],
//                ),
//              )
//            ],
//          ),
//      ),
//    );
//  }
//
////  Widget displayVideoAlert(){
////
////    return Container(
////      child:Center(
////          child:
////          videoController == null?
////          Text(
////              t(context, "loading_video")
////          )
////              :VideoPlayer(videoController)
////      ),
////      width: 300,
////      height: 300,
////    );
////  }
////
////  void _displayAlert(videoFile) async {
////
////    showDialog<void>(
////      barrierDismissible: false,
////      context: context,
////      builder: (BuildContext context) {
////        return AlertDialog(
////          content: displayVideoAlert(),
////          actions: <Widget>[
////            videoController != null ? FlatButton(
////              child: Text(tUpper(context, "close")),
////              onPressed: () {
////
////                if(videoController != null) {
////                  videoController.pause();
////                  videoController = null;
////                  videoPlayerListener = null;
////                  Navigator.of(context).pop();
////                }
////                Navigator.of(context).pop();
////              },
////            ):Container()
////          ],
////        );
////      },
////    );
////
////    if(videoController == null)
////      await _startVideoPlayer(videoFile);
////  }
////
////  Future<void> _startVideoPlayer(videoFile) async {
////
////    final VideoPlayerController vcontroller = VideoPlayerController.network(videoFile);
////
////    videoPlayerListener = () {
////      if (videoController != null && videoController.value.size != null) {
////        videoController.removeListener(videoPlayerListener);
////      }
////    };
////
////    vcontroller.addListener(videoPlayerListener);
////    await vcontroller.setLooping(true);
////    await vcontroller.initialize();
////
////    if (mounted) {
////      setState(() {
//////        videoController = vcontroller;
////      });
////    }
////
////    _displayAlert(videoFile);
////    await vcontroller.play();
////  }
//
//  @override
//  void deactivate() {
//
////    if(videoController != null) {
////      videoController.pause();
////      videoController = null;
////      videoPlayerListener = null;
////    }
//    super.deactivate();
//  }
//}
