import 'dart:typed_data';

/// A file from `BrixApi.download`: its bytes plus what the server said
/// about it (type and name, from `Content-Type` / `Content-Disposition`).
class DownloadedFile {
  const DownloadedFile({required this.bytes, this.contentType, this.fileName});

  /// Builds the file from an answer's bytes and headers (names compared
  /// without case). For your own `NetworkClient`.
  factory DownloadedFile.fromBytes(
    List<int> bytes, {
    Map<String, String> headers = const {},
  }) {
    String? header(String name) => headers.entries
        .where((entry) => entry.key.toLowerCase() == name)
        .map((entry) => entry.value)
        .firstOrNull;
    final type = header('content-type')?.split(';').first.trim();
    return DownloadedFile(
      bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      contentType: type == null || type.isEmpty ? null : type,
      fileName: _fileName(header('content-disposition')),
    );
  }

  final Uint8List bytes;

  /// e.g. `application/pdf`, `image/png`; `null` when the server sent none.
  final String? contentType;

  /// The name the server suggested, e.g. `report.pdf`; `null` when none.
  final String? fileName;

  int get size => bytes.length;

  bool get isPdf =>
      contentType == 'application/pdf' ||
      (fileName?.toLowerCase().endsWith('.pdf') ?? false);

  bool get isImage => contentType?.startsWith('image/') ?? false;

  /// "820 B", "245 KB", "1.4 MB".
  String get sizeLabel => size < 1024
      ? '$size B'
      : size < 1024 * 1024
      ? '${(size / 1024).toStringAsFixed(0)} KB'
      : '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';

  /// `filename*=UTF-8''report%20Q3.pdf` (preferred) or `filename="a.pdf"`.
  static String? _fileName(String? disposition) {
    if (disposition == null) return null;
    final encoded = RegExp(
      r"filename\*\s*=\s*[^']*''([^;]+)",
      caseSensitive: false,
    ).firstMatch(disposition);
    if (encoded != null) {
      return Uri.decodeComponent(encoded.group(1)!.trim().replaceAll('"', ''));
    }
    final plain = RegExp(
      r'filename\s*=\s*"?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(disposition);
    return plain?.group(1)?.trim();
  }

  @override
  String toString() =>
      'DownloadedFile(${fileName ?? 'unnamed'}, ${contentType ?? '?'}, $sizeLabel)';
}
