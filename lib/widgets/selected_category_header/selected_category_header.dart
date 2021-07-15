import 'package:flutter/material.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class SelectedCategoryHeader extends StatelessWidget {

  final String selectedCategoryId;
  final List<CategoryModel> categories;

  SelectedCategoryHeader({
    this.selectedCategoryId,
    this.categories,
  });

  @override
  Widget build(BuildContext context) {
    var selectedCategoryPath = CategoryModel.findCategoryWithId(
      categoryId: this.selectedCategoryId,
      categories: this.categories
    )?.fullPath;

    var label = ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8
      ),
      child: FittedBox(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: selectedCategoryPath != null? selectedCategoryPath[0] : tTitle(context, 'all_categories'),
            style: Theme.of(context).textTheme.display3.copyWith(
              fontSize: 24.0
            ),
            children: selectedCategoryPath != null? selectedCategoryPath.sublist(1).map((pathEntry) {
              return TextSpan(
                text: ' | $pathEntry',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                )
              );
            }).toList() : null
          ),
        ),
      ),
    );

    return PageHeader(
      widgetTitle: Center(child: label)
    );
  }
}