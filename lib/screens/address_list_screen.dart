import 'package:flutter/material.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/manage_address_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';
import 'package:momday_app/widgets/existing_addresses/existing_addresses.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final GlobalKey<ElegantMemoizedFutureBuilderState> _futureBuilder =
      GlobalKey<ElegantMemoizedFutureBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          PageHeader2(
            title: tTitle(context, 'my_addresses'),
          ),
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElegantMemoizedFutureBuilder(
              key: this._futureBuilder,
              futureCallBack: () => MomdayBackend().getAddresses(),
              contentBuilder: (context, data) {
                List addresses =
                    AddressModel.fromDynamicListOrMap(data['data']);

                return ExistingAddresses(
                  onAddressesModified: () {
                    setState(() {
                      this._futureBuilder.currentState.reset();
                    });
                  },
                  addresses: addresses,
                  allowSelection: false,
                );
              },
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  color: MomdayColors.MomdayGold,
                  colorBrightness: Brightness.dark,
                  padding: EdgeInsets.symmetric(
                      vertical:
                          ButtonTheme.of(context).padding.along(Axis.vertical),
                      horizontal: 3.0),
                  child: Text(
                    tUpper(context, 'add_address'),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: () async {
                    final bool addressAdded =
                        await Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => ManageAddressScreen()));

                    if (addressAdded) {
                      setState(() {
                        this._futureBuilder.currentState.reset();
                      });
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
