import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../home/widgets/settings_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoOpenAfterDownload = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final value = await SettingsService.getAutoOpenAfterDownload(context as bool);
    setState(() => _autoOpenAfterDownload = value);
  }

  Future<void> _toggleAutoOpen(bool value) async {
    await SettingsService.getAutoOpenAfterDownload(value);
    setState(() => _autoOpenAfterDownload = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SettingsToggle(
            value: _autoOpenAfterDownload,
            onChanged: _toggleAutoOpen,
          ),
          const Divider(height: 1),
          // Add more toggles or sections here as needed
        ],
      ),
    );
  }
}
