import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MaterialApp(home: IbrahimAgent(), debugShowCheckedModeBanner: false));

class IbrahimAgent extends StatefulWidget {
  @override
  State<IbrahimAgent> createState() => _IbrahimAgentState();
}

class _IbrahimAgentState extends State<IbrahimAgent> {
  final String apiKey = "ضع_مفتاحك_هنا";
  final TextEditingController _controller = TextEditingController();
  List<Map<String,String>> messages = [];
  bool loading = false;

  Future<void> askAI(String text, {File? image}) async {
    setState(() {
      loading = true;
      messages.add({"role":"user","text":text});
    });

    try {
      if(text.contains("اتصل") || text.contains("اتصال")){
        await handleCall(text);
        setState(() => loading = false);
        return;
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      Content content;
      if(image!= null){
        final bytes = await image.readAsBytes();
        content = Content.multi([TextPart(text), DataPart('image/jpeg', bytes)]);
      } else {
        content = Content.text(text);
      }

      final response = await model.generateContent([content]);
      setState(() {
        messages.add({"role":"ai","text": response.text?? "لم افهم"});
      });
    } catch(e){
      setState(() { messages.add({"role":"ai","text": "خطأ: $e"}); });
    }
    setState(() => loading = false);
  }

  Future<void> handleCall(String text) async {
    await Permission.contacts.request();
    await Permission.phone.request();
    String name = text.replaceAll("اتصل", "").replaceAll("ب", "").replaceAll("على", "").trim();

    if(await FlutterContacts.requestPermission()){
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final found = contacts.where((c) => c.displayName.contains(name)).toList();
      if(found.isNotEmpty && found.first.phones.isNotEmpty){
        String phone = found.first.phones.first.number;
        messages.add({"role":"ai","text":"جاري الاتصال بـ $name : $phone"});
        launchUrl(Uri.parse("tel:$phone"));
      } else {
        messages.add({"role":"ai","text":"لم أجد جهة اتصال باسم $name"});
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ibrahim AI"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(children: [
        Expanded(child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (c,i){
            final m = messages[i];
            bool isUser = m["role"]=="user";
            return Align(
              alignment: isUser? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(m["text"]!),
              ),
            );
          }
        )),
        if(loading) Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
        Row(children: [
          IconButton(icon: Icon(Icons.camera_alt), onPressed: () async {
            final img = await ImagePicker().pickImage(source: ImageSource.camera);
            if(img!=null) askAI("ما هذا في الصورة؟ حللها", image: File(img.path));
          }),
          Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "اسألني او قل اتصل بفلان"))),
          IconButton(icon: Icon(Icons.send), onPressed: (){
            if(_controller.text.isNotEmpty){ askAI(_controller.text); _controller.clear(); }
          })
        ])
      ]),
    );
  }
}
