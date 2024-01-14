# Flutter Secure Token Manager

### What it does

- **Secure Storage:** Safely stores access token and refresh token.
- **Efficient Token Refresh:** Efficiently renews access tokens upon expiration, ensuring a single
  refresh request even when multiple requests detect token expiry simultaneously.
- **Token Expiry Check:** Provides a mechanism to check if tokens have expired (only for JWT).

### Implementation Steps

1. **Add Package:** Include the package in your Flutter project.

    ```dart
    dependencies:
      flutter_secure_token_manager: ^latest_version
    ```

2. **Set Tokens After Login:**
   Use `FlutterSecureTokenManager().setToken(Token(accessToken, refreshToken))` whenever there are
   changes to tokens.

3. **Implement Token Expiry Check:** If your tokens are not JWT, set the expiry check logic (usually
   done once at the beginning).

    ```dart
    FlutterSecureTokenManager().isTokenExpired = (accessToken) async {
      // Your logic here
      // return true or flase; //
    };
    ```

4. **Token Refresh Logic:** Implement the logic for refreshing the token when it expires.

    ```dart
    FlutterSecureTokenManager().onTokenExpired = (refreshToken) async {
       // Your logic here to get new access token with refreshToken;
       // return newToken;
    };
    ```

5. **Access Token Retrieval:** Use `FlutterSecureTokenManager().getAccessToken()` wherever you need
   the access token. The package will handle the refresh automatically.

    ```dart
    headers: {
      "Authorization": "Bearer ${await FlutterSecureTokenManager().getAccessToken()}"
    }
    ```

Note: Ensure these steps are appropriately integrated into your app flow, especially during the
login process and before making authenticated requests.

🚀 Actively seeking feedback and suggestions for further enhancements to make this plugin even more
valuable! Share your thoughts to contribute to its improvement. Feel free to reach out if you have
any questions or encounter issues. Happy coding! 🙌