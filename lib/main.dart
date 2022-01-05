import 'dart:convert';

import 'package:app_chat/model/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_background_text/rounded_background_text.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Chat',
      theme: ThemeData(
        primaryColor: Colors.brown[700],
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: const TextStyle(fontFamily: 'NerkoOne'),
              bodyText1: const TextStyle(fontFamily: 'AmaticSC'),
              bodyText2: const TextStyle(fontFamily: 'AmaticSC'),
            ),
        appBarTheme: AppBarTheme(
          toolbarTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                headline6: const TextStyle(
                    fontFamily: 'NerkoOne', fontSize: 30, color: Colors.white),
              )
              .bodyText2,
          titleTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                headline6: const TextStyle(
                    fontFamily: 'NerkoOne', fontSize: 30, color: Colors.white),
              )
              .headline6,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> widgetsMessages = [];

  Future<List<Widget>> getMessages() async {
    var httpResponse = await http
        .get(Uri.parse('https://mkul-chat-app.herokuapp.com/message'));
    String jsonResponse = utf8.decode(httpResponse.bodyBytes);

    if (httpResponse.statusCode == 200) {
      List<Widget> messages = [];
      List<dynamic> body = jsonDecode(jsonResponse);
      messages = List.generate(body.length, (i) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                body[i]['nickName'],
              ),
              Text(
                body[i]['message'],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      });
      return messages;
    } else {
      throw Exception('Failed to load message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                getMessages().then((value) => {
                      setState(() {
                        widgetsMessages = value;
                      })
                    });
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widgetsMessages,
            )
          ],
        ),
      ),
    );
  }
}
