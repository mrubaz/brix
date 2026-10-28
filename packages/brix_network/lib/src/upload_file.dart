/// A file in a multipart upload. The [field] name is whatever your backend
/// expects (`avatar`, `files`, `signature`, …).
class UploadFile {
  /// A file on disk (mobile, desktop).
  const UploadFile.path(
    this.field,
    String this.path, {
    this.fileName,
    this.contentType,
  }) : bytes = null;

  /// File contents in memory (web, generated images).
  const UploadFile.bytes(
    this.field,
    List<int> this.bytes, {
    required String this.fileName,
    this.contentType,
  }) : path = null;

  final String field;
  final String? path;
  final List<int>? bytes;

  /// Defaults to the last part of [path].
  final String? fileName;

  /// e.g. `image/png`; `null` lets the client decide.
  final String? contentType;

  @override
  String toString() => 'UploadFile($field: ${fileName ?? path})';
}
