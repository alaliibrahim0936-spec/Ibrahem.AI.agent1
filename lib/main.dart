import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const IbrahimAI());

class IbrahimAI extends StatelessWidget {
  const IbrahimAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ChatPage());
  }
}

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text.trim();
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _loading = true;
      _controller.clear();
    });
    try {
      final url = Uri.parse('https://text.pollinations.ai/${Uri.encodeComponent(userText)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _messages.add({"role": "ai", "text": response.body}));
      } else {
        setState(() => _messages.add({"role": "ai", "text": "خطأ: ${response.statusCode}"}));
      }
    } catch (e) {
      setState(() => _messages.add({"role": "ai", "text": "خطأ: $e"}));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ibrahim AI - يعمل للأبد"), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemCount: _messages.length, itemBuilder: (c, i) {
            final m = _messages[i];
            final isUser = m["role"] == "user";
            return Align(alignment: isUser? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: EdgeInsets.all(8), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: isUser? Colors.deepPurple : Colors.grey[300], borderRadius: BorderRadius.circular(12)), child: Text(m["text"]!, style: TextStyle(color: isUser? Colors.white : Colors.black))));
          })),
          if (_loading) CircularProgressIndicator(),
          Padding(padding: EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "اكتب سؤالك...", border: OutlineInputBorder()))), IconButton(icon: Icon(Icons.send), onPressed: sendMessage)])),
        ],
      ),
    );
  }
}
