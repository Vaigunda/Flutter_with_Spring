import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentor/shared/models/verified.model.dart';

class VerifiedService {
  //final String apiUrl = 'http://localhost:8080/api/mentors/verified'; // Update with your actual API endpoint

  // Method to fetch verified mentors
  Future<List<VerifiedMentor>> fetchVerifiedMentors(String usertoken) async {

    final url = Uri.parse('http://localhost:8080/api/mentors/verified');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $usertoken',
      },
    );

    //final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Decode JSON response and map to VerifiedMentor list
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => VerifiedMentor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load verified mentors');
    }
  }
}
