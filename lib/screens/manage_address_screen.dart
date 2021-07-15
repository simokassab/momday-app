import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/search/search_helpers.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ManageAddressScreen extends StatefulWidget {
  final AddressModel addressModel;

  ManageAddressScreen({this.addressModel});

  @override
  _ManageAddressScreenState createState() => _ManageAddressScreenState();
}

enum _ManageAddressMode { EDIT, ADD }

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  List<String> _cities;

  String _country;
  String _city;
  String _address;
  bool _isCarryingOperation;
  bool _isDeleting;
  String _errorMessage;

  _ManageAddressMode get mode => (widget.addressModel != null
      ? _ManageAddressMode.EDIT
      : _ManageAddressMode.ADD);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _citiesFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    this._isCarryingOperation = false;
    this._isDeleting = false;
    this._citiesFieldController.text =
        this.mode == _ManageAddressMode.EDIT ? widget.addressModel.city : null;

    MomdayBackend().getCities(118).then((cities) {
      setState(() {
        this._cities = List.castFrom<dynamic, String>(cities['data']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(
              getLocalizedBackwardArrowIcon(context),
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            }),
      ),
      backgroundColor: Colors.white,
      body: Theme(
        data: ThemeData(fontFamily:'VAG',primaryColor: MomdayColors.MomdayGold),
        child: Form(
          key: this._formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            children: <Widget>[
              TextFormField(
                enabled: false,
                initialValue: tUpper(context, 'lebanon'),
                decoration:
                    getMomdayInputDecoration(tTitle(context, 'country')),
                onSaved: (value) => this._country = value,
              ),
              SizedBox(height: 10.0),
              TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                      decoration:
                          getMomdayInputDecoration(tTitle(context, 'city')),
                      controller: this._citiesFieldController),
                  onSuggestionSelected: (suggestion) {
                    this._citiesFieldController.text = suggestion;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  suggestionsCallback: (pattern) {
                    if (this._cities == null) {
                      return [];
                    } else {
                      return this._getSuggestions(pattern);
                    }
                  },
                  onSaved: (value) => this._city = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return tSentence(context, 'field_required');
                    }
                  }),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: this.mode == _ManageAddressMode.EDIT
                    ? widget.addressModel.addressLines
                    : null,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  labelText: tTitle(context, 'address'),
                ),
                onSaved: (value) => this._address = value,
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }

                  if (value.split('\n').length > 2) {
                    return tSentence(context, 'enter_less_than_2_lines');
                  }
                },
              ),
              SizedBox(height: 10.0),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                this.mode == _ManageAddressMode.EDIT
                    ? RaisedButton(
                        color: MomdayColors.MomdayGray,
                        padding: EdgeInsets.symmetric(
                            vertical: ButtonTheme.of(context)
                                .padding
                                .along(Axis.vertical),
                            horizontal: 3.0),
                        child: this._isDeleting
                            ? SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Theme(
                                  data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                ))
                            : Text(
                                tUpper(context, 'delete_address'),
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                        onPressed: this._removeAddress,
                      )
                    : Container(),
                SizedBox(width: 8.0),
                RaisedButton(
                  color: MomdayColors.MomdayGold,
                  colorBrightness: Brightness.dark,
                  padding: EdgeInsets.symmetric(
                      vertical:
                          ButtonTheme.of(context).padding.along(Axis.vertical),
                      horizontal: 3.0),
                  child: this._isCarryingOperation
                      ? SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: Theme(
                            data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                          ))
                      : Text(
                          tUpper(
                              context,
                              this.mode == _ManageAddressMode.EDIT
                                  ? 'change_address'
                                  : 'add_address'),
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                  onPressed: this._addOrEditAddress,
                )
              ]),
              SizedBox(
                height: 10.0,
              ),
              this._errorMessage != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          this._errorMessage,
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  _removeAddress() async {
    if (!this._isCarryingOperation && !this._isDeleting) {
      var confirmation = await showConfirmDialog(
          context, tSentence(context, 'confirm_remove_address'));

      if (confirmation != true) return;

      setState(() {
        this._isDeleting = true;
      });

      var response = await MomdayBackend()
          .deleteAddress(addressId: widget.addressModel.addressId);

      setState(() {
        if (response['success'] == 1) {
          this._errorMessage = null;
          Navigator.of(context).pop(true);
        } else {
          this._errorMessage = response['error'][0];
        }
        this._isDeleting = false;
      });
    }
  }

  _addOrEditAddress() async {
    if (!this._isCarryingOperation && !this._isDeleting) {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();

        setState(() {
          this._isCarryingOperation = true;
        });

        /*var response = await MomdayBackend().validateAddress(
            countryCode: 'LB',
            city: this._city,
            address: this._address
        );

        if (response!=null && response['HasErrors'] == false) {*/
        var response;

        if (this.mode == _ManageAddressMode.ADD) {
          response = await MomdayBackend().addAddress(
              address: this._address,
              city: this._city,
              firstName: AppStateManager.of(context).account.firstName,
              lastName: AppStateManager.of(context).account.firstName,
              countryId:
                  118 // hardcoded value for Lebanon, if we support other countries later this needs to change
              );
        } else {
          response = await MomdayBackend().editAddress(
              addressId: widget.addressModel.addressId,
              address: this._address,
              city: this._city,
              firstName: AppStateManager.of(context).account.firstName,
              lastName: AppStateManager.of(context).account.firstName,
              countryId:
                  118 // hardcoded value for Lebanon, if we support other countries later this needs to change
              );
        }

        setState(() {
          if (response['success'] == 1) {
            this._errorMessage = null;
            Navigator.of(context).pop(true);
          } else {
            this._errorMessage = response['error'][0];
          }
          this._isCarryingOperation = false;
        });
      }
      /*else {
          setState(() {
            this._isCarryingOperation = false;
            if (response['Notifications'] is List) {
              this._errorMessage
              = tSentence(context, 'failed_to_add_address');
            } else {
              this._errorMessage = response['Notifications']['Notification']['Message'];
            }
          });
        }
      }*/
    }
  }

  List<String> _getSuggestions(String search) {
    this._cities.sort(
        (a, b) => (this._distance(search, a) - this._distance(search, b)));

    return this._cities.take(4).toList();
  }

  int _distance(String first, String second) {
    return Levenshtein().distance(first, second);
  }
}
