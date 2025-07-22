// lib/services/download_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../utils/constants.dart'; // adjust path as needed

// You'd also create a DownloadResult model similar to GrabResult
class DownloadResult {
  final bool success;
  final String message;
  final String? filePath;

  DownloadResult({required this.success, required this.message, this.filePath});
}

class DownloadService {
  Future<DownloadResult> downloadFile(
      String imageUrl,
      bool autoOpen,
      Future<Directory?> Function(dynamic type) getDirectoryCallback, // Pass function to get dir
      ) async {
     // 1. Check Permissions
    final status = await Permission.storage.request(); // Or more specific like Permission.photos
    if (!status.isGranted) {
      return DownloadResult(success: false, message: '❌ Storage Permission denied.');
    }

    try {
      // 2. HTTP Get
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return DownloadResult(success: false, message: 'Failed to download: Status code ${response.statusCode}');
      }
      final bytes = response.bodyBytes;

      // 3. Get Directory (using callback for flexibility)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getDirectoryCallback(DirectoryType.downloads); // Example
        directory ??= await getExternalStorageDirectory(); // Fallback
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }
      await directory.create(recursive: true);

      // 4. Determine Filename & Extension
      String extension = ".png"; // Default
      if (imageUrl.contains(".")) {
        final lastDot = imageUrl.lastIndexOf(".");
        final ext = imageUrl.substring(lastDot);
        if (['.png', '.jpg', '.jpeg', '.gif', '.webp', '.mp4', '.mov'].contains(ext.toLowerCase())) {
          extension = ext;
        }
      }
      final fileName = 'Regrabber_${DateTime.now().millisecondsSinceEpoch}$extension';
      final file = File('${directory.path}/$fileName');

      // 5. Write File
      await file.writeAsBytes(bytes);

      // 6. Auto Open (if enabled)
      String openResultMessage = "";
      if (autoOpen) {
        final openResult = await OpenFile.open(file.path);
        if (openResult.type != ResultType.done) {
          openResultMessage = ' (Could not auto-open: ${openResult.message})';
        }
      }

      return DownloadResult(
          success: true,
          message: '✅ File downloaded to: $fileName$openResultMessage',
          filePath: file.path);
    } catch (e) {
      return DownloadResult(success: false, message: '⚠️ Failed to download: $e');
    }
  }
}
