//import 'package:flutter/material.dart';
//import 'package:momday_app/bloc_provider.dart';
//import 'package:momday_app/models/models.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';
//import 'package:momday_app/widgets/attachment_preview/attacment_preview.dart';
//
//class ProductVideo extends StatefulWidget {
//
//  final MyListProductModel selectedProduct;
//  final bool displayError;
//  ProductVideo({this.selectedProduct,this.displayError = false});
//
//  @override
//  ProductVideoState createState() {
//    return new ProductVideoState();
//  }
//}
//
//class ProductVideoState extends State<ProductVideo> with AutomaticKeepAliveClientMixin<ProductVideo> {
//
//  MyListProductManagerBloc productManagerBloc;
//
//  @override
//  Widget build(BuildContext context) {
//
//    this.productManagerBloc = BlocProvider.of<MyListProductManagerBloc>(context);
//    return
//      BlocProvider(
//        bloc: this.productManagerBloc,
//        child:
//        Padding(
//            padding: const EdgeInsets.all(10),
//            child:
//            AttachmentPreview(
//              isVideo: true,
//              selectedProduct: this.widget.selectedProduct,
//              displayError: this.widget.displayError
//            )
//        ),
//    );
//  }
//
//  @override
//  bool get wantKeepAlive => true;
//}