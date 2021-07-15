import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/widgets/featured/featured.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class CategoryListingScreen extends StatelessWidget {

  final String type;

  CategoryListingScreen({this.type});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        ListView(
          padding: EdgeInsets.all(8.0),
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            PageHeader(
              widgetTitle: this._getTitle(context)
            ),
            SizedBox(height: 15.0),
            Categories(
              onCategoryTap: (String categoryId) {
                Navigator.of(context).pushNamed('/product-listing?categoryId=$categoryId&type=$type');
              },
            ),
            SizedBox(height: 40.0),
            Text(
              tTitle(context, 'featured_items'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 10.0,),
            Featured(
              hasOverlay: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _getTitle(BuildContext context) {
    var nounStyle = Theme.of(context).textTheme.display3.copyWith(
      fontWeight: FontWeight.w300
    );
    var adjectiveStyle = Theme.of(context).textTheme.display3;
    String noun = tTitle(context, 'products',);
//    String adjective = tTitle(context, this.type);

    var language = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            text: noun,
            style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: "VAG",
                    fontWeight: FontWeight.w500),
//            children: [F
//              TextSpan(
//                  text: language == 'ar'? adjective : noun,
//                  style: language == 'ar'? adjectiveStyle : nounStyle
//              )
//            ]
          ),
        ),
      ],
    );
  }

}

typedef CategoryTapCallback(String categoryId);
class Categories extends StatelessWidget {

  final CategoryTapCallback onCategoryTap;

  Categories({this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    var categories = AppStateManager.of(context).categories;
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      mainAxisSpacing: 26.0,
      crossAxisSpacing: 8.0,
      crossAxisCount: 3,
      childAspectRatio: 1.4,
      children: categories.map((cat) {
        return Category(
          name: cat.name,
          image: cat.image,
          onTap: () {
            this.onCategoryTap(cat.categoryId);
          },
        );
      }).toList(),
    );
  }
}

class Category extends StatefulWidget {

  final GestureTapCallback onTap;
  final String name;
  final String image;
  Category({this.name, this.image, this.onTap});

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {

  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          this._isTapped = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          this._isTapped = false;
        });
      },
      onTapCancel: () {
        setState(() {
          this._isTapped = false;
        });
      },
      onTap: widget.onTap,
      child: Container(
        foregroundDecoration: BoxDecoration(
            border: this._isTapped? Border.all(
                color: Colors.black,
                width: 3.0
            ) : null
        ),
        child: Stack(
          children: <Widget>[
            MomdayNetworkImage(
              imageUrl: widget.image,
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              top: 0.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Wrap(
                  spacing: 2.0,
                  children: widget.name.split(' ').map((word) =>
                    FittedBox(
                      child: Text(
                        word,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.0
                        ),
                      ),
                    )
                  ).toList()
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}