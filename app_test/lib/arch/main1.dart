import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/////////////// 테스트용 코드 시작 ///////////////
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessibility App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SelectionPage(),
    );
  }
}

class SelectionPage extends StatelessWidget {
  void sendSelectionToBackend(String option) async {
    final url = Uri.parse('https://your-backend-url.com/selection');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'selection': option}),
      );
    } catch (e) {
      print('Error sending selection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose an Option')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                sendSelectionToBackend('전맹');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotPage()),
                );
              },
              child: Text('전맹'),
            ),
            ElevatedButton(
              onPressed: () {
                sendSelectionToBackend('약시');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotPage()),
                );
              },
              child: Text('약시'),
            ),
            ElevatedButton(
              onPressed: () {
                sendSelectionToBackend('일반인');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotPage()),
                );
              },
              child: Text('일반인'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  void sendMessage(String message) async {
    setState(() {
      _messages.add('You: $message');
    });

    final url = Uri.parse('https://your-backend-url.com/chatbot');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final botReply = responseData['reply'];

        if (botReply.contains('결제')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentPage()),
          );
        } else {
          setState(() {
            _messages.add('Bot: $botReply');
          });
        }
      }
    } catch (e) {
      print('Error communicating with chatbot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    _controller.clear();
                    sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: Text('Payment Page - Implement your payment logic here'),
      ),
    );
  }
}
