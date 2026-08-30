import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  LauncherUtils._();

  static Future<bool> callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openMap(double latitude, double longitude) async {
    final geoUri = Uri.parse('geo:$latitude,$longitude');
    if (await canLaunchUrl(geoUri)) {
      return await launchUrl(geoUri);
    }

    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      return await launchUrl(googleMapsUrl,
          mode: LaunchMode.externalApplication);
    }

    return false;
  }
}
