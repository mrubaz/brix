import 'package:brix_network/brix_network.dart';
import 'package:test/test.dart';

void main() {
  test('type without parameters and the quoted file name', () {
    final file = DownloadedFile.fromBytes(
      [1, 2],
      headers: {
        'Content-Type': 'application/pdf; charset=binary',
        'Content-Disposition': 'attachment; filename="Report Q3.pdf"',
      },
    );

    expect(file.contentType, 'application/pdf');
    expect(file.fileName, 'Report Q3.pdf');
    expect(file.isPdf, isTrue);
    expect(file.isImage, isFalse);
  });

  test('the encoded file name is preferred', () {
    final file = DownloadedFile.fromBytes(
      [1],
      headers: {
        'content-disposition': "attachment; filename=\"fallback.pdf\"; filename*=UTF-8''r%C3%A9sum%C3%A9.pdf",
      },
    );

    expect(file.fileName, 'résumé.pdf');
  });

  test('no headers: unknown type and name; images and sizes', () {
    expect(DownloadedFile.fromBytes([1]).contentType, isNull);
    expect(DownloadedFile.fromBytes([1]).fileName, isNull);
    expect(
      DownloadedFile.fromBytes(
        [1],
        headers: {'content-type': 'image/png'},
      ).isImage,
      isTrue,
    );
    expect(DownloadedFile.fromBytes(List.filled(820, 0)).sizeLabel, '820 B');
    expect(
      DownloadedFile.fromBytes(List.filled(250 * 1024, 0)).sizeLabel,
      '250 KB',
    );
    expect(
      DownloadedFile.fromBytes(List.filled(1536 * 1024, 0)).sizeLabel,
      '1.5 MB',
    );
  });
}
