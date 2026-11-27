import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper for copying text to the clipboard cleanly without intrusive toasts.
abstract final class ClipboardHelper {
  static Future<bool> copy(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e, stack) {
      // ignore: avoid_print
      print('CLIPBOARD EXCEPTION: $e\n$stack');
      return false;
    }
  }
}
