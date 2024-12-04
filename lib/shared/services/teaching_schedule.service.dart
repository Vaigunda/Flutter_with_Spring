import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentor/shared/models/teaching_schedule.model.dart';  // Import your TeachingScheduleModel class

class TeachingScheduleService {
  // The API endpoint for teaching schedules
  final String apiUrl = 'http://localhost:8080/api/mentors/teaching-schedules';

  // Method to fetch teaching schedules from the API
  Future<List<TeachingScheduleModel>> fetchTeachingSchedules() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode the response body into a List
        final List<dynamic> data = json.decode(response.body);

        // Map the List of JSON data to a List of TeachingScheduleModel
        return data.map((item) => TeachingScheduleModel(
          id: item['id'].toString(),
          dateStart: DateTime.parse(item['dateStart']),
          timeStart: DateTime.parse(item['timeStart']),
          timeEnd: DateTime.parse(item['timeEnd']),
          booked: item['booked'],
          mentorId: item['mentorId'].toString(),
        )).toList();
      } else {
        throw Exception('Failed to load teaching schedules');
      }
    } catch (error) {
      throw Exception('Error fetching teaching schedules: $error');
    }
  }
}
