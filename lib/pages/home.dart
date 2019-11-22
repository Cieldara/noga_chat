import 'package:flutter/material.dart';

import 'package:noga_chat/model/google_auth.dart';
import 'package:noga_chat/pages/login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't show the leading button
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin:EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
                radius: 25,
                backgroundColor: Colors.transparent,
              ),
            ),
            Text(loggedUser.displayName),
          ],
        ),


      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.only(top: 20.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("Other users : "),
                SizedBox(height: 20),
                SizedBox(height: 20),
                RaisedButton(
                  onPressed: () {
                    signOutGoogle();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
                  },
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                )
              ],
            ),
          ),
        ),
    );
  }
}