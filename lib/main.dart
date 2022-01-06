import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
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

  Future<List<Widget>> getMessages() async {
    var httpResponse = await http
        .get(Uri.parse('https://mkul-chat-app.herokuapp.com/message'));
    String jsonResponse = utf8.decode(httpResponse.bodyBytes);

    if (httpResponse.statusCode == 200) {
      List<Widget> messages = [];
      List<dynamic> body = jsonDecode(jsonResponse);
      if (body.isEmpty) {
        return List.generate(
            1,
            (index) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Empty messages',
                      style:
                          TextStyle(fontSize: 50, color: Colors.grey.shade200),
                    )
                  ],
                ));
      }
      messages = List.generate(body.length, (i) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          getMessages().then((value) => {
                setState(() {
                  widgetsMessages = value;
                })
              });
        },
        child: const Icon(Icons.refresh),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.all(10.0),
                color: Colors.grey[700],
                height: 500.0,
                child: SingleChildScrollView(
                  child: Expanded(
                    child: Wrap(
                      children: widgetsMessages,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
