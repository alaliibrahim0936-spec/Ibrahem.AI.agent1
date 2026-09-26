import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
void main() => runApp(const IbrahimAI());
class IbrahimAI extends StatelessWidget {
  const IbrahimAI({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ChatPage());
  }
}
class ChatPage extends StatefulWidget {
  @override State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final _c = TextEditingController();
  final List<Map<String,String>> _m = [];
  bool _l = false;
  Future<void> send() async {
    if(_c.text.isEmpty) return;
    final t = _c.text; setState((){_m.add({"r":"u","t":t}); _l=true; _c.clear();});
    try{
      final r = await http.get(Uri.parse('https://text.pollinations.ai/${Uri.encodeComponent(t)}'));
      setState((){_m.add({"r":"a","t":r.body});});
    }catch(e){setState((){_m.add({"r":"a","t":"خطأ: $e"});});}
    setState((){_l=false;});
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("Ibrahim AI"), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
    body: Column(children:[
      Expanded(child: ListView.builder(itemCount: _m.length, itemBuilder: (c,i){
        final isU = _m[i]["r"]=="u";
        return Align(alignment: isU?Alignment.centerRight:Alignment.centerLeft, child: Container(margin: EdgeInsets.all(8), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: isU?Colors.deepPurple:Colors.grey[300], borderRadius: BorderRadius.circular(12)), child: Text(_m[i]["t"]!, style: TextStyle(color: isU?Colors.white:Colors.black))));
      })),
      if(_l) CircularProgressIndicator(),
      Padding(padding: EdgeInsets.all(8), child: Row(children:[Expanded(child: TextField(controller: _c, decoration: InputDecoration(hintText:"اكتب...", border: OutlineInputBorder()))), IconButton(icon: Icon(Icons.send), onPressed: send)]))
    ]));
  }
}
