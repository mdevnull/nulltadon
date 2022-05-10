import 'dart:async';
import 'dart:convert';

import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nulltadon/status.dart';

class GodotEngineToots extends StatefulWidget {
  const GodotEngineToots({Key? key}) : super(key: key);

  static const routeName = '/hashtag_search';

  @override
  State<StatefulWidget> createState() {
    return _GodotEngineTootsState();
  }
}

class _GodotEngineTootsState extends State<GodotEngineToots> {
  late Future<Iterable<Status>> futureToots;
  String hashtag = '';

  Future<Iterable<Status>> fetchToots() async {
    if (hashtag.isEmpty) {
      return List<Status>.empty();
    }

    final response = await http
        .get(Uri.parse('https://mastodon.social/api/v1/timelines/tag/$hashtag'));

    if (response.statusCode == 200) {
      final List dataList = jsonDecode(response.body);
      return dataList.map((jsonEntry) => Status.fromJson(jsonEntry));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    super.initState();
    futureToots = fetchToots();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final argMap = args as Map<String, String>;
      if (argMap['hashtag'] != hashtag) {
        setState(() {
          hashtag = args['hashtag'] as String;
          futureToots = fetchToots();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toots about #$hashtag'),
      ),
      body: FutureBuilder<Iterable<Status>>(
        future: futureToots,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return StatusList(data: snapshot.data!);
          }

          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}