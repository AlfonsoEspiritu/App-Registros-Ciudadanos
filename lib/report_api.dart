import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportApi {
  // Ajusta la URL del servidor Flask según sea necesario
  static const String baseUrl = 'http://192.168.16.235:5000';

  static Future<void> sendReports(List<Map<String, dynamic>> reports) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/send_reports'),
        body: jsonEncode({'reports': reports}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send reports');
      }
    } catch (e) {
      print('Error sending reports: $e');
      throw e;
    }
  }
}
