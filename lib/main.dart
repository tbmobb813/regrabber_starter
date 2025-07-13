import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const ReGrabberApp());
}

class ReGrabberApp extends StatelessWidget {
  const ReGrabberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReGrabber',
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;
  String? _previewImageUrl;

  List<String> _grabHistory = [];

  @override
  void initState() {
    super.initState();
    _loadGrabHistory();
  }

  Future<void> _saveGrabHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('grab_history', _grabHistory);
  }

  Future<void> _loadGrabHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('grab_history');
    if (saved != null) {
      setState(() {
        _grabHistory = saved;
      });
    }
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('grab_history');
    setState(() {
      _grabHistory.clear();
    });
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _controller.text = data.text!.trim();
        _statusMessage = 'Pasted from clipboard!';
      });
    }
  }

  void _onGrabPressed() async {
    final input = _controller.text.trim();

    if (!input.startsWith('http')) {
      setState(() {
        _statusMessage = 'Invalid URL. Must start with http or https.';
        _previewImageUrl = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Grabbing post...';
      _previewImageUrl = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    final preview = _getThumbnailForUrl(input);

    setState(() {
      _isLoading = false;
      _statusMessage = '✅ Successfully grabbed post:\n$input';
      _previewImageUrl = preview ??
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Sample_User_Icon.png/480px-Sample_User_Icon.png';
      _grabHistory.insert(0, input);
    });

    _saveGrabHistory();
  }

  String? _getThumbnailForUrl(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final videoId = _extractYouTubeId(url);
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    }

    if (url.contains('tiktok.com')) {
      return 'https://www.tiktok.com/favicon.ico';
    }

    if (url.contains('instagram.com')) {
      return 'https://www.instagram.com/static/images/ico/favicon-192.png/68d99ba29cc8.png';
    }

    if (url.contains('facebook.com')) {
      return 'https://www.facebook.com/images/fb_icon_325x325.png';
    }

    return null;
  }

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }

    if (uri.host.contains('youtube.com') && uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }

    return null;
  }


  void _onDownloadPressed() async {
    if (_previewImageUrl == null) return;

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Storage Permission denied.')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(_previewImageUrl!));
      final bytes = response.bodyBytes;

      final dir = await getExternalStorageDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir?.path}/regrabber_$timestamp.jpg';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ReGrabber')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Paste link here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _onGrabPressed,
                  child: const Text('Grab Post'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _pasteFromClipboard,
                  child: const Text('Paste from Clipboard'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
              const SizedBox(height: 12),
              if (_previewImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _previewImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _onDownloadPressed,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20),
            if (_grabHistory.isNotEmpty)
              const Text(
                '📄 Recent Grabs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ..._grabHistory.map((url) => ListTile(
              leading: const Icon(Icons.link),
              title: Text(url),
            )),
            if (_grabHistory.isNotEmpty)
              TextButton.icon(
                onPressed: _clearHistory,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear History'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
