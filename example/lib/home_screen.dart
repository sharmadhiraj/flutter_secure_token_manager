import 'dart:convert';

import 'package:example/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_token_manager/flutter_secure_token_manager.dart';
import 'package:flutter_secure_token_manager/token.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _progress = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    FlutterSecureTokenManager().onTokenExpired = (refreshToken) async {
      return await Api.getNewToken(refreshToken);
    };
    FlutterSecureTokenManager().isTokenExpired = (accessToken) async {
      //Your logic here
      return true;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: _buildBody()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Flutter Secure Token Manager Demo"),
    );
  }

  Widget _buildBody() {
    if (_progress) {
      return _buildProgressWidget();
    } else if (_loggedIn) {
      return Column(
        children: [
          _buildSimulateExpireTokenButton(),
          const SizedBox(height: 8),
          _buildTokenRenewWidget(),
        ],
      );
    } else {
      return _buildLoginWidget();
    }
  }

  Widget _buildProgressWidget() {
    return const CircularProgressIndicator();
  }

  Widget _buildLoginWidget() {
    return ElevatedButton(
      onPressed: _login,
      child: const Text("Login"),
    );
  }

  Widget _buildSimulateExpireTokenButton() {
    return ElevatedButton(
      onPressed: () => _simulateTokenExpire(),
      child: const Text("Simulate Expire Token"),
    );
  }

  Widget _buildTokenRenewWidget() {
    return ElevatedButton(
      onPressed: _makeParallelApiCalls,
      child: const Text("Make Api Calls"),
    );
  }

  Future<void> _login() async {
    setState(() => _progress = true);
    try {
      final Token token = await Api.login();
      FlutterSecureTokenManager().setToken(token: token);
      setState(() => _loggedIn = true);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _progress = false);
    }
  }

  Future<void> _simulateTokenExpire() async {
    final Token? token = await FlutterSecureTokenManager().getToken();
    if (token != null) {
      await FlutterSecureTokenManager().setToken(
        token: Token(
          accessToken:
              "yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImlhdCI6MTY3Mjc2NjAyOCwiZXhwIjoxNjc0NDk0MDI4fQ.kCak9sLJr74frSRVQp0_27BY4iBCgQSmoT3vQVWKzJg",
          refreshToken: token.refreshToken,
        ),
      );
    }
  }

  Future<void> _makeParallelApiCalls() async {
    setState(() => _progress = true);
    List<Map<String, dynamic>> responses = await Future.wait(
      [
        Api.fetchProfile(),
        Future.delayed(
          const Duration(milliseconds: 10),
          Api.fetchProfile,
        )
      ],
    );
    for (var element in responses) {
      debugPrint(jsonEncode(element));
    }
    setState(() => _progress = false);
  }
}
