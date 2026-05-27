import 'package:http/http.dart' as http;

Future<bool> hasInternetConnection() async {
  try {
    final response = await http
        .get(Uri.parse('https://clients3.google.com/generate_204'))
        .timeout(const Duration(seconds: 4));

    return response.statusCode == 204 || response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
