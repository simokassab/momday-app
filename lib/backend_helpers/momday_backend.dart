import 'dart:async';
import 'package:momday_app/backend_helpers/momday_http.dart';
import 'package:momday_app/models/models.dart';
import 'package:xml/xml.dart';
class MomdayBackend {

  MomdayHttp _httpClient;

  static final MomdayBackend _momdayBackend = new MomdayBackend._internal(new MomdayHttp());
  MomdayBackend._internal(this._httpClient) {
    this._httpClient.init();
  }

  factory MomdayBackend() {
    return MomdayBackend._momdayBackend;
  }

  set language(String language) {
    this._httpClient.language = language;
  }

  Future<List> getFeaturedItems() async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.get(
      'feed/rest_api/featured',null,
    );

    if(response['data'] != null)
      return response['data'][0]['products'];

    return [];
  }

  Future<dynamic> getCategories() async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.get(
      'feed/rest_api/categories',null,
    );
    return response;
  }

  Future<dynamic> signUp(String firstName, String lastName, String email, String dob, String gender, String phoneNumber, String password, String confirmPassword) async {

    await this._httpClient.isInitialized;

    dynamic response = await this._httpClient.post('rest/register/register', {
      "firstname": firstName,
      "lastname": lastName,
      "email": email,
      "password": password,
      "confirm": confirmPassword,
      "telephone": phoneNumber,
      "agree": "1",
      "custom_field": {
        "account": {
          "12": dob,
          "13": gender
        },
      }
    });

    return response;
  }

  Future<dynamic> login(String email, {String password, String accessToken, String provider}) async {

    await this._httpClient.isInitialized;
    assert(password != null || (accessToken != null && provider != null));
    assert(password == null || (accessToken == null && provider == null));

    if (password != null) {
      return await this._httpClient.post('rest/login/login', {
        'email': email,
        'password': password
      });
    } else {
      return await this._httpClient.post('rest/login/sociallogin', {
        'email': email,
        'social_access_token': accessToken,
        'provider': provider
      });
    }
  }

  Future<dynamic> logout() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.post('rest/logout/logout', []);
  }

  Future<dynamic> forgotPassword(String email) async {
    await this._httpClient.isInitialized;
    return await this._httpClient.post('rest/forgotten/forgotten', {
      'email': email
    });
  }

  Future<int> getProductsCount({String categoryId, String brandId, String celebrityId, List<String> filters}) async {
    await this._httpClient.isInitialized;
    String params = this._constructGetParams({
      'category': categoryId,
      'subcategory': categoryId != null? '1' : '0',
      'manufacturer': brandId,
      'filters': filters.join(','),
      'celebrity_id': celebrityId
    });

    dynamic response = await this._httpClient.get('feed/rest_api/products' + params,null);

    return response['data'].length;
  }

  Future<List> getProducts({String categoryId, String celebrityId,
    int limit, int pageNumber, bool simple, String sortOption, String sortDirection, String brandId,
    List<String> filters, String type}) async {

    String itemsType = "";

    if(type == "preloved"){
      itemsType = "momday_preloved_products";
    }

    else{
      itemsType = "momday_new_products";
    }

    if(celebrityId != null){
      itemsType = 'celebrity';
    }

    dynamic request = {
      itemsType: '1',
      'category': categoryId,
      'subcategory': categoryId != null? '1' : '0',
      'limit': limit.toString(),
      'page': pageNumber.toString(),
      'simple': simple? '1' : '0',
      'sort': sortOption,
      'order': sortDirection,
      'manufacturer': brandId,
      'filters': filters.join(','),
      'celebrity_id': celebrityId,
      'type':type,
    };

    await this._httpClient.isInitialized;
    String params = this._constructGetParams(request);

    dynamic response = await this._httpClient.get('feed/rest_api/products' + params,null);

    return response['data'];
  }

  Future<dynamic> getProduct({String productId}) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.get('feed/rest_api/products&id=$productId',null);

    return response['data'];
  }

  Future<dynamic> getMyListProduct({String productId}) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.get('feed/rest_api/get_preloved_product&id=$productId',null);

    return response['data'];
  }

  Future<dynamic> getRelatedProducts({String productId}) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.get('feed/rest_api/related&id=$productId',null);

    return response['data'];
  }

  dynamic _constructGetParams(Map<String, dynamic> params) {
    List<dynamic> paramsList = [];

    params.forEach((key, value) {
      if (value != null) {
        paramsList.add(key + '=' + value);
      }
    });

    dynamic result = paramsList.join('&');

    if (result.length != 0) {
      result = '&' + result;
    }

    return result;
  }

  Future<dynamic> addProductToWishlist({String productId}) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.post('rest/wishlist/wishlist&id=$productId', []);

    return response;
  }

  Future<dynamic> removeProductFromWishlist({String productId}) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.delete('rest/wishlist/wishlist&id=$productId');

    return response;
  }

  Future<dynamic> removeProductFromCart({String productKey}) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.delete('rest/cart/cart&key=$productKey');

    return response;
  }

  Future<dynamic> addProductToCart({String productId,
    int quantity = 1, Map<OptionModel,OptionValueModel> selectedOptions}) async {

    await this._httpClient.isInitialized;

    dynamic request = {
      'product_id': productId,
      'quantity': quantity,
    };

    dynamic options = {};

    if(selectedOptions != null) {
      for (OptionModel option in selectedOptions.keys) {
        options[option.productOptionId] =
            selectedOptions[option].productOptionValueId;
      }
    }

    request["option"] = options;
print("request is: $request");
    dynamic response = await this._httpClient.post('/rest/cart/cart', request);

    return response;
  }

  Future<dynamic> changeProductQuantityInCart({String productKey, int quantity}) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.put('/rest/cart/cart', {
      'key': productKey,
      'quantity': quantity
    });
  }

  Future<dynamic> getAccount() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get('rest/account/account',this._httpClient.xsession);
    //return await this._httpClient.get('api/login');
  }

  Future<dynamic> getWishlist() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get('rest/wishlist/wishlist',this._httpClient.xsession);
  }

  Future<dynamic> getCart() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get('/rest/cart/cart',this._httpClient.xsession);
  }

  Future<dynamic> getDeepCategories() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
        'feed/rest_api/categories&level=5',null,
        imageDimensions: '140x100'
    );
  }

  Future<dynamic> getBrands() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
      'feed/rest_api/manufacturers',null
    );
  }

  Future<dynamic> getCharities() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
      'feed/momday/preloved/charities',null
    );
  }

  Future<dynamic> getConditions() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
      'feed/momday/preloved/product_condition_values',null
    );
  }

  Future<dynamic> getDimensionsUnits() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
      'feed/momday/preloved/length_class',null
    );
  }

  Future<dynamic> getWeightUnits() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
      'feed/momday/preloved/weight_class',null
    );
  }

  Future<dynamic> getCities(int country_id) async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get(
      'feed/rest_api/countries&id='+country_id.toString(),null
    );
  }

  Future<dynamic> getShippingAddresses() async {
    await this._httpClient.isInitialized;
    return await this._httpClient.get('rest/shipping_address/shippingaddress',this._httpClient.xsession);
  }

  Future<dynamic> validateAddress({String countryCode, String city, String address}) async {
    await this._httpClient.isInitialized;

    List<String> addressLines = address.split('\n');

    String params = this._constructGetParams({
      'country_code': countryCode,
      'city': city,
      'address_line_1': addressLines[0],
      'address_line_2': addressLines.length > 1? addressLines[1] : '',
    });

    dynamic response = await this._httpClient.get('feed/rest_api/validate_address' + params,this._httpClient.xsession);

    print('response is $response');
    return response['data'];
  }

  Future<dynamic> addAddress({String firstName, String lastName, int countryId, String city, String address}) async {
    await this._httpClient.isInitialized;

    List<String> addressLines = address.split('\n');

    dynamic response = await this._httpClient.post('rest/account/address', {
      'firstname': firstName,
      'lastname': lastName,
      'city': city,
      'address_1': addressLines[0],
      'address_2': addressLines.length > 1? addressLines[1] : '',
      'zone_id': 1, // not used
      'country_id': countryId,
      'postcode': '0000' // not used
    });

    return response;
  }

  Future<dynamic> editAddress({String addressId, String firstName, String lastName, int countryId, String city, String address}) async {
    await this._httpClient.isInitialized;

    List<String> addressLines = address.split('\n');

    dynamic response = await this._httpClient.put('rest/account/address&id=$addressId', {
      'firstname': firstName,
      'lastname': lastName,
      'city': city,
      'address_1': addressLines[0],
      'address_2': addressLines.length > 1? addressLines[1] : '',
      'zone_id': 1, // not used
      'country_id': countryId,
      'postcode': '0000' // not used
    });

    return response;
  }

  Future<dynamic> deleteAddress({String addressId}) async {
    await this._httpClient.isInitialized;

    dynamic response = await this._httpClient.delete('rest/account/address&id=$addressId');

    return response;
  }

  Future<dynamic> getAddresses() async {
    await this._httpClient.isInitialized;

    return await this._httpClient.get('rest/account/address',this._httpClient.xsession);
  }

  Future<dynamic> writeReview({String productId, String name, String text, double rating}) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.post('feed/rest_api/reviews&id=$productId', {
      'name': name,
      'text': text,
      'rating': rating
    });
  }

  Future<dynamic> editProfile({String firstName, String lastName, String email, String phoneNumber}) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.put('rest/account/account', {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'telephone':phoneNumber,
    });
  }

  Future<dynamic> changePassword({String newPassword, String confirmPassword}) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.put('rest/account/password', {
      'password': newPassword,
      'confirm': confirmPassword
    });
  }

  Future<dynamic> getCelebrities() async {
    await this._httpClient.isInitialized;

    return await this._httpClient.get('feed/momday/celebrity/celebrities',null

    );
  }

  Future<dynamic> addProductToStore({String productId}) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.post('rest/momday/celebrity/productToCelebrityStore', {
      'product_id': productId
    });
  }

  Future<dynamic> removeProductFromStore({String productId}) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.delete('rest/momday/celebrity/productToCelebrityStore&product_id=$productId');
  }

  Future<dynamic> getCelebrity(String celebrityId) async {
    await this._httpClient.isInitialized;

    return await this._httpClient.get('feed/momday/celebrity/celebrity_categories&id=$celebrityId',null,
    );
  }

  Future<dynamic> getMomsayPost(String postId) async {
    await this._httpClient.isInitialized;
    dynamic response = await this._httpClient.get('rest/momday/momsay/post&post_id=$postId',null,);
    return response['data'];
  }
  Future<dynamic> PayfortRequest({String amount, String email, String token_name, String card_number,String card_security_code,String expiry_date,String card_holder_name}) async{
    dynamic response = await this._httpClient.requestToPayfort({'command':'PURCHASE',
      'access_code': 'pPtc4lykkRxpahhWK34L',
      'merchant_identifier': 'cbfd3f63',
      'merchant_reference': 'TEST81003',
      'amount': amount,
      'currency': 'USD',
      'language': this._httpClient.language,
      'customer_email': email,
      'token_name': token_name,
      'return_url': 'http://momday.net/index.php?route=payment/payfort_fort/response',
      'card_security_code': card_security_code,
      'card_number':card_number,
      'expiry_date':expiry_date,
      'card_holder_name':card_holder_name
    });
    return response['response_message'];
  }
  Future<dynamic> AramexRequest({int width, int height, int length, int weight,String description,int nbpeices,List<Item> items}) async{

    AramexModel amx = new AramexModel();
    amx.clientInfo.userName = "testingapi@aramex.com";
    amx.clientInfo.password="R123456789\$r";
    amx.clientInfo.version="2.0";
    amx.clientInfo.accountNumber="60501036";
    amx.clientInfo.accountPin="216216";
    amx.clientInfo.accountEntity="AMM";
    amx.clientInfo.accountCountryCode="LB";
    amx.clientInfo.source=1;
    amx.labelInfo="null";
    Shipment shp = new Shipment();
    shp.reference1="Z1548741133331";
    shp.reference2="";
    shp.reference3="";
    Consignee shipper = new Consignee();
    shipper.reference2="";
    shipper.reference1="";
    shipper.accountNumber="20016";
    PartyAddress ptaddr = PartyAddress.fromJson({ "Line1":"TEST FROM COSMALINE",
        "Line2":"",
        "Line3":"",
        "City":"Beirut",
        "StateOrProvinceCode":"",
        "PostCode":"",
        "CountryCode":"LB",
        "Longitude":0,
        "Latitude":0,
        "BuildingNumber":null,
        "BuildingName":null,
        "Floor":null,
        "Apartment":null,
        "POBox":null,
        "Description":null});
    shipper.partyAddress=ptaddr;
    Contact contact = Contact.fromJson({
      "Department":"",
      "PersonName":"TEST FROM COSMALINE",
      "Title":"",
      "CompanyName":"TEST COMPANY COSMALINE",
      "PhoneNumber1":"03000000",
      "PhoneNumber1Ext":"",
      "PhoneNumber2":"",
      "PhoneNumber2Ext":"",
      "FaxNumber":"",
      "CellPhone":"03777777",
      "EmailAddress":"test@test.com",
      "Type":""
    });
    shipper.contact=contact;

    shp.shipper=shipper;

    Consignee consignee = new Consignee();
    consignee.reference2="";
    consignee.reference1="";
    consignee.accountNumber="";
    PartyAddress consigneeaddr = PartyAddress.fromJson({
      "Line1":"TEST ADDRESS IN LEBANON",
      "Line2":null,
      "Line3":null,
      "City":"Beirut",
      "StateOrProvinceCode":"",
      "PostCode":"",
      "CountryCode":"LB",
      "Longitude":0,
      "Latitude":0,
      "BuildingNumber":"",
      "BuildingName":"",
      "Floor":"",
      "Apartment":"",
      "POBox":null,
      "Description":""
    });
    consignee.partyAddress=consigneeaddr;
    Contact consigneecontact = Contact.fromJson({
      "Department":"",
      "PersonName":"TEST CONTACT in LEBANON",
      "Title":"",
      "CompanyName":"TEST CONTACT IN LEBANON",
      "PhoneNumber1":"009613010101",
      "PhoneNumber1Ext":"",
      "PhoneNumber2":"",
      "PhoneNumber2Ext":"",
      "FaxNumber":"",
      "CellPhone":"009613515111",
      "EmailAddress":"test@gmail.com",
      "Type":""
    });
    consignee.contact=consigneecontact;
    shp.consignee=consignee;
    Consignee ThirdParty = new Consignee();
    ThirdParty.reference2="";
    ThirdParty.reference1="";
    ThirdParty.accountNumber="";
    PartyAddress Thpartygneeaddr = PartyAddress.fromJson({
      "Line1":"",
      "Line2":"",
      "Line3":"",
      "City":"",
      "StateOrProvinceCode":"",
      "PostCode":"",
      "CountryCode":"",
      "Longitude":0,
      "Latitude":0,
      "BuildingNumber":null,
      "BuildingName":null,
      "Floor":null,
      "Apartment":null,
      "POBox":null,
      "Description":null
    });
    ThirdParty.partyAddress=Thpartygneeaddr;
    ThirdParty.contact= new Contact.fromJson({
      "Department":"",
      "PersonName":"",
      "Title":"",
      "CompanyName":"",
      "PhoneNumber1":"",
      "PhoneNumber1Ext":"",
      "PhoneNumber2":"",
      "PhoneNumber2Ext":"",
      "FaxNumber":"",
      "CellPhone":"",
      "EmailAddress":"",
      "Type":""
    });
    shp.thirdParty=ThirdParty;
    shp.shippingDateTime="Date("+DateTime.now().toString()+")";
    shp.comments="";
    shp.pickupLocation="";
    shp.operationsInstructions="";
    shp.accountingInstrcutions="";
    Details dt = new Details();
    Dimensions dimensions=new Dimensions();
    dimensions.height=0;
    dimensions.width=0;
    dimensions.length=0;
    dimensions.unit="cm";
    dt.dimensions=dimensions;
    dt.actualWeight = new Weight.fromJson({"Unit":"KG","value":weight});
    dt.chargeableWeight=null;
    dt.descriptionOfGoods=description;
    dt.goodsOriginCountry="LB";
    dt.numberOfPieces=nbpeices;
    dt.productGroup="DOM";
    dt.productType="CDA";
    dt.paymentType="p";
    dt.paymentOptions="";
    dt.customsValueAmount=new Amount.fromJson({"CurrencyCode":"USD","Value":"10"});
    dt.cashOnDeliveryAmount = new Amount.fromJson({"CurrencyCode":"LBP","Value":"10"});
    dt.insuranceAmount="null";
    dt.cashAdditionalAmount="";
    dt.services="";

    Set<Item> set = Set.from(items);
    set.forEach((element) => dt.items.add(element));
    shp.attachments=[];
    shp.foreignHawb="";
    shp.transportType=0;
    shp.pickupGuid="";
    shp.number=null;
    shp.scheduledDelivery=null;
    amx.shipments.add(shp);
    amx.transaction=new Transaction.fromJson({
      "Reference1":"",
      "Reference2":"",
      "Reference3":"",
      "Reference4":"",
      "Reference5":""
    });

    //amx.shipments.add(value)
    dynamic response = await this._httpClient.requestToAramex({
      amx.toJson()
    });
    return response;

  }

  setLikeOnMomsayPost(String postId, bool value) async {

    await this._httpClient.isInitialized;

    final path = 'rest/momday/momsay/like_post&post_id=$postId';

    final request = {
      'post_id' : postId
    };

    if(value)
      return await this._httpClient.post(path, request);

    else
      return await this._httpClient.delete(path);
  }

  addCommentToMomsayPost({String postId, String comment, String parentCommentId}) async {

    await this._httpClient.isInitialized;

    final path = 'rest/momday/momsay/add_comment&post_id=$postId';
    var request = {
      'comment': comment,
      'post_id': postId,
    };

    if (parentCommentId != null) {
      request['comment_parent_id'] = '$parentCommentId';
    }

    else
      request['comment_parent_id'] = '';

    dynamic response = await this._httpClient.post(path, request);

    if(response['success'] == 1){
      return response['data']['comment_id'];
    }

    return -1;
  }

  getMomsayPostSummaries({int pageNumber, int limit}) async {

    await this._httpClient.isInitialized;
    int offset = (pageNumber) * limit;

    await this._httpClient.isInitialized;

    String params = this._constructGetParams({
      'limit' : '$limit',
      'offset': '$offset',
    });

    dynamic response = await this._httpClient.get('feed/momday/momsay/posts' + params,null,);

    return response['data'];
  }

  getActivitiesSummaries({int pageNumber, int limit}) async {

    int offset = (pageNumber) * limit;
    await this._httpClient.isInitialized;
    String params = this._constructGetParams({
      'limit' : '$limit',
      'offset': '$offset',
    });

    dynamic response = await this._httpClient.get('feed/momday/activities/activities' + params,this._httpClient.xsession);

    return response['data'];
  }

  getActivity({activityId}) async {

    await this._httpClient.isInitialized;

    dynamic response = await this._httpClient.get('feed/momday/activities/activity&activity_id=$activityId',this._httpClient.xsession);

    return response['data'];
  }

  Future<List> getMyListProducts({int limit, int pageNumber, String status}) async {

    await this._httpClient.isInitialized;

    String params = "";

    int offset = (pageNumber) * limit;

    if(status != null)
      params = this._constructGetParams({
        'limit': limit.toString(),
        'offset': offset.toString(),
      });

    else
      params = this._constructGetParams({
        'limit': limit.toString(),
        'offset': pageNumber.toString(),
      });

    dynamic response = await this._httpClient.get('rest/momday/preloved/get_customerseller_preloved_products' + params,this._httpClient.xsession);

    return response['data'];
  }

  getHome() async {

    await this._httpClient.isInitialized;

    final featuredProducts = await this.getFeaturedItems();
    final featuredCelebrities = await this.getCelebrities(); // 4 random celebrities
    final featuredBrands = await this.getBrands(); // 3 random brands

    return {
      'featured_products': featuredProducts,
      'featured_celebrities': featuredCelebrities["data"],
      'featured_brands': featuredBrands["data"],
      'featured_momsay_posts': await this.getMomsayPostSummaries(pageNumber: 0,limit: 2),
    };
  }

  Future<dynamic> uploadAttachment(String filePath, bool isVideo) async {

    await this._httpClient.isInitialized;
    return await this._httpClient.uploadAttachment(filePath, isVideo);
  }

  Future<dynamic> deleteAttachment(String productId, String pathToDelete, isVideo) async {

    await this._httpClient.isInitialized;

    String params = "&filename=$pathToDelete";
    if(productId != null)
      params += "&product_id=$productId";
    if(isVideo)
      params += "&is_video=1";

    dynamic response = await this._httpClient.delete('rest/momday/preloved/remove_image' + params);

    return response;
  }

  Future<dynamic> uploadPrelovedItem(MyListProductModel productModel) async {
    await this._httpClient.isInitialized;

    String imagesString = '';
    for (dynamic image in productModel.images){
      imagesString += image + ',';
    }

    print('images string is $imagesString');

    dynamic params = {
      'name': productModel.name,
      'description': productModel.description,
      'manufacturer_id': productModel.brandId,
      'manufacturer': productModel.brandName,
      'product_category': [productModel.categoryId, productModel.subcategoryId],
      'Condition': productModel.condition,
      'Color': productModel.color,
      'Size': productModel.size,
      'price': productModel.price,
      'length_class_id': productModel.dimensionsUnit,
      'length': productModel.length,
      'width': productModel.width,
      'height': productModel.height,
      'weight_class_id': productModel.weightUnit,
      'weight': productModel.weight,
      'address': productModel.pickupLocation,
      'charity_id': productModel.charityId,
      'product_image': imagesString,
      'video': productModel.video,
      "status": "0",
      "quantity": "1"
    };

    if(productModel.id != null)
      params['product_id'] = productModel.id;

    dynamic response = await this._httpClient.post('rest/momday/preloved/post_preloved_item', params);

    return response;
  }

  Future<dynamic> deactivateProduct(String productId) async{

    await this._httpClient.isInitialized;

    final path = 'rest/momday/preloved/deactivate_product';

    final request = {
      'product_id' : productId
    };

    print("request is $request");
    return await this._httpClient.post(path,request);
  }

  Future<dynamic> deleteProduct(String productId) async{

    await this._httpClient.isInitialized;

    final path = 'rest/momday/preloved/delete_product&product_id=$productId';

    final request = {
      'product_id' : productId
    };

    print("request is $request");
    return await this._httpClient.post(path,request);
  }
}