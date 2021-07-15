import 'package:flutter/material.dart';
import 'package:momday_app/credit_card.dart';
import 'package:momday_app/screens/activity_screen/activity_screen.dart';
import 'package:momday_app/screens/cart_screen.dart';
import 'package:momday_app/screens/celebrity_screen.dart';
import 'package:momday_app/screens/momsay_post_screen/momsay_post_screen.dart';
import 'package:momday_app/screens/my_list_screen/my_list_product_details.dart';
import 'package:momday_app/screens/my_list_screen/my_list_product_manager/my_list_product_manager.dart';
import 'package:momday_app/screens/my_list_screen/my_list_screen.dart';
import 'package:momday_app/screens/product_listing_screen.dart';
import 'package:momday_app/screens/home_screen/home_screen.dart';
import 'package:momday_app/screens/momsay_screen.dart';
import 'package:momday_app/screens/product_screen.dart';
import 'package:momday_app/screens/shop_screen.dart';
import 'package:momday_app/screens/category_listing_screen.dart';
import 'package:momday_app/screens/celebrities_screen.dart';
import 'package:momday_app/screens/activities_screen.dart';
import 'package:momday_app/screens/wishlist_screen.dart';

// replaced shopscreen() everywhere with categorylisting() to remove preloved for now
abstract class MomdayNavigator extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey;
  final FocusScopeNode focusScopeNode;

  MomdayNavigator(
    this.navigatorKey,
    this.focusScopeNode
  );

  static MomdayNavigator of(int index, GlobalKey<NavigatorState> navigatorKey, FocusScopeNode focusScoepNode) {
    Widget subNavigator;
    switch (index) {
      case 0:
        subNavigator = HomeNavigator(navigatorKey, focusScoepNode);
        break;
      case 1:
        subNavigator = CelebritiesNavigator(navigatorKey, focusScoepNode);
        break;
      case 2:
        subNavigator = ShopNavigator(navigatorKey, focusScoepNode);
        break;
      case 3:
        subNavigator = ActivitiesNavigator(navigatorKey, focusScoepNode);
        break;
      case 4:
        subNavigator = MomsayNavigator(navigatorKey, focusScoepNode);
        break;
      default:
        throw("Unrecognized tab index");
    }

    return subNavigator;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: this.focusScopeNode,
      child: Navigator(
        key: this.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: onGenerateRoute,
        onUnknownRoute: onUnknownRoute,
      ),
    );
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings);
  Route<dynamic> onUnknownRoute(RouteSettings settings);

  Widget _surround(Widget child) {
    return Container(
      color: Colors.white,
      child: child
    );
  }

}

class HomeNavigator extends MomdayNavigator {

  HomeNavigator(navigatorKey, focusScopeNode): super(navigatorKey, focusScopeNode);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return NoAnimationRoute(
      builder: (context) => _surround(HomeScreen())
    );
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return NoAnimationRoute(
        builder: (context) => _surround(HomeScreen()),

    );
  }
}

class CelebritiesNavigator extends MomdayNavigator {

  CelebritiesNavigator(navigatorKey, focusScopeNode): super(navigatorKey, focusScopeNode);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/celebrities') {
      return MaterialPageRoute(
          builder: (context) => _surround(CelebritiesScreen())
      );
    } else if (settings.name.startsWith('/celebrity/')) {
      return MaterialPageRoute(
        builder: (context) =>
          _surround(CelebrityScreen(
            celebrityId: settings.name.substring('/celebrity/'.length),
          ))
      );
    } else if (settings.name.startsWith('/product')) {

      return MaterialPageRoute(
          builder: (context) {
            return _surround(ProductScreen(
              productId: settings.name.substring('/product/'.length),
            ));
          }
      );
    }
    return null;
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (context) => _surround(CelebritiesScreen())
    );
  }
}

class ShopNavigator extends MomdayNavigator {

  ShopNavigator(navigatorKey, focusScopeNode): super(navigatorKey, focusScopeNode);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {

    if (settings.name == '/shop') {
      return MaterialPageRoute(
        builder: (context) => _surround(
            CategoryListingScreen(
              type: 'new'
            )
        )
      );
    } else if (settings.name.startsWith('/category-listing')) {
      return MaterialPageRoute(
        builder: (context) {
          return _surround(CategoryListingScreen(
            type: settings.name.substring('/category-listing/'.length)
          ));
        }
      );
    } else if (settings.name.startsWith('/product-listing')) {
      return MaterialPageRoute(
          builder: (context) {
            var uri = Uri.parse(settings.name);

            return _surround(ProductListingScreen(
              categoryId: uri.queryParameters['categoryId'],
              brandId: uri.queryParameters['brandId'],
              type: uri.queryParameters['type'],
            ));
          }
      );
    } else if (settings.name.startsWith('/product')) {

      return MaterialPageRoute(
        builder: (context) {
          return _surround(ProductScreen(
            productId: settings.name.substring('/product/'.length),
          ));
        }
      );
    } else if (settings.name == '/cart') {
      return MaterialPageRoute(
        builder: (context) => _surround(CartScreen())
      );
    } else if (settings.name == '/wishlist') {
      return MaterialPageRoute(
          builder: (context) => _surround(WishlistScreen())
      );
    }else if (settings.name == '/visa') {
      return MaterialPageRoute(
          builder: (context) => _surround(credit_card())
      );
    }
//
//    else if (settings.name.startsWith('/my-list')) {
//      final subscreen = settings.name.substring('/my-list'.length);
//
//      if (subscreen == '') {
//
//        return MaterialPageRoute(
//            builder: (context) {
//              return _surround(MyListScreen());
//            }
//        );
//      }
//
//      else if (subscreen.startsWith('/product-details')) {
//        return MaterialPageRoute(
//            builder: (context) => _surround(MyListProductDetails())
//        );
//      }
//
//      else if (subscreen.startsWith('/product')) {
//        return MaterialPageRoute(
//            builder: (context) => _surround(MyListProductManager())
//        );
//      }
//    }
//
    else {
      return MaterialPageRoute(
        builder: (context) => _surround(CategoryListingScreen(
            type: 'new'
        ))
      );
    }
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => _surround(CategoryListingScreen(
          type: 'new'
      ))
    );
  }
}

class ActivitiesNavigator extends MomdayNavigator {

  ActivitiesNavigator(navigatorKey, focusScopeNode): super(navigatorKey, focusScopeNode);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/activities') {
      return MaterialPageRoute(
          builder: (context) => _surround(ActivitiesScreen())
      );
    } else if (settings.name.startsWith('/activity/')) {
      return MaterialPageRoute(
          builder: (context) =>
              _surround(ActivityScreen(
                activityId: settings.name.substring('/activity/'.length),
              ))
      );
    }
    return null;
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (context) => _surround(ActivitiesScreen())
    );
  }
}

class MomsayNavigator extends MomdayNavigator {

  MomsayNavigator(navigatorKey, focusScopeNode): super(navigatorKey, focusScopeNode);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/momsay') {
      return MaterialPageRoute(
          builder: (context) => _surround(MomsayScreen())
      );
    } else if (settings.name.startsWith('/momsay-post/')) {
      return MaterialPageRoute(
          builder: (context) =>
              _surround(MomsayPostScreen(
                postId: settings.name.substring('/momsay-post/'.length),
              ))
      );
    }
    return null;
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (context) => _surround(MomsayScreen())
    );
  }
}

class NoAnimationRoute extends MaterialPageRoute {

  NoAnimationRoute({builder}): super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}