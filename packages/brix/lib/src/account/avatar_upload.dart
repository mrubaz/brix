/// A picture for `AccountProvider.uploadAvatar`: a file path (mobile) or
/// the bytes (web, memory), plus its name and type.
class AvatarUpload {
  const AvatarUpload({
    required this.fileName,
    this.path,
    this.bytes,
    this.contentType,
  }) : assert(path != null || bytes != null, 'Give a path or the bytes');

  final String fileName;
  final String? path;
  final List<int>? bytes;

  /// e.g. `image/jpeg`; null lets the adapter decide.
  final String? contentType;

  @override
  String toString() => 'AvatarUpload($fileName)';
}
