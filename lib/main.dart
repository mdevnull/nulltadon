import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nulltadon/hashtag_search.dart';
import 'package:nulltadon/login.dart';
import 'package:nulltadon/status.dart';
import 'package:nulltadon/theme.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nulltadon',
      theme: buildMyTheme(),
      home: const Login(),
      routes: {
        UserTimelinePage.routeName: (context) => const UserTimelinePage(title: 'Home'),
        GodotEngineToots.routeName: (context) => const GodotEngineToots(),
      },
    );
  }
}

class UserTimelinePage extends StatefulWidget {
  const UserTimelinePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  static const routeName = '/user_timeline';

  @override
  State<UserTimelinePage> createState() => _UserTimelinePageState();
}

class _UserTimelinePageState extends State<UserTimelinePage> {
  String hashtag = '';
  String accessToken = '';
  Iterable<Status> timelineStatus = List<Status>.empty();

  final _formKey = GlobalKey<FormState>();

  final dateFormat = DateFormat.yMd();
  final timeFormat = DateFormat.Hms();

  void fetchUserTimeline(String token) async {
    final response = await http
        .get(Uri.parse('https://mastodon.social/api/v1/timelines/home'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to load user timeline');
    }

    final List dataList = jsonDecode(response.body);
    final loadedTimeline = dataList.map((jsonEntry) => Status.fromJson(jsonEntry));

    setState(() {
      timelineStatus = loadedTimeline;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;
    if (args['accessToken'] != accessToken) {
      setState(() {
        accessToken = args['accessToken'];
      });
      fetchUserTimeline(accessToken);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: 'godotengine',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a hashtag';
                      }
                      return null;
                    },
                    onSaved: (String? val) {
                      hashtag = val!;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Hashtag to search for',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pushNamed(context, GodotEngineToots.routeName, arguments: {
                          'hashtag': hashtag,
                        });
                      }
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          ...timelineStatus.map((e) => StatusCard(
            status: e,
            dateFormat: dateFormat,
            timeFormat: timeFormat,
          ))
        ],
      ),
    );
  }
}
