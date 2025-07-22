// lib/services/history_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _grabHistoryKey = 'grab_history_modular'; // New key to avoid conflicts

  Future<List<String>> loadHistory() async {
    return []; // TODO: Replace with actual loading logic
  }
  Future<void> addToHistory(String url) async {  }

  Future<List<String>> loadGrabHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_grabHistoryKey) ?? [];
  }

  Future<void> saveGrabHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_grabHistoryKey, history);
  }

  Future<void> clearGrabHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_grabHistoryKey);
  }
}