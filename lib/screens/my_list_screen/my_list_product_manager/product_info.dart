import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager_bloc.dart';

class ProductInfo extends StatefulWidget {

  final MyListProductModel product;
  final formKey;
  final bool submit;

  ProductInfo({this.product,this.formKey,this.submit});

  @override
  ProductInfoState createState() {
    return new ProductInfoState();
  }
}

class ProductInfoState extends State<ProductInfo> with AutomaticKeepAliveClientMixin<ProductInfo> {

  /* options */
  List<CategoryModel> categories;
  List<CategoryModel> subCategories = [];
  List<BrandModel> brands;
  List<dynamic> conditions;
  List<CharityModel> charities;
  List<UnitModel> dimensionsUnits;
  List<UnitModel> weightUnits;

  /* product details */
  String name;
  String description;
  String color;
  String size;
  String pickUpLocation;

  double price;
  double weight;
  double length;
  double width;
  double height;

  BrandModel selectedBrand;
  String selectedCondition;
  CharityModel selectedCharity;
  CategoryModel selectedCategory;
  CategoryModel selectedSubcategory;
  bool donate = false;

  UnitModel selectedDimensionsUnit;
  UnitModel selectedWeightUnit;

  /* editing controllers */
  TextEditingController nameController;
  TextEditingController descriptionController;
  TextEditingController colorController;
  TextEditingController sizeController;

  TextEditingController priceController;
  TextEditingController weightController;
  TextEditingController heightController;
  TextEditingController lengthController;
  TextEditingController widthController;

  TextEditingController locationController;

  MyListProductManagerBloc productManagerBloc;

  bool justLaunched = true;

  @override
  Widget build(BuildContext context) {

    /* check if editing product */

    if(this.widget.submit)
      updateBloc();

    if(this.widget.product != null && justLaunched){

      justLaunched = false;

      if(this.name == null)
        this.name = this.widget.product.name;

      if(this.description == null)
        this.description = this.widget.product.description;

      if(this.selectedBrand == null)
        this.selectedBrand = AppStateManager.of(context).findBrand(this.widget.product.brandId);

      if(this.selectedCategory == null) {
        this.selectedCategory = AppStateManager.of(context).findCategory(this.widget.product.categoryId);
        if(this.selectedCategory == null)
          this.subCategories = [];
      }

      if(this.selectedSubcategory == null)
        this.selectedSubcategory = AppStateManager.of(context).findSubCategory(this.widget.product.categoryId, this.widget.product.subcategoryId);

      if(this.size == null)
        this.size = this.widget.product.size;

      if(this.color == null)
        this.color = this.widget.product.color;

      if(this.price == null)
        this.price = this.widget.product.price;

      if(this.donate == null)
        this.donate = (this.widget.product.charityId != null);

      if(this.selectedCharity == null)
        this.selectedCharity = AppStateManager.of(context).findCharity(this.widget.product.charityId);

      if(this.selectedCondition == null)
        this.selectedCondition = this.widget.product.condition;

      if(this.pickUpLocation == null)
        this.pickUpLocation = this.widget.product.pickupLocation;

      if(donate == null)
        donate = false;
    }

    this.nameController = new TextEditingController(text:name);
    this.descriptionController = new TextEditingController(text:description);
    this.sizeController = new TextEditingController(text:size);
    this.colorController = new TextEditingController(text:color);

    if(weight == null)
      this.weightController = new TextEditingController();
    else
      this.weightController = new TextEditingController(text:"$weight");

    if(width == null)
      this.widthController = new TextEditingController();
    else
      this.widthController = new TextEditingController(text:"$width");

    if(length == null)
      this.lengthController = new TextEditingController();
    else
      this.lengthController = new TextEditingController(text:"$length");

    if(height == null)
      this.heightController = new TextEditingController();
    else
      this.heightController = new TextEditingController(text:"$height");

    if(price == null)
      this.priceController = new TextEditingController();
    else
      this.priceController = new TextEditingController(text:"$price");

    this.locationController = new TextEditingController(text:pickUpLocation);

    this.nameController.addListener(() {

      if(nameController.text != null)
        this.name = nameController.text;
    });

    this.descriptionController.addListener(() {

      if(descriptionController.text != null)
        this.description = descriptionController.text;
    });

    this.priceController.addListener(() {

      if(priceController.text != null)
        this.price = double.parse(priceController.text);
    });

    this.heightController.addListener(() {

      if(heightController.text != null)
        this.height = double.parse(heightController.text);
    });

    this.widthController.addListener(() {

      if(widthController.text != null)
        this.width = double.parse(widthController.text);
    });

    this.lengthController.addListener(() {

      if(lengthController.text != null)
        this.length = double.parse(lengthController.text);
    });

    this.weightController.addListener(() {

      if(weightController.text != null)
        this.weight = double.parse(weightController.text);
    });

    this.locationController.addListener(() {

      if(locationController.text != null)
        this.pickUpLocation = locationController.text;
      else
        this.pickUpLocation = null;
    });

    this.productManagerBloc = BlocProvider.of<MyListProductManagerBloc>(context);

    categories  = AppStateManager.of(context).categories;
    brands = AppStateManager.of(context).brands;
    charities = AppStateManager.of(context).charities;
    conditions = AppStateManager.of(context).conditions;

    dimensionsUnits = AppStateManager.of(context).dimensionsUnits;
    weightUnits = AppStateManager.of(context).weightUnits;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: this.widget.formKey,
        child: ListView(
            children: <Widget>[
              Text(
                  tTitle(context, "item_name"),
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black
                  )
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.nameController,
                    decoration: getMomdayInputDecoration(tSentence(context, "item_name_hint")),
                    validator: (value) {
                    if (value.isEmpty) {
                      return tSentence(context, 'field_required');
                    }
                  }
                ),
              ),
              Text(
                  tTitle(context, "description"),
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black
                  )
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: getMomdayInputDecoration(tSentence(context, "description_hint")),
                  validator: (value) {
                    if (value.isEmpty) {
                      return tSentence(context, 'field_required');
                    }
                  },
                ),
              ),
              Text(
                  tTitle(context, "brand"),
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black
                  )
              ),
              brandFormField(),
              Text(
                  tTitle(context, "category"),
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black
                  )
              ),
              categoryFormField(),
              subCategories.length == 0 ? Container() : subCategoryFormField(),
              Container(
                child: Text(
                    tTitle(context, "condition"),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black
                    )
                ),
              ),
              conditionFormField(),
              Container(
                child: Text(
                    tTitle(context, "color"),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black
                    )
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.colorController,
                  decoration: getMomdayInputDecoration(tSentence(context, "color_hint")),
                  onChanged: (text) {
                    this.color = text;
                    updateBloc();
                  },
                ),
              ),
              Container(
                child: Text(
                    tTitle(context, "size"),
                    style: new TextStyle(fontSize: 20.0, color: Colors.black)
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.sizeController,
                  decoration: getMomdayInputDecoration(tSentence(context, "size_hint")),
                  onChanged: (text) {
                    if(text.isEmpty)
                      this.size = "none";
                    this.size = text;
                    updateBloc();
                  },
                ),
              ),
              Container(
                child: Text(
                    tTitle(context, "price"),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black)
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.priceController,
                  decoration: getMomdayInputDecoration(tSentence(context, "price_hint")),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value.isEmpty) {
                      return tSentence(context, 'field_required');
                  }
                },
                ),
              ),
              Container(
                child: Text(
                    tTitle(context, "dimensions"),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black
                    )
                ),
              ),
              dimensionsFormField(),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.widthController,
                  decoration: getMomdayInputDecoration(tSentence(context, "width")),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.heightController,
                  decoration: getMomdayInputDecoration(tSentence(context, "height")),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.lengthController,
                  decoration: getMomdayInputDecoration(tSentence(context, "length")),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                child: Text(
                    tTitle(context, "weight"),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black
                    )
                ),
              ),
              weightFormField(),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: this.weightController,
                  decoration: getMomdayInputDecoration(tSentence(context, "weight")),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                child: Text(
                    tTitle(context, "pickup"),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black
                    )
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10),
                child: TextFormField(
                  style: TextStyle(
                      fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: getMomdayInputDecoration(tSentence(context, "pickup_hint")),
                  controller: locationController,
                  validator: (value) {
                    if(value.isEmpty) {
                      return tSentence(context, 'field_required');
                    }
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    tTitle(context, "donation_ask"),
                    style: TextStyle(fontSize: 16)
                  ),
                  Switch(
                      value: donate,
                      onChanged: (bool value) {
                        setState(() {
                          donate = value;
                        });
                      }
                  )
                ],
              ),
              donate?
              Container(
                width: MediaQuery.of(context).size.width,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CharityModel>(
                    hint: Text(
                      tSentence(context, "charity"),
                      style:
                      TextStyle(
                          fontSize: 16,
                      ),
                    ),
                    value: selectedCharity,
                    onChanged: (CharityModel newValue) {
                      setState(() {
                        selectedCharity = newValue;
                      });
                    },
                    items: charities.map((CharityModel charity) {
                      return new DropdownMenuItem<CharityModel>(
                        value: charity,
                        child: new Text(
                          charity.name,
                          style:
                          TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ): Container(),
              Text(tSentence(context, "donation_msg"),
                style: TextStyle(fontSize: 16)
              ),
            ]
        ),
      ),
    );
  }

  bool setRequiredFields(){
    return name != null && description != null && selectedBrand != null && selectedCategory != null &&
        !(subCategories != null && selectedSubcategory == null) && selectedCondition != ''
        && price != 0 && pickUpLocation != "";

  }

  updateBloc(){

    if(this.widget.submit) {
      this.productManagerBloc.updateDescription(
          name, description, selectedBrand, selectedCategory, selectedSubcategory, selectedCondition,
          size, color, price, selectedDimensionsUnit, width, height, length, selectedWeightUnit,  weight,  pickUpLocation,  selectedCharity);
    }
  }

  categoryFormField() {
    return FormField<CategoryModel>(
      validator: (value) {
        if (selectedCategory == null) {
          return tSentence(context, 'field_required');
        }
      },
      builder: (FormFieldState<CategoryModel> state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  hint: new Text(
                    tSentence(context, "category_hint"),
                    style: TextStyle(fontSize: 16)
                  ),
                  value: selectedCategory,
                  onChanged: (CategoryModel newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      if(selectedCategory != null)
                        subCategories = selectedCategory.subCategories;

                      if(selectedCategory == null && selectedCategory.subCategories == []){
                        selectedSubcategory = null;
                        subCategories = [];
                      }
                    });
                  },
                  items: categories.map((CategoryModel category) {
                    return new DropdownMenuItem<CategoryModel>(
                      value: category,
                      child: new Text(
                        category.fullName,
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
              TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  subCategoryFormField() {
    return FormField<CategoryModel>(
      validator: (value) {
        if (selectedSubcategory == null) {
          return tSentence(context, 'field_required');
        }
      },
      builder: (FormFieldState<CategoryModel> state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  hint: new Text(
                    tSentence(context, "subcategory_hint"),
                    style: TextStyle(fontSize: 16)
                  ),
                  value: selectedSubcategory,
                  onChanged: (CategoryModel newValue) {
                    setState(() {
                      selectedSubcategory = newValue;
                    });
                  },
                  items: subCategories.map((CategoryModel subCategory) {
                    return new DropdownMenuItem<CategoryModel>(
                      value: subCategory,
                      child: new Text(
                        subCategory.fullName,
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
              TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  brandFormField() {
    return FormField<BrandModel>(
      validator: (value) {
        if (selectedBrand == null) {
          return tSentence(context, 'field_required');
        }
      },
      builder: (FormFieldState<BrandModel> state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BrandModel>(
                  hint: new Text(
                    tSentence(context, "brand_hint"),
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                  value: selectedBrand,
                  onChanged: (BrandModel newValue) {
                    setState(() {
                      selectedBrand = newValue;
                    });
                  },
                  items: brands.map((BrandModel brand) {
                    return new DropdownMenuItem<BrandModel>(
                      value: brand,
                      child: new Text(
                          brand.name,
                          style: TextStyle(fontSize: 16)
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
              TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  weightFormField() {
    return FormField<UnitModel>(
      validator: (value) {
        if (selectedWeightUnit == null) { // check if weight is inputed
          return tSentence(context, 'field_required');
        }
      },
      builder: (FormFieldState<UnitModel> state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UnitModel>(
                  hint: new Text(
                    tSentence(context, "weight_unit"),
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                  value: selectedWeightUnit,
                  onChanged: (UnitModel newValue) {
                    setState(() {
                      selectedWeightUnit = newValue;
                    });
                  },
                  items: weightUnits.map((UnitModel unit) {
                    return new DropdownMenuItem<UnitModel>(
                      value: unit,
                      child: new Text(
                          unit.name,
                          style: TextStyle(fontSize: 16)
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
              TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  dimensionsFormField() {
    return FormField<UnitModel>(
      validator: (value) {
        if (selectedDimensionsUnit == null && (width != null || height != null || length != null)) { // check if dimensions is inputed
          return tSentence(context, 'field_required');
        }
      },
      builder: (FormFieldState<UnitModel> state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UnitModel>(
                  hint: new Text(
                    tSentence(context, "dimensions_unit"),
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                  value: selectedDimensionsUnit,
                  onChanged: (UnitModel newValue) {
                    setState(() {
                      selectedDimensionsUnit = newValue;
                    });
                  },
                  items: dimensionsUnits.map((UnitModel unit) {
                    return new DropdownMenuItem<UnitModel>(
                      value: unit,
                      child: new Text(
                          unit.name,
                          style: TextStyle(fontSize: 16)
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
              TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  conditionFormField() {
    return FormField<dynamic>(
      validator: (value) {
        if (selectedCondition == null) {
          return tSentence(context, 'field_required');
        }
      },
      builder: (FormFieldState<dynamic> state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<dynamic>(
                  hint: new Text(
                    tSentence(context, "condition_hint"),
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                  value: selectedCondition,
                  onChanged: (dynamic newValue) {
                    setState(() {
                      selectedCondition = newValue;
                    });
                  },
                  items: conditions.map((dynamic condition) {
                    return new DropdownMenuItem<dynamic>(
                      value: condition,
                      child: new Text(
                          condition,
                          style: TextStyle(fontSize: 16)
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
              TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}