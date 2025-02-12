import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_connect/homepage.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Step 1: Trigger Google Sign-In
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      // Handle case where user cancels the sign-in process
      if (googleSignInAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in was canceled.')),
        );
        return null;
      }

      // Step 2: Get authentication details from the Google account
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // Step 3: Create OAuth credentials for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Step 4: Sign in with Firebase using the credentials
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Optionally, log the user's display name (for debugging purposes)
      debugPrint('Signed in as: ${userCredential.user?.displayName}');

      // Step 5: Navigate to the HomePage after successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      return userCredential;
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
      return null;
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
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
              LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 200,
              ) // Show loading indicator
            else
              SignInButton(
                Buttons.google,
                onPressed: () async {
                  await signInWithGoogle(context);
                },
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
