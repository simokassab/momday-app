import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/styles/momday_styles.dart';
import 'package:momday_app/widgets/addresses/addresses.dart';
import 'package:momday_app/widgets/existing_addresses/existing_addresses.dart';
import 'package:momday_app/widgets/my_item/my_item.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartModel cart = AppStateManager.of(context).cart;
    var mainPage;
    if (!cart.isEmpty) {
      mainPage = ListView(
        primary: false,
        shrinkWrap: true,
        children: <Widget>[
          PageHeader(
            title: tTitle(context, 'my_cart'),
          )
        ]
          ..addAll(cart.products.expand((product) => [
                MyItem(
                  product: product,
                  isFirst: cart.products.first == product,
                  itemType: MyItemType.CART,
                  onItemMoved: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content:
                          Text(tSentence(context, 'item_moved_successfully')),
                      action: SnackBarAction(
                          label: tSentence(context, 'go_to_wishlist'),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/wishlist');
                          }),
                      duration: Duration(seconds: 3),
                    ));
                  },
                ),
                SizedBox(height: 8.0)
              ]))
          ..addAll([
            SizedBox(height: 30.0),
            Text(
              tTitle(context, 'subtotal') + ': ' + cart.total,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
            ),
            SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  tUpper(context, 'checkout'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0),
                ),
                color: MomdayColors.MomdayGold,
                onPressed: () {
                  this._showAvailableAddresses(context);
                },
              ),
            )
          ]),
      );
    } else {
      mainPage = ListView(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          PageHeader(
            title: tTitle(context, 'my_cart'),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(tSentence(context, 'cart_empty'),
              textAlign: TextAlign.center, style: MomdayStyles.LabelStyle),
          SizedBox(
            height: 8.0,
          ),
          this._backToShoppingButton(context)
        ],
      );
    }

    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: mainPage,
        ),
      ],
    );
  }

  _showAvailableAddresses(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Addresses();
        });
  }

  Widget _backToShoppingButton(BuildContext context) {
    return RaisedButton.icon(
        color: MomdayColors.MomdayGold,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        label: Text(
          tSentence(context, 'go_back_to_shopping'),
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }
}

class ContinueToPaymentButton extends StatefulWidget {
  final GlobalKey<ExistingAddressesState> existingAddressesKey;

  ContinueToPaymentButton({this.existingAddressesKey});

  @override
  _ContinueToPaymentButtonState createState() =>
      _ContinueToPaymentButtonState();
}

class _ContinueToPaymentButtonState extends State<ContinueToPaymentButton> {
  String _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RaisedButton(
          color: MomdayColors.MomdayGold,
          colorBrightness: Brightness.dark,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            tUpper(context, 'continue_to_payment'),
            style: TextStyle(fontSize: 20.0),
          ),
          onPressed: () {
            if (widget.existingAddressesKey.currentState.selectedAddress ==
                null) {
              setState(() {
                this._errorText = tSentence(context, 'no_address_selected');
              });
            } else {
              Navigator.of(context).pushNamed('/visa');
            }
          },
        ),
        SizedBox(
          height: 8.0,
        ),
        this._errorText != null
            ? Text(
                this._errorText,
                style: TextStyle(color: Theme.of(context).errorColor),
              )
            : Container()
      ],
    );
  }
}
