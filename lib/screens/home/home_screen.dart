import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Regrabber/screens/home/home_view_model.dart';
import 'package:Regrabber/screens/home/widgets/preview_section.dart';
import 'package:Regrabber/screens/home/widgets/history_list.dart';
import 'package:Regrabber/screens/home/widgets/settings_toggle.dart';
import 'package:Regrabber/screens/home/widgets/url_input_section.dart';
import 'package:Regrabber/utils/user_message.dart';
import 'package:Regrabber/screens/home/widgets/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReGrabber (Modular)'),
        actions: [
          SettingsToggle(
            value: viewModel.autoOpenAfterDownload,
            onChanged: (value) {
              viewModel.setAutoOpenAfterDownload(value);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            UrlInputSection(
              urlController: _urlController,
              onChanged: (url) => viewModel.updateUrl(url),
            ),
            const SizedBox(height: 16),
            PreviewSection(
              previewImageUrl: viewModel.previewImageUrl,
              isLoading: viewModel.isLoadingPreview,
            ),
            const SizedBox(height: 16),
            HistoryList(
              history: viewModel.grabHistory,
              onItemTap: viewModel.onHistoryItemTap,
            ),
            const SizedBox(height: 16),
            if (viewModel.statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(viewModel.statusType),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(viewModel.statusType),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.statusMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(StatusType type) {
    switch (type) {
      case StatusType.success:
        return Colors.green;
      case StatusType.error:
        return Colors.red;
      case StatusType.warning:
        return Colors.orange;
      case StatusType.info:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(StatusType type) {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.error:
        return Icons.error;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.info:
        return Icons.info;
    }
  }
}
