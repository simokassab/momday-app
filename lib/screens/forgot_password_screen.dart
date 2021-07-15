import 'package:flutter/material.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/momday_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email;

  bool _isSendingPassword;

  @override
  void initState() {
    super.initState();
    this._isSendingPassword = false;
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
          return Center(
            child: Form(
              key: this._formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/images/xbackground.png',height: 150,),
                  ),
                  SizedBox(height: 10.0),
                  Text(tTitle(context, 'no_worries'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(tSentence(context, 'forgot_password_instructions')),
                  SizedBox(height: 10.0),
                  Theme(
                    data: ThemeData(
                        fontFamily: 'VAG',
                        primaryColor: MomdayColors.MomdayGold),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      decoration:
                          getMomdayInputDecoration(tTitle(context, 'email')),
                      validator: (value) {
                        if (value.isEmpty) {
                          return tSentence(context, 'field_required');
                        }
                      },
                      onSaved: (value) => this._email = value,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton(
                    color: Colors.white,
                    child: this._isSendingPassword
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: Theme(
                                data: ThemeData(
                                    fontFamily: 'VAG',
                                    accentColor: Colors.black),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                ),
                              ),
                            ))
                        : ListTile(
                            title: Text(tSentence(context, 'send'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                          ),
                    onPressed: () => this._onSendPassword(context),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  _onSendPassword(BuildContext context) async {
    if (!this._isSendingPassword) {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();

        setState(() {
          this._isSendingPassword = true;
        });

        final response = await MomdayBackend().forgotPassword(this._email);

        setState(() {
          this._isSendingPassword = false;
        });

        if (response['success'] == 1) {
          Navigator.of(context).pop(true);
        } else {
          showTextSnackBar(context, response['error'][0]);
        }
      }
    }
  }
}
