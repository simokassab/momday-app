import 'package:flutter/material.dart';
import 'package:momday_app/styles/momday_colors.dart';

typedef void RatingChangeCallback(double rating);

class StarRatingFormField extends FormField<double> {
  StarRatingFormField(
      {double iconSize,
      Color color: MomdayColors.MomdayGold,
      onSaved,
      validator,
      double initialValue: 0.0,
      bool autovalidate: false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autovalidate,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StarRating(
                    color: color,
                    iconSize: iconSize,
                    readOnly: false,
                    rating: state.value,
                    onRatingChanged: (rating) {
                      state.didChange(rating);
                    },
                  ),
                  state.hasError && state.errorText != null
                      ? Builder(
                          builder: (context) => Text(
                            state.errorText,
                            style:
                                TextStyle(color: Theme.of(context).errorColor),
                          ),
                        )
                      : Container()
                ],
              );
            });
}

class StarRating extends StatelessWidget {
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final bool readOnly;
  final double iconSize;
  final Color color;

  StarRating(
      {this.rating = 0.0,
      this.onRatingChanged,
      this.readOnly,
      this.iconSize,
      this.color = MomdayColors.MomdayGold});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        size: this.iconSize,
        color: this.color,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        size: this.iconSize,
        color: this.color,
      );
    } else {
      icon = new Icon(
        Icons.star,
        size: this.iconSize,
        color: this.color,
      );
    }
    return new InkResponse(
      onTap: readOnly || onRatingChanged == null
          ? null
          : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        children: new List.generate(5, (index) => buildStar(context, index)));
  }
}
