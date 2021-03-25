import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;

  Future<void> _submitAuthForm(
    String email,
    String password,
    String userName,
    String number,
    File image,
    bool isLogin,
  ) async {
    UserCredential authResult;
    //AuthResult authResult;
    try {
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final ref = FirebaseStorage.instance //uploding ımages 339
            .ref()
            .child('user_image')
            .child(authResult.user.uid + '.jpg');

        UploadTask uploadTask = ref.putFile(image);
        uploadTask.whenComplete(() async {
          final url = await ref.getDownloadURL();

          /* await Firestore
            .instance //singuptaki verileri database kaydetme 323 storing extra data
            .collection('users')
            .document(authResult.user.uid)
            .setData({
          'username': userName,
          'email': email,
          'number': number,
        }); */

          await FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.user.uid)
              .set(
            {
              'username': userName,
              'email': email,
              'number': number,
              'image_url': url,
            },
          );
        });
      }
    } //on PlatformException catch (error)
    on FirebaseAuthException catch (error) {
      var errorMessage = 'An error ocurred. Please check your credentials.';
      if (error.message != null) {
        errorMessage = error.message;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content:
              Text("Giriş yapılamadı.Lütfen bilgilerinizi kontrol ediniz."),
          // content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm),
    );
  }
}
