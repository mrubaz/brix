## 1.1.1

- Docs: new README in the pub.dev format (short description, features, what is not included yet, the brix family with brix_bloc and brix_riverpod); images by absolute URL.

## 1.1.0

- New `BrixOfflineCache`: a list that also works offline. Backend answers are saved on the device and used when the backend cannot be reached (`fetch` for a whole list, `search` for searches), and `BrixCached.fromCache` says when the data is the saved copy.

## 1.0.1

- Docs: the README tells the brix family story (new app: start with brix_cli; existing app: add the packages you need, each brings the core), with sharper screenshots and a clearer pub.dev description.
- Docs: README and pub.dev image of what `BrixStorage` keeps where (values, secrets).

## 1.0.0

First release.

- `BrixStorage`: plain values, JSON values and secrets; fresh-install wipe of old Keychain secrets, broken-Keystore reads as `null`, old plain-text secrets moved once, secrets cached in memory, `onError`.
- `BrixSessionStore`: a complete brix `AuthSessionStore` (tokens + remembered password as secrets, user as JSON; logout keeps remember me), `SessionKeys` to keep an older app's keys.
- `ValueStore` / `SecretStore` interfaces with `SharedPrefsStore`, `SecureSecretStore` and `MemoryStore`.
