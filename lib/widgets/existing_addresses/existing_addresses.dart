import 'package:flutter/material.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/screens/manage_address_screen.dart';
import 'package:momday_app/styles/momday_colors.dart';

class ExistingAddresses extends StatefulWidget {
  final List<AddressModel> addresses;
  final bool allowSelection;
  final VoidCallback onAddressesModified;

  ExistingAddresses(
      {Key key,
      this.addresses,
      this.allowSelection: true,
      this.onAddressesModified})
      : super(key: key);

  @override
  ExistingAddressesState createState() => ExistingAddressesState();
}

class ExistingAddressesState extends State<ExistingAddresses> {
  AddressModel selectedAddress;

  @override
  void initState() {
    super.initState();

    if (widget.allowSelection == true) {
      if (widget.addresses.length > 0) {
        this.selectedAddress = widget.addresses[0];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var children;

    if (widget.addresses.length > 0) {
      children = widget.addresses
          .expand((address) => [
                Container(
                  foregroundDecoration: BoxDecoration(
                      border: Border.all(
                          color: address == this.selectedAddress
                              ? MomdayColors.MomdayGold
                              : Colors.black,
                          width: 2.0)),
                  child: ListTile(
                    title: Text(
                      address.oneLineFormat,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: address == this.selectedAddress
                              ? MomdayColors.MomdayGold
                              : Colors.black),
                    ),
                    trailing: IconButton(
                        icon: Icon(
                          getLocalizedForwardArrowIcon(context),
                          color: address == this.selectedAddress
                              ? MomdayColors.MomdayGold
                              : Colors.black,
                        ),
                        onPressed: () async {
                          final bool addressModified =
                              await Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(
                                      builder: (context) => ManageAddressScreen(
                                            addressModel: address,
                                          )));

                          if (addressModified &&
                              widget.onAddressesModified != null) {
                            widget.onAddressesModified();
                          }
                        }),
                    onTap: widget.allowSelection
                        ? () {
                            setState(() {
                              this.selectedAddress = address;
                            });
                          }
                        : null,
                  ),
                ),
                SizedBox(
                  height: address == widget.addresses.last ? 0.0 : 8.0,
                )
              ])
          .toList();
    } else {
      children = [
        Text(tSentence(context, 'no_addresses'),
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 16.0, color: Colors.black.withOpacity(0.4)))
      ];
    }

    return ListView(primary: false, shrinkWrap: true, children: children);
  }
}
