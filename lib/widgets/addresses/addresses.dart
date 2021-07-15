import 'package:flutter/material.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/cart_screen.dart';
import 'package:momday_app/screens/manage_address_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';
import 'package:momday_app/widgets/existing_addresses/existing_addresses.dart';

class Addresses extends StatefulWidget {
  @override
  _AddressesState createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {
  final GlobalKey<ExistingAddressesState> _existingAddressesKey =
      GlobalKey<ExistingAddressesState>();
  final GlobalKey<ElegantMemoizedFutureBuilderState> _futureBuilder =
      GlobalKey<ElegantMemoizedFutureBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 52.0),
      child: ElegantMemoizedFutureBuilder(
        key: this._futureBuilder,
        fullError: false,
        futureCallBack: () => MomdayBackend().getAddresses(),
        contentBuilder: (context, data) {
          var addresses = AddressModel.fromDynamicListOrMap(data['data']);

          return Column(
            children: <Widget>[
              Text(
                tUpper(context, "select_address"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MomdayColors.MomdayGold,
                    fontSize: 24.0),
              ),
              SizedBox(
                height: 8.0,
              ),
              Expanded(
                child: ListView(children: <Widget>[
                  ExistingAddresses(
                    addresses: addresses,
                    key: _existingAddressesKey,
                    onAddressesModified: () {
                      setState(() {
                        this._futureBuilder.currentState.reset();
                      });
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  RaisedButton(
                    colorBrightness: Brightness.dark,
                    color: Colors.black,
                    child: ListTile(
                      dense: true,
                      title: Text(
                        tTitle(context, 'add_new_address'),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      final bool didAdd =
                          await Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => ManageAddressScreen()));

                      if (didAdd) {
                        setState(() {
                          this._futureBuilder.currentState.reset();
                        });
                      }
                    },
                  ),
                ]),
              ),
              SizedBox(
                height: 8.0,
              ),
              ContinueToPaymentButton(
                existingAddressesKey: this._existingAddressesKey,
              ),
            ],
          );
        },
      ),
    );
  }
}
