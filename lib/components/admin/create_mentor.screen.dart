// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For date formatting
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class CreateMentorScreen extends StatefulWidget {
//   @override
//   _CreateMentorScreenState createState() => _CreateMentorScreenState();
// }

// class _CreateMentorScreenState extends State<CreateMentorScreen> {
//   // Controllers for basic mentor details
//   TextEditingController nameController = TextEditingController();
//   TextEditingController avatarUrlController = TextEditingController();
//   TextEditingController bioController = TextEditingController();
//   TextEditingController rateController = TextEditingController();
//   TextEditingController freePriceController = TextEditingController();
//   TextEditingController freeUnitController = TextEditingController();
//   TextEditingController numberOfMentoreeController = TextEditingController();
//   TextEditingController startDateController = TextEditingController();
//   TextEditingController endDateController = TextEditingController();
//   TextEditingController timeStartController = TextEditingController();
//   TextEditingController timeEndController = TextEditingController();

//   // Controllers for dynamic sections (certificates, experiences, categories)
//   List<TextEditingController> certificateNameControllers = [];
//   List<TextEditingController> certificateProviderControllers = [];
//   List<TextEditingController> certificateDateControllers = [];

//   List<TextEditingController> experienceRoleControllers = [];
//   List<TextEditingController> experienceCompanyControllers = [];
//   List<TextEditingController> experienceDescriptionControllers = [];
//   List<TextEditingController> experienceStartDateControllers = [];
//   List<TextEditingController> experienceEndDateControllers = [];

//   List<TextEditingController> categoryControllers = [];

//   // Date pickers
//   DateTime? startDate;
//   DateTime? endDate;

//   bool isVerified = false;
//   bool isSubmitting = false;
//   bool isBooked = false; // Track booked status for teaching schedule

//   // API endpoint for creating a mentor
//   final String apiUrl = "http://localhost:8080/api/mentors"; // Replace with your actual API URL

//   // Method to handle form submission
//   Future<void> submitMentor() async {
//     if (isSubmitting) return; // Prevent duplicate submissions

//     setState(() {
//       isSubmitting = true;
//     });

//     DateTime parsedStartDate = DateTime.parse(startDateController.text);
//     DateTime parsedEndDate = DateTime.parse(endDateController.text);

    

//     // Combine the parsed start date with the time from the controllers
//     DateTime parsedTimeStart = DateTime.parse('${parsedStartDate.toIso8601String().split("T")[0]} ${timeStartController.text}:00');
//     DateTime parsedTimeEnd = DateTime.parse('${parsedEndDate.toIso8601String().split("T")[0]} ${timeEndController.text}:00');

//     String formattedTimeStart = parsedTimeStart.toIso8601String().split(".")[0];
//     String formattedTimeEnd = parsedTimeEnd.toIso8601String().split(".")[0];

//     // Prepare the mentor data to be sent
//     Map<String, dynamic> mentorData = {
//       "name": nameController.text,
//       "avatarUrl": avatarUrlController.text,
//       "bio": bioController.text,
//       "role": "Software Development Mentor", // Hardcoded for now
//       "freePrice": double.parse(freePriceController.text),
//       "freeUnit": freeUnitController.text,
//       "verified": isVerified,
//       "rate": double.parse(rateController.text),
//       "numberOfMentoree": int.parse(numberOfMentoreeController.text),
//       "certificates": List.generate(certificateNameControllers.length, (index) {
//         return {
//           "name": certificateNameControllers[index].text,
//           "provideBy": certificateProviderControllers[index].text,
//           "createDate": certificateDateControllers[index].text,
//           "imageUrl": "https://example.com/certificate${index + 1}.jpg" // Placeholder image
//         };
//       }),
//       "experiences": List.generate(experienceRoleControllers.length, (index) {
//         return {
//           "role": experienceRoleControllers[index].text,
//           "companyName": experienceCompanyControllers[index].text,
//           "startDate": experienceStartDateControllers[index].text,
//           "endDate": experienceEndDateControllers[index].text,
//           "description": experienceDescriptionControllers[index].text,
//         };
//       }),
//       "teachingSchedule": {
//         // Format the dates to the required format
//         "dateStart": "${parsedTimeStart.toIso8601String().split('T')[0]}T00:00:00",
//         "timeStart": formattedTimeStart,
//         "timeEnd": formattedTimeEnd,
//         "booked": isBooked,
//       },
//       "categories": List.generate(categoryControllers.length, (index) {
//         return {"name": categoryControllers[index].text};
//       })
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: json.encode(mentorData),
//       );

//       if (response.statusCode == 201) {
//         // Mentor created successfully
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: const Text("Success"),
//             content: const Text("Mentor created successfully!"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // Clear the form after success
//                   _clearForm();
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//       } else {
//         // Handle failure
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: const Text("Error"),
//             content: const Text("Failed to create mentor. Please try again."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       print(e); // Handle any errors
//       setState(() {
//         isSubmitting = false;
//       });
//     }
//   }

//   // Clear all form fields after submission
//   void _clearForm() {
//     nameController.clear();
//     avatarUrlController.clear();
//     bioController.clear();
//     rateController.clear();
//     freePriceController.clear();
//     freeUnitController.clear();
//     numberOfMentoreeController.clear();
//     startDateController.clear();
//     endDateController.clear();
//     timeStartController.clear();
//     timeEndController.clear();
//     certificateNameControllers.clear();
//     certificateProviderControllers.clear();
//     certificateDateControllers.clear();
//     experienceRoleControllers.clear();
//     experienceCompanyControllers.clear();
//     experienceDescriptionControllers.clear();
//     experienceStartDateControllers.clear();
//     experienceEndDateControllers.clear();
//     categoryControllers.clear();
//     setState(() {
//       isVerified = false;
//       isSubmitting = false;
//       isBooked = false; // Reset booked status
//     });
//   }

//   // Date picker for start and end dates
//   Future<void> selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (picked != null && picked != (isStartDate ? startDate : endDate)) {
//       setState(() {
//         if (isStartDate) {
//           startDate = picked;
//           startDateController.text = DateFormat('yyyy-MM-dd').format(startDate!);
//         } else {
//           endDate = picked;
//           endDateController.text = DateFormat('yyyy-MM-dd').format(endDate!);
//         }
//       });
//     }
//   }

//   // Add new certificate input fields
//   void _addCertificate() {
//     setState(() {
//       certificateNameControllers.add(TextEditingController());
//       certificateProviderControllers.add(TextEditingController());
//       certificateDateControllers.add(TextEditingController());
//     });
//   }

//   // Add new experience input fields
//   void _addExperience() {
//     setState(() {
//       experienceRoleControllers.add(TextEditingController());
//       experienceCompanyControllers.add(TextEditingController());
//       experienceDescriptionControllers.add(TextEditingController());
//       experienceStartDateControllers.add(TextEditingController());
//       experienceEndDateControllers.add(TextEditingController());
//     });
//   }

//   // Add new category input field
//   void _addCategory() {
//     setState(() {
//       categoryControllers.add(TextEditingController());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create Mentor"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Name Field
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Name"),
//               ),
//               // Avatar URL Field
//               TextField(
//                 controller: avatarUrlController,
//                 decoration: const InputDecoration(labelText: "Avatar URL"),
//               ),
//               // Bio Field
//               TextField(
//                 controller: bioController,
//                 decoration: const InputDecoration(labelText: "Bio"),
//                 maxLines: 3,
//               ),
//               // Rate Field
//               TextField(
//                 controller: rateController,
//                 decoration: const InputDecoration(labelText: "Rate (1-5)"),
//                 keyboardType: TextInputType.number,
//               ),
//               // Free Price Field
//               TextField(
//                 controller: freePriceController,
//                 decoration: const InputDecoration(labelText: "Free Price"),
//                 keyboardType: TextInputType.number,
//               ),
//               // Free Unit Field
//               TextField(
//                 controller: freeUnitController,
//                 decoration: const InputDecoration(labelText: "Free Unit (e.g. hour)"),
//               ),
//               // Number of Mentoree Field
//               TextField(
//                 controller: numberOfMentoreeController,
//                 decoration: const InputDecoration(labelText: "Number of Mentoree"),
//                 keyboardType: TextInputType.number,
//               ),
//               // Verified Checkbox
//               CheckboxListTile(
//                 title: const Text("Verified Mentor"),
//                 value: isVerified,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     isVerified = value!;
//                   });
//                 },
//               ),
//               // Categories Section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Categories"),
//                   ...categoryControllers.map((controller) {
//                     return TextField(
//                       controller: controller,
//                       decoration: const InputDecoration(labelText: "Category"),
//                     );
//                   }),
//                   ElevatedButton(
//                     onPressed: _addCategory,
//                     child: const Text("Add Category"),
//                   ),
//                 ],
//               ),
//               // Certificates Section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Certificates"),
//                   ...List.generate(certificateNameControllers.length, (index) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//                           controller: certificateNameControllers[index],
//                           decoration: const InputDecoration(labelText: "Certificate Name"),
//                         ),
//                         TextField(
//                           controller: certificateProviderControllers[index],
//                           decoration: const InputDecoration(labelText: "Certificate Provider"),
//                         ),
//                         TextField(
//                           controller: certificateDateControllers[index],
//                           decoration: const InputDecoration(labelText: "Certificate Date"),
//                         ),
//                       ],
//                     );
//                   }),
//                   ElevatedButton(
//                     onPressed: _addCertificate,
//                     child: const Text("Add Certificate"),
//                   ),
//                 ],
//               ),
//               // Experiences Section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Experiences"),
//                   ...List.generate(experienceRoleControllers.length, (index) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//                           controller: experienceRoleControllers[index],
//                           decoration: const InputDecoration(labelText: "Role"),
//                         ),
//                         TextField(
//                           controller: experienceCompanyControllers[index],
//                           decoration: const InputDecoration(labelText: "Company"),
//                         ),
//                         TextField(
//                           controller: experienceDescriptionControllers[index],
//                           decoration: const InputDecoration(labelText: "Description"),
//                         ),
//                         TextField(
//                           controller: experienceStartDateControllers[index],
//                           decoration: const InputDecoration(labelText: "Start Date"),
//                         ),
//                         TextField(
//                           controller: experienceEndDateControllers[index],
//                           decoration: const InputDecoration(labelText: "End Date"),
//                         ),
//                       ],
//                     );
//                   }),
//                   ElevatedButton(
//                     onPressed: _addExperience,
//                     child: const Text("Add Experience"),
//                   ),
//                 ],
//               ),
//               // Start Date Field
//               TextField(
//                 controller: startDateController,
//                 decoration: const InputDecoration(labelText: "Start Date (YYYY-MM-DD)"),
//                 readOnly: true,
//                 onTap: () {
//                   selectDate(context, true);
//                 },
//               ),
//               // End Date Field
//               TextField(
//                 controller: endDateController,
//                 decoration: const InputDecoration(labelText: "End Date (YYYY-MM-DD)"),
//                 readOnly: true,
//                 onTap: () {
//                   selectDate(context, false);
//                 },
//               ),
//               // Time Start Field
//               TextField(
//                 controller: timeStartController,
//                 decoration: const InputDecoration(labelText: "Start Time (HH:MM)"),
//               ),
//               // Time End Field
//               TextField(
//                 controller: timeEndController,
//                 decoration: const InputDecoration(labelText: "End Time (HH:MM)"),
//               ),
//               // Booked Status Checkbox
//               CheckboxListTile(
//                 title: const Text("Is this time booked?"),
//                 value: isBooked,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     isBooked = value!;
//                   });
//                 },
//               ),
//               // Submit Button
//               ElevatedButton(
//                 onPressed: submitMentor,
//                 child: Text(isSubmitting ? "Submitting..." : "Submit Mentor"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateMentorScreen extends StatefulWidget {
  @override
  _CreateMentorScreenState createState() => _CreateMentorScreenState();
}

class _CreateMentorScreenState extends State<CreateMentorScreen> {
  // Controllers for basic mentor details
  TextEditingController nameController = TextEditingController();
  TextEditingController avatarUrlController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController freePriceController = TextEditingController();
  TextEditingController freeUnitController = TextEditingController();
  TextEditingController numberOfMentoreeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController timeEndController = TextEditingController();

  // Controllers for dynamic sections (certificates, experiences, categories)
  List<TextEditingController> certificateNameControllers = [];
  List<TextEditingController> certificateProviderControllers = [];
  List<TextEditingController> certificateDateControllers = [];

  List<TextEditingController> experienceRoleControllers = [];
  List<TextEditingController> experienceCompanyControllers = [];
  List<TextEditingController> experienceDescriptionControllers = [];
  List<TextEditingController> experienceStartDateControllers = [];
  List<TextEditingController> experienceEndDateControllers = [];

  //teaching schedules
  List<TextEditingController> teachingScheduleStartDateControllers = [];
  List<TextEditingController> teachingScheduleEndDateControllers = [];
  List<TextEditingController> teachingScheduleStartTimeControllers = [];
  List<TextEditingController> teachingScheduleEndTimeControllers = [];
  List<bool> teachingScheduleIsBooked = [];

  List<TextEditingController> categoryControllers = [];

  // Date pickers
  DateTime? startDate;
  DateTime? endDate;

  bool isVerified = false;
  bool isSubmitting = false;
  bool isBooked = false; // Track booked status for teaching schedule

  // API endpoint for creating a mentor
  final String apiUrl = "http://localhost:8080/api/mentors"; // Replace with your actual API URL

   // Method to handle form submission
  Future<void> submitMentor() async {
    if (isSubmitting) return; // Prevent duplicate submissions

    setState(() {
      isSubmitting = true;
    });

    DateTime parsedStartDate = DateTime.parse(startDateController.text);
    DateTime parsedEndDate = DateTime.parse(endDateController.text);

    // Prepare the mentor data to be sent
    Map<String, dynamic> mentorData = {
      "name": nameController.text,
      "avatarUrl": avatarUrlController.text,
      "bio": bioController.text,
      "role": "Software Development Mentor", // Hardcoded for now
      "freePrice": double.parse(freePriceController.text),
      "freeUnit": freeUnitController.text,
      "verified": isVerified,
      "rate": double.parse(rateController.text),
      "numberOfMentoree": int.parse(numberOfMentoreeController.text),
      "certificates": List.generate(certificateNameControllers.length, (index) {
        return {
          "name": certificateNameControllers[index].text,
          "provideBy": certificateProviderControllers[index].text,
          "createDate": certificateDateControllers[index].text,
          "imageUrl": "https://example.com/certificate${index + 1}.jpg" // Placeholder image
        };
      }),
      "experiences": List.generate(experienceRoleControllers.length, (index) {
        return {
          "role": experienceRoleControllers[index].text,
          "companyName": experienceCompanyControllers[index].text,
          "startDate": experienceStartDateControllers[index].text,
          "endDate": experienceEndDateControllers[index].text,
          "description": experienceDescriptionControllers[index].text,
        };
      }),
      "teachingSchedule": List.generate(teachingScheduleStartDateControllers.length, (index) {
        DateTime parsedTimeStart = DateTime.parse('${teachingScheduleStartDateControllers[index].text} ${teachingScheduleStartTimeControllers[index].text}:00');
        DateTime parsedTimeEnd = DateTime.parse('${teachingScheduleEndDateControllers[index].text} ${teachingScheduleEndTimeControllers[index].text}:00');

        String formattedTimeStart = parsedTimeStart.toIso8601String().split(".")[0];
        String formattedTimeEnd = parsedTimeEnd.toIso8601String().split(".")[0];

        return {
          "dateStart": "${parsedTimeStart.toIso8601String().split('T')[0]}T00:00:00",
          "timeStart": formattedTimeStart,
          "timeEnd": formattedTimeEnd,
          "booked": teachingScheduleIsBooked[index],
        };
      }),
      "categories": List.generate(categoryControllers.length, (index) {
        return {"name": categoryControllers[index].text};
      })
    };

    // Log the request body
    print("Request Body: ${json.encode(mentorData)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(mentorData),
      );

      if (response.statusCode == 201) {
        // Mentor created successfully
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Mentor created successfully!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Clear the form after success
                  _clearForm();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        // Handle failure
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Failed to create mentor. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e); // Handle any errors
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // Clear all form fields after submission
  void _clearForm() {
    nameController.clear();
    avatarUrlController.clear();
    bioController.clear();
    rateController.clear();
    freePriceController.clear();
    freeUnitController.clear();
    numberOfMentoreeController.clear();
    startDateController.clear();
    endDateController.clear();
    timeStartController.clear();
    timeEndController.clear();
    certificateNameControllers.clear();
    certificateProviderControllers.clear();
    certificateDateControllers.clear();
    experienceRoleControllers.clear();
    experienceCompanyControllers.clear();
    experienceDescriptionControllers.clear();
    experienceStartDateControllers.clear();
    experienceEndDateControllers.clear();
    categoryControllers.clear();
    teachingScheduleStartDateControllers.clear();
    teachingScheduleEndDateControllers.clear();
    teachingScheduleStartTimeControllers.clear();
    teachingScheduleEndTimeControllers.clear();
    teachingScheduleIsBooked.clear();
    setState(() {
      isVerified = false;
      isSubmitting = false;
      isBooked = false; // Reset booked status
    });
  }

  // Date picker for start and end dates
  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          startDateController.text = DateFormat('yyyy-MM-dd').format(startDate!);
        } else {
          endDate = picked;
          endDateController.text = DateFormat('yyyy-MM-dd').format(endDate!);
        }
      });
    }
  }

  // Add new certificate input fields
  void _addCertificate() {
    setState(() {
      certificateNameControllers.add(TextEditingController());
      certificateProviderControllers.add(TextEditingController());
      certificateDateControllers.add(TextEditingController());
    });
  }

  // Add new experience input fields
  void _addExperience() {
    setState(() {
      experienceRoleControllers.add(TextEditingController());
      experienceCompanyControllers.add(TextEditingController());
      experienceDescriptionControllers.add(TextEditingController());
      experienceStartDateControllers.add(TextEditingController());
      experienceEndDateControllers.add(TextEditingController());
    });
  }

   // Add new teaching schedule input fields
  void _addTeachingSchedule() {
    setState(() {
      teachingScheduleStartDateControllers.add(TextEditingController());
      teachingScheduleEndDateControllers.add(TextEditingController());
      teachingScheduleStartTimeControllers.add(TextEditingController());
      teachingScheduleEndTimeControllers.add(TextEditingController());
      teachingScheduleIsBooked.add(false); // Default value for "booked" status
    });
  }

  // Add new category input field
  void _addCategory() {
    setState(() {
      categoryControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Mentor"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Name Field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              // Avatar URL Field
              TextField(
                controller: avatarUrlController,
                decoration: const InputDecoration(labelText: "Avatar URL"),
              ),
              // Bio Field
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),
              // Rate Field
              TextField(
                controller: rateController,
                decoration: const InputDecoration(labelText: "Rate (1-5)"),
                keyboardType: TextInputType.number,
              ),
              // Free Price Field
              TextField(
                controller: freePriceController,
                decoration: const InputDecoration(labelText: "Free Price"),
                keyboardType: TextInputType.number,
              ),
              // Free Unit Field
              TextField(
                controller: freeUnitController,
                decoration: const InputDecoration(labelText: "Free Unit (e.g. hour)"),
              ),
              // Number of Mentoree Field
              TextField(
                controller: numberOfMentoreeController,
                decoration: const InputDecoration(labelText: "Number of Mentoree"),
                keyboardType: TextInputType.number,
              ),
              // Verified Checkbox
              CheckboxListTile(
                title: const Text("Verified Mentor"),
                value: isVerified,
                onChanged: (bool? value) {
                  setState(() {
                    isVerified = value!;
                  });
                },
              ),
              // Categories Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Categories"),
                  ...categoryControllers.map((controller) {
                    return TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: "Category"),
                    );
                  }),
                  ElevatedButton(
                    onPressed: _addCategory,
                    child: const Text("Add Category"),
                  ),
                ],
              ),
              // Certificates Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Certificates"),
                  ...List.generate(certificateNameControllers.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: certificateNameControllers[index],
                          decoration: const InputDecoration(labelText: "Certificate Name"),
                        ),
                        TextField(
                          controller: certificateProviderControllers[index],
                          decoration: const InputDecoration(labelText: "Certificate Provider"),
                        ),
                        TextField(
                          controller: certificateDateControllers[index],
                          decoration: const InputDecoration(labelText: "Certificate Date"),
                        ),
                      ],
                    );
                  }),
                  ElevatedButton(
                    onPressed: _addCertificate,
                    child: const Text("Add Certificate"),
                  ),
                ],
              ),
              // Experiences Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Experiences"),
                  ...List.generate(experienceRoleControllers.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: experienceRoleControllers[index],
                          decoration: const InputDecoration(labelText: "Role"),
                        ),
                        TextField(
                          controller: experienceCompanyControllers[index],
                          decoration: const InputDecoration(labelText: "Company"),
                        ),
                        TextField(
                          controller: experienceDescriptionControllers[index],
                          decoration: const InputDecoration(labelText: "Description"),
                        ),
                        TextField(
                          controller: experienceStartDateControllers[index],
                          decoration: const InputDecoration(labelText: "Start Date"),
                        ),
                        TextField(
                          controller: experienceEndDateControllers[index],
                          decoration: const InputDecoration(labelText: "End Date"),
                        ),
                      ],
                    );
                  }),
                  ElevatedButton(
                    onPressed: _addExperience,
                    child: const Text("Add Experience"),
                  ),
                ],
              ),
              // Add Teaching Schedules Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Teaching Schedules"),
                  ...List.generate(teachingScheduleStartDateControllers.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: teachingScheduleStartDateControllers[index],
                          decoration: const InputDecoration(labelText: "Start Date (YYYY-MM-DD)"),
                        ),
                        TextField(
                          controller: teachingScheduleEndDateControllers[index],
                          decoration: const InputDecoration(labelText: "End Date (YYYY-MM-DD)"),
                        ),
                        TextField(
                          controller: teachingScheduleStartTimeControllers[index],
                          decoration: const InputDecoration(labelText: "Start Time (HH:MM)"),
                        ),
                        TextField(
                          controller: teachingScheduleEndTimeControllers[index],
                          decoration: const InputDecoration(labelText: "End Time (HH:MM)"),
                        ),
                        CheckboxListTile(
                          title: const Text("Is this time booked?"),
                          value: teachingScheduleIsBooked[index],
                          onChanged: (bool? value) {
                            setState(() {
                              teachingScheduleIsBooked[index] = value!;
                            });
                          },
                        ),
                      ],
                    );
                  }),
                  ElevatedButton(
                    onPressed: _addTeachingSchedule,
                    child: const Text("Add Teaching Schedule"),
                  ),
                ],
              ),
              // Submit Button
              ElevatedButton(
                onPressed: submitMentor,
                child: Text(isSubmitting ? "Submitting..." : "Submit Mentor"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

