import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/options_screen/options_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';

class AddOrWish extends StatefulWidget {
  final ProductModel product;
  final int quantity;
  final bool hasStartBorder;

  final fromMenu;
  final bool newItem;
  final bool fromListing;

  final Map<OptionModel, OptionValueModel> selectedOptions;

  AddOrWish({
    this.product,
    this.quantity = 1,
    this.hasStartBorder = true,
    this.fromMenu = false,
    this.newItem,
    this.selectedOptions,
    this.fromListing = false,
  });

  @override
  AddOrWishState createState() {
    return new AddOrWishState(selectedOptions: selectedOptions);
  }
}

class AddOrWishState extends State<AddOrWish> {
  bool _isTogglingCart;
  bool _isTogglingWishlist;

  Map<OptionModel, OptionValueModel> selectedOptions;

  AddOrWishState({this.selectedOptions});

  @override
  void initState() {
    super.initState();
    this._isTogglingCart = false;
    this._isTogglingWishlist = false;

    if (this.selectedOptions == null) {
      selectedOptions = {};
    }
  }

  Widget _getActionButton(
      {BuildContext context,
      bool status,
      bool isPerformingAction,
      IconData containedIcon,
      IconData notContainedIcon,
      VoidCallback onPressed,
      bool isFirst}) {
    final loader = SizedBox(
        height: 16.0,
        width: 16.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
        ));

    final icon = Icon(status ? containedIcon : notContainedIcon);

    return Container(
        height: 48.0,
        foregroundDecoration: BoxDecoration(
            border: BorderDirectional(
            //   start: !isFirst || this.widget.hasStartBorder
            //       ? BorderSide(width: 0.1)
            //       : BorderSide.none,
            //   top: BorderSide(width: 0.1),
              bottom: BorderSide(width: 0.1),
              end: isFirst ? BorderSide.none : BorderSide(width: 0.1),
            ),
            color: Colors.transparent),
        child: FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: isPerformingAction ? loader : icon,
          onPressed: isPerformingAction ? null : onPressed,
          textColor: status ? MomdayColors.MomdayGold : Colors.black,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final appStateManager = AppStateManager.of(context);

    bool containedInWishList = appStateManager.wishlist.products
        .any((element) => element.productId == this.widget.product.productId);
//    bool containedInCart = appStateManager.cart.products
//        .any((element) => element.productId == this.widget.product.productId);

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: this._getActionButton(
            isFirst: true,
            context: context,
            status: false,
            containedIcon: Icons.shopping_cart,
            notContainedIcon: Icons.add_shopping_cart,
            isPerformingAction: this._isTogglingCart,
            onPressed: () => this._handleCartButton(false)),
      ),
      !this.widget.fromMenu
          ? Expanded(
              child: _getActionButton(
                  isFirst: false,
                  context: context,
                  status: containedInWishList,
                  containedIcon: Icons.favorite,
                  notContainedIcon: Icons.favorite_border,
                  isPerformingAction: this._isTogglingWishlist,
                  onPressed: () => this._handleWishButton(containedInWishList)),
            )
          : Container(),
    ]);
  }

  displayOptionsScreen() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return OptionsScreen(
            product: this.widget.product,
            fromMenu: true,
          );
        });
  }

  _handleWishButton(bool containedInWishList) async {
    final appStateManager = AppStateManager.of(context);

    if (!appStateManager.account.isLoggedIn) {
      askForLogin(context, 'add_this_item_to_wishlist');
    } else {
      var response;

      if (containedInWishList) {
        setState(() {
          this._isTogglingWishlist = true;
        });

        response = await appStateManager.removeProductFromWishList(
            productId: this.widget.product.productId);
      } else {
        setState(() {
          this._isTogglingWishlist = true;
        });

        response = await appStateManager.addProductToWishList(
          productId: this.widget.product.productId,
        );

        if (response != 'success') {
          showTextSnackBar(context, response);
        }

        if (this.widget.fromMenu) Navigator.pop(context);
      }

      setState(() {
        this._isTogglingWishlist = false;
      });
    }
  }

  _handleCartButton(bool containedInCart) async {
    final appStateManager = AppStateManager.of(context);

    setState(() {
      this._isTogglingCart = true;
    });

    if (this.widget.product.availableOptions != null &&
        this.widget.product.availableOptions.length > 0 &&
        this.widget.fromListing) {
      displayOptionsScreen();
    } else {
      bool missingFields = false;

      if (this.widget.newItem) {
        for (OptionModel option in this.selectedOptions.keys)
          if (this.selectedOptions[option] == null) {
            showTextSnackBar(context,
                "${tSentence(context, 'select_option')} ${option.name}");
            missingFields = true;
            break;
          }
      }

      if (this.widget.quantity > maxQuantity()) {
        showTextSnackBar(
            context, "not enough quantity for the selected options");
      } else if (!missingFields) {
        var response = await appStateManager.addProductToCart(
            productId: this.widget.product.productId,
            quantity: this.widget.quantity,
            selectedOptions: this.selectedOptions);

        if (response == 'success') {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(tSentence(context, 'item_added_successfully')),
            action: SnackBarAction(
                label: tSentence(context, 'go_to_cart'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                }),
            duration: Duration(seconds: 3),
          ));
          AppStateManager.of(context).removeProductFromWishList(
              productId: this.widget.product.productId);
        } else {
          showTextSnackBar(context, response);
        }

        if (this.widget.fromMenu) Navigator.pop(context);
      }
    }

    setState(() {
      this._isTogglingCart = false;
    });
  }

  int maxQuantity() {
    int max = this.widget.product.availableQuantity;

    if (this.selectedOptions != null && this.selectedOptions.length > 0) {
      for (OptionModel option in this.selectedOptions.keys) {
        OptionValueModel optionValue = this.selectedOptions[option];
        if (optionValue != null && optionValue.quantity < max)
          max = optionValue.quantity;
      }
    }

    return max;
  }
}
