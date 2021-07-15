import 'dart:math';

import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:observable/observable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter/trotter.dart';

class SearchHelper extends PropertyChangeNotifier {

  List<BrandModel> _brands;
  List<CategoryModel> _categories;
  List<SearchTuple> _searchTuples;
  List<String> _allOptionsCache;
  Map<String, SearchTuple> _reverseIndex;
  List<String> searchHistory = [];

  bool _isInitialized = false;

  static final SearchHelper _searchHelper = SearchHelper._internal();
  SearchHelper._internal();

  factory SearchHelper() {

    return SearchHelper._searchHelper;
  }

  init() async {
    if (!this._isInitialized) {
      var brandsResponse = await MomdayBackend().getBrands();
      if (brandsResponse['success'] == 1) {
        this._brands = BrandModel.fromDynamicList(brandsResponse['data']);
      } else {
        this._brands = [];
      }

      var categoriesResponse = await MomdayBackend().getCategories();
      if (categoriesResponse['success'] == 1) {
        this._categories = CategoryModel.fromDynamicList(categoriesResponse['data']);
      } else {
        this._categories = [];
      }

      this._generateTuples();

      this._reverseIndex = {};
      this._allOptionsCache = [];

      for (var tuple in this._searchTuples) {
        var options = tuple.options;
        for (var option in options) {
          this._reverseIndex[option] = tuple;
        }
        this._allOptionsCache.addAll(options);
        this._allOptionsCache = this._allOptionsCache.toSet().toList();
      }

      var prefs = await SharedPreferences.getInstance();

      this.searchHistory = prefs.getStringList('search_history') ?? [];

      this._isInitialized = true;
      this.notifyPropertyChange(#_isInitialized, false, true);
    }
  }

  get isInitialized async {
    if (this._isInitialized) {
      return this._isInitialized;
    } else {
      await this.changes.first;
      return this._isInitialized;
    }
  }

  List<String> getSuggestions(String search, [int limit = 5]) {

    this._allOptionsCache.sort((a, b) {

      return (this._distance(search, a) - this._distance(search, b));
    });

    return this._allOptionsCache.take(limit).toList();
  }

  storeSuggestionInHistory(String suggestion) async {
    var prefs = await SharedPreferences.getInstance();



    if (this.searchHistory.length > 0 && this.searchHistory[0] == suggestion) return;

    this.searchHistory.insert(0, suggestion);

    if (this.searchHistory.length > 5) {
      this.searchHistory.removeLast();
    }

    await prefs.setStringList('search_history', this.searchHistory);
  }

  int _distance(String first, String second) {
    return Levenshtein().distance(first, second);
  }

  SearchCriteria getSearchCriteriaFromOption(String option) {
    var tuple = this._reverseIndex[option];

    return SearchCriteria(
      brandId: tuple.brand?.brandId,
      categoryId: tuple.categories.length != 0? tuple.categories.last.categoryId : null
    );
  }

  _generateTuples() {
    this._searchTuples = [];
    for (var brand in this._brands) {
      this._searchTuples.add(SearchTuple(
        brand: brand
      ));
      for (var category in this._categories) {
        this._generateTuplesInner(brand, category, []);
      }
    }
  }

  _generateTuplesInner(BrandModel brand, CategoryModel category, List<CategoryModel> categoryList) {
    categoryList.add(category);

    this._searchTuples.add(SearchTuple(
      categories: categoryList.toList()
    ));

    this._searchTuples.add(SearchTuple(
      brand: brand,
      categories: categoryList.toList()
    ));

    if (categoryList.length > 1) {
      this._searchTuples.add(SearchTuple(
        categories: [categoryList.last]
      ));

      this._searchTuples.add(SearchTuple(
        brand: brand,
        categories: [categoryList.last]
      ));
    }

    if (category.subCategories.length > 0) {
      for (var subcategory in category.subCategories) {
        this._generateTuplesInner(brand, subcategory, categoryList);
      }
    }
  }
}

class SearchTuple {
  BrandModel brand;
  List<CategoryModel> categories;
  List<String> _optionsCache;

  SearchTuple({this.brand, this.categories = const []});


  List<String> get options {
    if (this._optionsCache != null) return this._optionsCache;

    List<String> properties = categories.map((cat) => cat.name).toList();
    if (this.brand != null) {
      properties.add(this.brand.name);
    }

    var permutations = Permutations(properties.length, properties);

    this._optionsCache = [];

    for (BigInt i = BigInt.from(0); i < permutations.length; i += BigInt.from(1)) {
      this._optionsCache.add(permutations[i].join(' '));
    }

    return this._optionsCache;
  }
}

class SearchCriteria {
  String brandId;
  String categoryId;

  SearchCriteria({this.brandId, this.categoryId});

  @override
  String toString() {
    String result = '';

    if (this.categoryId != null) {
      result += 'categoryId=${this.categoryId}';
    }

    if (this.brandId != null) {
      if (this.categoryId != null) {
        result += '&';
      }
      result += 'brandId=${this.brandId}';
    }

    return result;
  }
}

// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


class Levenshtein {

  int distance(String s1, String s2) {
    if (s1 == s2) {
      return 0;
    }

    if (s1.length == 0) {
      return s2.length;
    }

    if (s2.length == 0) {
      return s1.length;
    }

    List<int> v0 = new List<int>(s2.length + 1);
    List<int> v1 = new List<int>(s2.length + 1);
    List<int> vtemp;

    for (var i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (var i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (var j = 0; j < s2.length; j++) {
        int cost = 1;
        if (s1.codeUnitAt(i) == s2.codeUnitAt(j)) {
          cost = 0;
        }
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      vtemp = v0;
      v0 = v1;
      v1 = vtemp;
    }

    return v0[s2.length];
  }

  double normalizedDistance(String s1, String s2) {
    int maxLength = max(s1.length, s2.length);
    if (maxLength == 0) {
      return 0.0;
    }
    return distance(s1, s2) / maxLength;
  }
}