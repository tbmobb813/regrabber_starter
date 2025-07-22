import 'package:flutter/material.dart';

class PreviewSection extends StatelessWidget {
  final String? previewImageUrl;
  final bool isLoading;

  const PreviewSection({
    super.key,
    required this.previewImageUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (previewImageUrl == null || previewImageUrl!.isEmpty) {
      return const Text('No preview available.');
    }

    return Image.network(previewImageUrl!);
  }
}

