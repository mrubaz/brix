/// How the backend confirms that the user really wants their account gone.
enum AccountDeletionMode {
  /// No in-app deletion.
  none,

  /// One tap after an "are you sure?" dialog.
  confirm,

  /// The current password is asked.
  password,

  /// A code is emailed / texted and must be typed back.
  code,
}
