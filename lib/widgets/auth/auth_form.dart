import 'dart:io';

import 'package:chatapp/widgets/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final Future<void> Function(
    String email,
    String password,
    String userName,
    String number,
    File image,
    bool isLogin,
  ) submitFunction;

  AuthForm(this.submitFunction);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _submitPressed = false;
  var _isLoginMode = true;
  String _userEmail = '';
  String _userName = '';
  String _userNumber = '';
  String _password = '';
  var _showSpinner = false;
  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    // Close the keyboard if open
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLoginMode) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('resim ekle.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      setState(() {
        _showSpinner = true;
      });
      await widget.submitFunction(
        _userEmail.trim(),
        _password.trim(),
        _userName.trim(),
        _userNumber.trim(),
        _userImageFile,
        _isLoginMode,
      );
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: 300,
        ),
        height: _isLoginMode ? 450 : 600,
        child: Card(
          margin: EdgeInsets.all(20),
          child: _showSpinner
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      autovalidate: _submitPressed,
                      child: Column(
                        // MainAxisSize.min keeps column length to minimum
                        // Otherwise, it defaults to infinite length
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          /* Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 30.0),
                                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                child: Image.asset(
                                  'images/logo.jpeg',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (!_isLoginMode)
                                UserImagePicker(_pickedImage), //_pickedImage
                            ],
                          ), */
                          if (!_isLoginMode)
                            UserImagePicker(_pickedImage), //_pickedImage
                          if (_isLoginMode)
                            Center(
                                child: Text(
                              'Giriş Yapınız',
                              style: TextStyle(fontSize: 25),
                            ))
                          else
                            Center(
                              child: Text(
                                'Kayıt Olunuz',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          // Email
                          TextFormField(
                            key: ValueKey('email'),
                            initialValue: _userEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email address',
                            ),
                            validator: (value) {
                              if (value.isEmpty || !value.contains('@')) {
                                return 'Lütfen düzgün email giriniz.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userEmail = value;
                            },
                          ),

                          // User name
                          if (!_isLoginMode)
                            TextFormField(
                              key: ValueKey('userName'),
                              initialValue: _userName,
                              decoration: InputDecoration(
                                labelText: 'User Name',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a user name.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                _userName = value;
                              },
                              onSaved: (value) {
                                _userName = value;
                              },
                            ),
                          if (!_isLoginMode)
                            TextFormField(
                              key: ValueKey(
                                  'number'), //textform key birbirinden ayırt edilmesini sağlıyor.
                              initialValue: _userNumber,
                              autocorrect: true,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.number,
                              enableSuggestions: false,
                              validator: (value) {
                                if (value.isEmpty || value.length != 11) {
                                  return 'Telefon numarasını düzgün girin';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: 'Telefon numarasi:(0XXXXXXXXXX)'),
                              onSaved: (value) {
                                _userNumber = value;
                              },
                            ),
                          // Password
                          TextFormField(
                            key: ValueKey('password'),
                            initialValue: _password,
                            decoration: InputDecoration(labelText: 'Şifre'),
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty || value.length < 7) {
                                return 'En az sekiz haneli şifre giriniz.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value;
                            },
                          ),
                          /* if (!_isLoginMode)
                              TextFormField(
                                key: ValueKey('confrimPassword'),
                                validator: (value) {
                                  if (value == _password) {
                                    return null;
                                  }
                                  return 'Passwords do not match!';
                                },
                                decoration:
                                    InputDecoration(labelText: 'Sifre Tekrar:'),
                                obscureText: true,
                              ),
 */
                          // Empty space
                          SizedBox(
                            height: 30,
                          ),

                          // Login button
                          RaisedButton(
                            child: Text(_isLoginMode ? 'Giriş' : 'Yeni Kayıt',
                                style: TextStyle(color: Colors.white)),
                            onPressed: _trySubmit,
                          ),

                          // Create New Account button
                          FlatButton(
                            child: Text(_isLoginMode
                                ? 'Yeni kayıt oluştur'
                                : 'Zaten hesabım var'),
                            textColor: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
