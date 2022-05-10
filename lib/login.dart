import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nulltadon/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String userToken = '';

  final _clientID = const String.fromEnvironment('CLIENT_ID');
  final _clientSecret = const String.fromEnvironment('CLIENT_SECRET');

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO check in some kind of local storage for token.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _launchUrl,
              child: const Text('Get token'),
            ),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (String val) {
                      setState(() {
                        userToken = val;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'User token',
                    ),
                  ),
                  ElevatedButton(onPressed: _submitToken, child: const Text('Login'))
                ],
              ),
            )
          ],
        )
      ),
    );
  }

  void _submitToken() async {
    final token = await _fetchAccessToken();
    await http.get(Uri.parse('https://mastodon.social/api/v1/accounts/verify_credentials'), headers: {
      'Authorization': 'Bearer $token',
    });

    Navigator.pushNamed(context, UserTimelinePage.routeName, arguments: {
      'accessToken': token
    });
  }

  Future<String> _fetchAccessToken() async {
    final response = await http.post(Uri.parse('https://mastodon.social/oauth/token'), body: {
      'grant_type': 'authorization_code',
      'client_id': _clientID,
      'client_secret': _clientSecret,
      'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob',
      'scope': 'read',
      'code': userToken,
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> respData = jsonDecode(response.body);
      return respData['access_token'];
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void _launchUrl() async {
    final Uri _authStartUrl = Uri.parse('https://mastodon.social/oauth/authorize?response_type=code&scope=read&redirect_uri=urn:ietf:wg:oauth:2.0:oob&client_id=$_clientID');
    if (!await launchUrl(_authStartUrl)) throw 'Could not launch $_authStartUrl';
  }
}

