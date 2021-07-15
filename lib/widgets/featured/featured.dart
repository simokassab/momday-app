import 'package:flutter/material.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/widgets/carousel/carousel.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';

class Featured extends StatelessWidget {
  final bool miniVersion;
  final bool hasOverlay;
  final Widget midAnnouncement;
  final List<ProductModel> featuredProducts;
  final IndicatorPosition indicatorPosition;
  final double height;

  Featured({
    this.miniVersion = false,
    this.hasOverlay = false,
    this.midAnnouncement,
    this.featuredProducts,
    this.indicatorPosition = IndicatorPosition.Below,
    this.height = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return (this.featuredProducts != null && this.featuredProducts.length > 0)
        ? this._getCarousel(context, this.featuredProducts)
        : ElegantMemoizedFutureBuilder(
            futureCallBack: () => MomdayBackend().getFeaturedItems(),
            loadingHeight: this.miniVersion ? 100.0 : 200.0,
            errorHeight: this.miniVersion ? 100.0 : 200.0,
            fullError: false,
            contentBuilder: (context, data) {
              List<ProductModel> products = ProductModel.fromDynamicList(data);
              return this._getCarousel(context, products);
            },
          );
  }

  _getCarousel(context, products) {
    return Carousel(
      imageHeight: MediaQuery.of(context).size.width * this.height,
      aspectRatio: 1.0,
      boxFit: BoxFit.fill,
      images: products.map((product) => product.image).toList(),
      overlayShadow: this.hasOverlay,
      // subtext: tUpper(context, 'shop_now'),
      midAnnouncement: this.midAnnouncement,
      onItemTap: (index) {
        MainScreen.of(context)
            .navigateToTab(2, '/product/${products[index].productId}');
      },
      indicatorPosition: this.indicatorPosition,
    );
  }
}
