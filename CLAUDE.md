# flutter_secure_token_manager

Flutter package (pub.dev) for securely storing and auto-refreshing JWT access/refresh tokens.

## Structure

```
lib/
  flutter_secure_token_manager.dart  # Main singleton class — all public API
  storage.dart                        # Internal: thin wrapper over flutter_secure_storage
  token.dart                          # Token model (accessToken, refreshToken)
example/
  lib/
    api.dart         # Demo: login, refresh, and authenticated API calls
    home_screen.dart
```

## Key facts

- **Singleton**: `FlutterSecureTokenManager()` always returns `_instance`
- **Storage keys**: `fstm_access_token`, `fstm_refresh_token`
- **Token expiry**: defaults to `JwtDecoder.isExpired`; override `isTokenExpired` for non-JWT tokens
- **Refresh flow**: set `onTokenExpired` before calling `getAccessToken()`; only checked when token is actually expired
- **Concurrent refresh**: serialised via `_isRefreshing` flag + `Completer`; errors propagate to all waiting callers via `completeError`
- **`clearToken()`** deletes only the two token keys — does not affect other secure storage data
- **`setToken`/`clearToken`/`getToken`** all run their storage ops in parallel via `Future.wait`

## Refresh flow (critical — easy to break)

Three caller paths through `getAccessToken()`:

1. **Token valid** → returns `token.accessToken` from memory (no storage read)
2. **Token expired, no refresh in flight** → calls `onTokenExpired`, stores new token, reads fresh token from storage and returns it
3. **Refresh already in flight** → awaits `_completer.future`, reads fresh token from storage and returns it

All three paths return a valid (non-expired) token, or throw. Error in refresh propagates to path-2 caller via `rethrow` and to all path-3 callers via `completeError`.

## Commands

```bash
cd example && flutter run   # run example app
flutter analyze             # lint
dart format .               # format
```

## What to check before editing

- `getAccessToken()` — the three caller paths above must all return fresh tokens or throw
- `_isRefreshing` + `_completer` must be reset in `finally` — never in `try` or `catch` alone
- `isTokenExpired` is a mutable field — callers can replace it at runtime
