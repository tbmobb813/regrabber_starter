// lib/services/clipboard_service.dart
import 'package:flutter/services.dart';

class ClipboardService {

  Future<String?> getClipboardText() async {
    return null;
  }

  Future<String?> paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      return data.text!.trim();
    }
    return null;
  }
}
