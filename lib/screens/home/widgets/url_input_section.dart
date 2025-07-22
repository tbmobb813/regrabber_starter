import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_view_model.dart';

class UrlInputSection extends StatelessWidget {
  final TextEditingController urlController;
  final Function(String) onChanged;

  const UrlInputSection({
    super.key,
    required this.urlController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: urlController,
          onChanged: onChanged,
          decoration: const InputDecoration(
            labelText: 'Enter URL',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.paste),
              label: const Text('Paste'),
              onPressed: () async {
                await viewModel.pasteFromClipboard();
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Grab'),
              onPressed: viewModel.isLoadingPreview
                  ? null
                  : () => viewModel.grabPost(urlController.text),
            ),
          ],
        ),
      ],
    );
  }
}
