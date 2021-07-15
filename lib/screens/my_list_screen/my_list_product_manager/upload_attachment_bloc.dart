//import 'dart:async';
//import 'dart:io';
//
//import 'package:momday_app/bloc_provider.dart';
//
//enum UploadAttachmentActions {productDetails, deleteAttachment, uploadAttachment, previewAttachment, contactInfo}
//
//class Action {
//  UploadAttachmentActions type;
//  dynamic data;
//
//  Action(this.type, this.data);
//}
//
//class UploadAttachmentBloc extends BlocBase {
//
//  StreamController<File> _attachmentController = StreamController<File>();
//  StreamSink<File> get dataSink => _attachmentController.sink;
//  Stream<File> get dataStream => _attachmentController.stream;
//
//  StreamController<Action> _actionController = StreamController<Action>.broadcast();
//  StreamSink<Action> get actionSink => _actionController.sink;
//  Stream<Action> get actionStream => _actionController.stream;
//
//  @override
//  dispose() {
//
//  }
//
//  disposeBloc() {
//
//    _attachmentController.close();
//    _actionController.close();
//  }
//}