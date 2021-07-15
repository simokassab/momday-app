import 'package:flutter/material.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

enum _ProfileScreenMode { View, Edit }

class PorfileScreen extends StatefulWidget {
  @override
  _PorfileScreenState createState() => _PorfileScreenState();
}

class _PorfileScreenState extends State<PorfileScreen> {
  _ProfileScreenMode _mode;

  bool _showChangePassword;

  @override
  void initState() {
    super.initState();
    this._mode = _ProfileScreenMode.View;
    this._showChangePassword = false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (this._mode == _ProfileScreenMode.View) {
      children = [
        Text(
          AppStateManager.of(context).account.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: MomdayColors.MomdayGold,
              fontSize: 20.0,
              fontWeight: FontWeight.w300),
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          AppStateManager.of(context).account.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: MomdayColors.MomdayGold,
              fontSize: 20.0,
              fontWeight: FontWeight.w300),
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(tUpper(context, 'edit')),
              color: MomdayColors.MomdayGold,
              colorBrightness: Brightness.dark,
              onPressed: () {
                setState(() {
                  this._mode = _ProfileScreenMode.Edit;
                });
              },
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _ChangePassword(
              showChangePassword: this._showChangePassword,
              onTap: () {
                setState(() {
                  this._showChangePassword = !this._showChangePassword;
                });
              },
            )
          ],
        )
      ];
    } else if (this._mode == _ProfileScreenMode.Edit) {
      children = [
        _EditProfileForm(
          showChangePassword: this._showChangePassword,
          onSuccess: () {
            setState(() {
              this._mode = _ProfileScreenMode.View;
            });
          },
          onCancel: () {
            setState(() {
              this._mode = _ProfileScreenMode.View;
            });
          },
          onChangePasswordTap: () {
            setState(() {
              this._showChangePassword = !this._showChangePassword;
            });
          },
        )
      ];
    }

    if (this._showChangePassword) {
      children.add(_ChangePasswordForm(
        onSuccess: () {
          setState(() {
            this._showChangePassword = false;
          });
        },
      ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          PageHeader2(
            title: tTitle(context, 'my_profile'),
          ),
          SizedBox(
            height: 40.0,
          ),
        ]..addAll(children),
      ),
    );
  }
}

class _ChangePassword extends StatelessWidget {
  final bool showChangePassword;
  final GestureTapCallback onTap;

  _ChangePassword({this.showChangePassword, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(
        tLower(context, 'change_password'),
        style: TextStyle(
            color: !this.showChangePassword
                ? Colors.black.withOpacity(0.5)
                : MomdayColors.MomdayGold),
      ),
      onTap: this.onTap,
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;
  final GestureTapCallback onChangePasswordTap;
  final bool showChangePassword;

  _EditProfileForm(
      {this.onSuccess,
      this.onCancel,
      this.showChangePassword,
      this.onChangePasswordTap});

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  String _firstName;
  String _lastName;
  String _email;
  String _phoneNumber;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isChangingProfile;

  @override
  void initState() {
    super.initState();
    this._isChangingProfile = false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily:'VAG',primaryColor: MomdayColors.MomdayGold),
      child: Form(
        key: this._formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(-10.0, 0.0),
                    child: InkWell(
                      child: Icon(
                        Icons.close,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      onTap: widget.onCancel,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              TextFormField(
                initialValue: AppStateManager.of(context).account.firstName,
                decoration:
                    getMomdayInputDecoration(tTitle(context, 'first_name')),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }
                },
                onSaved: (value) => this._firstName = value,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                initialValue: AppStateManager.of(context).account.lastName,
                decoration:
                    getMomdayInputDecoration(tTitle(context, 'last_name')),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }
                },
                onSaved: (value) => this._lastName = value,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                initialValue: AppStateManager.of(context).account.email,
                decoration: getMomdayInputDecoration(tTitle(context, 'email')),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  } else if (!emailRegExp.hasMatch(value)) {
                    return tSentence(context, 'not_valid_email');
                  }
                },
                onSaved: (value) => this._email = value,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                initialValue: AppStateManager.of(context).account.phoneNumber,
                decoration: getMomdayInputDecoration(tTitle(context, 'phone')),
                validator: (value) {
                  if (value.isEmpty) {
                    return tSentence(context, 'field_required');
                  }
//                  else if (!emailRegExp.hasMatch(value)) {
//                    return tSentence(context, 'not_valid_email');
//                  }
                },
                onSaved: (value) => this._phoneNumber = value,
              ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _ChangePassword(
                    showChangePassword: widget.showChangePassword,
                    onTap: widget.onChangePasswordTap,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  RaisedButton(
                      color: MomdayColors.MomdayGold,
                      colorBrightness: Brightness.dark,
                      child: this._isChangingProfile
                          ? SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: Theme(
                                data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                ),
                              ),
                            )
                          : Text(tUpper(context, 'save_changes')),
                      onPressed: this._saveChanges),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _saveChanges() async {
    if (!this._isChangingProfile) {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();

        setState(() {
          this._isChangingProfile = true;
        });

        String response = await AppStateManager.of(context).editProfile(
            firstName: this._firstName,
            lastName: this._lastName,
            email: this._email,
            phoneNumber: this._phoneNumber);

        setState(() {
          this._isChangingProfile = false;
        });

        if (response == 'success') {
          widget.onSuccess();
        } else {
          showTextSnackBar(context, response);
        }
      }
    }
  }
}

class _ChangePasswordForm extends StatefulWidget {
  final VoidCallback onSuccess;

  _ChangePasswordForm({this.onSuccess});

  @override
  __ChangePasswordFormState createState() => __ChangePasswordFormState();
}

class __ChangePasswordFormState extends State<_ChangePasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  String _password;
  String _confirmPassword;

  bool _isChangingPassword;

  @override
  void initState() {
    super.initState();
    this._isChangingPassword = false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily:'VAG',primaryColor: MomdayColors.MomdayGold),
      child: Form(
        key: this._formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              TextFormField(
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
              ),
              SizedBox(height: 8.0),
              TextFormField(
                obscureText: true,
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
              SizedBox(
                height: 8.0,
              ),
              RaisedButton(
                color: MomdayColors.MomdayGold,
                colorBrightness: Brightness.dark,
                child: this._isChangingPassword
                    ? SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: Theme(
                          data: ThemeData(fontFamily:'VAG',accentColor: Colors.white),
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                          ),
                        ),
                      )
                    : Text(tUpper(context, 'save_changes')),
                onPressed: this._changePassword,
              )
            ],
          ),
        ),
      ),
    );
  }

  _changePassword() async {
    if (!this._isChangingPassword) {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();

        setState(() {
          this._isChangingPassword = true;
        });

        var response = await MomdayBackend().changePassword(
            newPassword: this._password,
            confirmPassword: this._confirmPassword);

        setState(() {
          this._isChangingPassword = false;
        });

        if (response['success'] == 1) {
          widget.onSuccess();
        } else {
          showTextSnackBar(context, response);
        }
      }
    }
  }
}
