import 'dart:async';

import 'package:momday_app/bloc_provider.dart';

class ProductListBloc extends BlocBase {

  FilterAndSortChoices filterAndSortChoices;

  StreamController<FilterAndSortChoices> _listController = StreamController<FilterAndSortChoices>();
  StreamSink<FilterAndSortChoices> get _in => _listController.sink;
  Stream<FilterAndSortChoices> get stream => _listController.stream;

  ProductListBloc({String categoryId, String brandId, String celebrityId}) {
    this.filterAndSortChoices = FilterAndSortChoices(
      selectedBrandId: brandId,
      selectedCategoryId: categoryId,
      selectedCelebrityId: celebrityId,
      selectedFilters: {},
      sortDirection: 'desc',
      sortOption: 'rating'
    );
  }

  setSortOption(String optionName, String direction) {
    this.filterAndSortChoices.sortOption = optionName;
    this.filterAndSortChoices.sortDirection = direction;
    this._in.add(this.filterAndSortChoices);
  }

  clearFilters() {
    this.filterAndSortChoices.selectedCategoryId = null;
    this.filterAndSortChoices.selectedBrandId = null;
    this.filterAndSortChoices.selectedFilters = {};
    this._in.add(this.filterAndSortChoices);
  }

  applyFilters(String categoryId, String brandId, Map<String, String> filters) {
    this.filterAndSortChoices.selectedCategoryId = categoryId;
    this.filterAndSortChoices.selectedBrandId = brandId;
    this.filterAndSortChoices.selectedFilters = filters;
    this._in.add(this.filterAndSortChoices);
  }

  @override
  dispose() {
    _listController.close();
    _in.close();
  }
}

class FilterAndSortChoices {
  String selectedCategoryId;
  String selectedBrandId;
  final String selectedCelebrityId; // not allowed to change
  String sortOption;
  String sortDirection;
  Map<String, String> selectedFilters;

  FilterAndSortChoices({
    this.selectedFilters,
    this.selectedBrandId,
    this.selectedCategoryId,
    this.selectedCelebrityId,
    this.sortDirection,
    this.sortOption
  });
}