//import 'package:flutter/material.dart';
//import 'package:flutter_pagewise/flutter_pagewise.dart';
//import 'package:intl/intl.dart';
//import 'package:momday_app/app_state_manager.dart';
//import 'package:momday_app/backend_helpers/momday_backend.dart';
//import 'package:momday_app/models/models.dart';
//import 'package:momday_app/momday_localizations.dart';
//import 'package:momday_app/momday_utils.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_details.dart';
//import 'package:momday_app/styles/momday_colors.dart';
//import 'package:momday_app/widgets/momday_card/momday_card.dart';
//import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
//import 'package:momday_app/widgets/page_header/page_header.dart';
//
//class MyListScreen extends StatefulWidget {
//
//  @override
//  MyListScreenState createState() {
//    return new MyListScreenState();
//  }
//}
//
//class MyListScreenState extends State<MyListScreen> {
//
//  String selectedStatus;
//  static const int PAGE_SIZE = 10;
//  List<String> statuses;
//
//  @override
//  Widget build(BuildContext context) {
//
//    this.statuses = AppStateManager.of(context).statuses;
//
//    return Scaffold(
//        body:Padding(
//          padding: MediaQuery.of(context).padding,
//          child: CustomScrollView(
//            slivers: <Widget>[
//              SliverPadding(
//                padding: const EdgeInsets.only(top:8.0),
//                sliver: SliverToBoxAdapter(
//                  child: PageHeader(
//                    title: tUpper(context, 'my_list'),
//                  ),
//                ),
//              ),
//              SliverToBoxAdapter(
//                child: FlatButton.icon(
//                    color: MomdayColors.MomdayGray,
//                    onPressed: () {
//                      this._showFilterOptions(context);
//                    },
//                    label: Text(
//                      tTitle(context, 'filter'),
//                      style: cancelArabicFontDelta(context),
//                    ),
//                    icon: Icon(Icons.filter_list)
//                ),
//              ),
//              SliverPadding(
//                padding: const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0),
//                sliver: _MyItemsList(context),
//              ),
//            ],
//          ),
//        ),
//        floatingActionButton: new FloatingActionButton(
//            heroTag: "add_product",
//            child:Container(
//              color: MomdayColors.MomdayGold ,
//              child: Icon(Icons.add),
//            ),
//            onPressed: () {
//              Navigator.of(context).pop();
//              Navigator.of(context).pushNamed('/my-list/product');
//            }
//        )
//    );
//  }
//
//  _showFilterOptions(BuildContext context) {
//
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return Dialog(
//            child: filterAlert(context),
//          );
//        }
//    );
//  }
//
//  Widget filterAlert(BuildContext context) {
//    return Column(
//      children: <Widget>[
//        SizedBox(height: 8.0),
//        Expanded(
//          child:ListView(
//            children:_getStatusTiles(context),
//          ),
//        ),
//        Row(
//          children: <Widget>[
//            Expanded(
//              child: RaisedButton(
//                shape: Border(),
//                padding: EdgeInsets.all(18.0),
//                colorBrightness: Brightness.dark,
//                color: Colors.black,
//                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                child: FittedBox(
//                  child: Text(
//                      tUpper(context, 'clear_filters')
//                  ),
//                ),
//                onPressed: () {
//                  setState(() {
//                    selectedStatus = null;
//                    Navigator.of(context).pop();
//                  });
//                },
//              ),
//            )
//          ],
//        )
//      ],
//    );
//  }
//
//  List<Widget> _getStatusTiles(BuildContext context) {
//
//    final statuses = AppStateManager.of(context).statuses;
//
//    return statuses.map((status) =>
//        this._getTile(
//          text: tSentence(context,status),
//          isFirst: status == statuses.first,
//          isSelected: this.selectedStatus == status,
//          onTap: () {
//            setState(() {
//              this.selectedStatus = status;
//              Navigator.of(context).pop();
//            });
//          },
//        )
//    ).toList();
//  }
//
//  Widget _getTile({String text, bool isSelected, GestureTapCallback onTap, bool isFirst}) {
//
//    return Container(
//      foregroundDecoration: BoxDecoration(
//        border: Border(
//            top: isFirst? BorderSide() : BorderSide.none,
//            bottom: BorderSide()
//        ),
//      ),
//      child: Material(
//        color: Colors.white,
//        child: InkWell(
//          child: Padding(
//            padding: const EdgeInsets.symmetric(vertical: 18.0),
//            child: Text(
//              text,
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                  color: isSelected? MomdayColors.MomdayGold  : Colors.black,
//                  fontWeight: FontWeight.w600,
//                  fontSize: 18.0
//              ),
//            ),
//          ),
//          onTap: onTap,
//        ),
//      ),
//    );
//  }
//
//  Widget _MyItemsList(BuildContext context) {
//
//    return new PagewiseSliverList(
//      pageSize: PAGE_SIZE,
//      itemBuilder: this._myListProduct,
//      pageFuture: this._pageFuture,
//      noItemsFoundBuilder: noItemsFound,
//    );
//  }
//
//  Widget noItemsFound(BuildContext context) {
//    return Text(
//        tUpper(context, 'no_items_found'),
//        textAlign: TextAlign.center,
//        style: TextStyle(
//            fontWeight: FontWeight.w300,
//            fontSize: 30.0,
//            color: MomdayColors.MomdayGold .withOpacity(0.44)
//        )
//    );
//  }
//
//  Future<List<MyListProductModel>> _pageFuture(pageIndex) async {
//
//    final posts = await MomdayBackend().getMyListProducts(
//        pageNumber: pageIndex,
//        limit: PAGE_SIZE,
//        status: this.selectedStatus
//    );
//
//    return MyListProductModel.fromDynamicList(posts);
//  }
//
//  Widget _myListProduct(context, product, index) {
//
//    if(selectedStatus != null && product.status != selectedStatus)
//      return Container();
//
//    var dateFormat = new DateFormat("yMd");
//
//    return Container(
//        child:
//        GestureDetector(
//          onTap: () {
//            Navigator.of(context).pop();
//            Navigator.push(context,
//              MaterialPageRoute(
//                builder: (context) => MyListProductDetails(productId:product.id),
//                maintainState: false,
//              ),
//            );
//          },
//          child: MomdayCard(
//            child:Stack(
//                alignment: AlignmentDirectional.topEnd,
//                children:[
//                  Positioned(
//                    child: ButtonTheme(
//                        minWidth: 30.0,
//                        child:
//                        FlatButton(
//                            child:Icon(Icons.clear),
//                            onPressed: () => alertDelete(product.id)
//                        )
//                    ),
//                  ),
//                  Container(
//                    child: Padding(
//                        padding: EdgeInsetsDirectional.only(bottom: 8.0),
//                        child: Padding(
//                          padding: const EdgeInsets.all(18.0),
//                          child: SizedBox(
//                            height: 180.0,
//                            child: Row(
//                              crossAxisAlignment: CrossAxisAlignment.stretch,
//                              children: <Widget>[
//                                Container(
//                                  child: Column(
//                                    children: <Widget>[
//                                      MomdayNetworkImage(
//                                        imageUrl: product.thumbnail,
//                                        height: 150.0,
//                                        width: 150.0,
//                                      ),
//                                    ],
//                                  ),
//                                ),
//                                Expanded(
//                                  child: Container(
//                                    margin: EdgeInsets.only(right: 10,left: 10),
//                                    child: Column(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        Expanded(
//                                          child: Column(
//                                            crossAxisAlignment: CrossAxisAlignment.start,
//                                            children: <Widget>[
//                                              Text(
//                                                product.name,
//                                                style: TextStyle(
//                                                    fontWeight: FontWeight.bold,
//                                                    color: Colors.black,
//                                                    fontSize: 20.0
//                                                ),
//                                              ),
//                                              AppStateManager.of(context).findBrand(product.brandId) != null?
//                                              Container(
//                                                margin: EdgeInsets.only(top:10),
//                                                child: Text(
//                                                    AppStateManager.of(context).findBrand(product.brandId).name,
//                                                    style: TextStyle(
//                                                        fontSize: 18.0
//                                                    )
//                                                ),
//                                              ):Container(),
//                                              product.status != null?
//                                              Container(
//                                                margin: EdgeInsets.only(top:10),
//                                                child: Text(
//                                                    tSentence(context, product.status),
//                                                    style: TextStyle(
//                                                        fontSize: 18.0
//                                                    )
//                                                ),
//                                              ):Container(),
//                                              Container(
//                                                margin:EdgeInsets.only(top:5),
//                                                child: Text(
//                                                  product.charityId != null ?
//                                                  "${product.price}\$" + ' ' +tUpper(context, "donate"):
//                                                  "${product.price}\$",
//                                                  style: TextStyle(
//                                                      color: MomdayColors.MomdayGold ,
//                                                      fontSize: 20.0
//                                                  ),
//                                                ),
//                                              ),
//                                              product.dateExpires != null?
//                                              Container(
//                                                margin:EdgeInsets.only(top:5),
//                                                child: Text(
//                                                  tTitle(context, 'expires') +'${ dateFormat.format(product.dateExpires)}',
//                                                  style: TextStyle(
//                                                      fontSize: 18.0
//                                                  ),
//                                                ),
//                                              ):Container(),
//                                            ],
//                                          ),
//                                        ),
//                                      ],
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ),
//                        )
//                    ),
//                  ),
//                ]),
//          ),
//        )
//    );
//  }
//
//  void alertDelete(String productId) {
//
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: new Text(tSentence(context, "delete_myitem")),
//          content: new Text(tSentence(context, "delete_myitem_confirm")),
//          actions: <Widget>[
//            new FlatButton(
//                child: new Text(tSentence(context, "delete")),
//                onPressed: () => deleteItem(context,productId)
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
//  deleteItem(alertContext, String productId) async {
//
//    dynamic response = await MomdayBackend().deleteProduct(productId);
//
//    if(response != null && response['success'] == 1){
//
//      setState(() {
//        Navigator.of(context).pop();
//        Navigator.of(context).pushNamed('/my-list');
//      });
//    }
//    Navigator.of(alertContext).pop();
//  }
//}
