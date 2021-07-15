import 'dart:async';
import 'dart:io';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
//import 'package:video_player/video_player.dart';

enum MyListProductManagerActionTypes {deletedAttachment, uploadedAttachment, preview}

class Action {

  MyListProductManagerActionTypes type;
  Map<String,dynamic> data;

  Action(this.type, this.data);
}

class MyListProductManagerBloc extends BlocBase {

  MyListProductManagerBloc();

  StreamController<MyListProductModel> _dataController = StreamController<MyListProductModel>();
  StreamSink<MyListProductModel> get dataSink => _dataController.sink;
  Stream<MyListProductModel> get dataStream => _dataController.stream;

  StreamController<Action> _actionController = StreamController<Action>.broadcast();
  StreamSink<Action> get actionSink => _actionController.sink;
  Stream<Action> get actionStream => _actionController.stream;

  updateDescription(String name, String description, BrandModel brand, CategoryModel category, CategoryModel subcategory, String condition,
      String size, String color, double price, UnitModel dimensionsUnit, double width, double height, double length,
      UnitModel weightUnit, double weight, String pickupLocation, CharityModel charity){

    MyListProductModel productModel = MyListProductModel();
    productModel.name = name;

    productModel.description = description;

    if(brand != null) {
      productModel.brandId = brand.brandId;
      productModel.brandName = brand.name;
    }

    if(category != null)
      productModel.categoryId = category.categoryId;

    if(subcategory != null)
      productModel.subcategoryId = subcategory.categoryId;

    productModel.condition = condition;
    productModel.size = size;
    productModel.color = color;
    productModel.price = price;

    if(dimensionsUnit != null)
      productModel.dimensionsUnit = dimensionsUnit.id;

    productModel.width = width;
    productModel.height = height;
    productModel.length = length;

    if(weightUnit != null)
      productModel.weightUnit = weightUnit.id;

    productModel.weight = weight;
    productModel.pickupLocation = pickupLocation;

    if(charity != null)
      productModel.charityId = charity.charityId;

    dataSink.add(productModel);
  }

  bool validateItem(MyListProductModel productModel){

    // required fields
    if(productModel.name == null || productModel.name == '' ||
        productModel.description == null || productModel.description == '' ||
        productModel.brandId == null || productModel.brandId == '' ||
        productModel.categoryId == null || productModel.categoryId == '' ||
//        productModel.subcategoryId == null || productModel.subcategoryId == '' || check if this category has a sub
        productModel.condition == null || productModel.condition == '' ||
        productModel.price == null || productModel.price == 0 ||
        productModel.pickupLocation == null || productModel.pickupLocation == ''){

      return false;
    }

    if(!validateDimensions(productModel) || !validateWeight(productModel))
      return false;

    return true;
  }

  bool validateDimensions(MyListProductModel productModel){

    // user should specify both unit and the dimensions or neither

    if((productModel.dimensionsUnit == null || productModel.dimensionsUnit == '')
        && (productModel.length == null || productModel.length == 0)
        && (productModel.height == null || productModel.height == 0)
        && (productModel.width == null || productModel.width == 0)) {

      return true;
    }

    if(productModel.dimensionsUnit != null && productModel.dimensionsUnit == ''
        && productModel.length != null && productModel.length != 0
        && productModel.height != null && productModel.height != 0
        && productModel.width != null && productModel.width != 0) {

      return true;
    }

    return false;
  }

  bool validateWeight(MyListProductModel productModel){

    // user should specify both unit and the weight or neither

    if((productModel.dimensionsUnit == null || productModel.dimensionsUnit == '')
        && (productModel.length == null || productModel.length == 0)
        && (productModel.height == null || productModel.height == 0)
        && (productModel.width == null || productModel.width == 0)) {

      return true;
    }

    if(productModel.dimensionsUnit != null && productModel.dimensionsUnit == ''
        && productModel.length != null && productModel.length != 0
        && productModel.height != null && productModel.height != 0
        && productModel.width != null && productModel.width != 0) {

      return true;
    }

    return false;
  }

  bool validateProduct(MyListProductModel productModel){
    return validateItem(productModel); // && validateImages()
  }

//  Future<int> videoLength(String videoPath) async {
//
//    // function that calculates the length of the video
//
//    VideoPlayerController videoController = VideoPlayerController.file(File(videoPath));
//    await videoController.initialize();
//
//    int duration;
//
//    if(videoController.value.duration != null)
//      duration = videoController.value.duration.inSeconds;
//
//    await videoController.dispose();
//    return duration;
//  }

  Future<dynamic> uploadPrelovedItem(MyListProductModel productModel) async{

    return await MomdayBackend().uploadPrelovedItem(productModel);
  }

  uploadAttachment(String attachmentPath, bool isVideo) async {

    if(attachmentPath == null)
      return {};

    if(attachmentPath.startsWith("http")){

      dynamic result = {
        'attachment_path': attachmentPath,
        'type': isVideo? 'video' : 'image'
      };

      this.actionSink.add(Action(MyListProductManagerActionTypes.uploadedAttachment,result));
      return result;
    }

//    if(isVideo){
//      int duration = await this.videoLength(attachmentPath);
//      if(duration == null)
//        return {'error': 'invalid file'};
//
//      else if (duration > 5)
//        return {'error': 'video length should be less than or equal to 5 seconds'};
//    }

    Map<String,dynamic> uploadAttachmentResponse = await MomdayBackend().uploadAttachment(attachmentPath,isVideo);

    if (uploadAttachmentResponse['success'] == 1) {

      if(uploadAttachmentResponse['data']['error'] != null){
        return {'error': uploadAttachmentResponse['data']['error']};
      }

      Map<String,dynamic> result = <String, dynamic>{};
      result['attachment_path'] = attachmentPath;
      result['image_directory'] = uploadAttachmentResponse['data']['image_directory'];
      result['filename'] = uploadAttachmentResponse['data']['filename'];
      result['type'] = isVideo? 'video' : 'image';

    this.actionSink.add(Action(MyListProductManagerActionTypes.uploadedAttachment,result));
      return result;
    }

    else if(uploadAttachmentResponse['error'] != null){
      return {'error': uploadAttachmentResponse['error']};
    }

    return {};
  }

  dynamic deleteAttachment(String productId, Map<String,dynamic> attachmentPath, bool isVideo) async {

    attachmentPath["type"] = isVideo? 'video': 'image';

    dynamic response = await MomdayBackend().deleteAttachment(productId, attachmentPath["filename"], isVideo);

    if(response['success'] == 1)
      this.actionSink.add(new Action(MyListProductManagerActionTypes.deletedAttachment, attachmentPath));

    return response;
  }

  @override
  dispose(){

  }

  disposeBloc() {
    _dataController.close();
    dataSink.close();
    _actionController.close();
    actionSink.close();
  }
}