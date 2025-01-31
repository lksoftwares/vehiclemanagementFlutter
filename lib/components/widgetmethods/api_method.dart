import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehiclemanagement/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<Map<String, dynamic>?> request(String method,
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    String? token = await _getToken();
    if (token == null) {
      return {'message': 'No token found'};
    }

    try {
      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse('${Config.apiUrl}$endpoint'),
            headers: {'Authorization': 'Bearer $token'},
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse('${Config.apiUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse('${Config.apiUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse('${Config.apiUrl}$endpoint'),
            headers: {'Authorization': 'Bearer $token'},
          );
          break;
        default:
          return {'message': 'Invalid HTTP method'};
      }

      return _handleResponse(response);
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        return {'message': 'Error parsing response'};
      }
    } else {
      return {'message': 'Server error. Status code: ${response.statusCode}'};
    }
  }
}
