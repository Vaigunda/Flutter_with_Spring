import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_timeline/event_item.dart';
import 'package:flutter_timeline/indicator_position.dart';
import 'package:flutter_timeline/timeline.dart';
import 'package:flutter_timeline/timeline_theme.dart';
import 'package:flutter_timeline/timeline_theme_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mentor/shared/shared.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _fromDate = DateTime.now().add(const Duration(days: -60));
  final _toDate = DateTime.now().add(const Duration(days: 60));
  static final _todayKey = GlobalKey();

  var provider;
  late String userId;
  late String userType;
  late String usertoken;

  late List bookingList = [];

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    userId = provider.userid;
    userType = provider.usertype;
    usertoken = provider.usertoken;

    Future.delayed(
        Duration.zero,
        () => {
              if (_todayKey.currentContext != null)
                {Scrollable.ensureVisible(_todayKey.currentContext!)}
            });

    WidgetsBinding.instance.addPostFrameCallback((_){
      getBookingList();
    });
  }

  getBookingList() async {
    int userid = int.parse(userId);
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    late final Uri url;

    if (userType == "Mentor") {
      url = Uri.parse(
        'http://localhost:8080/api/bookings/mentor/$userid/$formattedDate');
    } else if (userType == "User") {
      url = Uri.parse(
        'http://localhost:8080/api/bookings/user/$userid/$formattedDate');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $usertoken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Ensure data is a list and not null
      if (data != null && data.isNotEmpty) {
        setState(() {
          bookingList = data;
        });
      } else {
        setState(() {
          bookingList = []; // Default to empty list
        });
      }
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "My schedule",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _days()),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Today",
            style: context.headlineSmall,
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeline(), 
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  List<Widget> _days() {
    List<Widget> days = [];
    for (int i = 0; i <= _toDate.difference(_fromDate).inDays; i++) {
      days.add(_day(_fromDate.add(Duration(days: i))));
    }
    return days;
  }

  Widget _day(DateTime date) {
    final isToday = _isToday(date);
    return Container(
      key: isToday ? _todayKey : null,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(6),
      width: 60,
      height: 70,
      decoration: BoxDecoration(
          color: isToday ? context.colors.primary : context.colors.onSecondary,
          borderRadius: BorderRadius.circular(4)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          DateFormat('EEE').format(date),
          style: context.bodyLarge!.copyWith(
              color:
                  isToday ? context.colors.onPrimary : context.colors.tertiary),
        ),
        Text(DateFormat('MMM d').format(date))
      ]),
    );
  }

  List<TimelineEventDisplay> getPlainEventDisplay() {
  List<TimelineEventDisplay> events = [];

  for (int i = 0; i < bookingList.length; i++) {
    late String name;

    if (userType == "Mentor") {
      name = bookingList[i]['userName'] ?? 'Unknown User';
    } else if (userType == "User") {
      name = bookingList[i]['mentorName'] ?? 'Unknown Mentor';
    }
    
    final category = bookingList[i]['category'] ?? 'No Category';
    final connectMethod = bookingList[i]['connectMethod'] ?? 'Unknown Method';
    final timeSlotStart = bookingList[i]['timeSlotStart']?.toString() ?? '00:00';
    final timeSlotEnd = bookingList[i]['timeSlotEnd']?.toString() ?? '00:00';

    final timeSlot = "$timeSlotStart - $timeSlotEnd";

    TimelineEventDisplay event = TimelineEventDisplay(
      anchor: IndicatorPosition.top,
      indicatorOffset: const Offset(0, 24),
      child: _buildTimelineCard(
          name, category, connectMethod, timeSlot, false, true),
      indicator: const Icon(FontAwesomeIcons.circleDot),
    );

    events.add(event);
  }

  return events;
}

  Widget _buildTimelineCard(String name, String category, String connect, String time,
    [bool cancel = true, bool selected = false]) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: context.colors.onSecondary),
      borderRadius: BorderRadius.circular(8),
      color: selected ? context.colors.onSecondary : null,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Expanded(
            child: Text(
              name.isNotEmpty ? name : "No Name",
              style: context.bodyLarge,
            ),
          ),
          Text(time.isNotEmpty ? time : "No Time Provided",
              style: context.bodySmall)
        ],
      ),
      const SizedBox(height: 10),
      Text(category.isNotEmpty ? category : "No Category"),
      const SizedBox(height: 10),
      Text(connect.isNotEmpty ? connect : "No Connection Method"),
      const SizedBox(height: 10),
      Row(
        children: [
          // Expanded(
          //   child: Row(
          //     children: [
          //       const CircleAvatar(radius: 12),
          //       const SizedBox(width: 4),
          //       Text("Solo Moon", style: context.bodySmall)
          //     ],
          //   ),
          // ),
          if (cancel)
            SizedBox(
              height: 30,
              child: OutlinedButton(
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.ban, size: 14),
                    SizedBox(width: 4),
                    Text("Cancel"),
                  ],
                ),
                onPressed: () {},
              ),
            )
        ],
      ),
    ]),
  );
}

  Widget _buildTimeline() {
    return TimelineTheme(
        data: TimelineThemeData(lineColor: context.colors.primary),
        child: Timeline(
          indicatorSize: 20,
          events: getPlainEventDisplay(),
        ));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.day == date.day &&
        now.month == date.month &&
        now.year == date.year;
  }
}
