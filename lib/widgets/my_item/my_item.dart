import 'dart:async';

import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/screens/options_screen/options_screen.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
import 'package:momday_app/widgets/product_basic_info/product_basic_info.dart';
import 'package:momday_app/widgets/quantity_counter/quantity_counter.dart';

enum MyItemType {CART, WISHLIST}

class MyItem extends StatefulWidget {

  final ProductModel product;
  final bool isFirst;
  final MyItemType itemType;
  final VoidCallback onItemMoved;

  MyItem({this.product, this.isFirst, this.itemType, this.onItemMoved});

  @override
  MyItemState createState() {
    return new MyItemState();
  }
}

class MyItemState extends State<MyItem> {

  bool _isMoving;
  bool _isRemoving;

  @override
  void initState() {
    super.initState();
    this._isMoving = false;
    this._isRemoving = false;
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        MainScreen.of(context).navigateToTab(2, '/product/${this.widget.product.productId}');
      },
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: !this.widget.isFirst?
          Border.all(
            width: 0.1
          ) :
          Border(
            right: BorderSide(
              width: 0.1
            ),
            left: BorderSide(
              width: 0.1
            ),
            bottom: BorderSide(
              width: 0.1
            )
          )
        ),
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: 200.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 8.0,),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.5 - 32.0,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: this.widget.product.image != null? MomdayNetworkImage(
                        imageUrl: this.widget.product.image
                      ) : Image(
                        image: AssetImage('assets/images/no_image.png'),
                        fit: BoxFit.fill,
                      )
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(height: 8.0,),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: ProductBasicInfo(
                            product: this.widget.product,
                          ),
                        ),
                        this.widget.product.selectedOptions != null && this.widget.product.selectedOptions.length > 0?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: optionsList(this.widget.product.selectedOptions)
                          ):Container(),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: this.widget.itemType == MyItemType.CART? Row(
                            children: <Widget>[
                            QuantityCounter(
                                quantity: this.widget.product.quantityInCart,
                                changeQuantityCallback: (newQuantity) async {
                                  if (newQuantity == 0) {
                                    await this._removeItem(context);
                                  } else {
                                    await this._changeProductQuantity(context, newQuantity);
                                  }
                                }
                            ),
                            (this.widget.product.stockStatus == 'out_of_stock')?
                            Container(
                                margin: EdgeInsetsDirectional.only(start: 8.0),
                                child: Text(
                                  tSentence(context,this.widget.product.stockStatus),
                                  style: cancelArabicFontDelta(context).copyWith(
                                      color: Colors.red
                                  ),
                                )
                            ):Container(),
                            ],
                          ) : SizedBox(
                            height: 40.0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    tTitle(context, this.widget.product.stockStatus),
                                    textAlign: TextAlign.start,
                                    style: cancelArabicFontDelta(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  foregroundDecoration: BoxDecoration(
                                    border: BorderDirectional(
                                      start: BorderSide(
                                        width: 0.1
                                      ),
                                      top: BorderSide(
                                        width: 0.1
                                      )
                                    )
                                  ),
                                  child: Material(
                                    child: InkWell(
                                      onTap: this._move,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Icon(
                                              this.widget.itemType == MyItemType.CART? Icons.favorite_border : Icons.shopping_cart,
                                              color: this._isMoving? Colors.grey : null,
                                            ),
                                            SizedBox(width: 2.0,),
                                            Expanded(
                                              child: FittedBox(
                                                child: Text(
                                                  tTitle(context, this.widget.itemType == MyItemType.CART? 'move_to_wishlist' : 'move_to_cart'),
                                                  style: Theme.of(context).textTheme.button.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: this._isMoving? Colors.grey : Colors.black,
                                                  )
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            PositionedDirectional(
              top: 0.0,
              end: 0.0,
              child: InkWell(
                child: Icon(
                  Icons.close,
                  color: this._isRemoving? Colors.grey : null,
                ),
                onTap: () {
                  this._removeItem(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> optionsList(List<String> options){

    List<Widget> listView = [];
    for(String option in options){
      listView.add(
          Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child:
              Text(
                option,
                style: cancelArabicFontDelta(context),
                textAlign: TextAlign.start,
              )
          )
      );
    }

    return listView;
  }

  Future<void> _changeProductQuantity(BuildContext context, int newQuantity) async {
    await AppStateManager.of(context).changeProductQuantityInCart(
      productKey: this.widget.product.keyInCart,
      quantity: newQuantity
    );
  }

  Future<void> _move() async {

    if (!this._isMoving) {
      var response;

      setState(() {
        this._isMoving = true;
      });

      if (this.widget.itemType == MyItemType.CART) {
        response = await Future.wait([
          AppStateManager.of(context).addProductToWishList(productId: this.widget.product.productId),
          AppStateManager.of(context).removeProductFromCart(productKey: this.widget.product.keyInCart),
        ]);
      }

      else {

        ProductModel productDetails = ProductModel.fromDynamic(
            await MomdayBackend().getProduct(
                productId: widget.product.productId
            )
        );

        if(productDetails != null && productDetails.availableOptions != null && productDetails.availableOptions.length > 0){

          showModalBottomSheet(
              context: context,
              builder: (context) {
                return OptionsScreen(
                  product: productDetails,
                  fromMenu: true,
                );
              }
          );
        }

        else if(productDetails != null)

          response = await Future.wait([
            AppStateManager.of(context).addProductToCart(productId: this.widget.product.productId),
            AppStateManager.of(context).removeProductFromWishList(productId: this.widget.product.productId),
          ]);
      }

      if (this.mounted) {
        setState(() {
          this._isMoving = false;
        });
      }

      if (response != null && response.length > 0 && response[0] == 'success') {
        widget.onItemMoved();
      } else if(response != null && response.length > 0){
        showTextSnackBar(context, response[0]);
      } else{
        showTextSnackBar(context, 'error moving item');
      }
    }
  }

  Future<void> _removeItem(BuildContext context) async {
    bool confirmation = true;

    if (this.widget.itemType == MyItemType.CART) {
      confirmation = await showConfirmDialog(context, tSentence(context, 'confirm_remove_item_from_cart'));
    }

    if (confirmation == true) {
      setState(() {
        this._isRemoving = true;
      });
      if (this.widget.itemType == MyItemType.CART) {
        await AppStateManager.of(context).removeProductFromCart(productKey: widget.product.keyInCart);
      } else {
        await AppStateManager.of(context).removeProductFromWishList(productId: widget.product.productId);
      }
      if (this.mounted) {
        setState(() {
          this._isRemoving = false;
        });
      }
    }
  }
}
