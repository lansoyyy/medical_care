import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_care/utils/const.dart';

import 'package:medical_care/widgets/text_widget.dart';

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

  Future<void> _getResponse(String question) async {
    setState(() {
      chatMessages.add({'sender': 'bot', 'message': 'Thinking...'});
    });

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer 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',
      };
      final body = jsonEncode({
        'model': 'gpt-3.5-turbo', // Replace with your preferred model
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': question},
        ],
        'max_tokens': 256,
      });

      final response = await http.post(url, headers: headers, body: body);

      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatResponse = data['choices'][0]['message']['content'];

        setState(() {
          chatMessages.removeLast(); // Remove "Thinking..." message
          chatMessages.add({'sender': 'bot', 'message': chatResponse.trim()});
        });
      } else {
        setState(() {
          chatMessages.removeLast(); // Remove "Thinking..." message
          chatMessages.add(
              {'sender': 'bot', 'message': 'Error: Unable to get a response.'});
        });
      }
    } catch (e) {
      setState(() {
        chatMessages.removeLast(); // Remove "Thinking..." message
        chatMessages
            .add({'sender': 'bot', 'message': 'Error: ${e.toString()}'});
      });
    }
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
