import 'package:html_unescape/html_unescape.dart';
import 'dart:math';
import 'dart:convert';
class _ModelUtils {
  static String handleHtml(String html) {
    if (html == null) return null;

    return HtmlUnescape().convert(html);
  }

  static int handleInt(dynamic num) {
    return num is int? num : int.parse(num?? '0');
  }
}

class CartModel {
  String weight;
  List<ProductModel> products;
  String total;
  String error;

  CartModel({
    this.weight,
    this.products,
    this.total,
    this.error,
  });

  static CartModel fromDynamic(dynamic dynamicData) {

    print("cart dynamic is $dynamicData");
    if (dynamicData == null || dynamicData is List) {
      return CartModel.empty();
    }

    return CartModel(
        weight: dynamicData['weight'],
        products: ProductModel.fromDynamicList(dynamicData['products']),
        total: dynamicData['total'],
        error: dynamicData['error'],
    );
  }

  static CartModel empty() {
    return CartModel(
      products: []
    );
  }

  String getProductKeyFromId(String productId) {
    var product = this.products.firstWhere((product) => product.productId == productId);

    return product.keyInCart;
  }

  bool get isEmpty {
    return this.products.length == 0;
  }
}

class WishlistModel {
  List<ProductModel> products;

  WishlistModel({this.products});

  static WishlistModel fromDynamic(dynamicData) {

    if(dynamicData == null)
      return null;

    return WishlistModel(
      products: ProductModel.fromDynamicList(dynamicData is List? dynamicData : [])
    );
  }

  static WishlistModel empty() {
    return WishlistModel(
        products: []
    );
  }

  bool get isEmpty {
    return this.products.length == 0;
  }
}

class OptionModel {

  dynamic productOptionId;
  dynamic name;

  OptionModel({
    this.productOptionId,
    this.name,
  });

  static OptionModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    OptionModel op = new OptionModel(
      productOptionId: dynamicData["product_option_id"].toString(),
      name: dynamicData["name"].toString(),
    );

    return op;
  }
}

class OptionValueModel {

  dynamic productOptionValueId;
  dynamic optionValueId;
  dynamic name;
  int quantity;
  double price;
  String pricePrefix;

  OptionValueModel({
  this.productOptionValueId,
    this.optionValueId,
    this.name,
    this.quantity,
    this.price,
    this.pricePrefix
  });

  static OptionValueModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    OptionValueModel op = new OptionValueModel(
      productOptionValueId: dynamicData["product_option_value_id"].toString(),
      optionValueId: dynamicData["option_value_id"].toString(),
      name: dynamicData["name"].toString(),
      quantity: int.parse(dynamicData["quantity"].toString()),
      price: dynamicData['price'] != null ? double.parse(dynamicData['price'].toString()) : 0.0,
      pricePrefix: dynamicData['price_prefix'] != null ? dynamicData['price_prefix'] : '+'
    );

    return op;
  }
}

class ProductModel {

  String productId;
  String categoryId;
  String description;
  String price;
  double originalPrice;
  double minPrice;
  double maxPrice;
  String name;
  String brand;
  String image;
  String keyInCart; // only available when the item is in a cart
  int quantityInCart;
  int availableQuantity;
  String totalInCart;
  double rating;
  List<String> images;
  List<ReviewModel> reviews;
  int totalNumberOfReviews;
  String stockStatus;
  dynamic availableOptions; // map of available values for each option
  List<String> attributes; // product attributes
  String condition;
  int preloved;
  String charityId;
  String video;
  List<String> selectedOptions;
  String rewardGain;
  String rewardPrice;

  ProductModel({
    this.productId,
    this.categoryId,
    this.description,
    this.price,
    this.originalPrice,
    this.name,
    this.brand,
    this.image,
    this.keyInCart,
    this.availableQuantity,
    this.quantityInCart,
    this.totalInCart,
    this.rating,
    this.images,
    this.reviews,
    this.totalNumberOfReviews,
    this.stockStatus,
    this.condition,
    this.preloved,
    this.availableOptions,
    this.attributes,
    this.charityId,
    this.video,
    this.selectedOptions,
    this.rewardGain,
    this.rewardPrice
  });

  static ProductModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    List<dynamic> attributeGroups = dynamicData['attribute_groups'];
    List<String> attributes = [];

    if (attributeGroups != null) {
      for (dynamic attributeGroup in attributeGroups) {
        for (dynamic attributeDetails in attributeGroup["attribute"]) {
          if (attributeDetails['name'] != null && attributeDetails['text'] != null && attributeDetails['text'] != '')
            attributes.add(attributeDetails['name'] + ": " + attributeDetails['text']);
          else if (attributeDetails['name'] != null)
            attributes.add(attributeDetails['name']);
        }
      }
    }

    dynamic options = {};

    double minPrice = 0, maxPrice = 0, originalPrice = 0;

    if(dynamicData['price'] != null && (dynamicData['price'] is double || dynamicData['price'] is int)) {
      minPrice = double.parse(dynamicData['price'].toString());
      maxPrice = double.parse(dynamicData['price'].toString());
      originalPrice = double.parse(dynamicData['price'].toString());
    }

    if (dynamicData['options'] != null) {

      List<dynamic> availableOptions = dynamicData['options'];

      for (dynamic availableOption in availableOptions) {

        OptionModel option = OptionModel.fromDynamic(availableOption);

        List<dynamic> optionValues = new List();
        List<double> optionPrices = new List();

        for (dynamic option_value in availableOption["option_value"]) {

          OptionValueModel optionValue = OptionValueModel.fromDynamic(option_value);
          optionValues.add(optionValue);
          if(optionValue.pricePrefix == '-')
            optionPrices.add(optionValue.price * -1);
          else
            optionPrices.add(optionValue.price);
          print("option prices so far $optionPrices");
        }

        if(optionPrices.length > 0) {
          minPrice += optionPrices.reduce(min);
          maxPrice += optionPrices.reduce(max);
        }
        options[option] = optionValues;
      }
    }

    // selected options
    dynamic option = dynamicData['option'];
    List<String> selectedOptions = [];

    if(option != null) {
      for (dynamic op in option) {
        selectedOptions.add("${op['name']} : ${op['value']}");
      }
    }

    String formattedPrice = '';

    if(minPrice != maxPrice)
      formattedPrice = "\$$minPrice - \$$maxPrice";

    ProductModel productModel = ProductModel(
        productId: dynamicData['product_id'].toString(),
        categoryId: dynamicData['category'] != null && dynamicData['category'].length > 0? dynamicData['category'][0]['id'].toString() : null,
        price: dynamicData['total'] != null ? dynamicData['total'] : formattedPrice != '' ? formattedPrice : dynamicData['price_formated'] != null? dynamicData['price_formated'] : null,
        name: _ModelUtils.handleHtml(dynamicData['name']),
        description: _ModelUtils.handleHtml(dynamicData['description']),
        brand: _ModelUtils.handleHtml(dynamicData['manufacturer']),
        image: dynamicData['image'] != null && dynamicData['image'] != ''? dynamicData['image'] : (dynamicData['thumb'] != ''? dynamicData['thumb'] : null),
        availableQuantity: ProductModel._handleAvailableQuantity(dynamicData['quantity'], dynamicData['key'] != null),
        keyInCart: dynamicData['key'].toString(),
        quantityInCart: ProductModel._handleQuantityInCart(dynamicData['quantity'], dynamicData['key'] != null),
        rating: ProductModel._handleRating(dynamicData['rating']),
        images: dynamicData['images'] != null ? List<String>.from(dynamicData['images']) : [],
        reviews: ProductModel._handleReviews(dynamicData['reviews'] != null && !(dynamicData['reviews'] is List)? dynamicData['reviews']['reviews'] : null),
        totalNumberOfReviews: ProductModel._handleTotalNumberOfReviews(dynamicData['reviews']),
        stockStatus: ProductModel._handleStockStatus(dynamicData['stock']),
        attributes: attributes,
        condition: dynamicData['preloved'] != null? dynamicData['preloved']['condition']:null,
        charityId: dynamicData['preloved'] != null? dynamicData['preloved']['charity_id']:null,
        availableOptions: options,
        preloved: dynamicData['preloved'] != null? dynamicData['preloved']['is_preloved']:0,
        video: dynamicData['preloved'] != null? dynamicData['preloved']['video'] != ''? dynamicData['preloved']['video']:null:null,
        selectedOptions: selectedOptions,
        originalPrice: originalPrice,
        rewardGain: dynamicData['reward'] != null? dynamicData['reward'].toString():null,
        rewardPrice: dynamicData['points'] != null && dynamicData['points'].toString() != '0'? dynamicData['points'].toString():null,
    );

    return productModel;
  }

  static List<ProductModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<ProductModel>((entry) => ProductModel.fromDynamic(entry)).toList();
  }

  static String _handleStockStatus(dynamic stock) {
    if (stock is bool) {
      if (stock == true) {
        return 'in_stock';
      } else {
        return 'out_of_stock';
      }
    }

    if (stock is int) {
      if (stock > 0) {
        return 'in_stock';
      } else {
        return 'out_of_stock';
      }
    }

    if (stock is String) {
      if (stock == 'In Stock' || stock == 'متوفر') {
        return 'in_stock';
      } else {
        return 'out_of_stock';
      }
    }

    return null;
  }

  static double _handleRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is String) return double.parse(rating);
    if (rating is int) return rating.toDouble();
    return rating;
  }

  static List<ReviewModel> _handleReviews(dynamic reviews) {
    if (reviews == null) {
      return [];
    } else {
      return ReviewModel.fromDynamicList(reviews);
    }
  }

  static int _handleTotalNumberOfReviews(dynamic reviews) {
    if (reviews == null || reviews is List) {
      return 0;
    } else {
      return _ModelUtils.handleInt(reviews['review_total']);
    }
  }

  static int _handleQuantityInCart(quantity, bool isInCart) {
    if (quantity == null || !isInCart) {
      return 0;
    } else {
      return _ModelUtils.handleInt(quantity);
    }
  }

  static int _handleAvailableQuantity(quantity, bool isInCart) {
    if (quantity == null || isInCart) {
      return 0;
    } else {
      return _ModelUtils.handleInt(quantity);
    }
  }
}

class CategoryModel {

  String categoryId;
  String image;
  String name;
  List<CategoryModel> subCategories;
  CategoryModel parent;
  List<FilterGroupModel> filterGroups;

  CategoryModel({
    this.categoryId,
    this.image,
    this.name,
    this.subCategories,
    this.parent,
    this.filterGroups
  });

  static CategoryModel fromDynamic(dynamic dynamicData, [CategoryModel parent]) {

    if(dynamicData == null)
      return null;

    var category = CategoryModel(
      categoryId: dynamicData['category_id'].toString(),
      image: dynamicData['image'],
      name: _ModelUtils.handleHtml(dynamicData['name']),
      parent: parent,
      filterGroups: FilterGroupModel.fromDynamicList(dynamicData['filters'] != null? dynamicData['filters']['filter_groups'] : null)
    );
    category.subCategories = CategoryModel.fromDynamicList(dynamicData['categories'], category);
    return category;
  }

  static List<CategoryModel> fromDynamicList(List<dynamic> dynamicList, [CategoryModel parent]) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<CategoryModel>((entry) => CategoryModel.fromDynamic(entry, parent)).toList();
  }

  String get fullName {
    String fullName = this.name;

    var parent = this.parent;

    while (parent != null) {
      fullName = parent.name + ' -> ' + fullName;
      parent = parent.parent;
    }

    return fullName;
  }

  List<String> get fullPath {
    List<String> fullPath = [this.name];

    var parent = this.parent;

    while (parent != null) {
      fullPath.insert(0, parent.name);
      parent = parent.parent;
    }

    return fullPath;
  }

  bool isSubCategory(String categoryId) {
    return this.subCategories.any((subCategory) => subCategory.categoryId == categoryId);
  }

  static CategoryModel findCategoryWithId({List<CategoryModel> categories, String categoryId}) {
    var category = categories.firstWhere((cat) => cat.categoryId == categoryId, orElse: () => null);

    if (category == null) {
      for (var cat in categories) {
        var result = CategoryModel.findCategoryWithId(categories: cat.subCategories, categoryId: categoryId);
        if (result != null) {
          return result;
        }
      }
      return null;
    } else {
      return category;
    }
  }
}

class UnitModel {

  String name;
  String id;

  UnitModel({
    this.name,
    this.id
  });

  static UnitModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return UnitModel(
        name: dynamicData['title'].toString(),
        id: dynamicData['unit_id'].toString()
    );
  }

  static List<UnitModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<UnitModel>((entry) => UnitModel.fromDynamic(entry)).toList();
  }
}

class AccountModel {
  String customerId;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  bool isCelebrity;
  StoreModel store;

  AccountModel({
    this.customerId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.isCelebrity: false,
    this.store
  });

  static AccountModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return AccountModel(
      customerId: dynamicData['customer_id'].toString(),
      firstName: dynamicData['firstname'],
      lastName: dynamicData['lastname'],
      email: dynamicData['email'],
      phoneNumber: dynamicData['telephone'],
      isCelebrity: dynamicData['is_celebrity'].toString() == '1',
      store: StoreModel.fromDynamic(dynamicData['store'])
    );
  }

  bool get isLoggedIn {
    return this.customerId != null;
  }

  String get fullName {
    if (this.firstName != null && this.lastName != null) {
      return this.firstName + ' ' + this.lastName;
    } else {
      return null;
    }
  }
}

class ReviewModel {
  double rating;
  String text;
  String author;
  String dateAdded;
  String customerId;

  ReviewModel({
    this.rating,
    this.text,
    this.author,
    this.dateAdded,
    this.customerId
  });

  static ReviewModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return ReviewModel(
      rating: dynamicData['rating'].toDouble(),
      author: dynamicData['author'],
      text: _ModelUtils.handleHtml(dynamicData['text']),
      dateAdded: dynamicData['date_added'],
      customerId: dynamicData['customer_id']
    );
  }

  static List<ReviewModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<ReviewModel>((entry) => ReviewModel.fromDynamic(entry)).toList();
  }
}

class FilterGroupModel {

  String name;
  String filterGroupId;
  List<FilterModel> filters;

  FilterGroupModel({
    this.name,
    this.filterGroupId,
    this.filters
  });

  static FilterGroupModel fromDynamic(dynamic dynamicData) {
    return FilterGroupModel(
      name: _ModelUtils.handleHtml(dynamicData['name']),
      filterGroupId: dynamicData['filter_group_id'].toString(),
      filters: FilterModel.fromDynamicList(dynamicData['filter'])
    );
  }

  static List<FilterGroupModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<FilterGroupModel>((entry) => FilterGroupModel.fromDynamic(entry)).toList();
  }
}

class FilterModel {

  String name;
  String filterId;

  FilterModel({
    this.name,
    this.filterId
  });

  static FilterModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return FilterModel(
      name: FilterModel._extractNameFromNameWithNumber(dynamicData['name']),
      filterId: dynamicData['filter_id'].toString()
    );
  }

  // the filter name is usually received as: filter name (filter number). we remove the filter number
  static String _extractNameFromNameWithNumber(String nameWithNumber) {
    int paranthesisIndex = nameWithNumber.lastIndexOf('(');
    return _ModelUtils.handleHtml(nameWithNumber.substring(0, paranthesisIndex - 1));
  }

  static List<FilterModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<FilterModel>((entry) => FilterModel.fromDynamic(entry)).toList();
  }
}

class BrandModel {
  String name;
  String brandId;
  String image;

  BrandModel({
    this.name,
    this.brandId,
    this.image
  });

  static BrandModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return BrandModel(
        name: _ModelUtils.handleHtml(dynamicData['name']),
        brandId: dynamicData['manufacturer_id'].toString(),
        image: dynamicData['image']
    );
  }

  static List<BrandModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<BrandModel>((entry) => BrandModel.fromDynamic(entry)).toList();
  }
}

class CharityModel {

  String name;
  String charityId;

  CharityModel({
    this.name,
    this.charityId
  });

  static CharityModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return CharityModel(
      name: dynamicData['name'],
      charityId: dynamicData['charity_id'].toString(),
    );
  }

  static List<CharityModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<CharityModel>((entry) => CharityModel.fromDynamic(entry)).toList();
  }
}

class NotificationModel {
  String message;

  NotificationModel({this.message});

  static NotificationModel fromDynamic(dynamic dynamicData) {
    return NotificationModel(
      message: _ModelUtils.handleHtml(dynamicData['message']),
    );
  }

  static List<NotificationModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<NotificationModel>((entry) => NotificationModel.fromDynamic(entry)).toList();
  }
}

class AddressModel {
  String addressId;
  String city;
  String addressLine1;
  String addressLine2;
  String country;
  String countryId;

  AddressModel({
    this.addressId,
    this.addressLine1,
    this.addressLine2,
    this.countryId,
    this.country,
    this.city
  });

  static AddressModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return AddressModel(
      addressId: dynamicData['address_id'].toString(),
      addressLine1: dynamicData['address_1'],
      addressLine2: dynamicData['address_2'],
      city: dynamicData['city'],
      countryId: dynamicData['country_id'].toString(),
      country: dynamicData['country']
    );
  }

  static List<AddressModel> fromDynamicListOrMap(dynamicListOrMap) {
    if (dynamicListOrMap == null) {
      return [];
    }

    if (dynamicListOrMap is List) {
      return dynamicListOrMap.map<AddressModel>((entry) => AddressModel.fromDynamic(entry)).toList();
    }

    return dynamicListOrMap['addresses'].map<AddressModel>((entry) => AddressModel.fromDynamic(entry)).toList();
  }

  String get oneLineFormat {
    String result = this.addressLine1 + ', ';

    if (this.addressLine2 != null && this.addressLine2 != '') {
      result += this.addressLine2 + ', ';
    }

    result += this.city + ', ';
    result += this.country;

    return result;
  }

  String get addressLines {
    String result = this.addressLine1;

    if (this.addressLine2 != null && this.addressLine2 != '') {
      result += '\n' + this.addressLine2;
    }

    return result;
  }
}

class CelebrityModel {
  String celebrityId;
  String firstName;
  String lastName;
  String squareImage;
  String portraitImage;
  String description;

  CelebrityModel({
    this.celebrityId,
    this.firstName,
    this.lastName,
    this.squareImage,
    this.portraitImage,
    this.description,
  });

  static CelebrityModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return CelebrityModel(
      celebrityId: dynamicData['celebrity_id'].toString(),
      firstName: dynamicData['first_name'],
      lastName: dynamicData['last_name'],
      portraitImage: dynamicData['portrait_image'],
      squareImage: dynamicData['square_image'],
      description: _ModelUtils.handleHtml(dynamicData['bio']),
    );
  }

  static List<CelebrityModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<CelebrityModel>((entry) => CelebrityModel.fromDynamic(entry)).toList();
  }

  String get fullName {
    if (this.firstName != null && this.lastName != null) {
      return this.firstName + ' ' + this.lastName;
    } else {
      return null;
    }
  }
}

class StoreModel {
  List<String> productIds;

  StoreModel({this.productIds});

  static StoreModel fromDynamic(dynamic dynamicData) {

    if (dynamicData == null) {
      return StoreModel(
        productIds: []
      );
    }

    return StoreModel(
      productIds: dynamicData.map<String>((product) => product['product_id'].toString()).toList()
    );
  }
}

class MomsayPostSummaryModel {
  MomsayAuthorModel author;
  String name;
  String description;
  DateTime date;
  String image;
  int likes;
  String id;

  MomsayPostSummaryModel({this.author, this.description, this.date, this.image, this.likes, this.name, this.id});

  static MomsayPostSummaryModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return MomsayPostSummaryModel(
      author: MomsayAuthorModel.fromDynamic(dynamicData),
      description: _ModelUtils.handleHtml(dynamicData['description']),
      name: _ModelUtils.handleHtml(dynamicData['name']),
      date: DateTime.parse(dynamicData['date']),
      image: dynamicData['image'],
      likes: _ModelUtils.handleInt(dynamicData['likes']),
      id: dynamicData['post_id'].toString()
    );
  }

  static List<MomsayPostSummaryModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<MomsayPostSummaryModel>((entry) => MomsayPostSummaryModel.fromDynamic(entry)).toList();
  }
}

class MomsayPostModel {
  MomsayAuthorModel author;
  String name;
  String description;
  DateTime date;
  int numberOfLikes;
  String id;
  List<CommentModel> comments;
  bool isLikedByUser;
  bool commentStatus;

  MomsayPostModel({this.author, this.description, this.date,
    this.numberOfLikes, this.name, this.id, this.comments, this.isLikedByUser, this.commentStatus});

  static MomsayPostModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;
    print("comment status is ${dynamicData['comment_status'].toString() != '0'}");

    return MomsayPostModel(
        author: MomsayAuthorModel.fromDynamic(dynamicData),
        description: _ModelUtils.handleHtml(dynamicData['description']),
        name: dynamicData['name'],
        date: DateTime.parse(dynamicData['date']),
        numberOfLikes: _ModelUtils.handleInt(dynamicData['likes']),
        id: dynamicData['post_id'].toString(),
        comments: CommentModel.fromDynamicList(dynamicData['comments']),
        isLikedByUser: dynamicData['customer_like'].toString() != '0',
        commentStatus: dynamicData['comment_status'].toString() != '0',
    );
  }
}

class MomsayAuthorModel {
  String image;
  String name;
  String biography;

  MomsayAuthorModel({this.image, this.name, this.biography});

  static MomsayAuthorModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return MomsayAuthorModel(
      image: dynamicData['author_image'],
      name: dynamicData['author_name'],
      biography: _ModelUtils.handleHtml(dynamicData['author_biography'])
    );
  }
}

class ActivitySummaryModel {
  String title;
  String description;
  String location;
  String image;
  String id;

  ActivitySummaryModel({this.title, this.description, this.location, this.image, this.id});

  static ActivitySummaryModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return ActivitySummaryModel(
      title: dynamicData['name'],
      description: dynamicData['description'],
      location: dynamicData['location'],
      image: dynamicData['image'],
      id: dynamicData['post_id'].toString(),
    );
  }

  static List<ActivitySummaryModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<ActivitySummaryModel>((entry) => ActivitySummaryModel.fromDynamic(entry)).toList();
  }
}

class ActivityModel {
  String title;
  String description;
  String location;
  String image;
  String id;
  String phone;
  String email;
  String website;

  ActivityModel({this.title, this.description, this.location, this.image, this.id, this.phone, this.email, this.website});

  static ActivityModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return ActivityModel(
      title: dynamicData['name'],
      description: dynamicData['description'],
      location: dynamicData['location'],
      image: dynamicData['image'],
      id: dynamicData['post_id'].toString(),
      phone: dynamicData['phone'].toString(),
      email: dynamicData['email'],
      website: dynamicData['website']
    );
  }

  static List<ActivityModel> fromDynamicList(List<dynamic> dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map<ActivityModel>((entry) => ActivityModel.fromDynamic(entry)).toList();
  }

}

class CommentModel {

  String author;
  String text;
  String id;
  String parentId;
  List<CommentModel> replies;
  String date;
  CommentModel({this.author, this.text, this.replies, this.id, this.parentId, this.date});

  static CommentModel fromDynamic(dynamic dynamicData, List<dynamic> dynamicList) {

    if(dynamicData == null)
      return null;

    List<CommentModel> replies = [];

    for(dynamic comment in dynamicList){
      if(comment["comment_parent_id"] == dynamicData["comment_id"])
        replies.add(CommentModel.fromDynamic(comment, dynamicList));
    }

    return CommentModel(
      id: dynamicData['comment_id'].toString(),
      text: dynamicData['comment_text'],
      parentId: dynamicData['comment_parent_id'],
      date: dynamicData['date_commented'],
      author: dynamicData['comment_author'],
      replies: replies,
    );
  }

  static CommentModel findParentComment(List<CommentModel> comments, String parentID){
    for(CommentModel comment in comments){
      if(comment.id == parentID)
        return comment;
    }
    return null;
  }

  static List<CommentModel> fromDynamicList(List<dynamic> dynamicList) {

    if (dynamicList == null) {
      return [];
    }

    List<CommentModel> comments = [];

    for(dynamic comment in dynamicList){

      if(comment["comment_parent_id"] == '0')
        comments.add(CommentModel.fromDynamic(comment,dynamicList));
    }

    return comments;
  }
}

class HomeModel {
  List<ProductModel> featuredProducts;
  List<CelebrityModel> featuredCelebrities;
  List<BrandModel> featuredBrands;
  List<MomsayPostSummaryModel> featuredMomsayPosts;

  HomeModel({this.featuredProducts, this.featuredCelebrities, this.featuredBrands, this.featuredMomsayPosts});

  static HomeModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    return HomeModel(
      featuredProducts: ProductModel.fromDynamicList(dynamicData['featured_products']),
      featuredCelebrities: CelebrityModel.fromDynamicList(dynamicData['featured_celebrities']),
      featuredBrands: BrandModel.fromDynamicList(dynamicData['featured_brands']),
      featuredMomsayPosts: MomsayPostSummaryModel.fromDynamicList(dynamicData['featured_momsay_posts'])
    );
  }
}

class MyListProductModel {

  String id;
  String name;
  String description;
  String brandId;
  String brandName;
  String categoryId;
  String subcategoryId;
  String condition;
  String size;
  String color;
  double price;
  String dimensionsUnit;
  double length;
  double width;
  double height;
  String weightUnit;
  double weight;
  List<String> images;
  String video;
  String charityId;
  String status;
  String email;
  String phoneNumber;
  String pickupLocation;
  DateTime dateExpires;
  String adminRemark;
  String thumbnail;

  MyListProductModel({
    this.id, this.name, this.description,
    this.brandId, this.categoryId, this.subcategoryId,
    this.condition, this.charityId,
    this.size, this.color, this.price,
    this.images, this.video, this.email, this.phoneNumber, this.pickupLocation, this.status,
    this.dateExpires, this.adminRemark,
    this.length,this.height,this.width,this.weight,this.dimensionsUnit,this.weightUnit,
    this.thumbnail
  });

  static MyListProductModel fromDynamic(dynamic dynamicData) {

    if(dynamicData == null)
      return null;

    final t = MyListProductModel(
        id: dynamicData['product_id'] != null? dynamicData['product_id'].toString() : null,
        status: dynamicData['preloved_status'] != null? dynamicData['preloved_status'] : dynamicData['preloved']['preloved_item_status'] != null ? dynamicData['preloved']['preloved_item_status'] : '',
        dateExpires: dynamicData['date_expire'] != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(dynamicData['date_expire'].toString()) * 1000): null,
        name: dynamicData['name'],
        brandId: dynamicData['manufacturer_id'].toString(),
        price: double.parse(dynamicData['price'].toString()),
        thumbnail: dynamicData['original_image'] != null? dynamicData['original_image']:dynamicData['image'],
        charityId: dynamicData['preloved'] != null ? dynamicData['preloved']['charity_id']:null,
        description: dynamicData['description'],
        categoryId: dynamicData['category'] != null
            && dynamicData['category'].length > 0 ? dynamicData['category'][0]['id'].toString() : '',
        subcategoryId: dynamicData['category'] != null
            && dynamicData['category'].length > 1 ? dynamicData['category'][1]['id'].toString() : '',
        video: dynamicData['preloved'] != null? dynamicData['preloved']['video'] != ''? dynamicData['preloved']['video']:null:null,
        condition: getAttribute(dynamicData,'condition'),
        color: getAttribute(dynamicData,'color'),
        size: getAttribute(dynamicData,'size'),
        images: dynamicData['original_images'] != null ? List<String>.from(dynamicData['original_images']) : [],
        pickupLocation: dynamicData['preloved'] != null ? dynamicData['preloved']['preloved_item_address']:null,
        adminRemark: dynamicData['preloved'] != null ? dynamicData['preloved']['remarks']:null
    );

    return t;
  }

  static String getAttribute(dynamic dynamicData, String requiredAttribute){

    if(dynamicData['attribute_groups'] != null && dynamicData['attribute_groups'].length > 0){
      for(dynamic attributeGroup in dynamicData['attribute_groups']){
        if(attributeGroup['name'].toString().toLowerCase() == 'additional information'){
          if(attributeGroup['attribute'] != null && attributeGroup['attribute'].length > 0){
            for (dynamic attribute in attributeGroup['attribute']){
              if(attribute['name'].toString().toLowerCase() == requiredAttribute){
                return attribute['text'].toString();
              }
            }
          }
        }
      }
    }

    return null;
  }

  static List<MyListProductModel> fromDynamicList(List<dynamic> dynamicList) {

    if (dynamicList == null) {
      return [];
    }

    return dynamicList.map<MyListProductModel>((entry) => MyListProductModel.fromDynamic(entry)).toList();
  }

  void copyBasicInfo(MyListProductModel copyFrom){

    this.name = copyFrom.name;
    this.description = copyFrom.description;
    this.brandId = copyFrom.brandId;
    this.brandName = copyFrom.brandName;
    this.categoryId = copyFrom.categoryId;
    this.subcategoryId = copyFrom.subcategoryId;
    this.condition = copyFrom.condition;
    this.size = copyFrom.size;
    this.color = copyFrom.color;
    this.price = copyFrom.price;
    this.dimensionsUnit = copyFrom.dimensionsUnit;
    this.width = copyFrom.width;
    this.height = copyFrom.height;
    this.length = copyFrom.length;
    this.weightUnit = copyFrom.weightUnit;
    this.weight = copyFrom.weight;
    this.pickupLocation = copyFrom.pickupLocation;
    this.charityId = copyFrom.charityId;
  }
}

AramexModel aramexModelFromJson(String str) => AramexModel.fromJson(json.decode(str));

String aramexModelToJson(AramexModel data) => json.encode(data.toJson());

class AramexModel {
  AramexModel({
    this.clientInfo,
    this.labelInfo,
    this.shipments,
    this.transaction,
  });

  ClientInfo clientInfo;
  dynamic labelInfo;
  List<Shipment> shipments;
  Transaction transaction;

  factory AramexModel.fromJson(Map<String, dynamic> json) => AramexModel(
    clientInfo: ClientInfo.fromJson(json["ClientInfo"]),
    labelInfo: json["LabelInfo"],
    shipments: List<Shipment>.from(json["Shipments"].map((x) => Shipment.fromJson(x))),
    transaction: Transaction.fromJson(json["Transaction"]),
  );

  Map<String, dynamic> toJson() => {
    "ClientInfo": clientInfo.toJson(),
    "LabelInfo": labelInfo,
    "Shipments": List<dynamic>.from(shipments.map((x) => x.toJson())),
    "Transaction": transaction.toJson(),
  };
}

class ClientInfo {
  ClientInfo({
    this.userName,
    this.password,
    this.version,
    this.accountNumber,
    this.accountPin,
    this.accountEntity,
    this.accountCountryCode,
    this.source,
  });

  String userName;
  String password;
  String version;
  String accountNumber;
  String accountPin;
  String accountEntity;
  String accountCountryCode;
  int source;

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(
    userName: json["UserName"],
    password: json["Password"],
    version: json["Version"],
    accountNumber: json["AccountNumber"],
    accountPin: json["AccountPin"],
    accountEntity: json["AccountEntity"],
    accountCountryCode: json["AccountCountryCode"],
    source: json["Source"],
  );

  Map<String, dynamic> toJson() => {
    "UserName": userName,
    "Password": password,
    "Version": version,
    "AccountNumber": accountNumber,
    "AccountPin": accountPin,
    "AccountEntity": accountEntity,
    "AccountCountryCode": accountCountryCode,
    "Source": source,
  };
}

class Shipment {
  Shipment({
    this.reference1,
    this.reference2,
    this.reference3,
    this.shipper,
    this.consignee,
    this.thirdParty,
    this.shippingDateTime,
    this.comments,
    this.pickupLocation,
    this.operationsInstructions,
    this.accountingInstrcutions,
    this.details,
    this.attachments,
    this.foreignHawb,
    this.transportType,
    this.pickupGuid,
    this.number,
    this.scheduledDelivery,
  });

  String reference1;
  String reference2;
  String reference3;
  Consignee shipper;
  Consignee consignee;
  Consignee thirdParty;
  String shippingDateTime;
  String comments;
  String pickupLocation;
  String operationsInstructions;
  String accountingInstrcutions;
  Details details;
  List<dynamic> attachments;
  String foreignHawb;
  int transportType;
  String pickupGuid;
  dynamic number;
  dynamic scheduledDelivery;

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
    reference1: json["Reference1"],
    reference2: json["Reference2"],
    reference3: json["Reference3"],
    shipper: Consignee.fromJson(json["Shipper"]),
    consignee: Consignee.fromJson(json["Consignee"]),
    thirdParty: Consignee.fromJson(json["ThirdParty"]),
    shippingDateTime: json["ShippingDateTime"],
    comments: json["Comments"],
    pickupLocation: json["PickupLocation"],
    operationsInstructions: json["OperationsInstructions"],
    accountingInstrcutions: json["AccountingInstrcutions"],
    details: Details.fromJson(json["Details"]),
    attachments: List<dynamic>.from(json["Attachments"].map((x) => x)),
    foreignHawb: json["ForeignHAWB"],
    transportType: json["TransportType "],
    pickupGuid: json["PickupGUID"],
    number: json["Number"],
    scheduledDelivery: json["ScheduledDelivery"],
  );

  Map<String, dynamic> toJson() => {
    "Reference1": reference1,
    "Reference2": reference2,
    "Reference3": reference3,
    "Shipper": shipper.toJson(),
    "Consignee": consignee.toJson(),
    "ThirdParty": thirdParty.toJson(),
    "ShippingDateTime": shippingDateTime,
    "Comments": comments,
    "PickupLocation": pickupLocation,
    "OperationsInstructions": operationsInstructions,
    "AccountingInstrcutions": accountingInstrcutions,
    "Details": details.toJson(),
    "Attachments": List<dynamic>.from(attachments.map((x) => x)),
    "ForeignHAWB": foreignHawb,
    "TransportType ": transportType,
    "PickupGUID": pickupGuid,
    "Number": number,
    "ScheduledDelivery": scheduledDelivery,
  };
}

class Consignee {
  Consignee({
    this.reference1,
    this.reference2,
    this.accountNumber,
    this.partyAddress,
    this.contact,
  });

  String reference1;
  String reference2;
  String accountNumber;
  PartyAddress partyAddress;
  Contact contact;

  factory Consignee.fromJson(Map<String, dynamic> json) => Consignee(
    reference1: json["Reference1"],
    reference2: json["Reference2"],
    accountNumber: json["AccountNumber"],
    partyAddress: PartyAddress.fromJson(json["PartyAddress"]),
    contact: Contact.fromJson(json["Contact"]),
  );

  Map<String, dynamic> toJson() => {
    "Reference1": reference1,
    "Reference2": reference2,
    "AccountNumber": accountNumber,
    "PartyAddress": partyAddress.toJson(),
    "Contact": contact.toJson(),
  };
}

class Contact {
  Contact({
    this.department,
    this.personName,
    this.title,
    this.companyName,
    this.phoneNumber1,
    this.phoneNumber1Ext,
    this.phoneNumber2,
    this.phoneNumber2Ext,
    this.faxNumber,
    this.cellPhone,
    this.emailAddress,
    this.type,
  });

  String department;
  String personName;
  String title;
  String companyName;
  String phoneNumber1;
  String phoneNumber1Ext;
  String phoneNumber2;
  String phoneNumber2Ext;
  String faxNumber;
  String cellPhone;
  String emailAddress;
  String type;

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    department: json["Department"],
    personName: json["PersonName"],
    title: json["Title"],
    companyName: json["CompanyName"],
    phoneNumber1: json["PhoneNumber1"],
    phoneNumber1Ext: json["PhoneNumber1Ext"],
    phoneNumber2: json["PhoneNumber2"],
    phoneNumber2Ext: json["PhoneNumber2Ext"],
    faxNumber: json["FaxNumber"],
    cellPhone: json["CellPhone"],
    emailAddress: json["EmailAddress"],
    type: json["Type"],
  );

  Map<String, dynamic> toJson() => {
    "Department": department,
    "PersonName": personName,
    "Title": title,
    "CompanyName": companyName,
    "PhoneNumber1": phoneNumber1,
    "PhoneNumber1Ext": phoneNumber1Ext,
    "PhoneNumber2": phoneNumber2,
    "PhoneNumber2Ext": phoneNumber2Ext,
    "FaxNumber": faxNumber,
    "CellPhone": cellPhone,
    "EmailAddress": emailAddress,
    "Type": type,
  };
}

class PartyAddress {
  PartyAddress({
    this.line1,
    this.line2,
    this.line3,
    this.city,
    this.stateOrProvinceCode,
    this.postCode,
    this.countryCode,
    this.longitude,
    this.latitude,
    this.buildingNumber,
    this.buildingName,
    this.floor,
    this.apartment,
    this.poBox,
    this.description,
  });

  String line1;
  String line2;
  String line3;
  String city;
  String stateOrProvinceCode;
  String postCode;
  String countryCode;
  int longitude;
  int latitude;
  String buildingNumber;
  String buildingName;
  String floor;
  String apartment;
  dynamic poBox;
  String description;

  factory PartyAddress.fromJson(Map<String, dynamic> json) => PartyAddress(
    line1: json["Line1"],
    line2: json["Line2"] == null ? null : json["Line2"],
    line3: json["Line3"] == null ? null : json["Line3"],
    city: json["City"],
    stateOrProvinceCode: json["StateOrProvinceCode"],
    postCode: json["PostCode"],
    countryCode: json["CountryCode"],
    longitude: json["Longitude"],
    latitude: json["Latitude"],
    buildingNumber: json["BuildingNumber"] == null ? null : json["BuildingNumber"],
    buildingName: json["BuildingName"] == null ? null : json["BuildingName"],
    floor: json["Floor"] == null ? null : json["Floor"],
    apartment: json["Apartment"] == null ? null : json["Apartment"],
    poBox: json["POBox"],
    description: json["Description"] == null ? null : json["Description"],
  );

  Map<String, dynamic> toJson() => {
    "Line1": line1,
    "Line2": line2 == null ? null : line2,
    "Line3": line3 == null ? null : line3,
    "City": city,
    "StateOrProvinceCode": stateOrProvinceCode,
    "PostCode": postCode,
    "CountryCode": countryCode,
    "Longitude": longitude,
    "Latitude": latitude,
    "BuildingNumber": buildingNumber == null ? null : buildingNumber,
    "BuildingName": buildingName == null ? null : buildingName,
    "Floor": floor == null ? null : floor,
    "Apartment": apartment == null ? null : apartment,
    "POBox": poBox,
    "Description": description == null ? null : description,
  };
}

class Details {
  Details({
    this.dimensions,
    this.actualWeight,
    this.chargeableWeight,
    this.descriptionOfGoods,
    this.goodsOriginCountry,
    this.numberOfPieces,
    this.productGroup,
    this.productType,
    this.paymentType,
    this.paymentOptions,
    this.customsValueAmount,
    this.cashOnDeliveryAmount,
    this.insuranceAmount,
    this.cashAdditionalAmount,
    this.cashAdditionalAmountDescription,
    this.collectAmount,
    this.services,
    this.items,
  });

  Dimensions dimensions;
  Weight actualWeight;
  dynamic chargeableWeight;
  String descriptionOfGoods;
  String goodsOriginCountry;
  int numberOfPieces;
  String productGroup;
  String productType;
  String paymentType;
  String paymentOptions;
  Amount customsValueAmount;
  Amount cashOnDeliveryAmount;
  dynamic insuranceAmount;
  dynamic cashAdditionalAmount;
  String cashAdditionalAmountDescription;
  dynamic collectAmount;
  String services;
  List<Item> items;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    dimensions: Dimensions.fromJson(json["Dimensions"]),
    actualWeight: Weight.fromJson(json["ActualWeight"]),
    chargeableWeight: json["ChargeableWeight"],
    descriptionOfGoods: json["DescriptionOfGoods"],
    goodsOriginCountry: json["GoodsOriginCountry"],
    numberOfPieces: json["NumberOfPieces"],
    productGroup: json["ProductGroup"],
    productType: json["ProductType"],
    paymentType: json["PaymentType"],
    paymentOptions: json["PaymentOptions"],
    customsValueAmount: Amount.fromJson(json["CustomsValueAmount"]),
    cashOnDeliveryAmount: Amount.fromJson(json["CashOnDeliveryAmount"]),
    insuranceAmount: json["InsuranceAmount"],
    cashAdditionalAmount: json["CashAdditionalAmount"],
    cashAdditionalAmountDescription: json["CashAdditionalAmountDescription"],
    collectAmount: json["CollectAmount"],
    services: json["Services"],
    items: List<Item>.from(json["Items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Dimensions": dimensions.toJson(),
    "ActualWeight": actualWeight.toJson(),
    "ChargeableWeight": chargeableWeight,
    "DescriptionOfGoods": descriptionOfGoods,
    "GoodsOriginCountry": goodsOriginCountry,
    "NumberOfPieces": numberOfPieces,
    "ProductGroup": productGroup,
    "ProductType": productType,
    "PaymentType": paymentType,
    "PaymentOptions": paymentOptions,
    "CustomsValueAmount": customsValueAmount.toJson(),
    "CashOnDeliveryAmount": cashOnDeliveryAmount.toJson(),
    "InsuranceAmount": insuranceAmount,
    "CashAdditionalAmount": cashAdditionalAmount,
    "CashAdditionalAmountDescription": cashAdditionalAmountDescription,
    "CollectAmount": collectAmount,
    "Services": services,
    "Items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Weight {
  Weight({
    this.unit,
    this.value,
  });

  String unit;
  double value;

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    unit: json["Unit"],
    value: json["Value"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "Unit": unit,
    "Value": value,
  };
}

class Amount {
  Amount({
    this.currencyCode,
    this.value,
  });

  String currencyCode;
  String value;

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
    currencyCode: json["CurrencyCode"],
    value: json["Value"],
  );

  Map<String, dynamic> toJson() => {
    "CurrencyCode": currencyCode,
    "Value": value,
  };
}

class Dimensions {
  Dimensions({
    this.length,
    this.width,
    this.height,
    this.unit,
  });

  int length;
  int width;
  int height;
  String unit;

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    length: json["Length"],
    width: json["Width"],
    height: json["Height"],
    unit: json["Unit"],
  );

  Map<String, dynamic> toJson() => {
    "Length": length,
    "Width": width,
    "Height": height,
    "Unit": unit,
  };
}

class Item {
  Item({
    this.packageType,
    this.quantity,
    this.weight,
    this.comments,
  });

  String packageType;
  int quantity;
  Weight weight;
  String comments;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    packageType: json["PackageType"],
    quantity: json["Quantity"],
    weight: Weight.fromJson(json["Weight"]),
    comments: json["Comments"],
  );

  Map<String, dynamic> toJson() => {
    "PackageType": packageType,
    "Quantity": quantity,
    "Weight": weight.toJson(),
    "Comments": comments,
  };
}

class Transaction {
  Transaction({
    this.reference1,
    this.reference2,
    this.reference3,
    this.reference4,
    this.reference5,
  });

  String reference1;
  String reference2;
  String reference3;
  String reference4;
  String reference5;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    reference1: json["Reference1"],
    reference2: json["Reference2"],
    reference3: json["Reference3"],
    reference4: json["Reference4"],
    reference5: json["Reference5"],
  );

  Map<String, dynamic> toJson() => {
    "Reference1": reference1,
    "Reference2": reference2,
    "Reference3": reference3,
    "Reference4": reference4,
    "Reference5": reference5,
  };
}