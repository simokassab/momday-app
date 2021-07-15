import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/widgets/add_or_wish/add_or_wish.dart';
import 'package:momday_app/widgets/celebrity_button/celebrity_button.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
import 'package:momday_app/widgets/product_basic_info/product_basic_info.dart';

class Product extends StatelessWidget {
  final ProductModel product;
  final GestureTapCallback onTap;
  final int index;

  Product({this.product, this.onTap, this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                foregroundDecoration: BoxDecoration(
                  border: BorderDirectional(
                      //   top: index < 2? BorderSide(
                      //       width: 0.1
                      //   ) : BorderSide.none,
                      //   start: index % 2 == 0? BorderSide(
                      //     width: 0.1
                      //   ) : BorderSide.none,
                      end: BorderSide(width: 0.1)),
                ),
                child: Column(
                  children: <Widget>[
                    AspectRatio(
                        aspectRatio: 1.0,
                        child: MomdayNetworkImage(
                          imageUrl: this.product.image,
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: ProductBasicInfo(
                          product: this.product,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            AddOrWish(
              newItem: this.product.preloved == 0,
              hasStartBorder: this.index % 2 == 0,
              product: this.product,
              fromListing: true,
            ),
            Builder(
              builder: (context) {
                if (AppStateManager.of(context).account.isCelebrity) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: CelebrityButton(
                          productId: this.product.productId,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
