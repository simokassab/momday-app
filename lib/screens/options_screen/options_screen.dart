import 'package:flutter/material.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/styles/momday_styles.dart';
import 'package:momday_app/widgets/add_or_wish/add_or_wish.dart';
import 'package:momday_app/widgets/quantity_counter/quantity_counter.dart';

class OptionsScreen extends StatefulWidget {
  final ProductModel product;
  final bool fromMenu;

  OptionsScreen({
    this.product,
    this.fromMenu = false,
  });

  @override
  OptionsScreenState createState() {
    return new OptionsScreenState();
  }
}

class OptionsScreenState extends State<OptionsScreen> {
  Map<OptionModel, OptionValueModel> selectedOptions = {};
  int quantity = 1;
  double finalPrice = 0;

  @override
  void initState() {
    this.quantity = 1;
    this.finalPrice = this.widget.product.originalPrice;

    for (OptionModel option in widget.product.availableOptions.keys)
      this.selectedOptions[option] = null;

    super.initState();
  }

  Widget build(context) {
    this.finalPrice = this.widget.product.originalPrice;

    for (OptionModel option in this.selectedOptions.keys) {
      if (this.selectedOptions[option] != null) {
        if (this.selectedOptions[option].pricePrefix == '-')
          finalPrice += this.selectedOptions[option].price * -1;
        else
          finalPrice += this.selectedOptions[option].price;
      }
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _options(),
      ),
    );
  }

  List<Widget> _options() {
    List<Widget> list = [];

    if (this.widget.product.availableOptions != null &&
        this.widget.product.availableOptions.length != 0) {
      list.add(Text(
        tUpper(context, "specify_options"),
        style: MomdayStyles.ThickMediumStyle,
      ));

      for (OptionModel option in this.widget.product.availableOptions.keys) {
        list.add(SizedBox(
          height: 10,
        ));
        List<DropdownMenuItem<OptionValueModel>> items = new List();

        for (OptionValueModel optionValue
            in widget.product.availableOptions[option]) {
          items.add(new DropdownMenuItem<OptionValueModel>(
            value: optionValue,
            child: new Text(
              optionValue.name,
              style: TextStyle(fontSize: 16),
            ),
          ));
        }

        list.add(Text(
          option.name,
          style: MomdayStyles.hint,
        ));

        list.add(Container(
          width: MediaQuery.of(context).size.width,
          child: items.length > 0
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<OptionValueModel>(
                    hint: new Text(
                        tSentence(context, "select_option") + " " + option.name,
                        style: TextStyle(fontSize: 16)),
                    value: selectedOptions[option],
                    onChanged: (OptionValueModel newValue) {
                      setState(() {
                        selectedOptions[option] = newValue;
                      });
                    },
                    items: items,
                  ),
                )
              : Text("option out of stock"),
        ));
      }
    }

//    if(this.finalPrice != 0)
//      list.add(
//          Text(
//          tSentence(context, 'final_price') + ': \$$finalPrice',
//            style: cancelArabicFontDelta(context).copyWith(
//                fontSize: 20.0,
//                color: MomdayColors.MomdayGold
//            ),
//          )
//      );

    if (this.widget.product.preloved == 0) {
      list.add(SizedBox(
        height: 10,
      ));
      list.add(
        Row(
          children: <Widget>[
            Text(
              tTitle(context, 'quantity'),
              style: cancelArabicFontDelta(context).copyWith(fontSize: 16.0),
            ),
            SizedBox(width: 8.0),
            QuantityCounter(
              quantity: this.quantity,
//            max: this.maxQuantity(),
              changeQuantityCallback: (newQuantity) {
                setState(() {
                  this.quantity = newQuantity;
                });
              },
            )
          ],
        ),
      );
    }

    list.add(SizedBox(height: 8));
    list.add(AddOrWish(
      newItem: true,
      quantity: this.quantity,
      fromMenu: this.widget.fromMenu,
      selectedOptions: selectedOptions,
      product: this.widget.product,
    ));

    return list;
  }
}
