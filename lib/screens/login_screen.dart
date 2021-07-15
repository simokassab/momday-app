import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/styles/momday_colors.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
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
        //FDC334
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          children: <Widget>[
            // SizedBox(
            //   height: 100,
            // ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/images/xbackground.png',height: 150,),
            ),

            Text(tTitle(context, 'welcome'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'VAG',
                )),
            SizedBox(height: 10.0),
            InkWell(
              child: RichText(
                textAlign: TextAlign.center,
                text: new TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: tSentence(context, 'dont_have_an_account') + " ",
                        style: new TextStyle(
                          fontFamily: 'VAG',
                        )),
                    new TextSpan(
                        text: tSentence(context, 'sign_up'),
                        style: new TextStyle(
                          color: Colors.white,
                          fontFamily: 'VAG',
                        )),
                  ],
                ),
              ),
              onTap: () async {
                Navigator.of(context).pushNamed('/signup');
              },
            ),
            SizedBox(height: 20),
            _LoginForm(),
            SizedBox(height: 30),
            _ForgotPasswordLink(),
//          SizedBox(height: 10.0),
//          Stack(
//            alignment: Alignment.center,
//            children: <Widget>[
//              Container(
//                height: 1.0,
//                color: MomdayColors.MomdayGold ,
//              ),
//              Positioned(
//                child: Container(
//                  color: Colors.white,
//                  width: 30.0,
//                  child: Text(
//                    tUpper(context, 'or'),
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      color: MomdayColors.MomdayGold
//                    ),
//                  ),
//                ),
//              ),
//            ],
//          ),
//          SizedBox(height: 20.0),
//          _FacebookLoginButton(),
//          SizedBox(height: 10.0),
//          _GoogleLoginButton(),
//          SizedBox(height: 10.0),
//          InkWell(
//            child: Text(
//              tSentence(context, 'dont_have_an_account') +
//                  ' ' + tSentence(context, 'sign_up'),
//              textAlign: TextAlign.end,
//              style: TextStyle(
//                  color: Colors.black.withOpacity(0.44)
//              )
//            ),
//            onTap: () async {
//              Navigator.of(context).pushNamed('/signup');
//            },
//          )
          ],
        ));
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  void _handleLogin(BuildContext context) async {
    if (!this._isLoggingIn) {
      if (this._formKey.currentState.validate()) {
        setState(() {
          this._isLoggingIn = true;
        });

        this._formKey.currentState.save();

        dynamic response = await AppStateManager.of(context)
            .login(this._email, password: this._password);

        setState(() {
          this._isLoggingIn = false;
        });

        if (response == 'success') {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          showTextSnackBar(context, response);
        }
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  bool _isLoggingIn;

  @override
  void initState() {
    super.initState();
    this._isLoggingIn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: this._formKey,
        child: Theme(
          data: ThemeData(fontFamily:'VAG',
            primaryColor: MomdayColors.MomdayGold,
          ),
          child: ListView(
            primary: false,
            shrinkWrap: true,
            children: <Widget>[
              TextFormField(
                style: TextStyle(fontFamily: "VAG"),
                keyboardType: TextInputType.emailAddress,
                decoration: getMomdayInputDecoration(tTitle(context, 'email')),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }
                },
                onSaved: (value) => this._email = value,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                style: TextStyle(fontFamily: "VAG"),

                autofocus: false,
                obscureText: true,
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
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                  color: Colors.white,
                  child: this._isLoggingIn
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                          title: Text(tSentence(context, 'log_in'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                        ),
                  onPressed: () {
                    this._handleLogin(context);
                  }),
            ],
          ),
        ));
  }
}
//
//class _FacebookLoginButton extends StatelessWidget {
//
//  void _handleLogin(BuildContext context) async {
//    FacebookLogin facebookLogin = FacebookLogin();
//    FacebookLoginResult result = await facebookLogin.logInWithReadPermissions(['email']);
//
//    if (result.status == FacebookLoginStatus.loggedIn) {
//
//      FacebookAccessToken accessToken = result.accessToken;
//      // Facebook plugin does not fetch the email by default
//      // but the backend "for some reason" requires the email to be provided
//      // so we fetch the email and send it to the backend
//      http.Response graphResponse = await http.get(
//          'https://graph.facebook.com/v2.12/me?fields=email&access_token=${accessToken.token}');
//      String email = json.decode(graphResponse.body)['email'];
//
//      dynamic response = await AppStateManager.of(context).login(
//          email,
//          accessToken: accessToken.token,
//          provider: 'facebook'
//      );
//
//      if (response == 'success') {
//        Navigator.pushReplacementNamed(context, '/');
//      } else {
//        showTextSnackBar(context, response);
//      }
//    } else if (result.status == FacebookLoginStatus.error) {
//      showTextSnackBar(context, result.errorMessage);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      foregroundDecoration: BoxDecoration(
//        border: Border.all(color: MomdayColors.FacebookBlue)
//      ),
//      child: FlatButton(
//        color: Colors.white,
//        onPressed: () {
//          this._handleLogin(context);
//        },
//        child: ListTile(
//          leading: ImageIcon(
//            AssetImage('assets/icons/facebook2.png'),
//            color: MomdayColors.FacebookBlue,
//            size: 30.0,
//          ),
//          title: Text(
//              tLower(context, 'log_in_with_facebook'),
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                color: MomdayColors.FacebookBlue,
//                fontSize: 18.0
//              )
//          ),
//        ),
//      ),
//    );
//  }
//}
//
//
//class _GoogleLoginButton extends StatelessWidget {
//
//  void _handleLogin(BuildContext context) async {
//    GoogleSignIn googleSignIn = GoogleSignIn(
//        scopes: ['email']
//    );
//
//    try {
//      GoogleSignInAccount account = await googleSignIn.signIn();
//      String accessToken = (await account.authentication).accessToken;
//      String email = account.email;
//
//      dynamic response = await AppStateManager.of(context).login(
//          email,
//          accessToken: accessToken,
//          provider: 'google'
//      );
//
//      if (response == 'success') {
//        Navigator.pushReplacementNamed(context, '/');
//      } else {
//        showTextSnackBar(context, response);
//      }
//    } catch(error) {
//      showTextSnackBar(context, error.toString());
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      foregroundDecoration: BoxDecoration(
//        border: Border.all(color: MomdayColors.GoogleRed)
//      ),
//      child: FlatButton(
//        color: Colors.white,
//        onPressed: () {
//          this._handleLogin(context);
//        },
//        child: ListTile(
//          leading: ImageIcon(
//            AssetImage('assets/icons/google2.png'),
//            color: MomdayColors.GoogleRed,
//            size: 30.0,
//          ),
//          title: Text(
//              tLower(context, 'log_in_with_google'),
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                color: MomdayColors.GoogleRed,
//                fontSize: 18.0
//              )
//          ),
//        ),
//      ),
//    );
//  }
//}

class _ForgotPasswordLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(tLower(context, 'forgot_password'),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'VAG',
          )),
      onTap: () async {
        var result = await Navigator.of(context).pushNamed('/forgot-password');

        if (result == true) {
          Timer(Duration(milliseconds: 500), () {
            showTextSnackBar(context, tSentence(context, 'check_email_forgot'));
          });
        }
      },
    );
  }
}
