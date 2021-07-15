import 'dart:async';

import 'package:flutter/material.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/backend_helpers/momday_cache.dart';
import 'package:momday_app/backend_helpers/momday_http.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateManager extends StatefulWidget {
  final Widget child;

  AppStateManager({this.child});

  static _AppStateManagerState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_AppStateManagerInherited>()).data;
  }

  /// gets the inherited widget, but does not register for changes
  static _AppStateManagerState ofPassive(BuildContext context) {
    return (context.getElementForInheritedWidgetOfExactType<_AppStateManagerInherited>().widget as _AppStateManagerInherited).data;
  }

  @override
  _AppStateManagerState createState() => _AppStateManagerState();
}

class _AppStateManagerState extends State<AppStateManager> {

  bool _isPrepared = false;

  @override
  void initState() {
    super.initState();

    this.prepare().then((_) {
      setState(() {
        this._isPrepared = true;
      });
    });
  }

  AccountModel _account;
  CartModel _cart;
  WishlistModel _wishlist;
  List<NotificationModel> _notifications;
  List<CategoryModel> _categories;
  List<UnitModel> _weightUnits;
  List<UnitModel> _dimensionsUnits;
  List<BrandModel> _brands;
  List<dynamic> _conditions;
  List<String> _statuses;
  List<CharityModel> _charities;
  bool _notificationsEnabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // To get informed whenever the locale changes
    Localizations.localeOf(context);
    this._isPrepared = false;
    MomdayCache().clearCache().then((_) {
      this.prepare().then((_) {
        setState(() {
          this._isPrepared = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if (!this._isPrepared) {
      return SplashScreen();
    }

    return _AppStateManagerInherited(
        data: this,
        child: widget.child
    );
  }

  Future<void> prepare() async {
    List userInfo = await Future.wait(
        [
          MomdayBackend().getAccount(),
          MomdayBackend().getCart(),
          MomdayBackend().getWishlist(),
          MomdayBackend().getCategories(),
          MomdayBackend().getBrands(),
          MomdayBackend().getCharities(),
          MomdayBackend().getConditions(),
          MomdayBackend().getDimensionsUnits(),
          MomdayBackend().getWeightUnits(),
        ]
    );

    if (userInfo[0]['success'] == 1) {
      this._account = AccountModel.fromDynamic(userInfo[0]['data']);
    } else {
      this._account = AccountModel();
    }

    if (userInfo[1]['success'] == 1) {
      this._cart = CartModel.fromDynamic(userInfo[1]['data']);
    } else {
      this._cart = CartModel.empty();
    }

    if (userInfo[2]['success'] == 1) {
      this._wishlist = WishlistModel.fromDynamic(userInfo[2]['data']);
    } else {
      this._wishlist = WishlistModel.empty();
    }

    if (userInfo[3]['success'] == 1) {
      print(userInfo[3]['data']);
      this._categories = CategoryModel.fromDynamicList(userInfo[3]['data']);
    } else {
      this._categories = [];
    }

    if (userInfo[4]['success'] == 1) {
      this._brands = BrandModel.fromDynamicList(userInfo[4]['data']);
    } else {
      this._brands = [];
    }

    if (userInfo[5]['success'] == 1) {
      this._charities = CharityModel.fromDynamicList(userInfo[5]['data']);
    } else {
      this._charities = [];
    }

    if (userInfo[6]['success'] == 1) {
      this._conditions = userInfo[6]['data'];
    } else {
      this._conditions = [];
    }

    if (userInfo[7]['success'] == 1) {
      this._dimensionsUnits = UnitModel.fromDynamicList(userInfo[7]['data']);
    } else {
      this._dimensionsUnits = [];
    }

    if (userInfo[8]['success'] == 1) {
      this._weightUnits = UnitModel.fromDynamicList(userInfo[8]['data']);
    } else {
      this._weightUnits = [];
    }

    this._statuses = ['active','inactive', 'pending', 'sold', 'rejected'];

    this._notifications = NotificationModel.fromDynamicList([{'message' : 'This is a notification'}]);
    this._notificationsEnabled = true;
  }

  Future<void> clearSessionData() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      this._isPrepared = false;
    });

    await MomdayHttp().reset();
    await this.prepare();

    setState(() {
      this._isPrepared = true;
    });
  }

  Future<String> login(String email, {String password, String accessToken, String provider}) async {
    assert(password != null || (accessToken != null && provider != null));
    assert(password == null || (accessToken == null && provider == null));

    dynamic loginResponse = await MomdayBackend().login(email, password: password, accessToken: accessToken, provider: provider);

    if (loginResponse['success'] == 1) {

      List extraUserInfo = await Future.wait(
          [
            MomdayBackend().getCart(),
            MomdayBackend().getWishlist()
          ]
      );

      setState(() {
        this._account = AccountModel.fromDynamic(loginResponse['data']);
        this._cart = CartModel.fromDynamic(extraUserInfo[0]['data']);
        this._wishlist = WishlistModel.fromDynamic(extraUserInfo[0]['data']);
      });

      return 'success';
    } else {
      return loginResponse['error'][0];
    }
  }

  Future<String> logout() async {
    dynamic logoutResponse = await MomdayBackend().logout();

    if (logoutResponse['success'] == 1) {
      setState(() {
        this._account = AccountModel();
        this._wishlist = WishlistModel.empty();
        this._cart = CartModel.empty();
      });
      return 'success';
    } else {
      return logoutResponse['error'][0];
    }
  }

  Future<String> signup(String firstName, String lastName, String email, String dob, String gender, String phoneNumber, String password, String confirmPassword) async {
    dynamic signupResponse = await MomdayBackend().signUp(firstName, lastName, email, dob, gender, phoneNumber, password, confirmPassword);

    if (signupResponse['success'] == 1) {
      setState(() {
        this._account = AccountModel.fromDynamic(signupResponse['data']);
      });

      return 'success';
    } else {
      return signupResponse['error'][0];
    }
  }

  Future<String> editProfile({String firstName, String lastName, String email, String phoneNumber}) async {
    dynamic result = await MomdayBackend().editProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber:phoneNumber
    );

    if (result['success'] == 1) {
      this.account.firstName = firstName;
      this.account.lastName = lastName;
      this.account.email = email;
      this.account.phoneNumber = phoneNumber;
      return 'success';
    } else {
      return result['error'][0];
    }
  }

  Future addProductToWishList({String productId}) async {
    dynamic result = await MomdayBackend().addProductToWishlist(
        productId: productId);

    if (result['success'] == 1) {
      dynamic wishList = await MomdayBackend().getWishlist();
      setState(() {
        this._wishlist = WishlistModel.fromDynamic(wishList['data']);
      });
      return 'success';
    } else {
      return result['error'][0];
    }
  }

  Future removeProductFromWishList({String productId}) async {
    dynamic result = await MomdayBackend().removeProductFromWishlist(productId: productId);

    if (result['success'] == 1) {
      setState(() {
        this._wishlist.products.removeWhere((element) => element.productId == productId);
      });
      return 'success';
    } else {
      return result['error'][0];
    }
  }

  Future removeProductFromCart({String productKey}) async {
    dynamic result = await MomdayBackend().removeProductFromCart(productKey: productKey);

    if (result['success'] == 1) {
      dynamic cart = await MomdayBackend().getCart();
      setState(() {
        this._cart = CartModel.fromDynamic(cart['data']);
      });
      return 'success';
    } else {
      return result['error'][0];
    }
  }

  Future addProductToCart({String productId,
    int quantity = 1, Map<OptionModel,OptionValueModel> selectedOptions}) async {

    dynamic result = await MomdayBackend().addProductToCart(
      productId: productId,
      quantity: quantity,
      selectedOptions:selectedOptions
    );

    if(result['error'] != null && result['error'].length != 0){
      return result['error'][0];
    }

    else if (result['success'] == 1) {
      dynamic cart = await MomdayBackend().getCart();
      setState(() {
        this._cart = CartModel.fromDynamic(cart['data']);
      });
      return 'success';
    }
  }

  Future changeProductQuantityInCart({String productKey, int quantity}) async {
    dynamic result = await MomdayBackend().changeProductQuantityInCart(
        productKey: productKey,
        quantity: quantity
    );

    if (result['success'] == 1) {
      dynamic cart = await MomdayBackend().getCart();
      setState(() {
        this._cart = CartModel.fromDynamic(cart['data']);
      });
      return 'success';
    } else {
      return result['error'][0];
    }
  }

  Future addToMyCelebrityStore({String productId}) async {
    dynamic result = await MomdayBackend().addProductToStore(
      productId: productId
    );

    if (result['success'] == 1) {
      setState(() {
        this.account.store.productIds.add(productId);
      });
      return 'success';
    } else {
      return result['error'][0];
    }
  }

  Future removeFromMyCelebrityStore({String productId}) async {
    dynamic result = await MomdayBackend().removeProductFromStore(
      productId: productId
    );

    if (result['success'] == 1) {
      setState(() {
        this.account.store.productIds.remove(productId);
      });
      return 'success';
    } else {
      return result['error'][0];
    }
  }
  Future postTopayfort() async{
    dynamic result;
  }
  AccountModel get account {
    return this._account;
  }

  WishlistModel get wishlist {
    return this._wishlist;
  }

  CartModel get cart {
    return this._cart;
  }

  List<CategoryModel> get categories {
    return this._categories;
  }

  List<UnitModel> get weightUnits {
    return this._weightUnits;
  }

  List<UnitModel> get dimensionsUnits {
    return this._dimensionsUnits;
  }

  List<CharityModel> get charities {
    return this._charities;
  }

  List<BrandModel> get brands {
    return this._brands;
  }

  List<dynamic> get conditions {
    return this._conditions;
  }

  BrandModel findBrand(String brandId){

    for(BrandModel brand in this.brands){
      if(brand.brandId == brandId)
        return brand;
    }

    return null;
  }

  CategoryModel findCategory(String categoryId){

    for(CategoryModel category in this.categories){
      if(category.categoryId == categoryId)
        return category;
    }

    return null;
  }

  CategoryModel findSubCategory(String categoryId, String subCategoryId){

    for(CategoryModel category in this.categories){
      if(category.categoryId == categoryId){
        for(CategoryModel subCategory in category.subCategories)
          if(subCategory.categoryId == subCategoryId)
            return subCategory;
      }
    }

    return null;
  }

  List<String> get statuses {
    return this._statuses;
  }

  List<NotificationModel> get notifications {
    return this._notifications;
  }

  bool get notificationsEnabled {
    return this._notificationsEnabled;
  }

  set notificationsEnabled(bool newState) {
    this.setState(() {
      this._notificationsEnabled = newState;
    });
  }

  CharityModel findCharity(String charityId){

    for(CharityModel charity in this.charities){
      if(charity.charityId == charityId)
        return charity;
    }

    return null;
  }

  UnitModel findDimensionUnit(String unitId){

    for(UnitModel unit in this._dimensionsUnits){
      if(unit.id == unitId)
        return unit;
    }

    return null;
  }

 UnitModel findWeightUnit(String unitId){

    for(UnitModel unit in this._dimensionsUnits){
      if(unit.id == unitId)
        return unit;
    }

    return null;
  }
}

class _AppStateManagerInherited extends InheritedWidget {

  final _AppStateManagerState data;

  _AppStateManagerInherited({Key key, this.data, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_AppStateManagerInherited old) => true;
}