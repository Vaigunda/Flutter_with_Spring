// lib/shared/services/top_rated_mentor.service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/top_rated_mentor.model.dart';

class MentorService {
  Future<List<TopRatedMentorModel>> fetchTopRatedMentors(String usertoken) async {
    //final response = await http.get(Uri.parse('http://localhost:8080/api/mentors/top-rated'));

    final url = Uri.parse('http://localhost:8080/api/mentors/top-rated');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $usertoken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => TopRatedMentorModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load top-rated mentors');
    }
  }
}
