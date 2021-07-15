//import 'dart:collection';
//import 'dart:io';
//import 'dart:math';
//
//import 'package:flutter/material.dart';
//import 'package:momday_app/backend_helpers/momday_backend.dart';
//import 'package:momday_app/bloc_provider.dart';
//import 'package:momday_app/models/models.dart';
//import 'package:momday_app/momday_localizations.dart';
//import 'package:momday_app/momday_utils.dart';
//import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';
//import 'package:momday_app/widgets/attachment_button/attachment_button.dart';
//import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
//import 'package:momday_app/widgets/upload_button/upload_button.dart';
//import 'package:video_player/video_player.dart';
//
///* used by product image and video views */
//
//class AttachmentPreview extends StatefulWidget {
//
//  final bool isVideo;
//  final MyListProductModel selectedProduct;
//  final bool displayError;
//  AttachmentPreview({this.isVideo, this.selectedProduct,this.displayError});
//
//  @override
//  AttachmentPreviewState createState() {
//    return new AttachmentPreviewState(isVideo: this.isVideo);
//  }
//}
//
//class AttachmentPreviewState extends State<AttachmentPreview> {
//
//  final bool isVideo;
//  AttachmentPreviewState({this.isVideo});
//  MyListProductManagerBloc productManagerBloc;
//
//  VideoPlayerController videoController;
//  VoidCallback videoPlayerListener;
//
//  List<Map<String,dynamic>> images = [];
//  Map<String,dynamic> previewed;
//  bool loadingVideo = false;
//  bool missingImages = false;
//  bool missingVideo = false;
//
//  @override
//  void initState() {
//
//    super.initState();
//    videoPlayerListener = () {
//      setState(() {});
//    };
//
//    this.productManagerBloc = BlocProvider.of<MyListProductManagerBloc>(context);
//    productManagerBloc.actionStream.listen((Action action) {
//
//      setState(() {
//
//        if(action != null){
//
//          if(action.type == MyListProductManagerActionTypes.uploadedAttachment) {
//
//            if(action.data["error"] != null){
//              return;
//            }
//
//            if(action.data["type"].toString() == 'image') {
//
//              images = List.from(images)..add(action.data);
//              missingImages = false;
//            }
//
//            else{
//              missingVideo = false;
//            }
//
//            previewed = action.data;
//          }
//
//          else if(action.type == MyListProductManagerActionTypes.preview)
//            previewed = action.data;
//
//          else if(action.type == MyListProductManagerActionTypes.deletedAttachment) {
//
//            images = List.from(images)..remove(action.data);
//            if(images.length > 0)
//              previewed = images[images.length -1];
//            else
//              previewed = null;
//          }
//        }
//      });
//    });
//
//    if(this.widget.selectedProduct != null){
//
//      if(this.widget.selectedProduct.images != null && !isVideo)
//        for(String image in this.widget.selectedProduct.images)
//          if(!isVideo)
//            productManagerBloc.uploadAttachment(image,isVideo);
//
//      if(isVideo) {
//        productManagerBloc.uploadAttachment(this.widget.selectedProduct.video,isVideo);
//      }
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    return ListView(
//        children: <Widget>[
//          Text(
//            isVideo ? tTitle(context, "video") : tTitle(context, "photos"),
//            style: new TextStyle(
//                fontSize: 30.0,
//                color: Colors.black
//            )
//          ),
//
//          Text(
//            isVideo ? tSentence(context, "upload_video_header"):tSentence(context, "upload_image_header"),
//            style: new TextStyle(
//                  fontSize: 17.0,
//                  color: Colors.black)
//          ),
//          _previewContainer(),
//          (!isVideo) ? _imageListView():Container(),
//          this.widget.displayError && !isVideo?
//          Text(
//            tSentence(context, "image_required"),
//            textAlign: TextAlign.center,
//            style:
//            TextStyle(color: Colors.redAccent.shade700, fontSize: 14.0),
//          ) :Container()
//        ]
//    );
//  }
//
//  Widget _imageListView(){
//
//    return Container(
//      margin: const EdgeInsets.all(10.0),
//      padding: EdgeInsets.all(0),
//      child: GridView.count(
//        crossAxisCount: 5,
//        scrollDirection: Axis.vertical,
//        shrinkWrap:true,
//        children: images.map((imageFile) {
//          return _smallImagePreview(imageFile);
//        }).toList()..add(_addImageButton())
//      ),
//    );
//  }
//
//  Widget _addImageButton(){
//
//    if(images.length > 0 && images.length < 4){
//      return Container(
//        padding: const EdgeInsets.all(0.0),
//        margin: const EdgeInsets.only(left: 10),
//        child: GestureDetector(
//          onTap: _displayAlert,
//            child: Icon(Icons.add),
//        ),
//      );
//    }
//
//    return Container();
//  }
//
//  Widget _smallImagePreview(Map<String,dynamic> attachment) {
//
//    return Container(
//      margin: const EdgeInsets.only(left: 10),
//      padding: const EdgeInsets.all(0.0),
//      width: 50,
//      height: 50,
//      child: GestureDetector(
//        onTap: () => productManagerBloc.actionSink.add(new Action(MyListProductManagerActionTypes.preview, attachment)),
//        child:
//          attachment["attachment_path"].startsWith("http") ? Image.network(attachment["attachment_path"]) : Image.file(File(attachment["attachment_path"])),
//      ),
//    );
//  }
//
////  Future<void> _startVideoPlayer(String videoFile) async {
////
////    setState(() {
////      loadingVideo = true;
////    });
////
////    if(videoFile.startsWith("http"))
////      videoController = VideoPlayerController.network(videoFile);
////    else
////      videoController = VideoPlayerController.file(File(videoFile));
////
////    videoPlayerListener = () {
////      if (videoController != null && videoController.value.size != null) {
////        videoController.removeListener(videoPlayerListener);
////      }
////    };
////
////    videoController.addListener(videoPlayerListener);
////    await videoController.setLooping(true);
////    await videoController.initialize();
////
////    if (mounted) {
////      setState(() {
////        loadingVideo = false;
////      });
////    }
////
////    await videoController.play();
////  }
//
//  Widget _previewContainer(){
//
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        Container(
//            margin: const EdgeInsets.only(top: 10),
//            child:previewed != null ?_attachmentPreview(previewed):_uploadButtonView(),
//            width: min(MediaQuery.of(context).size.width, 300),
//            height: 300.0
//        ),
//      ],
//    );
//  }
//
//  Widget _attachmentPreview(Map<String,dynamic> attachedFile){
//
//    if(isVideo)
//      return _videoView(attachedFile);
//
//    else
//      return _imageView(attachedFile);
//  }
//
//  Widget _imageView(Map<String,dynamic> image){
//
//    return Center(
//        child:Stack(
//            children:[
//              image["attachment_path"].startsWith("http")? MomdayNetworkImage(imageUrl: image["attachment_path"]):
//              Image.file(File(image["attachment_path"])),
//              Positioned(
//                  top: 0,
//                  child:ButtonTheme(
//                    minWidth: 30.0,
//                    child:  FlatButton(
//                      child:Icon(Icons.clear),
//                      onPressed: () => alertDelete(image)
//                    )
//                  )
//              )
//            ]
//        )
//    );
//  }
//
//  void alertDelete(Map<String,dynamic> attachedFile) {
//
//      showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: new Text(tSentence(context, "delete_attachment")),
//            content: new Text(tSentence(context, "delete_attachment_confirm")),
//            actions: <Widget>[
//              new FlatButton(
//                child: new Text(tSentence(context, "delete")),
//                onPressed: () async {
//                  Navigator.of(context).pop();
//                  await _removeAttachment(attachedFile, context);
//                },
//              ),
//              new FlatButton(
//                child: new Text(tSentence(context, "cancel")),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              )
//            ],
//          );
//        },
//      );
//  }
//
//  Widget _videoView(Map<String,dynamic> attachedFile){
//
//    if(videoController == null) {
//      return Center(
//        child: Container(
//            color: Colors.white,
//            child:
//            FlatButton(
//              splashColor: Colors.transparent,
//              highlightColor: Colors.transparent,
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                Text(
//                  tTitle(context, 'preview_video'),
//                  style: TextStyle(
//                      fontSize: 12
//                  ),
//                ),
//                Icon(Icons.play_circle_filled),
//                ],
//              ),
//              onPressed: () => _startVideoPlayer(attachedFile["attachment_path"]),
//            )
//        ),
//      );
//    }
//
//    return Center(child:Stack(
//        children:[
//          loadingVideo ? Text(
//              tTitle(context, 'loading_video'),
//              style: TextStyle(
//                  fontSize: 12,
//                  color: Colors.black
//              )
//          ) :
////          VideoPlayer(videoController),
//          Positioned(
//              top: 0,
//              child:
//              ButtonTheme(
//                  minWidth: 30.0,
//                  child:  FlatButton(
//                      child:Icon(Icons.clear),
//                      onPressed: () => alertDelete(attachedFile)
//                  )
//              )
//          ),
//        ]
//    ));
//  }
//
//  _removeAttachment(Map<String,dynamic> attachedFile, context) async {
//
//    dynamic response = await this.productManagerBloc.deleteAttachment(this.widget.selectedProduct != null? this.widget.selectedProduct.id : null, attachedFile, isVideo);
//
//    if (response['success'] != 1)
//      videoController = null;
//
//    else if (response["error"] != null && response["error"].length != 0) {
//
//      // alert that an error occurred in deleting the attachment
//      showDialog<void>(
//        barrierDismissible: true,
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            content: Container(
//              child: Center(
//                  child:
//                  Text(response["error"])
//              ),
//              width: 50,
//              height: 50,
//            ),
//            actions: <Widget>[
//              new FlatButton(
//                  child: Text(tUpper(context, 'ok')),
//                  onPressed: () {
//                    Navigator.pop(context, false);
//                  }
//              )
//            ],
//          );
//        },
//      );
//    }
//  }
//
//  Widget _uploadButtonView(){
//    return Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children:[
//          BlocProvider<MyListProductManagerBloc>(
//            bloc: this.productManagerBloc,
//            child: UploadButton(isVideo: isVideo),
//          )
//        ]
//    );
//  }
//
//  @override
//  void dispose() {
//
//    super.dispose();
//    if(videoController != null) {
//      videoController.dispose();
//      videoController = null;
//    }
//  }
//
//  @override
//  void deactivate() {
//
//    if (videoController != null) {
//      videoController.pause();
//      videoController.removeListener(videoPlayerListener);
//    }
//
//    super.deactivate();
//  }
//
//  @override
//  void didUpdateWidget(AttachmentPreview oldWidget) {
//
//    if(videoController != null)
//      videoController.pause();
//
//    videoController = null;
//    videoPlayerListener = null;
//
//    super.didUpdateWidget(oldWidget);
//  }
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
//                      )]
//                ),
//                Row(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children:[
//                      BlocProvider<MyListProductManagerBloc>(
//                        bloc: this.productManagerBloc,
//                        child: AttachmentButton(isVideo: isVideo,fromGallery: false,),
//                      )
//                    ]
//                ),
//              ],
//            ),
//          ),
//        );
//      },
//    );
//  }
//}