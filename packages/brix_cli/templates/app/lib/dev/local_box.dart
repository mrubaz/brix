// Where the local backend keeps its accounts: a file on phones and
// desktops, the browser's storage on the web.
export 'local_box_io.dart' if (dart.library.js_interop) 'local_box_web.dart';
