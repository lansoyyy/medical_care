import 'package:medical_care/services/chat_data.dart';
import 'package:medical_care/widgets/drawer_widget.dart';
import 'package:medical_care/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msg = TextEditingController();

  List<Map<String, String>> chatMessages = [];

  void _sendMessage() {
    final message = msg.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        chatMessages.add({'sender': 'user', 'message': message});
      });

      _getResponse(message);

      msg.clear();
    }
  }

  void _getResponse(String question) {
    String response =
        'Sorry, I didn\'t understand the question. Please ask something else.';

    for (var faq in faqData) {
      if (faq['question']!.toLowerCase() == question.toLowerCase()) {
        response = faq['answer']!;
        break;
      }
    }

    setState(() {
      chatMessages.add({'sender': 'bot', 'message': response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.arrow_back,
              ),
              const SizedBox(
                width: 10,
              ),
              TextWidget(
                text: 'Back',
                fontSize: 14,
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
        actions: [
          Image.asset(
            'assets/images/logo.png',
            height: 100,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                final isUserMessage = message['sender'] == 'user';

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          isUserMessage ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUserMessage ? Colors.black : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msg,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
