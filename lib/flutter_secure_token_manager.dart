library flutter_secure_token_manager;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_token_manager/storage.dart';
import 'package:flutter_secure_token_manager/token.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class FlutterSecureTokenManager {
  static const String _accessTokenKey = "fstm_access_token";
  static const String _refreshTokenKey = "fstm_refresh_token";

  Future<bool> Function(String? accessToken) isTokenExpired =
      (accessToken) async {
    try {
      return accessToken == null || JwtDecoder.isExpired(accessToken);
    } catch (_) {}
    return false;
  };

  Future<Token> Function(String refreshToken)? onTokenExpired;

  bool _isRefreshing = false;
  Completer<void>? _completer;

  static final FlutterSecureTokenManager _instance =
      FlutterSecureTokenManager._internal();

  FlutterSecureTokenManager._internal();

  factory FlutterSecureTokenManager() => _instance;

  Future<void> setToken({required Token token}) async {
    await Storage.write(
      key: _accessTokenKey,
      value: token.accessToken,
    );
    await Storage.write(
      key: _refreshTokenKey,
      value: token.refreshToken,
    );
  }

  Future<Token?> getToken() async {
    return (await hasToken())
        ? Token(
            accessToken: (await Storage.read(key: _accessTokenKey))!,
            refreshToken: (await Storage.read(key: _refreshTokenKey))!,
          )
        : null;
  }

  Future<String> getAccessToken() async {
    final Token? token = await getToken();
    if (token == null) {
      throw Exception(
          "Unable to retrieve access token. Please set the token using setToken first.");
    }
    if (onTokenExpired == null) {
      throw Exception(
          "Token refresh callback (onTokenExpired) is not set. Please provide a valid callback function.");
    }
    if (await isTokenExpired(token.accessToken) && !_isRefreshing) {
      debugPrint("Access token has expired, initiating the refresh process.");
      _isRefreshing = true;
      _completer = Completer<void>();
      setToken(token: await onTokenExpired!(token.refreshToken));
      _isRefreshing = false;
      _completer?.complete();
    }
    if (_isRefreshing) {
      debugPrint(
          "Already refreshing access token, waiting for the process to complete.");
      await _completer?.future;
    }
    return (await getToken())!.accessToken;
  }

  Future<String?> getRefreshToken() async {
    return Storage.read(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    return await Storage.containsKey(key: _accessTokenKey) &&
        await Storage.containsKey(key: _refreshTokenKey);
  }

  Future<void> clearToken() async {
    await Storage.deleteAll();
  }
}
