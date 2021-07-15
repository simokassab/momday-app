//import 'package:flutter/material.dart';
//import 'package:momday_app/bloc_provider.dart';
//import 'package:momday_app/momday_localizations.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/upload_attachment_bloc.dart';
//import 'package:momday_app/styles/momday_colors.dart';
//import 'package:momday_app/widgets/attachment_button/attachment_button.dart';
//
///* used by upload image and upload video views */
//
//class UploadButton extends StatefulWidget {
//
//  final bool isVideo;
//  UploadButton({this.isVideo});
//  @override
//  UploadButtonState createState() {
//    return new UploadButtonState(isVideo: this.isVideo);
//  }
//}
//
//class UploadButtonState extends State<UploadButton> {
//
//  bool _isPerformingAction;
//  final bool isVideo;
//  UploadButtonState({this.isVideo});
//  MyListProductManagerBloc productManagerBloc;
//
//  @override
//  void initState() {
//    super.initState();
//    this._isPerformingAction = false;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    this.productManagerBloc = BlocProvider.of<MyListProductManagerBloc>(context);
//
//    final loading = SizedBox(
//      height: 18.0,
//      width: 18.0,
//      child: Theme(
//        data: ThemeData(
//            accentColor: Colors.white
//        ),
//        child: CircularProgressIndicator(
//          strokeWidth: 3.0,
//        ),
//      ),
//    );
//
//    return  Padding(
//        padding: const EdgeInsets.all(30),
//        child:FlatButton(
//          color: MomdayColors.MomdayGold ,
//          colorBrightness: Brightness.dark,
//          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//          shape: Border(),
//          child: this._isPerformingAction? loading : FittedBox(
//            child: Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//            children:[
//              Container(
//                  child: Text(
//                isVideo? tTitle(context, "upload_video") : tTitle(context, "upload_image")
//            )),
//         Icon(Icons.file_upload)]),
//          ),
//          onPressed: this._handleButtonPress,
//        ));
//  }
//
//  _handleButtonPress() async {
//
//    if (!this._isPerformingAction) {
//      setState(() {
//        this._isPerformingAction = true;
//      });
//
//      _displayAlert();
//
//      setState(() {
//        this._isPerformingAction = false;
//      });
//    }
//  }
//
//  void _displayAlert() {
//
//    showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          content: SingleChildScrollView(
//            child: ListBody(
//              children: <Widget>[
//                Row(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children:[
//                      BlocProvider<MyListProductManagerBloc>(
//                        bloc: this.productManagerBloc,
//                        child: AttachmentButton(isVideo: isVideo,fromGallery: true,),
//                      )]),
//                Row(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children:[BlocProvider<MyListProductManagerBloc>(
//                      bloc: this.productManagerBloc,
//                      child: AttachmentButton(isVideo: isVideo,fromGallery: false,),
//                    )]),
//              ],
//            ),
//          ),
//        );
//      },
//    );
//  }
//}
