class GrabResult {
  final bool success;
  final String? previewUrl;
  final String message;

  GrabResult({
    required this.success,
    this.previewUrl,
    required this.message,
  });
}
