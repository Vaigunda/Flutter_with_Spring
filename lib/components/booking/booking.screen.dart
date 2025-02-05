import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mentor/constants/ui.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/models/connect_method.model.dart';
import 'package:mentor/shared/models/fixed_time_slot.model.dart';
import 'package:mentor/shared/models/profile_mentor.model.dart';
import 'package:mentor/shared/services/token.service.dart';
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
      ProfileMentorService.fetchMentorById(
          int.parse(widget.profileId), usertoken),
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
          widget.profileId, _selectedDay, usertoken);
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
                  borderRadius: 10,
                ),
              const SizedBox(width: 10),
              if (_index < 3)
                CustomButton(
                  label: "Next",
                  onPressed: onStepContinue,
                  borderRadius: 10,
                ),
              if (_index == 3)
                CustomButton(
                  label: "Booking",
                  borderRadius: 10,
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
    var isWeb = MediaQuery.of(context).size.width > 800;
    return Column(
      children: [
        isWeb
            ? Card(
                elevation: 4,
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Learn Your Way',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 2,
                                fontFamily: "Lobster",
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Learn what you want, How you want with our Mentors',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  wordSpacing: 4,
                                  letterSpacing: 2),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Find the right mentor to guide you on your journey and gain valuable insights to grow.\n Choose a time that fits your schedule and start learning from the best.\n Take the next step toward success with personalized mentorship',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  wordSpacing: 4,
                                  letterSpacing: 1),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Image.asset(
                                'assets/images/booking.jpeg',
                                height: 240,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Card(
                color: Theme.of(context).cardColor,
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Learn Your Way',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2,
                              fontFamily: "Lobster",
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Learn what you want, How you want with our Mentoors',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                wordSpacing: 4,
                                letterSpacing: 2),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Image.asset(
                              'assets/images/booking.jpeg',
                              height: 240,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        Card(
            child: Container(
          height: 40,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.pinkAccent, Colors.orangeAccent],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Distributes space evenly
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.find_replace, size: isWeb ? 18 : 15),
                      const SizedBox(width: 5),
                      Text(
                        'Find your Ideal Mentor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 16 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3), // Fixed spacing for mobile/web
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online, size: isWeb ? 18 : 15),
                      const SizedBox(width: 5),
                      Text(
                        'Book Sessions Instantly',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 16 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grade_outlined, size: isWeb ? 18 : 15),
                      const SizedBox(width: 5),
                      Text(
                        'Grow With Expert Guidance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 16 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 1,
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: renderHeaderStep("Select a category"),
                )),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10.0, left: 10, right: 10),
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mentor!.categories.length + 1,
                      itemBuilder: (context, index) {
                        final item = index < mentor!.categories.length
                            ? mentor!.categories[index]
                            : Category(
                                id: 'other',
                                name: "Other",
                                icon: "circleQuestion");

                        return InkWell(
                          onTap: () {
                            setState(() {
                              formData[_index]["value"] = item.id;
                              _errorMessage = '';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: formData[_index]["value"] == item.id
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.transparent,
                            ),
                            child: ListTile(
                              leading: const Icon(
                                  Icons.connect_without_contact_sharp),
                              minLeadingWidth: 10,
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              dense: true,
                              title: Text(
                                item.name,
                                style: context.bodyMedium!.copyWith(
                                  color: formData[_index]["value"] == item.id
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              trailing: Radio<String>(
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
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
    var isWeb = MediaQuery.of(context).size.width > 800;
    return Column(
      children: [
        isWeb
            ? Card(
                elevation: 4,
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Let\'s Connect & Learn together',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 2,
                                fontFamily: "Lobster",
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Seamless Mentor Sessions,  Anytime, Anywhere',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  wordSpacing: 4,
                                  letterSpacing: 2),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Connect with expert mentors instantly, schedule flexible \n sessions, gain valuable insights, and accelerate your growth \n from anywhere, anytime with ease.',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  wordSpacing: 4,
                                  letterSpacing: 1),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Image.asset(
                                'assets/images/videocall.jpg',
                                height: 280,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
            : Card(
                color: Theme.of(context).cardColor,
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Let\'s Connect & Learn together',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2,
                              fontFamily: "Lobster",
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Seamless Mentor Sessions,  Anytime, Anywhere',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                wordSpacing: 4,
                                letterSpacing: 2),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Image.asset(
                              'assets/images/videocall.jpg',
                              height: 240,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
        Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                renderHeaderStep("Select method connect"),
                Card(
                  elevation: 3,
                  color: Theme.of(context).colorScheme.onTertiary,
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
                          value: value
                              .id, // Assuming value.id is a string like "1", "2", etc.
                          child: Text(value.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          formData[_index]["value"] = value;
                          _errorMessage = '';

                          // Reset Google Meet specific fields if another method is selected
                          if (value != '1') {
                            // Replace '3' with the actual ID for "Google Meet"
                            googleMeetLink = null;
                            googleMeetError = null;
                          }
                        });
                      },
                    ),
                  ),
                ),
                // Conditionally render the text field if the ID for "Google Meet" is selected
                if (formData[_index]["value"] ==
                    '2') // Replace '3' with the correct ID for "Google Meet"
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
                          if (!RegExp(
                                  r"^https://meet\.google\.com/[a-zA-Z0-9-]+$")
                              .hasMatch(value)) {
                            googleMeetError =
                                'Please enter a valid Google Meet link.';
                          } else {
                            googleMeetError = null;
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget renderSelectMethodConnect() {
  //   var isWeb = MediaQuery.of(context).size.width > 800;
  //   return Column(
  //     children: [
  //       Card(
  //         color: Theme.of(context).cardColor,
  //         elevation: 4,
  //         child: isWeb
  //             ? Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   const Padding(
  //                     padding: EdgeInsets.symmetric(horizontal: 20),
  //                     child: Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             'Let\'s Connect & Learn together',
  //                             style: TextStyle(
  //                               fontSize: 42,
  //                               fontWeight: FontWeight.w400,
  //                               letterSpacing: 2,
  //                               fontFamily: "Lobster",
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           Text(
  //                             'Seamless Mentor Sessions,  Anytime, Anywhere',
  //                             style: TextStyle(
  //                                 fontSize: 20,
  //                                 fontWeight: FontWeight.bold,
  //                                 wordSpacing: 4,
  //                                 letterSpacing: 2),
  //                           ),
  //                           SizedBox(
  //                             height: 20,
  //                           ),
  //                           Text(
  //                             'Connect with expert mentors instantly, schedule flexible \n sessions, gain valuable insights, and accelerate your growth \n from anywhere, anytime with ease.',
  //                             style: TextStyle(
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.w100,
  //                                 wordSpacing: 4,
  //                                 letterSpacing: 2),
  //                             textAlign: TextAlign.center,
  //                           ),
  //                           SizedBox(
  //                             height: 20,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Column(
  //                       children: [
  //                         Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Card(
  //                             child: Image.asset(
  //                               'assets/images/videocall.jpg',
  //                               height: 280,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               )
  // : Column(
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Text(
  //               'Let\'s Connect & Learn together',
  //               style: TextStyle(
  //                 fontSize: 38,
  //                 fontWeight: FontWeight.w400,
  //                 letterSpacing: 2,
  //                 fontFamily: "Lobster",
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),
  //             Text(
  //               'Seamless Mentor Sessions,  Anytime, Anywhere',
  //               style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   wordSpacing: 2,
  //                   letterSpacing: 2),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //           ],
  //         ),
  //       ),
  //       Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Container(
  //               height: 280,
  //               decoration: const BoxDecoration(
  //                 borderRadius:
  //                     BorderRadius.all(Radius.circular(10)),
  //                 image: DecorationImage(
  //                   image:
  //                       AssetImage('assets/images/videocall.jpg'),
  //                   fit: BoxFit.contain,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   ),
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       Card(
  //         elevation: 2,
  //         color: Theme.of(context).cardColor,
  //         child: Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               renderHeaderStep("Select method connect"),
  //               Card(
  //                 elevation: 3,
  //                 color: Theme.of(context).colorScheme.onTertiary,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(10),
  //                   child: DropdownButton<String>(
  //                     focusColor: Colors.transparent,
  //                     isExpanded: true,
  //                     isDense: true,
  //                     underline: Container(),
  //                     value: formData[_index]["value"],
  //                     hint: const Text("Select method to connect with mentor"),
  //                     items: connectMethods.map((ConnectMethodModel value) {
  //                       return DropdownMenuItem<String>(
  //                         value: value
  //                             .id, // Assuming value.id is a string like "1", "2", etc.
  //                         child: Text(value.name),
  //                       );
  //                     }).toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         formData[_index]["value"] = value;
  //                         _errorMessage = '';

  //                         // Reset Google Meet specific fields if another method is selected
  //                         if (value != '1') {
  //                           // Replace '3' with the actual ID for "Google Meet"
  //                           googleMeetLink = null;
  //                           googleMeetError = null;
  //                         }
  //                       });
  //                     },
  //                   ),
  //                 ),
  //               ),
  //               // Conditionally render the text field if the ID for "Google Meet" is selected
  //               if (formData[_index]["value"] ==
  //                   '2') // Replace '3' with the correct ID for "Google Meet"
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 10),
  //                   child: TextField(
  //                     decoration: InputDecoration(
  //                       labelText: 'Enter Google Meet Link',
  //                       border: const OutlineInputBorder(),
  //                       errorText: googleMeetError,
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         googleMeetLink = value;

  //                         // Validate the Google Meet link
  //                         if (!RegExp(
  //                                 r"^https://meet\.google\.com/[a-zA-Z0-9-]+$")
  //                             .hasMatch(value)) {
  //                           googleMeetError =
  //                               'Please enter a valid Google Meet link.';
  //                         } else {
  //                           googleMeetError = null;
  //                         }
  //                       });
  //                     },
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget renderSubmitBooking() {
    var isWeb = MediaQuery.of(context).size.width > 800;
    // Get selected category and connect method
    var category = mentor!.categories.firstWhere(
        (element) => element.id == formData[0]["value"],
        orElse: () => Category(id: 'default', name: 'Default', icon: 'circle'));

    var method = connectMethods.firstWhere(
        (element) => element.id == formData[2]["value"],
        orElse: () => const ConnectMethodModel(id: 'default', name: 'Default'));

    var selectedTimeSlot =
        formData[1]["value"]; // This will hold the selected time slot object

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Booking Details",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 120 : 16),
          child: HoverableContainer(
            context: context,
            hover: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  child: Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Image.asset(
                      'assets/images/booking.jpg',
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoBox(
                  Icons.person,
                  "Mentor",
                  mentor!.name,
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.blue.shade50)!, // Ensure non-null
                  context,
                ),
                _buildInfoBox(
                  Icons.category,
                  "Category",
                  category.name,
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.green.shade50)!, // Ensure non-null
                  context,
                ),
                _buildInfoBox(
                  Icons.timer,
                  "Time Slot",
                  "${selectedTimeSlot.timeStart} - ${selectedTimeSlot.timeEnd}",
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.orange.shade50)!, // Ensure non-null
                  context,
                ),
                _buildInfoBox(
                  Icons.video_call,
                  "Connect Method",
                  method.name,
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.purple.shade50)!, // Ensure non-null
                  context,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value, Color bgColor,
      BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withAlpha((0.2 * 255).round())
                  : Colors.grey.withAlpha((0.2 * 255).round()),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, size: 28, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 14,
                    ))
              ]))
        ]));

    //  Column(
    //     children: [
    //       Card(
    //         color: Theme.of(context).cardColor,
    //         elevation: 4,
    //         child: isWeb
    //             ? Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                 children: [
    //                   const Padding(
    //                     padding: EdgeInsets.symmetric(horizontal: 20),
    //                     child: Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           Text(
    //                             'Let\'s Connect & Learn together',
    //                             style: TextStyle(
    //                               fontSize: 42,
    //                               fontWeight: FontWeight.w400,
    //                               letterSpacing: 2,
    //                               fontFamily: "Lobster",
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             height: 10,
    //                           ),
    //                           Text(
    //                             'Seamless Mentor Sessions,  Anytime, Anywhere',
    //                             style: TextStyle(
    //                                 fontSize: 20,
    //                                 fontWeight: FontWeight.bold,
    //                                 wordSpacing: 4,
    //                                 letterSpacing: 2),
    //                           ),
    //                           SizedBox(
    //                             height: 20,
    //                           ),
    //                           Text(
    //                             'Connect with expert mentors instantly, schedule flexible \n sessions, gain valuable insights, and accelerate your growth \n from anywhere, anytime with ease.',
    //                             style: TextStyle(
    //                                 fontSize: 14,
    //                                 fontWeight: FontWeight.w100,
    //                                 wordSpacing: 4,
    //                                 letterSpacing: 2),
    //                             textAlign: TextAlign.center,
    //                           ),
    //                           SizedBox(
    //                             height: 20,
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   Expanded(
    //                     child: Column(
    //                       children: [
    //                         Padding(
    //                           padding: const EdgeInsets.all(8.0),
    //                           child: Card(
    //                             child: Image.asset(
    //                               'assets/images/videocall.jpg',
    //                               height: 280,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               )
    //             : Column(
    //                 children: [
    //                   const Padding(
    //                     padding: EdgeInsets.symmetric(horizontal: 20),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.center,
    //                       children: [
    //                         Text(
    //                           'Let\'s Connect & Learn together',
    //                           style: TextStyle(
    //                             fontSize: 38,
    //                             fontWeight: FontWeight.w400,
    //                             letterSpacing: 2,
    //                             fontFamily: "Lobster",
    //                           ),
    //                           textAlign: TextAlign.center,
    //                         ),
    //                         SizedBox(
    //                           height: 10,
    //                         ),
    //                         Text(
    //                           'Seamless Mentor Sessions,  Anytime, Anywhere',
    //                           style: TextStyle(
    //                               fontSize: 18,
    //                               fontWeight: FontWeight.bold,
    //                               wordSpacing: 2,
    //                               letterSpacing: 2),
    //                           textAlign: TextAlign.center,
    //                         ),
    //                         SizedBox(
    //                           height: 20,
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   Column(
    //                     children: [
    //                       Padding(
    //                         padding: const EdgeInsets.all(8.0),
    //                         child: Container(
    //                           height: 280,
    //                           decoration: const BoxDecoration(
    //                             borderRadius:
    //                                 BorderRadius.all(Radius.circular(10)),
    //                             image: DecorationImage(
    //                               image:
    //                                   AssetImage('assets/images/videocall.jpg'),
    //                               fit: BoxFit.contain,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //       ),
    //       const SizedBox(
    //         height: 10,
    //       ),
    //       Card(
    //         elevation: 2,
    //         color: Theme.of(context).cardColor,
    //         child: Padding(
    //           padding: const EdgeInsets.all(10.0),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               renderHeaderStep("Select method connect"),
    //               Card(
    //                 elevation: 3,
    //                 color: Theme.of(context).colorScheme.onTertiary,
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(10),
    //                   child: DropdownButton<String>(
    //                     focusColor: Colors.transparent,
    //                     isExpanded: true,
    //                     isDense: true,
    //                     underline: Container(),
    //                     value: formData[_index]["value"],
    //                     hint: const Text("Select method to connect with mentor"),
    //                     items: connectMethods.map((ConnectMethodModel value) {
    //                       return DropdownMenuItem<String>(
    //                         value: value
    //                             .id, // Assuming value.id is a string like "1", "2", etc.
    //                         child: Text(value.name),
    //                       );
    //                     }).toList(),
    //                     onChanged: (value) {
    //                       setState(() {
    //                         formData[_index]["value"] = value;
    //                         _errorMessage = '';

    //                         // Reset Google Meet specific fields if another method is selected
    //                         if (value != '1') {
    //                           // Replace '3' with the actual ID for "Google Meet"
    //                           googleMeetLink = null;
    //                           googleMeetError = null;
    //                         }
    //                       });
    //                     },
    //                   ),
    //                 ),
    //               ),
    //               // Conditionally render the text field if the ID for "Google Meet" is selected
    //               if (formData[_index]["value"] ==
    //                   '2') // Replace '3' with the correct ID for "Google Meet"
    //                 Padding(
    //                   padding: const EdgeInsets.only(top: 10),
    //                   child: TextField(
    //                     decoration: InputDecoration(
    //                       labelText: 'Enter Google Meet Link',
    //                       border: const OutlineInputBorder(),
    //                       errorText: googleMeetError,
    //                     ),
    //                     onChanged: (value) {
    //                       setState(() {
    //                         googleMeetLink = value;

    //                         // Validate the Google Meet link
    //                         if (!RegExp(
    //                                 r"^https://meet\.google\.com/[a-zA-Z0-9-]+$")
    //                             .hasMatch(value)) {
    //                           googleMeetError =
    //                               'Please enter a valid Google Meet link.';
    //                         } else {
    //                           googleMeetError = null;
    //                         }
    //                       });
    //                     },
    //                   ),
    //                 ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
  }

  Widget renderHeaderStep(String label) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

      // Check if token has expired
      bool isExpired = JwtDecoder.isExpired(usertoken);
      if (isExpired) {
        final tokenService = TokenService();
        tokenService.checkToken(usertoken, context);
      } else {
        context.push(
            '${AppRoutes.payment}/${mentor!.free.price}/${mentor!.id}/${mentor!.name}/$bookingData');
      }
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
