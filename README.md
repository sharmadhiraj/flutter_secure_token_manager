# Flutter Secure Token Manager

Securely store and auto-refresh access/refresh tokens in Flutter. Handles concurrent requests — only
one refresh ever runs at a time.

## Install

Run

```bash
flutter pub add flutter_secure_token_manager
```

Or, add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_secure_token_manager: ^latest_version
```

## Setup

Configure once at app startup (e.g. in `main.dart`):

```
// Required: called when access token is expired
FlutterSecureTokenManager().onTokenExpired = (refreshToken) async {
  return await MyApi.refreshToken(refreshToken); // return new Token
};

// Optional: only needed if your tokens are not JWTs
FlutterSecureTokenManager().isTokenExpired = (accessToken) async {
  return myCustomExpiryCheck(accessToken);
};
```

## Usage

**After login:**

```
await FlutterSecureTokenManager().setToken(
  token: Token(accessToken: '...', refreshToken: '...'),
);
```

**In API calls:**

```
headers: {
  'Authorization': 'Bearer ${await FlutterSecureTokenManager().getAccessToken()}',
}
```

`getAccessToken()` refreshes automatically if expired. Safe to call concurrently.

**On logout:**

```
await FlutterSecureTokenManager().clearToken();
```

## API

| Method              | Description                                  |
|---------------------|----------------------------------------------|
| `setToken(token)`   | Store access + refresh tokens                |
| `getAccessToken()`  | Get valid access token, refreshing if needed |
| `getToken()`        | Get raw `Token`, or `null` if not set        |
| `getRefreshToken()` | Get raw refresh token string                 |
| `hasToken()`        | Check if tokens are stored                   |
| `clearToken()`      | Delete stored tokens                         |

## Error handling

`getAccessToken()` throws if:

- No token has been set → call `setToken` after login
- Token is expired and `onTokenExpired` is not set
- `onTokenExpired` callback throws (e.g. network error, 401)

---

🚀 Actively seeking feedback and suggestions for further enhancements to make this plugin even more
valuable! Share your thoughts to contribute to its improvement. Feel free to reach out if you have
any questions or encounter issues. Happy coding! 🙌