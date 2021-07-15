import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';

import 'app_state_manager.dart';
import 'models/models.dart';
import 'momday_localizations.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  runApp(credit_card());
}

class credit_card extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<credit_card> {
  final GlobalKey<ElegantMemoizedFutureBuilderState> _futureBuilder =
      GlobalKey<ElegantMemoizedFutureBuilderState>();

  String cardNumber = "";
  String cardHolderName = "";
  String expiryDate = "";
  String cvv = "";
  bool showBack = false;
  bool _ispaid = false;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            CreditCard(
              cardNumber: cardNumber,
              cardExpiry: expiryDate,
              cardHolderName: cardHolderName,
              cvv: cvv,
              bankName: "Axis Bank",
              showBackSide: showBack,
              frontBackground: CardBackgrounds.black,
              backBackground: CardBackgrounds.white,
              showShadow: true,
            ),
            SizedBox(
              height: 40,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Card Number"),
                    maxLength: 19,
                    onChanged: (value) {
                      setState(() {
                        cardNumber = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Card Expiry"),
                    maxLength: 5,
                    onChanged: (value) {
                      setState(() {
                        expiryDate = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Card Holder Name"),
                    onChanged: (value) {
                      setState(() {
                        cardHolderName = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "CVV"),
                    maxLength: 3,
                    onChanged: (value) {
                      setState(() {
                        cvv = value;
                      });
                    },
                    focusNode: _focusNode,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: RaisedButton(
                      color: MomdayColors.MomdayGold,
                      child: this._ispaid
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Theme(
                                  data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                ),
                              ))
                          : ListTile(
                              title: Text(tSentence(context, 'pay'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                      onPressed: () => this._payfort(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showTextSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 3),
    ));
  }

  _payfort(BuildContext context) async {
    CartModel cart = AppStateManager.of(context).cart;
    AccountModel user = AppStateManager.of(context).account;
    dynamic response = await MomdayBackend().PayfortRequest(
        amount: cart.total,
        email: user.email,
        token_name: user.fullName,
        card_number: cardNumber,
        card_security_code: cvv,
        expiry_date: expiryDate,
        card_holder_name: cardHolderName);
    if (response == 'success') {
      Set<ProductModel> set = Set.from(cart.products);
      List<Item> items = new List<Item>();
      set.forEach((element) => {
            items.add(new Item.fromJson({
              "PackageType": "Box",
              "Quantity": element.quantityInCart,
              "Weight":
                  new Weight.fromJson({"Unit": "Kg", "Value": cart.weight}),
              "Comments": element.description
            }))
          });
      response = await MomdayBackend().AramexRequest(
          width: 0,
          height: 0,
          length: 0,
          weight: 0,
          description: "",
          nbpeices: cart.products.length);

      if (response == 'success')
        Navigator.pushReplacementNamed(context, '/');
      else {
        showTextSnackBar(context, response.toString());
      }
    } else {
      showTextSnackBar(context, response.toString());
    }
  }

  _aramex(BuildContext context) async {
    CartModel cart = AppStateManager.of(context).cart;
    AccountModel user = AppStateManager.of(context).account;
    dynamic response = await MomdayBackend().PayfortRequest(
        amount: cart.total,
        email: user.email,
        token_name: user.fullName,
        card_number: cardNumber,
        card_security_code: cvv,
        expiry_date: expiryDate,
        card_holder_name: cardHolderName);
    if (response == 'success') {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      showTextSnackBar(context, response.toString());
    }
  }
}
