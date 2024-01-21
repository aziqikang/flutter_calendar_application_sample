// CHAT-GPT KEY:
// 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

import 'dart:async';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_application_sample/chat_message.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;

  StreamSubscription? _subscription;

  void initState() {
    super.initState();
    chatGPT = OpenAI.instance.build(
      token: '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',
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 5)),
      enableLog: true
    );
  }

  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    ChatMessage _message = ChatMessage(text: _controller.text, sender: "user");

    setState(() {
      _messages.insert(0, _message);
    });

    _controller.clear();

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(), 
      messages: [
        Messages(
          role: Role.user,
          content: _message.text,
        )
      ]
    );

    final response = await chatGPT!.onChatCompletion(request: request);
      
    insertNewData(response?.choices[0].toString());
  }

  void insertNewData(String? response) {
    ChatMessage botMessage = ChatMessage(
      text: "",
      sender: "bot",
    );

    setState(() {
      _messages.insert(0, botMessage);
    });
  }


  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: InputDecoration.collapsed(hintText: "Send a message..."),
          )),
        IconButton(
          onPressed: () => {_sendMessage()}, 
          icon: const Icon(Icons.send_outlined, color: Colors.deepPurple),)    
    ],);
  }

  @override
  Widget build(BuildContext context) {

    // require google authentication

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: '114534697707-rl6m8gao2qd862bjra7n378cf2rpt82p.apps.googleusercontent.com',
      scopes: [
        'https://www.googleapis.com/auth/calendar.events'
      ],
    );

    // display home page

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 400,
              height: 700,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: SfCalendar(
                view: CalendarView.month,
                monthViewSettings: MonthViewSettings(
                  showAgenda: true, 
                  agendaViewHeight: 300,
                ),
              ),
            ),
            Container(           
              width: 600,
              height: 700,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      reverse: true,

                      itemBuilder: (content, index) {
                        return Container(
                          margin: EdgeInsets.all(20),
                          child: _messages[index]
                        );
                    })),
                  Container(
                    padding: EdgeInsets.only(top: 50),
                    child: _buildTextComposer()
                  ),
                ],)
            )
          ],
        )),
    );
      
  }

}