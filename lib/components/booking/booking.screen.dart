import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mentor/shared/models/connect_method.model.dart';
import 'package:mentor/shared/models/fixed_time_slot.model.dart';
import 'package:mentor/shared/models/profile_mentor.model.dart';
import 'package:mentor/shared/shared.dart';
import 'package:mentor/shared/views/button.dart';
import 'package:mentor/shared/services/connect_method.service.dart';
import 'package:mentor/shared/services/profile_mentor.service.dart';
import 'package:mentor/shared/services/time_slot.service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.profileId});
  final String profileId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late ProfileMentor? mentor;
  int _index = 0;
  String _errorMessage = "";
  DateTime _focusedDay = DateTime.now(); // Add this
  bool isLoading = false; // Add this
  DateTime _selectedDay = DateTime.now();
  late List<ConnectMethodModel> connectMethods = [];
  late List<FixedTimeSlotModel> timeSlots = [];

  late String usertoken;
  late String userid;
  var provider;

  List<Map<String, dynamic>> formData = [
    {"message": "Please choose a category", "value": null},
    {"message": "Please select a date and time slot", "value": null},
    {"message": "Please select a connection method", "value": null},
  ];

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;

    ConnectMethodService connectMethodService = ConnectMethodService();

    Future.wait([
      ProfileMentorService.fetchMentorById(int.parse(widget.profileId), usertoken),
      connectMethodService.fetchConnectMethods(usertoken),
    ]).then((results) {
      setState(() {
        mentor = results[0] as ProfileMentor;
        connectMethods = results[1] as List<ConnectMethodModel>;
      });
      // Fetch time slots for today's date
      fetchTimeSlots();
    }).catchError((error) {
      setState(() {
        _errorMessage = "Failed to fetch data.";
      });
    });
  }

  Future<void> fetchTimeSlots() async {
    TimeSlotService timeSlotService = TimeSlotService();
    try {
      var slots = await timeSlotService.fetchAvailableTimeSlots(
        widget.profileId,
        _selectedDay,
        usertoken
      );
      setState(() {
        timeSlots = slots; // List of time slots from API
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to fetch time slots.";
      });
    }
  }

  void onStepCancel() {
    if (_index > 0) {
      setState(() {
        _index -= 1;
      });
    }
  }

  void onStepContinue() {
    if (formData[_index]["value"] == null) {
      setState(() {
        _errorMessage = formData[_index]["message"];
      });
      return;
    }
    setState(() {
      _index += 1;
      _errorMessage = "";
    });
  }

  StepState stateStep(int index) {
    return _index > index
        ? StepState.complete
        : _index == index
            ? StepState.editing
            : StepState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking ${mentor?.name ?? ''}"),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(child: bookingStepperForm()),
      ),
    );
  }

  Widget bookingStepperForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_index == 0)
            renderSelectCategory()
          else if (_index == 1)
            renderSelectDateAndTimeSlot()
          else if (_index == 2)
            renderSelectMethodConnect()
          else if (_index == 3)
            renderSubmitBooking(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (_index != 0)
                CustomButton(
                  label: "Previous",
                  onPressed: onStepCancel,
                  type: EButtonType.outline,
                ),
              const SizedBox(width: 10),
              if (_index < 3)
                CustomButton(label: "Next", onPressed: onStepContinue),
              if (_index == 3)
                CustomButton(
                  label: "Booking",
                  onPressed: () async {
                    await submitBooking();
                    context.pop();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderSelectCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        renderHeaderStep("Select a category"),
        for (var item in [
          ...mentor!.categories,
          Category(id: 'other', name: "Other", icon: "circleQuestion"),
        ])
          ListTile(
            minLeadingWidth: 10,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            dense: true,
            tileColor: Colors.transparent,
            title: Text(item.name,
                style: context.bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            leading: Radio<String>(
              value: item.id,
              groupValue: formData[_index]["value"],
              onChanged: (String? value) {
                setState(() {
                  formData[_index]["value"] = value;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget renderSelectDateAndTimeSlot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        renderHeaderStep("Select a date and time slot"),
        TableCalendar(
          focusedDay: _selectedDay, // This will be updated
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay; // Update selected day
              _focusedDay = focusedDay; // Update focused day
              isLoading = true; // Set loading state to true
            });

            fetchTimeSlots().then((_) {
              // After fetching, set loading state to false
              setState(() {
                isLoading = false;
              });
            }).catchError((error) {
              // Handle any errors
              setState(() {
                isLoading = false;
              });
              // Show error feedback if needed
            });
          },
          enabledDayPredicate: (day) {
            // Disable Sundays (day.weekday == 7 represents Sunday in Dart)
            return day.weekday != DateTime.sunday;
          },
        ),
        const SizedBox(height: 10),
        Text("Available Time Slots:", style: context.titleSmall),
        const SizedBox(height: 10),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(), // Show loading spinner
          )
        else if (timeSlots.isEmpty)
          const Center(
            child: Text("No time slots available for the selected date."),
          )
        else
          Column(
            children: timeSlots.map((slot) {
              return ListTile(
                title: Text(
                  "${slot.timeStart} - ${slot.timeEnd} (${slot.status})",
                ),
                leading: Radio<FixedTimeSlotModel>(
                  value: slot,
                  groupValue: formData[_index]["value"],
                  onChanged: slot.status == "available"
                      ? (value) {
                          setState(() {
                            formData[_index]["value"] = value;
                          });
                        }
                      : null,
                ),
                enabled: slot.status == "available",
              );
            }).toList(),
          ),
      ],
    );
  }


  Widget renderSelectMethodConnect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        renderHeaderStep("Select method connect"),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline, width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              focusColor: Colors.transparent,
              isExpanded: true,
              isDense: true,
              underline: Container(),
              value: formData[_index]["value"],
              hint: const Text("Select method to connect with mentor"),
              items: connectMethods.map((ConnectMethodModel value) {
                return DropdownMenuItem<String>(
                  value: value.id,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  formData[_index]["value"] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget renderSubmitBooking() {
    // Get selected category and connect method
    var category = mentor!.categories
        .firstWhere((element) => element.id == formData[0]["value"], orElse: () => Category(id: 'default', name: 'Default', icon: 'circle'));

    var method = connectMethods
        .firstWhere((element) => element.id == formData[2]["value"], orElse: () => const ConnectMethodModel(id: 'default', name: 'Default'));

    var selectedTimeSlot = formData[1]["value"]; // This will hold the selected time slot object

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your booking information: ", style: context.titleSmall),
        const SizedBox(height: 10),
        Text("Mentor:", style: context.titleSmall),
        Text(mentor!.name),
        const SizedBox(height: 10),
        Text("Category:", style: context.titleSmall),
        Text(category.name),
        const SizedBox(height: 10),
        Text("Time Slot:", style: context.titleSmall),
        Text("${selectedTimeSlot.timeStart} - ${selectedTimeSlot.timeEnd}"), // Display time slot
        const SizedBox(height: 10),
        Text("Connect method:", style: context.titleSmall),
        Text(method.name),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget renderHeaderStep(String label) {
    return Column(
      children: [
        Text(label, style: context.titleSmall),
        const SizedBox(height: 10),
        if (_errorMessage.isNotEmpty)
          Text(_errorMessage,
              style: context.bodySmall!.copyWith(color: Colors.red)),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> submitBooking() async {
    // Get the selected values
    var category = mentor!.categories.firstWhere(
      (element) => element.id == formData[0]["value"],
      orElse: () => Category(id: 'default', name: 'Default', icon: 'circle'),
    );

    var method = connectMethods.firstWhere(
      (element) => element.id == formData[2]["value"],
      orElse: () => const ConnectMethodModel(id: 'default', name: 'Default'),
    );

    var selectedTimeSlot = formData[1]["value"]; // This will hold the selected time slot object

    // Prepare the body for the POST request
    var requestBody = jsonEncode({
      "mentorId": mentor!.id, // You can replace with the actual mentor ID
      "userId": int.parse(userid), // Replace with the actual user ID (you may get this from the user profile)
      "timeSlotId": selectedTimeSlot.id, // Time slot ID user selected
      "date": DateFormat('yyyy-MM-dd').format(_selectedDay), // Format the selected day to string
      "category": category.name, // Category name selected by user
      "connectMethod": method.name, // Connection method selected by user
    });

    try {
      // Send the POST request to your backend API
      var response = await http.post(
        Uri.parse('http://localhost:8080/api/bookings'), // Replace with your actual API endpoint
        headers: {
          'Authorization': 'Bearer $usertoken',
          'Content-Type': 'application/json', // Ensure the API expects JSON
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Successfully booked
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booked successfully!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Something went wrong, handle the error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit booking. Please try again.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}





  // Widget renderHeaderStep(label) {
  //   return Column(
  //     children: [
  //       Text(label, style: context.titleSmall),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       if (_errorMessage.isNotEmpty)
  //         Text(_errorMessage,
  //             style: context.bodySmall!.copyWith(color: context.colors.error)),
  //     ],
  //   );
  // }

  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   if (!isSameDay(_selectedDay, selectedDay)) {
  //     setState(() {
  //       _selectedDay = selectedDay;
  //       // _focusedDay = focusedDay;
  //     });
      
  //   }
  // }

//   Future<void> _submitBooking() async {
//     var category = mentor!.categories
//         .firstWhere((element) => element.id == formData[0]["value"]);
//     var selectedSlot = teachSchedule
//         .firstWhere((slot) => slot.id == formData[1]["value"]);
//     var method = connectMethods
//         .firstWhere((element) => element.id == formData[2]["value"]);

//     var bookingRequest = {
//       'mentorId': mentor!.id,
//       'categoryId': category.id,
//       'timeSlotId': selectedSlot.id,
//       'connectMethodId': method.id,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse('your_api_url/bookings'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(bookingRequest),
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Booking Successful!")));
//         context.pop();
//       } else {
//         throw Exception("Failed to submit booking");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }
// }
  


  // List<TeachingScheduleModel> _getEventsForDay(DateTime day) {
  //   // Normalize the selected day to midnight (ignore the time)
  //   var selectedDayNormalized = DateTime(day.year, day.month, day.day);
  //   return kEvents[selectedDayNormalized] ?? [];
  // }

  // Future<void> _submitBooking() async {
  //   // Collect the data for the booking submission
  //   var category = mentor!.categories
  //       .firstWhere((element) => element.id == formData[0]["value"]);
  //   var studySchedule = teachSchedule
  //       .firstWhere((element) => element.id == formData[1]["value"]);
  //   var method = connectMethods
  //       .firstWhere((element) => element.id == formData[2]["value"]);

  //   // Create a BookingRequest model
  //   var bookingRequest = BookingRequest(
  //     mentorId: mentor!.id,
  //     categoryId: category.id,
  //     scheduleId: studySchedule.id,
  //     connectMethodId: method.id,
  //   );

  //   try {
  //     // Make the API request to submit the booking
  //     await BookingService.submitBooking(bookingRequest);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Booking Successful!")),
  //     );
  //     // Navigate back after successful booking
  //     context.pop();
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }




// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:mentor/shared/models/connect_method.model.dart';
// import 'package:mentor/shared/models/profile_mentor.model.dart';
// import 'package:mentor/shared/models/teaching_schedule.model.dart';
// import 'package:mentor/shared/shared.dart';
// import 'package:mentor/shared/views/button.dart';
// import 'package:mentor/shared/views/calendar_booking.dart';
// import 'package:table_calendar/table_calendar.dart';


// import 'package:mentor/shared/services/teaching_schedule.service.dart'; 
// import 'package:mentor/shared/services/connect_method.service.dart'; 
// import 'package:mentor/shared/services/profile_mentor.service.dart'; 

// class BookingScreen extends StatefulWidget {
//   const BookingScreen({super.key, required this.profileId});
//   final String profileId;

//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends State<BookingScreen> {
//   late List<TeachingScheduleModel> _selectedEvents;

//   late final kEvents;
//   late final _kEventSource;
//   late ProfileMentor? mentor;
//   int _index = 0;
//   String _errorMessage = "";
//   DateTime _selectedDay = DateTime.now();
//   late List<TeachingScheduleModel> teachSchedule =[];
//   late List<ConnectMethodModel> connectMethods =[];

//   List<Map<String, dynamic>> formData = [
//     {"message": "Please choose a category", "value": null},
//     {"message": "Please booking time", "value": null},
//     {"message": "Please select method connect", "value": null},
//   ];

//   @override
//   void initState() {
//     super.initState();

//     TeachingScheduleService teachingScheduleService = TeachingScheduleService();
//     ConnectMethodService connectMethodService = ConnectMethodService();
//     // Fetch mentor, teaching schedule, and connect methods data asynchronously
//     Future.wait([
//       ProfileMentorService.fetchMentorById(int.parse(widget.profileId)),
//       teachingScheduleService.fetchTeachingSchedules(),
//       connectMethodService.fetchConnectMethods(),
//     ]).then((results) {
//       setState(() {
//         mentor = results[0] as ProfileMentor;
//         teachSchedule = results[1] as List<TeachingScheduleModel>;
//         connectMethods = results[2] as List<ConnectMethodModel>;

//         print(teachSchedule); // Will print the entire list with each item formatted as per toString()

//   // Print each individual TeachingScheduleModel in the teachSchedule list
//         for (var schedule in teachSchedule) {
//           print(schedule);  // Will print individual schedule objects with values
//         }

//         // Prepare events for the calendar based on teaching schedules
//         // _kEventSource = {
//         //   for (var item in teachSchedule)
//         //     item.dateStart: teachSchedule
//         //         .where(((schedule) =>
//         //             schedule.timeStart.compareTo(item.dateStart) >= 0 &&
//         //             schedule.timeEnd.compareTo(
//         //                     item.dateStart.add(const Duration(hours: 24))) <=
//         //                 0))
//         //         .toList()
                
//         // };

//         _kEventSource = {
//           for (var item in teachSchedule)
//             // Ensure we match only the date, not time
//             DateTime(item.dateStart.year, item.dateStart.month, item.dateStart.day): teachSchedule
//                 .where((schedule) =>
//                     schedule.timeStart.isBefore(item.dateStart.add(const Duration(hours: 24))) &&
//                     schedule.timeEnd.isAfter(item.dateStart))
//                 .toList(),
//         };

//         kEvents = LinkedHashMap<DateTime, List<TeachingScheduleModel>>(
//           equals: isSameDay,
//         )..addAll(_kEventSource);

//         _selectedEvents = _getEventsForDay(_selectedDay);
//       });
//     }).catchError((error) {
//       // Handle error if fetching fails
//       print('Error fetching data: $error');
//       setState(() {
//         _errorMessage = "Failed to fetch data.";
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Booking ${mentor!.name}"),
//           leading: IconButton(
//             icon: const Icon(FontAwesomeIcons.chevronLeft),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: SafeArea(
//             child: SingleChildScrollView(child: bookingStepperForm())));
//   }

//   onStepCancel() {
//     if (_index > 0) {
//       setState(() {
//         _index -= 1;
//       });
//     }
//   }

//   onStepContinue() {
//     if (formData[_index]["value"] == null) {
//       setState(() {
//         _errorMessage = formData[_index]["message"];
//       });
//       print(_errorMessage);
//       return;
//     }
//     setState(() {
//       _index += 1;
//       _errorMessage = "";
//     });
//   }

//   StepState stateStep(index) {
//     return _index > index
//         ? StepState.complete
//         : _index == index
//             ? StepState.editing
//             : StepState.disabled;
//   }

//   Widget bookingStepperForm() {
//     return Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_index == 0)
//               renderSelectCategory()
//             else if (_index == 1)
//               renderSelectTime()
//             else if (_index == 2)
//               renderSelectMethodConnect()
//             else if (_index == 3)
//               renderSubmitBooking(),
//             const SizedBox(
//               height: 20,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 if (_index != 0)
//                   CustomButton(
//                     label: "Previous",
//                     onPressed: onStepCancel,
//                     type: EButtonType.outline,
//                   ),
//                 const SizedBox(width: 10),
//                 if (_index < 3)
//                   CustomButton(label: "Next", onPressed: onStepContinue),
//                 if (_index == 3)
//                   CustomButton(
//                       label: "Booking",
//                       onPressed: () => {
//                             //TODO: submit booking here
//                             context.pop()
//                           }),
//               ],
//             ),
//           ],
//         ));
//   }

//   Widget renderSelectCategory() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       renderHeaderStep("Select a category"),
//       for (var item in [
//         ...mentor!.categories,
//         Category(
//             id: 'other', name: "Other", icon: "circleQuestion") // changed icon: FontAwesomeIcons.circleQuestion to icon: "circleQuestion"
//       ])
//         ListTile(
//           minLeadingWidth: 10,
//           visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
//           dense: true,
//           tileColor: Colors.transparent,
//           title: Text(item.name,
//               style: context.bodyMedium!
//                   .copyWith(color: Theme.of(context).colorScheme.onSurface)),
//           leading: Radio<String>(
//             value: item.id,
//             groupValue: formData[_index]["value"],
//             onChanged: (String? value) {
//               setState(() {
//                 formData[_index]["value"] = value;
//               });
//             },
//           ),
//         ),
//     ]);
//   }

//   Widget renderSelectTime() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         renderHeaderStep("Select day has dot"),
//         CalendarBooking(
//           selectedDay: _selectedDay,
//           onDaySelected: _onDaySelected,
//           getEventsForDay: _getEventsForDay,
//         ),
//         const SizedBox(height: 8.0),
//         for (var value in _selectedEvents)
//           Container(
//             margin: const EdgeInsets.symmetric(
//               horizontal: 12.0,
//               vertical: 4.0,
//             ),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: value.booked ? context.colors.error : Colors.green,
//               ),
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: ListTile(
//               selected: formData[_index]["value"] == value.id,
//               selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
//               onTap: () => {
//                 if (!value.booked)
//                   {
//                     setState(() {
//                       formData[_index]["value"] =
//                           formData[_index]["value"] == value.id
//                               ? null
//                               : value.id;
//                     })
//                   }
//               },
//               title: Text(
//                   '${DateFormat.Hm().format(value.timeStart)} - ${DateFormat.Hm().format(value.timeEnd)}',
//                   style: context.titleSmall),
//               subtitle: Text(value.booked ? "Occupied" : "Available",
//                   style: context.bodySmall!.copyWith(
//                       color:
//                           value.booked ? context.colors.error : Colors.green)),
//             ),
//           )
//       ],
//     );
//   }

//   Widget renderSelectMethodConnect() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         renderHeaderStep("Select method connect"),
//         DecoratedBox(
//             decoration: BoxDecoration(
//               //border of dropdown button
//               border: Border.all(
//                   color: Theme.of(context).colorScheme.outline, width: 1),
//               borderRadius:
//                   BorderRadius.circular(8), //border raiuds of dropdown button
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: DropdownButton<String>(
//                 focusColor: Colors.transparent,
//                 isExpanded: true,
//                 isDense: true,
//                 underline: Container(),
//                 value: formData[_index]["value"],
//                 hint: const Text("Select method to connect with mentor"),
//                 items: connectMethods.map((ConnectMethodModel value) {
//                   return DropdownMenuItem<String>(
//                     value: value.id,
//                     child: Text(value.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     formData[_index]["value"] = value;
//                   });
//                 },
//               ),
//             ))
//       ],
//     );
//   }

//   Widget renderSubmitBooking() {
//     var category = mentor!.categories
//         .firstWhere((element) => element.id == formData[0]["value"]);
//     var studySchedule = teachSchedule
//         .firstWhere((element) => element.id == formData[1]["value"]);
//     var method = connectMethods
//         .firstWhere((element) => element.id == formData[2]["value"]);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Your booking information: ", style: context.titleSmall),
//         const SizedBox(
//           height: 10,
//         ),
//         Text("Mentor:", style: context.titleSmall),
//         Text(mentor!.name),
//         const SizedBox(
//           height: 10,
//         ),
//         Text("Category:", style: context.titleSmall),
//         Text(category.name),
//         const SizedBox(
//           height: 10,
//         ),
//         Text("Study schedule:", style: context.titleSmall),
//         Text(
//             "${DateFormat.Hm().format(studySchedule.timeStart)} - ${DateFormat.Hm().format(studySchedule.timeEnd)}"),
//         const SizedBox(
//           height: 10,
//         ),
//         Text("Connect method", style: context.titleSmall),
//         Text(method.name),
//         const SizedBox(
//           height: 10,
//         ),
//       ],
//     );
//   }

//   Widget renderHeaderStep(label) {
//     return Column(
//       children: [
//         Text(label, style: context.titleSmall),
//         const SizedBox(
//           height: 10,
//         ),
//         if (_errorMessage.isNotEmpty)
//           Text(_errorMessage,
//               style: context.bodySmall!.copyWith(color: context.colors.error)),
//       ],
//     );
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         // _focusedDay = focusedDay;
//       });
//       _selectedEvents = _getEventsForDay(selectedDay);
//     }
//   }

//   // get teaching schedule by day
//   // List<TeachingScheduleModel> _getEventsForDay(DateTime day) {
//   //   var utc = DateTime.utc(day.year, day.month, day.day);
//   //   return kEvents[utc] ?? [];
//   // }

//   List<TeachingScheduleModel> _getEventsForDay(DateTime day) {
//   // Normalize the selected day to midnight (ignore the time)
//     var selectedDayNormalized = DateTime(day.year, day.month, day.day);
//     return kEvents[selectedDayNormalized] ?? [];
//   }
// }
