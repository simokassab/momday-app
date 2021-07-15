//import 'dart:async';
//import 'dart:io';
//
//import 'package:flutter/material.dart';
//import 'package:momday_app/app_permissions.dart';
//import 'package:momday_app/bloc_provider.dart';
//import 'package:momday_app/momday_utils.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:image_cropper/image_cropper.dart';
//
//import 'package:momday_app/momday_localizations.dart';
//import 'package:permission_handler/permission_handler.dart';
//
///* used for attaching and taking images/videos */
//
//class AttachmentButton extends StatefulWidget {
//
//  final bool fromGallery;
//  final bool isVideo;
//
//  AttachmentButton({this.fromGallery, this.isVideo});
//
//  @override
//  AttachmentButtonState createState() {
//    return new AttachmentButtonState(fromGallery:this.fromGallery, isVideo:this.isVideo);
//  }
//}
//
//class AttachmentButtonState extends State<AttachmentButton> {
//
//  String text; // text to be displayed on button
//  Icon icon; // icon to be displayed on button
//
//  File attachedFile; // the attached/uploaded image/video
//
//  final bool fromGallery;
//  final bool isVideo;
//
//  AttachmentButtonState({this.fromGallery, this.isVideo});
//
//  AppPermissions appPermissions = new AppPermissions();
//
//  MyListProductManagerBloc productManagerBloc;
//
//  @override
//  void initState() {
//
//    if(isVideo) {
//
//      if(fromGallery) {
//        text = "video_from_gallery";
//        icon = Icon(Icons.video_library);
//      }
//
//      else {
//        text = "video_from_camera";
//        icon = Icon(Icons.videocam);
//      }
//    }
//
//    else {
//
//      if(fromGallery) {
//        text = "image_from_gallery";
//        icon = Icon(Icons.image);
//      }
//
//      else {
//        text = "image_from_camera";
//        icon = Icon(Icons.photo_camera);
//      }
//    }
//
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    this.productManagerBloc = BlocProvider.of<MyListProductManagerBloc>(context);
//    return FlatButton(
//      textColor: Colors.black,
//      color: Colors.white,
//      colorBrightness: Brightness.dark,
//      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//      shape: Border(),
//      child: FittedBox(
//        child: Row(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children:[
//              Column(children:[Container(child:icon)]),
//              Container(
//                child:
//                Text(
//                    tSentence(context,text),
//                    style: new TextStyle(color: Colors.black)
//                )
//              )
//            ],
//        ),
//      ),
//      onPressed: () => this._buttonPressed(context),
//    );
//  }
//
//  _buttonPressed(context) async {
//
//    List<PermissionGroup> requiredPermissions = [];
//    ImageSource imageSource;
//
//    requiredPermissions.add(PermissionGroup.camera);
//
//    if(fromGallery){
//      requiredPermissions.add(PermissionGroup.storage);
//      imageSource = ImageSource.gallery;
//    }
//
//    else{
//      imageSource = ImageSource.camera;
//      if(isVideo && !fromGallery)
//          requiredPermissions.add(PermissionGroup.microphone);
//    }
//
////    // get the current permissions status of the needed permissions or request it
//
//    Map<PermissionGroup, PermissionStatus> currentPermissions = await appPermissions.getOrRequestPermissions(requiredPermissions);
//
//    currentPermissions.forEach((permissionGroup,permissionStatus) async {
//      if(permissionStatus != PermissionStatus.granted){
//        showTextSnackBar(context, 'requested permissions denied');
//        return; // one of the needed permissions isn't granted
//      }
//    });
//
//    if(isVideo)
//      attachedFile = await ImagePicker.pickVideo(source: imageSource);
//
//    else {
//      attachedFile = await ImagePicker.pickImage(source: imageSource);
//      attachedFile = await _cropImage(attachedFile);
//    }
//
//    dynamic uploadResult = await _updateStream(context);
//
//    setState(() {
//
//      Navigator.of(context).pop(); // pop the alert that prompted the attachment
//      Navigator.of(context).pop(); // pop the alert that says uploading attachment
//
//      if(uploadResult["error"] != null){
//
//        // alert that an error occurred in uploading the attachment to server
//
//        showDialog<void>(
//          barrierDismissible: true,
//          context: context,
//          builder: (BuildContext context) {
//            return AlertDialog(
//              content: Container(
//                child:Center(
//                    child:
//                    Text(uploadResult["error"])
//                ),
//                width: 50,
//                height: 50,
//              ),
//              actions: <Widget>[
//                new FlatButton(
//                    child: Text(tUpper(context, 'ok')),
//                    onPressed: () {
//                      Navigator.pop(context, false);
//                    }
//                )
//              ],
//            );
//          },
//        );
//      }
//    });
//  }
//
//  Future<File> _cropImage(File imageFile) async {
//
//    return  await ImageCropper.cropImage(
//      sourcePath: imageFile.path,
//      ratioX: 1.0,
//      ratioY: 1.0,
//    );
//  }
//
//  Future<dynamic> _updateStream(context) async {
//
//    showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          content: Container(
//            child:Center(
//                child: Text(tSentence(context, "uploading_attachment"))
//            ),
//            width: 100,
//            height: 100,
//          ),
//        );
//      },
//    );
//
//    // @todo handle when user cancels without uploading i.e. attachfile.path = null
//    return await productManagerBloc.uploadAttachment(attachedFile.path, isVideo);
//  }
//}