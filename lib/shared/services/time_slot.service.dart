import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mentor/shared/models/fixed_time_slot.model.dart';

class TimeSlotService {
  Future<List<FixedTimeSlotModel>> fetchAvailableTimeSlots(
      String mentorId, DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final String apiUrl =
        'http://localhost:8080/api/mentors/time-slots/$mentorId?date=$formattedDate';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((slot) => FixedTimeSlotModel.fromJson(slot)).toList();
    } else {
      throw Exception("Failed to load time slots");
    }
  }
}

