import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noga_chat/model/google_auth.dart';
import 'package:noga_chat/services/conversations_service.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage(
      {Key key,
      @required this.conversationID,
      @required this.otherPersonID,
      @required this.otherPersonDocument})
      : super(key: key);

  final String conversationID;
  final String otherPersonID;
  final DocumentSnapshot otherPersonDocument;

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _messageEditingController = TextEditingController();
  final _messageListScrollController = ScrollController();

  _isMessageSenderTheLoggedUser(DocumentSnapshot document) {
    return document.data['sender'] == loggedUser.uid;
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    return ListTile(
        title: Row(
      mainAxisAlignment: _isMessageSenderTheLoggedUser(document)
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: _isMessageSenderTheLoggedUser(document)
                  ? Colors.blue
                  : Colors.black12,
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(document.data['content']),
          ),
        )
      ],
    ));
  }

  Widget _buildMessagesList() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('conversations')
            .document(widget.conversationID)
            .collection('messages')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading data !');
          }
          return ListView.builder(
            controller: this._messageListScrollController,
            reverse: true,
            itemExtent: 80,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildMessageItem(snapshot.data.documents[index]),
          );
        });
  }

  Widget _buildSpeechRecognitionButton() {
    return Container(
      margin: new EdgeInsets.only(left: 10),
      child: SizedBox(
        width: 50,
        child: new RaisedButton(
          color: Colors.blueAccent,
          onPressed: () {},
          child: Icon(
            Icons.textsms,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't show the leading button
        title: new Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new Container(
              margin: EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.otherPersonDocument.data['photoURL'],
                ),
                radius: 25,
                backgroundColor: Colors.transparent,
              ),
            ),
            Text(widget.otherPersonDocument.data['displayName']),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: _buildMessagesList()),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: 'Write your message',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                            controller: this._messageEditingController,
                          )),
                    ),
                  ),
                  Material(
                    child: new Container(
                      margin: new EdgeInsets.only(left: 10),
                      child: SizedBox(
                        width: 50,
                        child: new RaisedButton(
                          color: Colors.blueAccent,
                          onPressed: () {
                            ConversationService.sendMessageToPerson(
                                loggedUser.uid,
                                widget.otherPersonID,
                                this._messageEditingController.value.text);
                            this._messageEditingController.clear();
                            this._messageListScrollController.jumpTo(0);
                          },
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildSpeechRecognitionButton(),
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}
