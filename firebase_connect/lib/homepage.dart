import 'package:firebase_connect/googlelogin.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    // Ask the user for confirmation before signing out
    final bool? confirmSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to cancel
              },
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to proceed
              },
            ),
          ],
        );
      },
    );

    // If user confirms sign-out
    if (confirmSignOut == true) {
      await _googleSignIn.signOut();

      // Show a snackbar or message to inform the user they signed out
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have signed out successfully.')),
      );

      // Optionally, navigate back to the login page or clear the session
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GoogleLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: const Color.fromARGB(255, 136, 202, 255),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            MaterialButton(
              onPressed: () =>
                  _signOut(context), // Call the new sign-out function
              color: Colors.lightBlueAccent,
              child: Text('Sign Out'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}
