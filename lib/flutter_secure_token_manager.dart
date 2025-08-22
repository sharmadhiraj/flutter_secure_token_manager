library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_token_manager/storage.dart';
import 'package:flutter_secure_token_manager/token.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// A singleton manager to securely handle access and refresh tokens.
///
/// Provides storage, retrieval, validation, and automatic refresh handling
/// for tokens in Flutter applications.
class FlutterSecureTokenManager {
  static const String _accessTokenKey = "fstm_access_token";
  static const String _refreshTokenKey = "fstm_refresh_token";

  /// Callback to check whether an access token is expired.
  ///
  /// Defaults to using [JwtDecoder]. Override if you need custom logic.
  Future<bool> Function(String? accessToken) isTokenExpired =
      (accessToken) async {
    try {
      return accessToken == null || JwtDecoder.isExpired(accessToken);
    } catch (_) {}
    return false;
  };

  /// Callback triggered when the access token has expired.
  ///
  /// Should return a new [Token] using the provided refresh token.
  Future<Token> Function(String refreshToken)? onTokenExpired;

  bool _isRefreshing = false;
  Completer<void>? _completer;

  static final FlutterSecureTokenManager _instance =
      FlutterSecureTokenManager._internal();

  FlutterSecureTokenManager._internal();

  /// Returns the singleton instance of [FlutterSecureTokenManager].
  factory FlutterSecureTokenManager() => _instance;

  /// Saves the given [token] securely.
  ///
  /// Stores both access and refresh tokens in secure storage.
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

  /// Retrieves the saved [Token].
  ///
  /// Returns `null` if no token exists.
  Future<Token?> getToken() async {
    return (await hasToken())
        ? Token(
            accessToken: (await Storage.read(key: _accessTokenKey))!,
            refreshToken: (await Storage.read(key: _refreshTokenKey))!,
          )
        : null;
  }

  /// Retrieves a valid access token.
  ///
  /// - Throws an [Exception] if no token is set.
  /// - If the token is expired, calls [onTokenExpired] to refresh it.
  /// - Handles concurrent refresh calls safely.
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

  /// Retrieves the refresh token.
  ///
  /// Returns `null` if no refresh token is stored.
  Future<String?> getRefreshToken() async {
    return Storage.read(key: _refreshTokenKey);
  }

  /// Checks whether both access and refresh tokens are stored.
  Future<bool> hasToken() async {
    return await Storage.containsKey(key: _accessTokenKey) &&
        await Storage.containsKey(key: _refreshTokenKey);
  }

  /// Clears all stored tokens.
  Future<void> clearToken() async {
    await Storage.deleteAll();
  }
}
