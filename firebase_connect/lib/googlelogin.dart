import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_connect/homepage.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';


class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          "641705878587-b95h5sbcpu2sj4kfl839t2f01s9kc5oo.apps.googleusercontent.com");
  bool _isLoading = false;
  final FirebaseInAppMessaging _fiam = FirebaseInAppMessaging.instance;

  Future<UserCredential?> _signInWithGoogleLogic(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in was canceled.')),
        );
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      _fiam.triggerEvent("successful_signin");


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              LoadingAnimationWidget.dotsTriangle(
                color: const Color.fromARGB(255, 146, 248, 255),
                size: 50,
              )
            else
              SignInButton(
                Buttons.google,
                onPressed: () => _signInWithGoogleLogic(context),
                text: 'Sign in with Google',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  
                ),
              ),
          ],
        ),
      ),
    );
  }
}
