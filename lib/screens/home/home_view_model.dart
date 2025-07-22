import 'package:flutter/foundation.dart';
import 'package:Regrabber/services/download_service.dart';
import 'package:Regrabber/services/history_service.dart';
import 'package:Regrabber/services/clipboard_service.dart';
import 'package:Regrabber/services/settings_service.dart';
import 'package:Regrabber/utils/user_message.dart'; // For StatusType
import 'package:Regrabber/services/grab_service.dart';


class HomeViewModel extends ChangeNotifier {
  // Services
  final GrabService _grabService;
  final DownloadService _downloadService;
  final HistoryService _historyService;
  final ClipboardService _clipboardService;
  final SettingsService _settingsService;

  // Internal State
  String _statusMessage = '';
  StatusType _statusType = StatusType.info;

  bool _autoOpenAfterDownload = false;
  bool _isLoadingPreview = false;
  final bool _isDownloading = false;
  String? _previewImageUrl;
  List<String> _grabHistory = [];

  // Constructor
  HomeViewModel({
    required GrabService grabService,
    required DownloadService downloadService,
    required HistoryService historyService,
    required ClipboardService clipboardService,
    required SettingsService settingsService,
  })  : _grabService = grabService,
        _downloadService = downloadService,
        _historyService = historyService,
        _clipboardService = clipboardService,
        _settingsService = settingsService;

  // Getters
  String get statusMessage => _statusMessage;
  StatusType get statusType => _statusType;

  bool get isLoadingPreview => _isLoadingPreview;
  bool get isDownloading => _isDownloading;
  bool get autoOpenAfterDownload => _autoOpenAfterDownload;

  void setAutoOpenAfterDownload(bool value) {
    _autoOpenAfterDownload = value;
    _settingsService.setAutoOpen(value);
    notifyListeners();
  }


  String? get previewImageUrl => _previewImageUrl;
  List<String> get grabHistory => _grabHistory;

  // Methods
  Future<void> loadInitialData() async {
    _grabHistory = await _historyService.loadHistory();
    _autoOpenAfterDownload = await _settingsService.autoOpen;
    notifyListeners();
  }

  Future<void> pasteFromClipboard() async {
    final text = await _clipboardService.getClipboardText();
    if (text != null && text.isNotEmpty) {
      _statusMessage = '📋 Link pasted from clipboard';
      _statusType = StatusType.success;
    } else {
      _statusMessage = '⚠️ Clipboard is empty';
      _statusType = StatusType.warning;
    }
    notifyListeners();
  }

  Future<void> grabPost(String url) async {
    try {
      _isLoadingPreview = true;
      _statusMessage = '🔍 Grabbing preview...';
      _statusType = StatusType.info;
      notifyListeners();

      final result = await _grabService.grab(url);

      if (result != null) {
        _previewImageUrl = result.previewUrl;
        _statusMessage =
        result.previewUrl != null ? '✅ Preview loaded!' : '⚠️ Nothing found';
        _statusType = result.previewUrl != null
            ? StatusType.success
            : StatusType.error;

        await _historyService.addToHistory(url);
        _grabHistory = await _historyService.loadHistory();
      } else {
        _statusMessage = '⚠️ Nothing found';
        _statusType = StatusType.warning;
      }
    } catch (e) {
      _statusMessage = '❌ Error: ${e.toString()}';
      _statusType = StatusType.error;
    } finally {
      _isLoadingPreview = false;
      notifyListeners();
    }
  }

  void onHistoryItemTap(String url) {
    // Optionally re-grab the preview or prefill input
    _statusMessage = '📜 History item selected: $url';
    _statusType = StatusType.info;
    notifyListeners();
  }

  void updateUrl(String url) {
    // Optional: can be used to track URL input changes
  }
}
