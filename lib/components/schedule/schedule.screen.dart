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
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mentor/shared/services/token.service.dart';
import 'package:mentor/shared/shared.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

import '../../shared/models/chat.model.dart';
import 'chat.box.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _fromDate = DateTime.now().add(const Duration(days: -60));
  final _toDate = DateTime.now().add(const Duration(days: 60));
  static final _todayKey = GlobalKey();

  List<ChatMessage> _unreadMessages = [];

  var provider;
  late String userId;
  late String userType;
  late String usertoken;

  List bookingList = [];

  DateTime selectedDate = DateTime.now();
  String textDate = "Today";
  bool isDay = false;

  bool _isDisposed = false;

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
      DateTime currentDate = DateTime.now();
      getBookingList(currentDate);
    });
  }

@override
void dispose() {
  _isDisposed = true;
  super.dispose();
}

Future<List<ChatMessage>> fetchHistoryMessages(int userId, int mentorId) async {
    List<ChatMessage> messages1 = await fetchChatHistory(userId, mentorId);
    List<ChatMessage> historyMessages1 = messages1;

    List<ChatMessage> messages2 = await fetchChatHistory(mentorId, userId);
    List<ChatMessage> historyMessages2 = messages2;

    return mergeAndSort(historyMessages1, historyMessages2);
  }

  Future<List<ChatMessage>> fetchChatHistory(int senderId, int recipientId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/chat/history/$senderId/$recipientId'),
      headers: {
        'Authorization': 'Bearer $usertoken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load chat messages");
    }
  }

  List<ChatMessage> mergeAndSort(List<ChatMessage> list1, List<ChatMessage> list2) {
    // Combine both lists
    List<ChatMessage> mergedList = [...list1, ...list2];

    // Sort by timestamp
    mergedList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return mergedList;
  }

Future<List<ChatMessage>> getUnreadMessages(int senderId, int recipientId) async {
  final response = await http.get(
    Uri.parse('http://localhost:8080/api/chat/unread/$senderId/$recipientId'),
    headers: {
      'Authorization': 'Bearer $usertoken',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load unread messages");
  }
}

Future<void> getBookingList(DateTime date) async {
  int userIdInt = int.tryParse(userId) ?? -1; // Safely parse userId
  if (userIdInt == -1) {
    return;
  }

  String formattedDate = DateFormat('yyyy-MM-dd').format(date);
  late final Uri url;

  // Define the URL based on the userType
  if (userType == "Mentor") {
    url = Uri.parse(
      'http://localhost:8080/api/bookings/mentor/$userIdInt/$formattedDate',
    );
  } else if (userType == "User") {
    url = Uri.parse(
      'http://localhost:8080/api/bookings/user/$userIdInt/$formattedDate',
    );
  } else {
    return;
  }

  try {
    // Check if token has expired
    bool isExpired = JwtDecoder.isExpired(usertoken);
    if (isExpired) {
      final tokenService = TokenService();
      tokenService.checkToken(usertoken, context);
    } else {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          if (!_isDisposed) {  // ✅ Check if widget is still in the tree
            setState(() {
              bookingList = data.isNotEmpty ? data : [];
            });
          }
        } else {
          setState(() {
            bookingList = [];
          });
        }
      } else {
        throw Exception('Failed to load bookings');
      }
    }
  } on FormatException {
      if (!_isDisposed) {
        setState(() {
          bookingList = [];
        });
      }
    } on Exception {
      if (!_isDisposed) {
        setState(() {
          bookingList = [];
        });
      }
    }
}

Future<void> fetchUnreadMessages(int userId, int mentorId) async {
  List<ChatMessage> messages = await getUnreadMessages(userType == 'Mentor' ? userId : mentorId, userType == 'Mentor' ? mentorId : userId);
  if (!_isDisposed) {
      setState(() {
        _unreadMessages = messages;
      });
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "My schedule",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _days()),
          ),
          const SizedBox(
            height: 20,
          ),
          if (isDay)
            Text(
              "Today",
              style: context.headlineSmall,
            ),
          if (!isDay)
            Text(
              textDate,
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
                  bookingList.isNotEmpty
                    ? _buildTimeline()
                    : Center(
                        child: Text(
                          "No Schedule Events",
                          style: context.bodyMedium,
                        ),
                      ),
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
    final isSelected = selectedDate == date;

    return GestureDetector(
      onTap: () {
        setState(() {
          isDay = _isToday(date);
          selectedDate = date;
          textDate = DateFormat('dd-MM-yyyy').format(date);
        });
        getBookingList(date);
      },
      child: Container(
        key: _isToday(date) ? _todayKey : ValueKey(date),
        width: 60,
        height: 70,
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : context.colors.onSecondary,
            borderRadius: BorderRadius.circular(4)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            DateFormat('EEE').format(date),
            style: context.bodyLarge!.copyWith(
                color:
                    isSelected ? context.colors.onPrimary : context.colors.tertiary),
          ),
          Text(DateFormat('MMM d').format(date))
        ]),
      ),
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

    fetchUnreadMessages(bookingList[i]['userId'] , bookingList[i]['mentorId']);
    
    final category = bookingList[i]['category'] ?? 'No Category';
    final connectMethod = bookingList[i]['connectMethod'] ?? 'Unknown Method';
    final timeSlotStart = bookingList[i]['timeSlotStart']?.toString() ?? '00:00';
    final timeSlotEnd = bookingList[i]['timeSlotEnd']?.toString() ?? '00:00';

    final timeSlot = "$timeSlotStart - $timeSlotEnd";

    final userId = bookingList[i]['userId'];
    final mentorId = bookingList[i]['mentorId'];

    TimelineEventDisplay event = TimelineEventDisplay(
      anchor: IndicatorPosition.top,
      indicatorOffset: const Offset(0, 24),
      child: _buildTimelineCard(
          name, category, connectMethod, timeSlot, userId, mentorId, true),
      indicator: const Icon(FontAwesomeIcons.circleDot),
    );

    events.add(event);
  }

  return events;
}

  Widget _buildTimelineCard(String name, String category, String connect, String time,
    int userId, int mentorId, [bool cancel = true, bool selected = false]) {
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
      Row(
        children: [
          Expanded(
            child: Text(connect.isNotEmpty ? connect : "No Connection Method"),
          ),
          Stack(
            clipBehavior: Clip.none, // Ensures the badge is visible outside the button
            children: [
              OutlinedButton(
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.message, size: 14),
                    SizedBox(width: 4),
                    Text("Chat"),
                  ],
                ),
                onPressed: () async {
                  var chatBox = ChatBox();
                  List<ChatMessage> messages = await fetchHistoryMessages(userId, mentorId);
                  chatBox.openChatBox(context, userId, mentorId, messages, _unreadMessages);
                },
              ),
            if (_unreadMessages.isNotEmpty)
              // Message Count Badge
              Positioned(
                right: 0,
                top: -5, // Adjust to position the badge correctly
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red, // Badge background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    _unreadMessages.length.toString(), // Your unread message count variable
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Smaller text
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 10),
      const Row(
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
          /*if (cancel)
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
            )*/
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
