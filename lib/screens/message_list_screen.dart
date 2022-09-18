import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/message.dart';
import '../data/message_dao.dart';
import '../data/user_dao.dart';
import '../widgets/message_widget.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  MessageListScreenState createState() => MessageListScreenState();
}

class MessageListScreenState extends State<MessageListScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? email;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    final messageDao = Provider.of<MessageDao>(context, listen: false);
    final userDao = Provider.of<UserDao>(context, listen: false);
    email = userDao.email();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              userDao.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text('Red Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messageDao.getMessageStream(),
                builder: (context, snapshot) {
                  final messages = snapshot.data?.docs ?? [] ;
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  } else {
                      return ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data?.size,
                        itemBuilder: (context, index) {
                          final message = Message.fromSnapshot(messages[index]);
                          return MessageWidget(
                            message.text,
                            message.date,
                            message.email,
                          );
                        },
                      );
                    }
                  },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _messageController,
                      onSubmitted: (input) {
                        _sendMessage(messageDao);
                      },
                      decoration:
                          const InputDecoration(hintText: 'Enter new message'),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_canSendMessage()
                      ? CupertinoIcons.arrow_right_circle_fill
                      : CupertinoIcons.arrow_right_circle),
                  onPressed: () {
                    _sendMessage(messageDao);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(MessageDao messageDao) {
    if (_canSendMessage()) {
      final message = Message(
        text: _messageController.text,
        date: DateTime.now(),
        email: email,
      );
      messageDao.saveMessage(message);
      _messageController.clear();
      setState(() {});
    }
  }



  bool _canSendMessage() => _messageController.text.isNotEmpty;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

}
