import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AnalyticsService {
  final String trackingId = '456738582'; // Your tracking ID
  final String clientId = const Uuid().v4(); // Unique client ID

  void trackPage(String pageName) async {
    final url = Uri.parse('https://www.google-analytics.com/collect');
    final payload = {
      'v': '1', // Protocol version
      'tid': trackingId, // Tracking ID
      'cid': clientId, // Client ID
      't': 'pageview', // Event type (pageview)
      'dp': pageName, // Document Path (page name)
    };

    await http.post(url, body: payload);
  }

  void trackEvent(String category, String action, {String? label}) async {
    final url = Uri.parse('https://www.google-analytics.com/collect');
    final payload = {
      'v': '1',
      'tid': trackingId,
      'cid': clientId,
      't': 'event', // Event type
      'ec': category, // Event category
      'ea': action, // Event action
      if (label != null) 'el': label, // Event label
    };

    await http.post(url, body: payload);
  }
}
