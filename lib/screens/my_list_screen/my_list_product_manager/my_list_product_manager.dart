//import 'package:flutter/material.dart';
//import 'package:momday_app/bloc_provider.dart';
//import 'package:momday_app/models/models.dart';
//import 'package:momday_app/momday_localizations.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/product_images.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/product_video.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/product_info.dart';
//import 'package:momday_app/styles/momday_colors.dart';
//
//class MyListProductManager extends StatefulWidget {
//
//  final MyListProductModel product;
//
//  MyListProductManager({this.product});
//
//  @override
//  MyListProductManagerState createState() {
//    return new MyListProductManagerState(product: this.product);
//  }
//}
//
//class MyListProductManagerState extends State<MyListProductManager> {
//
//  MyListProductManagerBloc productManagerBloc;
//
//  MyListProductManagerState({this.product});
//
//  final PageController _pageController = PageController(initialPage: 0);
//  int page = 0;
//
//  final infoForm  = GlobalKey<FormState>();
//  bool displayImageError = false;
//  bool displayVideoError = false;
//  bool submitProductInfo = false;
//
//  MyListProductModel product;
//  List<String> productImages = [];
//  dynamic productVideo;
//
//  @override
//  void dispose() {
//    this.productManagerBloc.disposeBloc();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    this.productManagerBloc = MyListProductManagerBloc();
//
//    _blocListener();
//
//    return Scaffold(
//      resizeToAvoidBottomPadding:false,
//      body: BlocProvider(
//        bloc: this.productManagerBloc,
//        child:
//        GestureDetector(
//          onTap: () {
//            FocusScope.of(context).requestFocus(new FocusNode());
//          },
//          child: Padding(
//            padding: MediaQuery.of(context).padding,
//            child: Column(
//              children: <Widget>[
//                Expanded(
//                  child: PageView(
//                    physics:new NeverScrollableScrollPhysics(),
//                    controller: this._pageController,
//                    children: <Widget>[
//                      ProductInfo(product: product,formKey: this.infoForm, submit:submitProductInfo),
//                      ProductImages(selectedProduct: product, displayError: displayImageError),
//                      ProductVideo(selectedProduct: product, displayError: displayVideoError),
//                    ],
//                  ),
//                ),
//                Center(
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Padding(
//                          padding: const EdgeInsets.all(5),
//                          child:FlatButton(
//                            color: MomdayColors.MomdayBlack,
//                            colorBrightness: Brightness.dark,
//                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                            shape: Border(),
//                            child: Text(tUpper(context,"cancel")),
//                            onPressed: () {
//                              alertCancelConfirm();
//                            },
//                          )
//                      ),
//                      Padding(
//                          padding: const EdgeInsets.all(5),
//                          child:FlatButton(
//                            color: MomdayColors.MomdayBlack,
//                            colorBrightness: Brightness.dark,
//                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                            shape: Border(),
//                            child: Text(tUpper(context,"previous")),
//                            onPressed: () {
//                              this._pageController.previousPage(
//                                    duration: Duration(milliseconds: 500),
//                                    curve: Curves.easeOut
//                              );
//                              setState(() {
//                                page = this._pageController.page.round();
//                              });
//                            },
//                          )
//                      ),
//                      Padding(
//                          padding: const EdgeInsets.all(5),
//                          child:FlatButton(
//                            color: MomdayColors.MomdayGold ,
//                            colorBrightness: Brightness.dark,
//                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                            shape: Border(),
//                            child: Text(
//                                tUpper(context, "next")
//                            ),
//                            onPressed: getNextPage,
//                          )
//                      ),
//                    ],
//                  ),
//                )
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  getNextPage() async {
//
//    setState(() {
//      page = this._pageController.page.round();
//    });
//
//    if(page == 0){
//      this.infoForm.currentState.validate();
//
//      setState(() {
//        this.submitProductInfo = true;
//      });
//    }
//
//    else if(page == 1){
//
//      if(productImages.length == 0)
//        setState(() {
//          displayImageError = true;
//        });
//    }
//
//    else if(page == 2){
//
//      if(this.productManagerBloc.validateProduct(this.product)){
//
//        this.product.images = productImages;
//
//        if(productVideo == null)
//          this.product.video = null;
//
//        else if(productVideo['attachment_path'].toString().startsWith('http'))
//          product.video = productVideo['attachment_path'];
//
//        else {
//          product.video = productVideo['filename'];
//        }
//
//        dynamic response = await this.productManagerBloc.uploadPrelovedItem(this.product);
//
//        print("response is $response");
//        if(response['success'] == 1){
//          Navigator.of(context).pop();
//          Navigator.of(context).pushNamed('/my-list');
//          alertMessage('Your item has been posted successfully ');
//        }
//
//        else if(response['error'] != null){
//          alertMessage(response['error'][0]);
//        }
//      }
//
//      else{
//        alertMessage('missing fields. please make sure to fill all required fields');
//      }
//    }
//
//    this._pageController.nextPage(
//        duration: Duration(milliseconds: 500),
//        curve: Curves.easeOut
//    );
//  }
//
//  _blocListener() async {
//
//    productManagerBloc.dataStream.listen((MyListProductModel productModel) {
//
//      setState(() {
//
//        if(productModel != null) {
//
//          if(product == null)
//            product = MyListProductModel();
//
//          product.copyBasicInfo(productModel);
//        }
//
//        submitProductInfo = false;
//      });
//    });
//
//    productManagerBloc.actionStream.listen((Action action) {
//
//      setState(() {
//        if(action != null) {
//
//          if (action.type == MyListProductManagerActionTypes.uploadedAttachment) {
//
//            if(action.data["error"] != null)
//              return;
//
//            if(action.data["type"].toString() == 'video') {
//              productVideo = action.data;
//              displayVideoError = false;
//            }
//            else {
//              if(action.data['attachment_path'].toString().startsWith('http'))
//                productImages = List.from(productImages)..add(action.data['attachment_path'].toString());
//              else
//                productImages = List.from(productImages)..add(action.data['filename'].toString());
//              displayImageError = false;
//            }
//          }
//
//          else if (action.type == MyListProductManagerActionTypes.deletedAttachment) {
//            if(action.data["type"].toString() == 'video')
//              productVideo = null;
//            else
//              productImages = List.from(productImages)..remove(action.data);
//          }
//        }
//      });
//    });
//  }
//
//  alertCancelConfirm(){
//
//    showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          content: SingleChildScrollView(
//            child: Center(
//              child: ListBody(
//                children: <Widget>[
//                  Text("Are you sure you want to cancel?")
//                ],
//              ),
//            ),
//          ),
//          actions: <Widget>[
//              new FlatButton(
//                  child: Text("Stay on page"),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  }
//              ),
//              new FlatButton(
//                  child: Text('Cancel Changes'),
//                  onPressed: () => cancelProduct(context),
//              )
//          ],
//        );
//      },
//    );
//  }
//
//  cancelProduct(alertContext) async{
//
//    Navigator.of(alertContext).pop();
//    Navigator.of(context).pop();
//    Navigator.of(context).pushNamed('/my-list');
//  }
//
//  alertMessage(messageContent){
//
//    showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          content: SingleChildScrollView(
//            child: Center(
//              child: ListBody(
//                children: <Widget>[
//                  Text(messageContent)
//                ],
//              ),
//            ),
//          ),
//          actions: <Widget>[
//            new FlatButton(
//                child: Text(tUpper(context, 'ok')),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                }
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  donationAlert(){
//
//    showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          content: SingleChildScrollView(
//            child: Center(
//              child: ListBody(
//                children: <Widget>[
//                  Image(
//                    image: AssetImage("assets/images/donate_image.png"),
//                    width: 100,
//                    height: 100,
//                  ),
//                  Flexible(
//                    child: Container(
//                      margin: EdgeInsetsDirectional.only(top:10, bottom: 10),
//                      child: Text(
//                          tTitle(context, "donation_ask"),
//                          textAlign: TextAlign.center,
//                          style: new TextStyle(
//                              fontSize: 25.0,
//                              color: Colors.black
//                          )
//                      ),
//                    ),
//                  ),
//                  Container(
//                    margin: EdgeInsetsDirectional.only(top:10, bottom: 10),
//                    child: Text(tSentence(context, "donation_msg"),
//                        textAlign: TextAlign.center,
//                        style: new TextStyle(
//                            fontSize: 15.0,
//                            color: Colors.grey
//                        )
//                    ),
//                  ),
//                  Container(
//                    margin: EdgeInsetsDirectional.only(top:10, bottom: 10),
//                    child: SizedBox(
//                      width: 100,
//                      height: 40,
//                      child: FittedBox(
//                        child: FlatButton(
//                          color: MomdayColors.MomdayGold ,
//                              colorBrightness: Brightness.dark,
//                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                              child: Text(tUpper(context, "donate")),
//                              onPressed: () {
//
//                              },
//                            ),
//                      ),
//                    ),
//                  ),
//                  Container(
//                    margin: EdgeInsetsDirectional.only(top:10, bottom: 10),
//                    child: SizedBox(
//                      width: 100,
//                      height: 40,
//                      child: FittedBox(
//                        child: FlatButton(
//                          color: Colors.transparent,
//                          colorBrightness: Brightness.dark,
//                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                          child:
//                            Text(
//                                tTitle(context, "no_thanks"),
//                              style: TextStyle(
//                                color: Colors.grey
//                              ),
//                            ),
//                          onPressed: () {
//
//                          },
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ),
//        );
//      },
//    );
//  }
//}
