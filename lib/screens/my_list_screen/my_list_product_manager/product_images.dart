//import 'package:flutter/material.dart';
//import 'package:momday_app/bloc_provider.dart';
//import 'package:momday_app/models/models.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';
//import 'package:momday_app/widgets/attachment_preview/attacment_preview.dart';
//
//class ProductImages extends StatefulWidget {
//
//  final MyListProductModel selectedProduct;
//  final bool displayError;
//  ProductImages({this.selectedProduct,this.displayError});
//
//  @override
//  ProductImagesState createState() {
//    return new ProductImagesState();
//  }
//}
//
//class ProductImagesState extends State<ProductImages> with AutomaticKeepAliveClientMixin<ProductImages> {
//
//
//  @override
//  Widget build(BuildContext context) {
//
//    return BlocProvider(
//        bloc: BlocProvider.of<MyListProductManagerBloc>(context),
//        child:
//        Padding(
//            padding: const EdgeInsets.all(10),
//            child: AttachmentPreview(isVideo: false, selectedProduct: this.widget.selectedProduct,displayError: this.widget.displayError,)
//        )
//    );
//  }
//
//  @override
//  bool get wantKeepAlive => true;
//}