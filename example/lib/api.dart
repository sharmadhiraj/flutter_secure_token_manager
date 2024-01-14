import 'dart:convert';

import 'package:flutter_secure_token_manager/flutter_secure_token_manager.dart';
import 'package:flutter_secure_token_manager/token.dart';
import 'package:http/http.dart' as http;

class Api {
  static Future<Token> login() async {
    final dynamic response = await http.post(
      Uri.parse("https://api.escuelajs.co/api/v1/auth/login"),
      body: {
        "email": "john@mail.com",
        "password": "changeme",
      },
    );
    final json = jsonDecode(response.body);
    return Token(
        accessToken: json["access_token"], refreshToken: json["refresh_token"]);
  }

  static Future<Token> getNewAccessToke(String refreshToken) async {
    final dynamic response = await http.post(
      Uri.parse("https://api.escuelajs.co/api/v1/auth/refresh-token"),
      body: {
        "refreshToken": refreshToken,
      },
    );
    final json = jsonDecode(response.body);
    return Token(
        accessToken: json["access_token"], refreshToken: json["refresh_token"]);
  }

  static Future<Map<String, dynamic>> makeApiCall(String url) async {
    final dynamic response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization":
            "Bearer ${await FlutterSecureTokenManager().getAccessToken()}"
      },
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchProfile() async {
    return await makeApiCall("https://api.escuelajs.co/api/v1/auth/profile");
  }
}
