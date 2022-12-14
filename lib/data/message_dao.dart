import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';
class MessageDao {

  //the collection name is 'messages'
  final CollectionReference collection = FirebaseFirestore.instance.collection('messages');

  void saveMessage(Message message) {
    collection.add(message.toJson());
  }

  Stream<QuerySnapshot> getMessageStream() {
    return collection.orderBy('date').snapshots();
  }

  void deleteMessage(Message message) async {
    await collection.doc(message.reference?.id).delete();
  }


}