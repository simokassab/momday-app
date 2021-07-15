import 'package:flutter/material.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/star_rating/star_rating.dart';

class ProductBasicInfo2 extends StatelessWidget {
  final ProductModel product;

  ProductBasicInfo2({this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            this.product.brand != null
                ? Text(
                    this.product.brand,
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  )
                : Container(),
                SizedBox(
              height: 5,
            ),
            Text(
              this.product.name,
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18,color: MomdayColors.LocationGray),
            ),
            SizedBox(
              height: 5,
            ),
            this.product.price != null
                ? Text(
                    this.product.price,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black, fontSize: 21),
                  )
                : Container(),
            this.product.rewardGain != null
                ? Text(
                    "${tTitle(context, 'reward_points')}: ${this.product.rewardGain}")
                : Container(),
            this.product.rewardPrice != null
                ? Text("Price in reward points: ${this.product.rewardPrice}")
                : Container(),
            Text(
                (product.availableQuantity != null &&
                        product.availableQuantity > 0)
                    ? tTitle(context, 'in_stock')
                    : tTitle(context, 'out_of_stock'),
                style: cancelArabicFontDelta(context)
                    .copyWith(fontWeight: FontWeight.w300,fontSize: 18)),
            product.preloved == 0
                ? StarRating(
                    iconSize: 17,
                    rating: this.product.rating,
                    readOnly: true,
                    color: MomdayColors.MomdayGold,
                  )
                : Container(),
          ]),
    );
  }
}
