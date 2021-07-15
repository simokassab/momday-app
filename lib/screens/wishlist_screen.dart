import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/styles/momday_styles.dart';
import 'package:momday_app/widgets/featured/featured.dart';
import 'package:momday_app/widgets/my_item/my_item.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class WishlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WishlistModel wishlist = AppStateManager.of(context).wishlist;

    var mainPage;

    var featured = [
      SizedBox(height: 40.0),
      Text(
        tTitle(context, 'featured_items'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),
      ),
      SizedBox(
        height: 10.0,
      ),
      Featured(
        hasOverlay: true,
      ),
    ];

    if (!wishlist.isEmpty) {
      mainPage = ListView(
        primary: false,
        shrinkWrap: true,
        children: <Widget>[
          PageHeader(
            title: tTitle(context, 'my_wishlist'),
          )
        ]
          ..addAll(wishlist.products.expand((product) => [
                MyItem(
                  product: product,
                  isFirst: wishlist.products.first == product,
                  itemType: MyItemType.WISHLIST,
                  onItemMoved: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content:
                          Text(tSentence(context, 'item_moved_successfully')),
                      action: SnackBarAction(
                          label: tSentence(context, 'go_to_cart'),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/cart');
                          }),
                      duration: Duration(seconds: 3),
                    ));
                  },
                ),
                SizedBox(height: 8.0)
              ]))
          ..addAll(featured),
      );
    } else {
      mainPage = ListView(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          PageHeader(
            title: tTitle(context, 'my_wishlist'),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(tSentence(context, 'wishlist_empty'),
              textAlign: TextAlign.center, style: MomdayStyles.LabelStyle),
          SizedBox(
            height: 8.0,
          ),
          this._backToShoppingButton(context)
        ]..addAll(featured),
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

  Widget _backToShoppingButton(BuildContext context) {
    return RaisedButton.icon(
        color: MomdayColors.MomdayGray,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.shopping_cart,
          color: MomdayColors.MomdayGold,
        ),
        label: Text(
          tSentence(context, 'go_back_to_shopping'),
          textAlign: TextAlign.start,
          style: TextStyle(
              color: MomdayColors.MomdayGold, fontWeight: FontWeight.bold),
        ));
  }
}
