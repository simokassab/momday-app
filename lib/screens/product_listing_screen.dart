import 'package:flutter/material.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:momday_app/widgets/product_list/product_list.dart';
import 'package:momday_app/widgets/product_list/product_list_bloc.dart';

class ProductListingScreen extends StatelessWidget {

  final String categoryId;
  final String brandId;
  final String type;

  ProductListingScreen({this.categoryId, this.brandId, this.type});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: PageHeader(
            title: tTitle(context, 'products'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: BlocProvider<ProductListBloc>(
            child: ProductList(
              independentlyScrollable: false,
              type:this.type,
              onProductTap: (productId) {
                Navigator.of(context).pushNamed('/product/$productId');
              },
            ),
            bloc: ProductListBloc(
              categoryId: this.categoryId,
              brandId: this.brandId,
            ),
          ),
        ),
      ],
    );
  }
}