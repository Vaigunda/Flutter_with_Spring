import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentor/shared/models/connect_method.model.dart';

class ConnectMethodService {

  // Method to fetch the connect methods from the API
  Future<List<ConnectMethodModel>> fetchConnectMethods(String usertoken) async {
    try {
      // Send the GET request to the API
      final url = Uri.parse('http://localhost:8080/api/mentors/connect-methods');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        // Map the response data into a list of ConnectMethodModel objects
        return data.map((item) => ConnectMethodModel.fromJson(item)).toList();
      } else {
        // Handle the error if the request fails
        throw Exception('Failed to load connect methods');
      }
    } catch (e) {
      // Catch and handle any other errors
      throw Exception('Error fetching connect methods: $e');
    }
  }
}
