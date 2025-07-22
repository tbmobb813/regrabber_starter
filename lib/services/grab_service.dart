import 'package:Regrabber/models/grab_result.dart';
import 'package:Regrabber/utils/url_parser.dart';

const String _defaultPreviewImageUrlFromService =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Sample_User_Icon.png/480px-Sample_User_Icon.png';
const Duration _simulatedGrabDelayFromService = Duration(seconds: 1);

class GrabService {
  Future<GrabResult?> grab(String url) async {
    await Future.delayed(_simulatedGrabDelayFromService); // Simulate network delay
    try {
      String? thumbnailUrl = _getThumbnailForUrlLogic(url);

      if (thumbnailUrl != null) {
        return GrabResult(
          success: true,
          previewUrl: thumbnailUrl,
          message: "Preview ready.",
        );
      } else {
        // Fallback to default if nothing matched
        return GrabResult(
          success: true,
          previewUrl: _defaultPreviewImageUrlFromService,
          message: "Preview ready (default).",
        );
      }
    } catch (e) {
      return GrabResult(success: false, message: "Error grabbing preview: $e");
    }
  }

  String? _getThumbnailForUrlLogic(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final videoId = UrlParser.extractYouTubeId(url);
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
}
