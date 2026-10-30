/// Login details kept for "remember me".
///
/// The password is kept as typed (never trimmed or hashed, the server needs
/// the real one) and must only be stored in secure storage.
class RememberedCredentials {
  const RememberedCredentials({
    required this.identifier,
    required this.password,
  });

  final String identifier;
  final String password;

  /// The password is left out so it never ends up in a log.
  @override
  String toString() => 'RememberedCredentials(identifier: $identifier)';
}
