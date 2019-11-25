import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noga_chat/model/google_auth.dart';

class ConversationService {
  static sendMessageToPerson(
      String loggedUserID, String otherPersonID, String content) {
    if (content.length > 0) {
      String conversationID = (loggedUserID.compareTo(otherPersonID) < 0)
          ? (loggedUserID + otherPersonID)
          : (otherPersonID + loggedUserID);

      final messageData = {
        'sender': loggedUserID,
        'receivers': [otherPersonID],
        'content': content,
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      Firestore.instance
          .collection('conversations')
          .document(conversationID)
          .collection('messages')
          .add(messageData);

    }
  }

  String getConversationID(String otherPersonID) {
    return (loggedUser.uid.compareTo(otherPersonID) < 0)
        ? (loggedUser.uid + otherPersonID)
        : (otherPersonID + loggedUser.uid);
  }
}
