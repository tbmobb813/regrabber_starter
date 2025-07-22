import 'dart:io'; // For Platform
import 'package:path_provider/path_provider.dart'; // For DirectoryType
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _autoOpenKey = 'autoOpenAfterDownload';

  Future<void> setAutoOpen (bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoOpenKey, value);
  }

  Future<bool> get autoOpen async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoOpenKey) ?? false;
  }

  // Example of how the DownloadService might get the directory via SettingsService
  // This keeps directory logic somewhat centralized if it becomes complex
  Future<Directory?> getDownloadDirectory(dynamic typeHint) async {
    Directory? directory;
    if (Platform.isAndroid) {
      // Using your existing helper logic, which could also be moved into this service
      directory = await _getExternalStoragePublicDirectory(typeHint); // typeHint would be DirectoryType.downloads
      directory ??= await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory(); // For desktop
    }
    return directory;
  }

  // Copied from your original _HomeScreenState, could be refined
  Future<Directory?> _getExternalStoragePublicDirectory(dynamic type) async {
    if (!Platform.isAndroid) return null;
    try {
      final directoryPath = "/storage/emulated/0/${type.toString().split('.').last}";
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        return directory;
      } else {
        // Consider creating it, or rely on higher level functions in path_provider if available
        // lib/services/settings_service.dart (continued)
        // final createdDir = await directory.create(recursive: true);
        // return createdDir;
        // For simplicity, if it doesn't exist, we might fall back or let path_provider handle creation.
        // Or, this could indicate a setup where this path isn't standard, so fall back.
        print("Standard public directory for ${type.toString()} not found at $directoryPath, attempting fallback.");
        return null; // Let the caller decide on a fallback like getExternalStorageDirectory()
      }
    } catch (e) {
      print("Error accessing/creating _getExternalStoragePublicDirectory for ${type.toString()}: $e");
      return null; // Fallback if any error
    }
  }

  static Future getAutoOpenAfterDownload(bool value) async {}
}
