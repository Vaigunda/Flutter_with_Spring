import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mentor/navigation/router.dart';
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
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';


class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.profileId});
  final String profileId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ProfileMentor? mentor;
  int _index = 0;
  String _errorMessage = "";
  DateTime _focusedDay = DateTime.now(); // Add this
  bool isLoading = false; // Add this
  DateTime _selectedDay = DateTime.now();
  late List<ConnectMethodModel> connectMethods = [];
  late List<FixedTimeSlotModel> timeSlots = [];

  late String usertoken;
  late String userid;
  late String usertype;
  late String username;
  var provider;

  String? googleMeetLink;
  String? googleMeetError;

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
    usertype = provider.usertype;
    username = provider.name;

    ConnectMethodService connectMethodService = ConnectMethodService();

    Future.wait([
      ProfileMentorService.fetchMentorById(int.parse(widget.profileId), usertoken),
      connectMethodService.fetchConnectMethods(usertoken),
    ]).then((results) {
      setState(() {
        mentor = results[0] as ProfileMentor;
        connectMethods = results[1] as List<ConnectMethodModel>;

        // Log connectMethods to console
      for (var method in connectMethods) {
        print('ID: ${method.id}, Name: ${method.name}');
      }
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
        _errorMessage = '';
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

    if (connectMethods.isEmpty || mentor == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    //context.pop();
                    //context.go('${AppRoutes.payment}/${mentor!.free.price}');
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
                  _errorMessage = '';
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
                            _errorMessage = '';
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
                value: value.id, // Assuming value.id is a string like "1", "2", etc.
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                formData[_index]["value"] = value;
                _errorMessage = '';

                // Reset Google Meet specific fields if another method is selected
                if (value != '1') { // Replace '3' with the actual ID for "Google Meet"
                  googleMeetLink = null;
                  googleMeetError = null;
                }
              });
            },
          ),
        ),
      ),
      // Conditionally render the text field if the ID for "Google Meet" is selected
      if (formData[_index]["value"] == '2') // Replace '3' with the correct ID for "Google Meet"
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Enter Google Meet Link',
              border: const OutlineInputBorder(),
              errorText: googleMeetError,
            ),
            onChanged: (value) {
              setState(() {
                googleMeetLink = value;

                // Validate the Google Meet link
                if (!RegExp(r"^https://meet\.google\.com/[a-zA-Z0-9-]+$")
                    .hasMatch(value)) {
                  googleMeetError = 'Please enter a valid Google Meet link.';
                } else {
                  googleMeetError = null;
                }
              });
            },
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

    var selectedTimeSlot = formData[1]["value"];

    // Prepare the body for the POST request
    var requestBody = jsonEncode({
      "mentorId": mentor!.id,
      "userId": int.parse(userid),
      "timeSlotId": selectedTimeSlot.id,
      "date": DateFormat('yyyy-MM-dd').format(_selectedDay),
      "category": category.name,
      "connectMethod": method.name,
      "googleMeetLink": (googleMeetLink != null && googleMeetLink!.isNotEmpty) 
        ? googleMeetLink 
        : null,
    });

    if (usertype == 'User') {
      //context.go(AppRoutes.payment);
      String bookingData = Uri.encodeComponent(jsonEncode(requestBody));
    
      context.push('${AppRoutes.payment}/${mentor!.free.price}/$bookingData');
      /*try {
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
          String mentorName = mentor!.name;        
          var notifyBody = jsonEncode({
            "mentorId": mentor!.id,
            "recipientId": int.parse(userid),
            "title": "New Booking",
            "message": "$username booked $mentorName",
          });

          var notifyRes = await http.post(
            Uri.parse('http://localhost:8080/api/notify/createNotification'), // Replace with your actual API endpoint
            headers: {
              'Authorization': 'Bearer $usertoken',
              'Content-Type': 'application/json', // Ensure the API expects JSON
            },
            body: notifyBody,
          );
 
          if (notifyRes.statusCode == 200) {
            // Successfully booked
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment and Schedule booking successfully!'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
            context.go(AppRoutes.home);
          }
        } else if (response.statusCode == 400) {
          String output = response.body;
          // Something went wrong, handle the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(output),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
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
      }*/
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only user can book the Mentor.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
    }
     
  }

}