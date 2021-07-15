import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/product_list/product.dart';
import 'package:momday_app/widgets/product_list/product_list_bloc.dart';

typedef ProductTapCallback(String productId);

class ProductList extends StatelessWidget {
  final ProductTapCallback onProductTap;
  final bool independentlyScrollable;
  final String type;

  ProductList({this.onProductTap, this.independentlyScrollable, this.type});

  @override
  Widget build(BuildContext context) {
    var filters = Filters(sortOptions: [
      SortOptionModel(
          name: 'price',
          title: tTitle(context, 'price'),
          ascendingText: tTitle(context, 'low_to_high'),
          descendingText: tTitle(context, 'high_to_low'),
          supportsDirectional: true),
      SortOptionModel(
        name: 'rating',
        title: tTitle(context, 'customer_reviews'),
        defaultDirection: 'desc',
      )
    ]);

    var grid = _ProductsGrid(
      independentlyScrollable: this.independentlyScrollable,
      onProductTap: this.onProductTap,
      type: this.type,
    );

    if (this.independentlyScrollable) {
      return Column(
        children: <Widget>[filters, Expanded(child: grid)],
      );
    } else {
      return ListView(
        primary: false,
        shrinkWrap: true,
        children: <Widget>[filters, grid],
      );
    }
  }
}

class _ProductsGrid extends StatefulWidget {
  final bool independentlyScrollable;
  final ProductTapCallback onProductTap;
  final String type;

  _ProductsGrid({this.onProductTap, this.independentlyScrollable, this.type});

  @override
  __ProductsGridState createState() => __ProductsGridState();
}

class __ProductsGridState extends State<_ProductsGrid> {
  static const PAGE_SIZE = 10;

  PagewiseLoadController _pageLoadController;

  @override
  void initState() {
    super.initState();

    final bloc = BlocProvider.of<ProductListBloc>(context);

    this._pageLoadController = PagewiseLoadController(
        pageFuture: (pageIndex) => this._pageFuture(
            pageIndex, bloc.filterAndSortChoices, this.widget.type),
        pageSize: PAGE_SIZE);

    bloc.stream.forEach((filtersAndSort) {
      setState(() {
        this._pageLoadController = PagewiseLoadController(
            pageFuture: (pageIndex) =>
                this._pageFuture(pageIndex, filtersAndSort, this.widget.type),
            pageSize: PAGE_SIZE);
      });
    });
  }

  Future<List<ProductModel>> _pageFuture(
      int pageIndex, FilterAndSortChoices filtersAndSort, String type) async {
    final response = await MomdayBackend().getProducts(
      categoryId: filtersAndSort.selectedCategoryId,
      limit: PAGE_SIZE,
      pageNumber: pageIndex + 1,
      simple: false,
      sortOption: filtersAndSort.sortOption,
      sortDirection: filtersAndSort.sortDirection,
      brandId: filtersAndSort.selectedBrandId,
      filters: filtersAndSort.selectedFilters.values.toList(),
      celebrityId: filtersAndSort.selectedCelebrityId,
      type: type,
    );

    return ProductModel.fromDynamicList(response);
  }

  Widget _noItemsFoundBuilder(BuildContext context) {
    return ListView(
      primary: widget.independentlyScrollable,
      shrinkWrap: !widget.independentlyScrollable,
      children: <Widget>[
        SizedBox(height: 16.0),
        Text(tUpper(context, 'no_items_found'),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 30.0,
                color: MomdayColors.MomdayGold.withOpacity(0.44))),
        SizedBox(
          height: 32.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                MainScreen.of(context).startSearch();
              },
              child: Column(
                children: <Widget>[
                  Icon(Icons.search),
                  Text(
                    tLower(context, 'new_search'),
                    style: cancelArabicFontDelta(context),
                  )
                ],
              ),
            ),
            InkWell(
              child: Column(
                children: <Widget>[
                  ImageIcon(AssetImage('assets/images/logo_small.png')),
                  Text(
                    tLower(context, 'back_to_home'),
                    style: cancelArabicFontDelta(context),
                  )
                ],
              ),
              onTap: () {
                MainScreen.of(context).navigateToTab(0);
              },
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var entryWidth = constraints.maxWidth / 2;

        var entryHeight = entryWidth; // the photo of the product is square
        entryHeight +=
            170.0; // The product basic info and the add or wish button
        if (AppStateManager.of(context).account.isCelebrity) {
          entryHeight += 36.0; // The typical button height
        }
        entryHeight += 12.0; // Some extra white space
        var childAspectRatio = entryWidth / (entryHeight);

        return PagewiseGridView.count(
          primary: widget.independentlyScrollable,
          shrinkWrap: !widget.independentlyScrollable,
          padding: EdgeInsets.only(top: 8.0),
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          crossAxisCount: 2,
          pageLoadController: this._pageLoadController,
          itemBuilder: (context, product, index) {
            return Product(
                product: product,
                index: index,
                onTap: () {
                  widget.onProductTap(product.productId);
                });
          },
          noItemsFoundBuilder: this._noItemsFoundBuilder,
        );
      },
    );
  }
}

class Filters extends StatelessWidget {
  final List<SortOptionModel> sortOptions;

  Filters({this.sortOptions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FlatButton.icon(
                  color: MomdayColors.MomdayGray,
                  onPressed: () {
                    this._showFilterOptions(context);
                  },
                  label: Text(
                    tTitle(context, 'filter'),
                    style: cancelArabicFontDelta(context),
                  ),
                  icon: Icon(Icons.filter_list)),
            ),
            SizedBox(
              width: 1.0,
            ),
            Expanded(
              child: FlatButton.icon(
                  color: MomdayColors.MomdayGray,
                  onPressed: () {
                    this._showSortOptions(context);
                  },
                  label: Text(
                    tTitle(context, 'sort'),
                    style: cancelArabicFontDelta(context),
                  ),
                  icon: Icon(Icons.sort)),
            ),
          ],
        ),
      ],
    );
  }

  _showFilterOptions(BuildContext context) {
    final parentContext = context;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: FilterDialog(
              parentContext: parentContext,
            ),
          );
        });
  }

  _showSortOptions(BuildContext context) {
    final ProductListBloc productListBloc =
        BlocProvider.of<ProductListBloc>(context);

    List<Widget> sortOptions = this.sortOptions.map((option) {
      return SortOption(
        parentContext: context,
        name: option.name,
        title: option.title,
        isFirst: option == this.sortOptions.first,
        isSelected:
            productListBloc.filterAndSortChoices.sortOption == option.name,
        selectedDirection: productListBloc.filterAndSortChoices.sortDirection,
        ascendingText: option.ascendingText,
        descendingText: option.descendingText,
        defaultDirection: option.defaultDirection,
        supportsDirectional: option.supportsDirectional,
      );
    }).toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tSentence(context, 'sort_by'),
                        style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20),
                      ),
                    ],
                  ),
                ),
                ListView(shrinkWrap: true, children: sortOptions),
              ],
            ),
          );
        });
  }
}

class SortOptionModel {
  final String name;
  final String title;
  final bool supportsDirectional;
  final String ascendingText;
  final String descendingText;
  final String defaultDirection;

  SortOptionModel({
    this.name,
    this.title,
    this.supportsDirectional = false,
    this.ascendingText,
    this.descendingText,
    this.defaultDirection = 'asc',
  });
}

class SortOption extends StatelessWidget {
  final BuildContext parentContext;
  final String name;
  final String title;
  final bool isSelected;
  final bool isFirst;
  final String selectedDirection;
  final bool supportsDirectional;
  final String ascendingText;
  final String descendingText;
  final String defaultDirection;

  SortOption({
    this.parentContext,
    this.name,
    this.title,
    this.isSelected,
    this.isFirst,
    this.selectedDirection,
    this.supportsDirectional = false,
    this.ascendingText,
    this.descendingText,
    this.defaultDirection = 'asc',
  });

  @override
  Widget build(BuildContext context) {
    return this._getExpansionTile(
        text: this.title,
        isSelected: this.isSelected,
        children: this.supportsDirectional
            ? [
                DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                      border: Border(
                          top: Divider.createBorderSide(context),
                          bottom: Divider.createBorderSide(context))),
                  child: ListTile(
                    title: Text(
                      this.ascendingText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:
                              this.isSelected && this.selectedDirection == 'asc'
                                  ? MomdayColors.MomdayGold
                                  : null),
                    ),
                    onTap: () {
                      BlocProvider.of<ProductListBloc>(this.parentContext)
                          .setSortOption(this.name, 'asc');
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: Divider.createBorderSide(context))),
                  child: ListTile(
                    title: Text(
                      this.descendingText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: this.isSelected &&
                                  this.selectedDirection == 'desc'
                              ? MomdayColors.MomdayGold
                              : null),
                    ),
                    onTap: () {
                      BlocProvider.of<ProductListBloc>(this.parentContext)
                          .setSortOption(this.name, 'desc');
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ]
            : [],
        onTap: () {
          if (!this.supportsDirectional) {
            // Then tapping it should cause it to become selected
            BlocProvider.of<ProductListBloc>(this.parentContext)
                .setSortOption(this.name, this.defaultDirection);
            Navigator.of(context).pop();
          }
        });
  }

  Widget _getExpansionTile(
      {String text,
      bool isSelected,
      List<Widget> children,
      GestureTapCallback onTap}) {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(
            top: this.isFirst ? BorderSide() : BorderSide.none,
            bottom: BorderSide()),
      ),
      child: ExpansionTile(
        title: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isSelected ? MomdayColors.MomdayGold : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18.0),
        ),
        trailing: Container(
          height: 0.0,
          width: 0.0,
        ),
        children: children,
        // If children are empty, then we treat it like a list tile
        onExpansionChanged: children.isEmpty ? (_) => onTap() : null,
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final BuildContext parentContext;

  FilterDialog({this.parentContext});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog>
    with TickerProviderStateMixin {
  List<FilterGroupModel> filterGroups;
  Map<String, String> selectedFilters;
  String selectedBrandId;
  String selectedCategoryId;

  TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ProductListBloc productListBloc =
        BlocProvider.of<ProductListBloc>(widget.parentContext);

    this.filterGroups = CategoryModel.findCategoryWithId(
                categories: AppStateManager.of(context).categories,
                categoryId:
                    productListBloc.filterAndSortChoices.selectedCategoryId)
            ?.filterGroups ??
        [];

    this.selectedFilters = productListBloc.filterAndSortChoices.selectedFilters;
    this.selectedBrandId = productListBloc.filterAndSortChoices.selectedBrandId;
    this.selectedCategoryId =
        productListBloc.filterAndSortChoices.selectedCategoryId;

    this._resetTabController();
  }

  void _resetTabController() {
    int initialIndex = 0;
    if (this._tabController != null) {
      // same index as the previous tab controller
      initialIndex = this._tabController.index;
      if (initialIndex > this.filterGroups.length + 1) {
        initialIndex = this.filterGroups.length + 1;
      }
    }
    this._tabController = TabController(
        length: this.filterGroups.length + 2,
        vsync: this,
        initialIndex: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 8.0),
        TabBar(
            controller: this._tabController,
            indicator: BoxDecoration(),
            labelStyle: TextStyle(fontSize: 18.0),
            indicatorWeight: 1.0,
            labelColor: MomdayColors.MomdayGold,
            unselectedLabelColor: Colors.black.withOpacity(0.5),
            tabs: [
              FittedBox(
                child: Tab(
                  text: tTitle(context, 'brand'),
                ),
              ),
              FittedBox(
                child: Tab(
                  text: tTitle(context, 'category'),
                ),
              )
            ]..addAll(this
                .filterGroups
                .map((filterGroup) => FittedBox(
                      child: Tab(
                        text: filterGroup.name,
                      ),
                    ))
                .toList())),
        Expanded(
          child: TabBarView(
              controller: this._tabController,
              children: [
                ListView(
                  children: this._getBrandTiles(context),
                ),
                ListView(children: this._getCategoryTiles(context))
              ]..addAll(this
                  .filterGroups
                  .map((filterGroup) => ListView(
                        children: this._getFilterTiles(context, filterGroup),
                      ))
                  .toList())),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                shape: Border(),
                padding: EdgeInsets.all(16.0),
                colorBrightness: Brightness.dark,
                color: MomdayColors.MomdayGold,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: FittedBox(
                  child: Text(tUpper(context, 'apply_filters')),
                ),
                onPressed: () {
                  BlocProvider.of<ProductListBloc>(widget.parentContext)
                      .applyFilters(this.selectedCategoryId,
                          this.selectedBrandId, this.selectedFilters);
                  Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(
              child: RaisedButton(
                shape: Border(),
                padding: EdgeInsets.all(16.0),
                colorBrightness: Brightness.dark,
                color: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: FittedBox(
                  child: Text(tUpper(context, 'clear_filters')),
                ),
                onPressed: () {
                  BlocProvider.of<ProductListBloc>(widget.parentContext)
                      .clearFilters();
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        )
      ],
    );
  }

  List<Widget> _getFilterTiles(
      BuildContext context, FilterGroupModel filterGroup) {
    return filterGroup.filters
        .map((filter) => this._getTile(
              text: filter.name,
              isFirst: filter == filterGroup.filters.first,
              isSelected: this.selectedFilters[filterGroup.filterGroupId] ==
                  filter.filterId,
              onTap: () {
                setState(() {
                  this.selectedFilters[filterGroup.filterGroupId] =
                      filter.filterId;
                });
              },
            ))
        .toList();
  }

  List<Widget> _getBrandTiles(BuildContext context) {
    final brands = AppStateManager.of(context).brands;

    return brands
        .map((brand) => this._getTile(
              text: brand.name,
              isFirst: brand == brands.first,
              isSelected: this.selectedBrandId == brand.brandId,
              onTap: () {
                setState(() {
                  this.selectedBrandId = brand.brandId;
                });
              },
            ))
        .toList();
  }

  Widget _getTile(
      {String text, bool isSelected, GestureTapCallback onTap, bool isFirst}) {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(
            top: isFirst ? BorderSide() : BorderSide.none,
            bottom: BorderSide()),
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? MomdayColors.MomdayGold : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _getExpansionTile(
      {String text,
      bool isSelected,
      List<Widget> children: const [],
      bool isFirst,
      GestureTapCallback onTap}) {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(
            top: isFirst ? BorderSide() : BorderSide.none,
            bottom: BorderSide()),
      ),
      child: ExpansionTile(
        title: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isSelected ? MomdayColors.MomdayGold : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18.0),
        ),
        trailing: Container(
          height: 0.0,
          width: 0.0,
        ),
        children: children,
        onExpansionChanged: children.isEmpty ? (_) => onTap() : null,
      ),
    );
  }

  _getCategoryTiles(BuildContext context) {
    return [
      this._getExpansionTile(
          text: tTitle(context, 'all'),
          isSelected: this.selectedCategoryId == null,
          isFirst: true,
          onTap: () {
            setState(() {
              this.selectedCategoryId = null;
              this.filterGroups = [];
              this.selectedFilters = {};
              this._resetTabController();
            });
          })
    ]..addAll(AppStateManager.of(context).categories.map((cat) {
        return this._getCategoryTile(context, cat);
      }));
  }

  Widget _getCategoryTile(BuildContext context, CategoryModel category) {
    List<Widget> childTiles = [];
    if (category.subCategories.isNotEmpty) {
      // We add the parent category as a child tile with the name 'all'
      childTiles = [
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
              border: Border(
                  top: Divider.createBorderSide(context),
                  bottom: Divider.createBorderSide(context))),
          child: ListTile(
            title: Text(
              tTitle(context, 'all'),
              textAlign: TextAlign.center,
              style: cancelArabicFontDelta(context).copyWith(
                  color: this.selectedCategoryId == category.categoryId
                      ? MomdayColors.MomdayGold
                      : Colors.black,
                  fontSize: 16.0),
            ),
            onTap: () {
              setState(() {
                this.selectedCategoryId = category.categoryId;

                this.filterGroups = category.filterGroups ?? [];
                this.selectedFilters = {};
                this._resetTabController();
              });
            },
          ),
        )
      ]..addAll(category.subCategories.map((subcategory) => DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
                border: Border(bottom: Divider.createBorderSide(context))),
            child: ListTile(
              title: subcategory.name != null
                  ? Text(titlecase(subcategory.name),
                      textAlign: TextAlign.center,
                      style: cancelArabicFontDelta(context).copyWith(
                          color:
                              this.selectedCategoryId == subcategory.categoryId
                                  ? MomdayColors.MomdayGold
                                  : Colors.black,
                          fontSize: 16.0))
                  : Container(),
              onTap: () {
                setState(() {
                  this.selectedCategoryId = subcategory.categoryId;
                  this.filterGroups = subcategory.filterGroups ?? [];
                  this.selectedFilters = {};
                  this._resetTabController();
                });
              },
            ),
          )));
    }

    return this._getExpansionTile(
        text: category.name,
        isSelected: this.selectedCategoryId == category.categoryId ||
            category.isSubCategory(this.selectedCategoryId),
        children: childTiles,
        isFirst: false,
        onTap: () {
          setState(() {
            this.selectedCategoryId = category.categoryId;
          });
        });
  }
}
