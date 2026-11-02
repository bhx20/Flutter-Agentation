/// Cross-platform conditional export for widget source code file reading.
///
/// Uses `dart:io` file access on desktop/mobile platforms, and a safe stub on Web.
library;

export 'widget_code_file_reader_stub.dart'
    if (dart.library.io) 'widget_code_file_reader_io.dart';

