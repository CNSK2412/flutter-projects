import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
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
            onPressed: () async {
              await _googleSignIn.signOut();
            },
            color: Colors.lightBlueAccent,
            child: Text('Sign Out'),
          ),
        ],
      )),
    );
  }
}
