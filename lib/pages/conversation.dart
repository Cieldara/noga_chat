import 'package:flutter/material.dart';
import 'package:noga_chat/pages/home.dart';
import 'package:noga_chat/model/google_auth.dart';

class ConversationPage extends StatefulWidget {

  ConversationPage({Key key, this.conversationID}) : super(key: key);

  final String conversationID;
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 150),
              SizedBox(height: 50),

            ],
          ),
        ),
      ),
    );
  }

}