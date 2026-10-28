## 1.0.0

First release.

- `BrixStorage`: plain values, JSON values and secrets; fresh-install wipe of old Keychain secrets, broken-Keystore reads as `null`, old plain-text secrets moved once, secrets cached in memory, `onError`.
- `BrixSessionStore`: a complete brix `AuthSessionStore` (tokens + remembered password as secrets, user as JSON; logout keeps remember me), `SessionKeys` to keep an older app's keys.
- `ValueStore` / `SecretStore` interfaces with `SharedPrefsStore`, `SecureSecretStore` and `MemoryStore`.
