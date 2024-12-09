import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mentor/shared/models/profile_mentor.model.dart';

class ProfileMentorService {
  static Future<ProfileMentor?> fetchMentorById(int profileId) async {
    
    final response = await http.get(Uri.parse('http://localhost:8080/api/mentors'));
    

    if (response.statusCode == 200) {
      // Parse the JSON response into a list of mentors
      
      List<dynamic> mentorList = json.decode(response.body);
      

      // Convert the list of JSON objects into ProfileMentor objects
      List<ProfileMentor> mentors = mentorList
          .map((mentorJson) => ProfileMentor.fromJson(mentorJson))
          .toList();
      
    
      // Find and return the mentor with the matching profileId
      ProfileMentor? mentor = ProfileMentor.getMentorById(mentors, profileId);
      print(profileId);
      print(mentor);
      return mentor;
    } else {
      throw Exception('Failed to load mentor data');
    }
  }
}
