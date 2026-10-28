# brix_storage

Local storage that gets the tricky parts right – plain values, secrets, and a ready-made session store for [brix](https://pub.dev/packages/brix).

- **Values** (`shared_preferences`) and **secrets** (`flutter_secure_storage`: Keychain / Keystore) behind one class.
- **Reinstall safe:** iOS keeps Keychain items after the app is deleted – brix_storage wipes them on a fresh install, so nobody is logged in as the previous user.
- **Never crashes on a broken Keystore** (Android after a backup restore): the read gives `null`, the error goes to `onError`.
- **Moves old plain-text secrets** into secure storage on the first read.
- **Ready session store:** `BrixSessionStore` is a complete brix `AuthSessionStore` – tokens and the remembered password as secrets, the user as JSON.

## Install

```
flutter pub add brix_storage
```

## Use

```dart
final storage = BrixStorage(onError: (error, stack) => log('storage: $error'));

await storage.write('locale', 'en');
await storage.writeJson('settings', {'darkMode': true});
await storage.writeSecret('token', token);   // Keychain / Keystore

final token = await storage.readSecret('token');      // cached in memory after the first read
final settings = await storage.readJson('settings');  // null if missing or broken

await storage.clear(); // everything, e.g. after deleting the account
```

### Session store for brix flows

```dart
final store = BrixSessionStore<User>(
  storage: storage,
  userToJson: (user) => user.toJson(),
  userFromJson: User.fromJson,
);

LoginFlow(provider: auth, store: store, navigator: nav, feedback: alerts);
```

| Call | Keeps |
|---|---|
| `clearSession()` (logout) | "remember me" |
| `clearAll()` (account deleted) | nothing |

Moving from your own storage? Pass the keys you used so users stay logged in:

```dart
BrixSessionStore<User>(
  storage: BrixStorage(installMarkerKey: 'hasSecureData'),
  keys: const SessionKeys(token: 'apiToken', user: 'user_data'),
  userToJson: (user) => user.toJson(),
  userFromJson: User.fromJson,
);
```

### Other backends

`ValueStore` and `SecretStore` are small interfaces – plug in Hive, a file, or `MemoryStore` in tests:

```dart
final storage = BrixStorage(values: MemoryStore(), secrets: MemoryStore());
```

## License

MIT
