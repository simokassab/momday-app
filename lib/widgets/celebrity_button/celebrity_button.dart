import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/styles/momday_colors.dart';

class CelebrityButton extends StatefulWidget {
  final String productId;

  CelebrityButton({this.productId});

  @override
  CelebrityButtonState createState() {
    return new CelebrityButtonState();
  }
}

class CelebrityButtonState extends State<CelebrityButton> {
  bool _isPerformingAction;

  @override
  void initState() {
    super.initState();
    this._isPerformingAction = false;
  }

  @override
  Widget build(BuildContext context) {
    final appStateManager = AppStateManager.of(context);

    final containedInStore = appStateManager.account.isCelebrity &&
        appStateManager.account.store.productIds.contains(widget.productId);

    final buttonColor =
        containedInStore ? MomdayColors.MomdayGold : Colors.black;

    final buttonText = !containedInStore ? 'add_to_my_store' : 'in_my_my_store';

    final loading = SizedBox(
      height: 18.0,
      width: 18.0,
      child: Theme(
        data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
      ),
    );

    return FlatButton(
      color: buttonColor,
      colorBrightness: Brightness.dark,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: Border(),
      child: this._isPerformingAction
          ? loading
          : FittedBox(
              child: Text(tUpper(context, buttonText)),
            ),
      onPressed: () => this._handleButtonPress(containedInStore),
    );
  }

  _handleButtonPress(bool containedInStore) async {
    if (!this._isPerformingAction) {
      setState(() {
        this._isPerformingAction = true;
      });

      if (!containedInStore) {
        await AppStateManager.of(context)
            .addToMyCelebrityStore(productId: this.widget.productId);
      } else {
        await AppStateManager.of(context)
            .removeFromMyCelebrityStore(productId: this.widget.productId);
      }

      setState(() {
        this._isPerformingAction = false;
      });
    }
  }
}
