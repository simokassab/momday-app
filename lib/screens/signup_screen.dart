import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

enum Genders { female, male }

class _SignupScreenState extends State<SignupScreen> {
  bool _isSigningUp;
  Genders radioGender = Genders.female;
  DateFormat _dateFormat = DateFormat("dd/MM/yyyy");
  String countrycode = "+961";
  @override
  void initState() {
    super.initState();
    this._lastNameFocusNode = FocusNode();
    this._emailFocusNode = FocusNode();
    this._dobFocusNode = FocusNode();
    this._phoneNumberFocusNode = FocusNode();
    this._passwordFocusNode = FocusNode();
    this._confirmPasswordFocusNode = FocusNode();
    this._isSigningUp = false;
  }

  FocusNode _lastNameFocusNode;
  FocusNode _emailFocusNode;
  FocusNode _dobFocusNode;
  FocusNode _phoneNumberFocusNode;
  FocusNode _passwordFocusNode;
  FocusNode _confirmPasswordFocusNode;

  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  String _firstName;
  String _lastName;
  String _email;
  String _dob;
  String _gender = '7'; // female
  String _phoneNumber;
  String _password;
  String _confirmPassword;

  TextEditingController tbod = TextEditingController();

  void setGender(Genders gender) {
    setState(() {
      this.radioGender = gender;

      if (gender == Genders.male)
        this._gender = '8';
      else
        this._gender = '7';

      print("gender is $_gender");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MomdayColors.MomdayGold,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(
                getLocalizedBackwardArrowIcon(context),
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        backgroundColor: MomdayColors.MomdayGold,
        body: Builder(builder: (BuildContext context) {
          return Form(
            key: this._formKey,
            child: Theme(
              data: ThemeData(fontFamily:'VAG',
                primaryColor: MomdayColors.MomdayGold,
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Text(tTitle(context, 'welcome'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.w600)),
                  SizedBox(height: 30.0),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    decoration:
                        getMomdayInputDecoration(tTitle(context, 'first_name')),
                    validator: (value) {
                      if (value.isEmpty) {
                        return tSentence(context, 'field_required');
                      }
                    },
                    onSaved: (value) => this._firstName = value,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(this._lastNameFocusNode),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: false,
                    focusNode: this._lastNameFocusNode,
                    decoration:
                        getMomdayInputDecoration(tTitle(context, 'last_name')),
                    validator: (value) {
                      if (value.isEmpty) {
                        return tSentence(context, 'field_required');
                      }
                    },
                    onSaved: (value) => this._lastName = value,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(this._emailFocusNode),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    focusNode: this._emailFocusNode,
                    decoration:
                        getMomdayInputDecoration(tTitle(context, 'email')),
                    validator: (value) {
                      if (value.isEmpty) {
                        return tSentence(context, 'field_required');
                      } else if (!emailRegExp.hasMatch(value)) {
                        return tSentence(context, 'not_valid_email');
                      }
                    },
                    onSaved: (value) => this._email = value,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(this._dobFocusNode),
                  ),
                  SizedBox(height: 10.0),
                  // FlatButton(

                  //     child: Text(
                  //       'show date time picker (Chinese)',
                  //       style: TextStyle(color: Colors.blue),
                  //     )),
                  TextFormField(
                    keyboardType: TextInputType.datetime,
                    autofocus: false,
                    focusNode: this._dobFocusNode,
                    controller: tbod,
                    decoration:
                        getMomdayInputDecoration(tTitle(context, 'dob')),
                    validator: (value) {
                      if (value.isEmpty) {
                        return tSentence(context, 'field_required');
                      } else if (!dobRegExp.hasMatch(value)) {
                        return tSentence(context, 'not_valid_dob');
                      }
                    },
                    onTap: () {
                      FocusScope.of(context).requestFocus(_dobFocusNode);
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(1950, 2, 1),
                          maxTime: DateTime(2005, 12, 12), onChanged: (date) {
                        print('change $date');
                      }, onConfirm: (date) {
                        setState(() {
                          String date_string = _dateFormat.format(date);
                          this._dob = date_string;
                          tbod.text = date_string;
                        });

                        // print(this._dob + "sfsdfsd");
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                    onSaved: (value) => this._dob = value,
//                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(this._phoneNumberFocusNode),
                  ),
                  SizedBox(height: 10.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Radio(
                        value: Genders.female,
                        groupValue: radioGender,
                        onChanged: (value) => setGender(value),
                        activeColor: Colors.white,
                      ),
                      new Text(
                        'Female',
                        style: new TextStyle(fontSize: 16.0),
                      ),
                      new Radio(
                        value: Genders.male,
                        groupValue: radioGender,
                        onChanged: (value) => setGender(value),
                        activeColor: Colors.white,
                      ),
                      new Text(
                        'Male',
                        style: new TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(),
                        child: CountryCodePicker(
                          onChanged: (code) {
                            setState(() {
                              countrycode = code.dialCode.toString();
                            });
                            print(countrycode);
                          },

                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: 'LB',
                          favorite: ['+961', 'LB', '+965', 'KW'],
                          //countryFilter: ['LB', 'KW'],
                          // optional. Shows only country name and flag
                          showCountryOnly: false,
                          // optional. Shows only country name and flag when popup is closed.
                          showOnlyCountryWhenClosed: false,
                          // optional. aligns the flag and the Text left
                          alignLeft: false,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          autofocus: false,
                          focusNode: this._phoneNumberFocusNode,
                          decoration: getMomdayInputDecoration(
                              tTitle(context, 'phone')),
                          validator: (value) {
                            if (value.isEmpty) {
                              return tSentence(context, 'field_required');
                            } else if (!phoneRegExp.hasMatch(value)) {
                              return tSentence(context, 'invalid_phoneNumber');
                            }
                          },
                          onSaved: (value) =>
                              this._phoneNumber = countrycode + value,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(this._passwordFocusNode),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0),
                  TextFormField(
                    autofocus: false,
                    focusNode: this._passwordFocusNode,
                    obscureText: true,
                    controller: this._passwordController,
                    decoration:
                        getMomdayInputDecoration(tTitle(context, 'password')),
                    validator: (value) {
                      if (value.isEmpty) {
                        return tSentence(context, 'field_required');
                      } else if (value.length < 4 || value.length > 20) {
                        return tSentence(context, 'password_length');
                      }
                    },
                    onSaved: (value) => this._password = value,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(this._confirmPasswordFocusNode),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    autofocus: false,
                    obscureText: true,
                    focusNode: this._confirmPasswordFocusNode,
                    decoration: getMomdayInputDecoration(
                        tTitle(context, 'confirm_password')),
                    validator: (value) {
                      if (value.isEmpty) {
                        return tSentence(context, 'field_required');
                      } else if (value != this._passwordController.text) {
                        return tSentence(context, 'confirm_password_different');
                      }
                    },
                    onSaved: (value) => this._confirmPassword = value,
                  ),
                  SizedBox(height: 20.0),
                  RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.grey),
                        text: tSentence(context, 'by_submitting'),
                        children: [
                          TextSpan(
                              text: t(context, 'terms_of_service'),
                              style: TextStyle(color: Colors.white),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('terms of service');
                                }),
                          TextSpan(text: t(context, 'and')),
                          TextSpan(
                              text: t(context, 'privacy_policy'),
                              style: TextStyle(color: Colors.white),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('privacy policy');
                                }),
                          TextSpan(text: '.')
                        ]),
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton(
                      color: Colors.white,
                      child: this._isSigningUp
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Theme(
                                  data: ThemeData(fontFamily:'VAG',accentColor: MomdayColors.MomdayGold),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                ),
                              ))
                          : ListTile(
                              title: Text(tSentence(context, 'sign_up'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                      onPressed: () => this._onSignUp(context)),
                ],
              ),
            ),
          );
        }));
  }

  _onSignUp(context) async {
    if (!this._isSigningUp) {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();

        setState(() {
          this._isSigningUp = true;
        });

        String response = await AppStateManager.of(context).signup(
          this._firstName,
          this._lastName,
          this._email,
          this._dob,
          this._gender,
          this._phoneNumber,
          this._password,
          this._confirmPassword,
        );

        setState(() {
          this._isSigningUp = false;
        });

        print("response $response");
        if (response == 'success') {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          showTextSnackBar(context, response.toString());
        }
      }
    }
  }
}
