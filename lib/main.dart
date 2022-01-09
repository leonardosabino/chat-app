import 'dart:convert';

import 'package:app_chat/model/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Chat',
      theme: ThemeData(
        primaryColor: Colors.grey[700],
        backgroundColor: Colors.grey[700],
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: const TextStyle(fontFamily: 'decterm'),
              bodyText1: const TextStyle(fontFamily: 'decterm'),
              bodyText2: const TextStyle(fontFamily: 'decterm'),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[700],
          toolbarTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                headline6: const TextStyle(
                    fontFamily: 'decterm', fontSize: 30, color: Colors.white),
              )
              .bodyText2,
          titleTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                headline6: const TextStyle(
                    fontFamily: 'decterm', fontSize: 30, color: Colors.white),
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
  final nickNameController = TextEditingController();
  var _validateNickName = true;

  getMessages() async {
    var httpResponse = await http
        .get(Uri.parse('https://mkul-chat-app.herokuapp.com/message'));
    String jsonResponse = utf8.decode(httpResponse.bodyBytes);

    if (httpResponse.statusCode == 200) {
      List<Widget> messages = [];
      List<dynamic> body = jsonDecode(jsonResponse);
      if (body.isEmpty) {
        setState(() {
          widgetsMessages = List.generate(
              1,
              (index) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Empty messages',
                        style: TextStyle(
                            fontSize: 50, color: Colors.grey.shade200),
                      )
                    ],
                  ));
        });
        return;
      }
      messages = List.generate(body.length, (i) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  children: <Widget>[
                    Text(body[i]['nickName'] + ': ',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey.shade200,
                            fontWeight: FontWeight.w200)),
                    Text(body[i]['message'],
                        style: TextStyle(
                            fontSize: 25, color: Colors.grey.shade200)),
                  ],
                ),
              ),
            ],
          ),
        );
      });
      setState(() {
        widgetsMessages = messages;
      });
    } else {
      throw Exception('Failed to load message');
    }
  }

  sendMessage(String? message) async {
    if (message == null) {
      setState(() {
        nickNameController.text.isEmpty
            ? _validateNickName = false
            : _validateNickName = true;
      });
      return;
    }

    var data = jsonEncode(<String, String>{
      'nickName': nickNameController.text,
      'message': message
    });

    var httpResponse = await http.post(
      Uri.parse('https://mkul-chat-app.herokuapp.com/message'),
      body: data,
      headers: {"Content-Type": "application/json"},
    );

    if (httpResponse.statusCode != 200) {
      debugPrint('Error response: $httpResponse');
      return;
    }

    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Chat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          getMessages();
        },
        child: const Icon(Icons.refresh),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: nickNameController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Enter your nickname',
                  errorText:
                      !_validateNickName ? 'Value can\'t be empty' : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.all(10.0),
                color: Colors.grey[700],
                height: 400.0,
                child: SingleChildScrollView(
                  child: Expanded(
                    child: Wrap(
                      children: widgetsMessages,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onSubmitted: (value) => sendMessage(value),
                  textInputAction: TextInputAction.go,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter your message',
                  )),
            )
          ],
        ),
      ),
    );
  }
}
