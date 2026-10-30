/// What the profile form saves. Add the fields your API lets users change.
class ProfileUpdate {
  const ProfileUpdate({required this.name});

  final String name;

  Map<String, Object?> toJson() => {'name': name};
}
