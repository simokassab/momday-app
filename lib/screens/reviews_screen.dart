import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:momday_app/widgets/star_rating/star_rating.dart';

enum ReviewMode { ViewAll, Write, ViewOne }

class ReviewsScreen extends StatefulWidget {
  final ProductModel product;
  final ReviewMode mode;
  final ReviewModel currentReview;

  ReviewsScreen({this.mode, this.currentReview, this.product});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  ReviewMode mode;
  ReviewModel currentReview;

  @override
  void initState() {
    super.initState();
    if (widget.mode != null) {
      this.mode = widget.mode;
      this.currentReview = widget.currentReview;
    } else {
      this.mode = ReviewMode.ViewAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goIcon = Localizations.localeOf(context).languageCode == 'ar'
        ? Icons.keyboard_arrow_left
        : Icons.keyboard_arrow_right;

    final alreadyReviewed = widget.product.reviews.any((review) =>
        review.customerId == AppStateManager.of(context).account?.customerId);

    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            primary: false,
            shrinkWrap: true,
            children: <Widget>[
              PageHeader(
                title: tTitle(context, 'customer_reviews'),
              ),
            ]
              ..addAll(this.mode == ReviewMode.Write
                  ? this._buildWriteReview(context)
                  : [])
              ..addAll(this.mode == ReviewMode.ViewOne
                  ? this._buildCurrentReview(context, this.currentReview)
                  : [])
              ..addAll(this._buildMainView(context))
              ..addAll(this.mode != ReviewMode.Write && !alreadyReviewed
                  ? [
                      Container(
                        foregroundDecoration: BoxDecoration(
                          border: Border.all(
                              color: MomdayColors.MomdayGold, width: 0.5),
                        ),
                        child: ListTile(
                          title: Row(
                            children: <Widget>[
                              Text(
                                tUpper(context, 'add_your_review'),
                                style: TextStyle(
                                    color: MomdayColors.MomdayGold,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              StarRating(
                                  iconSize: 16.0, readOnly: true, rating: 0.0),
                            ],
                          ),
                          subtitle: Text(
                            tLower(context, 'share_your_review'),
                            style: TextStyle(color: MomdayColors.MomdayGold),
                          ),
                          trailing: Icon(
                            goIcon,
                            color: MomdayColors.MomdayGold,
                          ),
                          onTap: () {
                            if (!AppStateManager.of(context)
                                .account
                                .isLoggedIn) {
                              askForLogin(context, 'add_your_review');
                            } else {
                              setState(() {
                                this.mode = ReviewMode.Write;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      )
                    ]
                  : []),
          ),
        )
      ],
    );
  }

  List<Widget> _buildMainView(BuildContext context) {
    return [
      SizedBox(
        height: 16.0,
      ),
      Row(
        children: <Widget>[
          Text(
            tCount(context, 'review', widget.product.totalNumberOfReviews),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
          SizedBox(
            width: 4.0,
          ),
          StarRating(
            readOnly: true,
            color: Colors.black,
            rating: widget.product.rating,
            iconSize: 12.0,
          )
        ],
      ),
      SizedBox(
        height: 16.0,
      ),
    ]..addAll(this._buildReviews(context));
  }

  List<Widget> _buildReviews(BuildContext context) {
    final goIcon = Localizations.localeOf(context).languageCode == 'ar'
        ? Icons.keyboard_arrow_left
        : Icons.keyboard_arrow_right;

    return widget.product.reviews.expand((review) {
      return [
        SizedBox(
          height: 8.0,
        ),
        Container(
          foregroundDecoration: BoxDecoration(border: Border.all(width: 0.5)),
          child: ListTile(
            title: Text(
              review.text,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            subtitle: Row(
              children: <Widget>[
                Text(
                  '- ' + review.author,
                  style: TextStyle(height: 1.5),
                ),
                StarRating(
                    iconSize: 16.0, readOnly: true, rating: review.rating),
              ],
            ),
            trailing: Icon(goIcon),
            onTap: () {
              setState(() {
                this.mode = ReviewMode.ViewOne;
                this.currentReview = review;
              });
            },
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
      ];
    }).toList();
  }

  List<Widget> _buildWriteReview(BuildContext context) {
    return [
      SizedBox(
        height: 16.0,
      ),
      WriteReviewWidget(
        onWriteReview: (name, text, rating) async {
          var result = await MomdayBackend().writeReview(
              productId: widget.product.productId,
              name: name,
              text: text,
              rating: rating);

          if (result['success'] == 1) {
            setState(() {
              this.mode = ReviewMode.ViewAll;
            });
            showTextSnackBar(context, tSentence(context, 'review_submitted'));
          }
        },
      ),
      SizedBox(
        height: 16.0,
      ),
      Container(
        height: 2.0,
        color: MomdayColors.MomdayGray,
      )
    ];
  }

  List<Widget> _buildCurrentReview(
      BuildContext context, ReviewModel currentReview) {
    return [
      SizedBox(
        height: 16.0,
      ),
      Container(
        foregroundDecoration: BoxDecoration(border: Border.all(width: 0.5)),
        child: ListTile(
            title: Text(
              currentReview.text,
            ),
            subtitle: Row(
              children: <Widget>[
                Text(
                  '- ' + currentReview.author,
                  style: TextStyle(height: 1.5),
                ),
                StarRating(
                    iconSize: 16.0,
                    readOnly: true,
                    rating: currentReview.rating),
              ],
            )),
      ),
      SizedBox(
        height: 16.0,
      ),
      Container(
        height: 2.0,
        color: MomdayColors.MomdayGray,
      )
    ];
  }
}

typedef WriteReviewCallback(
    String name, String reviewText, double reviewRating);

class WriteReviewWidget extends StatefulWidget {
  final WriteReviewCallback onWriteReview;

  WriteReviewWidget({this.onWriteReview});

  @override
  _WriteReviewWidgetState createState() => _WriteReviewWidgetState();
}

class _WriteReviewWidgetState extends State<WriteReviewWidget> {
  double _rating;
  String _reviewText;
  String _name;
  bool _isLoading;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this._rating = 0.0;
    this._isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (AppStateManager.of(context).account != null &&
        AppStateManager.of(context).account.fullName != null)
      this._name = AppStateManager.of(context).account.fullName;

    return Form(
      key: this._formKey,
      child: Column(
        children: <Widget>[
          Theme(
            data: ThemeData(fontFamily:'VAG',
              hintColor: MomdayColors.MomdayGold,
              primaryColor: MomdayColors.MomdayGold,
            ),
            child: TextFormField(
                initialValue: _name,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  hintText: tLower(context, 'name'),
                  hintStyle: TextStyle(color: MomdayColors.MomdayGold),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }
                },
                onSaved: (value) => this._name = value),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            foregroundDecoration: BoxDecoration(
                border: Border(
              right: BorderSide(
                color: MomdayColors.MomdayGold,
              ),
              left: BorderSide(
                color: MomdayColors.MomdayGold,
              ),
            )),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StarRatingFormField(
                  iconSize: 18.0,
                  onSaved: (value) => this._rating = value,
                  validator: (value) {
                    if (value == 0.0) {
                      return tSentence(context, 'provide_rating');
                    }
                  },
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  tTitle(context, 'rate_this_item'),
                  style:
                      TextStyle(color: MomdayColors.MomdayGold, fontSize: 16.0),
                )
              ],
            ),
          ),
          Theme(
            data: ThemeData(fontFamily:'VAG',
              hintColor: MomdayColors.MomdayGold,
              primaryColor: MomdayColors.MomdayGold,
            ),
            child: TextFormField(
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  contentPadding:
                      EdgeInsets.only(right: 8.0, left: 8.0, bottom: 70.0),
                  hintText: tLower(context, 'share_your_review'),
                  hintStyle: TextStyle(color: MomdayColors.MomdayGold),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }

                  if (value.length < 25) {
                    return tSentence(context, 'review_length_restrictions');
                  }
                },
                onSaved: (value) => this._reviewText = value),
          ),
          SizedBox(
            height: 16.0,
          ),
          RaisedButton(
            color: MomdayColors.MomdayGold,
            colorBrightness: Brightness.dark,
            child: this._isLoading
                ? SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: Theme(
                      data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                    ))
                : Text(tUpper(context, 'add_your_review')),
            onPressed: () async {
              if (!this._isLoading) {
                if (this._formKey.currentState.validate()) {
                  this._formKey.currentState.save();

                  setState(() {
                    this._isLoading = true;
                  });

                  await widget.onWriteReview(
                      this._name, this._reviewText, this._rating);

                  setState(() {
                    this._isLoading = false;
                  });
                }
              }
            },
          )
        ],
      ),
    );
  }
}
