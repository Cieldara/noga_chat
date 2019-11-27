import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noga_chat/model/google_auth.dart';
import 'package:noga_chat/pages/conversation.dart';
import 'package:noga_chat/pages/login.dart';
import 'package:noga_chat/pages/random_color.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildSideMenu(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image(
                image: AssetImage('assets/image/side_back.png'),
              ),
              Positioned.fill(
                top: 10,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      loggedUser.photoUrl,
                    ),
                    radius: 50,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              Positioned.fill(
                  bottom: 20,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        loggedUser.displayName,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ))),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: GestureDetector(
              child: Text('Color guesser'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RandomColorPage()));
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RaisedButton(
                onPressed: () {
                  signOutGoogle();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }), ModalRoute.withName('/'));
                },
                color: Colors.blue,
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
          )
        ],
      ),
    );
  }

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
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't show the leading button
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new SizedBox(
              width: 30,
              child: new FlatButton(
                  padding: EdgeInsets.only(left: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  }),
            ),
            new Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
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
      drawer: _buildSideMenu(context),
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
            ],
          ),
        ),
      ),
    ));
  }
}
