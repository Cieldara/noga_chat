import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noga_chat/model/google_auth.dart';
import 'package:noga_chat/pages/conversation.dart';
import 'package:noga_chat/pages/login.dart';

class HomePage extends StatelessWidget {

  String _getConversationID(String otherPersonID) {
    return (loggedUser.uid.compareTo(otherPersonID) < 0)
        ? (loggedUser.uid + otherPersonID)
        : (otherPersonID + loggedUser.uid);
  }

  Widget _buildUserItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
              document.data['photoURL'],
            ),
            radius: 25,
            backgroundColor: Colors.transparent,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(document.data['displayName']),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationPage(
                    conversationID: _getConversationID(document.data['uid']),
                    otherPersonID: document.data['uid'],
                    otherPersonDocument: document)));
      },
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading data !');
          }
          return ListView.builder(
            itemExtent: 80,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildUserItem(context, snapshot.data.documents[index]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't show the leading button
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: EdgeInsets.only(right: 10),
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
              Text("Start chatting with : "),
              SizedBox(height: 20),
              Expanded(
                child: _buildUsersList(),
              ),
              RaisedButton(
                onPressed: () {
                  signOutGoogle();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }), ModalRoute.withName('/'));
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
    ));
  }
}
