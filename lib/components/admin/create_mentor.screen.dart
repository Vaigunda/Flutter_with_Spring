import 'package:flutter/material.dart';
// For date formatting
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:mentor/shared/models/category.model.dart';
import 'package:mentor/shared/services/categories.service.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

import 'package:multi_select_flutter/multi_select_flutter.dart';


import '../../shared/utils/validator.dart';
import '../../shared/views/button.dart';
import '../../shared/views/input_field.dart';

class CreateMentorScreen extends StatefulWidget {
  @override
  _CreateMentorScreenState createState() => _CreateMentorScreenState();
}

class _CreateMentorScreenState extends State<CreateMentorScreen> {
  // Controllers for basic mentor details
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController avatarUrlController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController roleController = TextEditingController();
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

  //Time Slots
  List<TextEditingController> timeSlotsTimeStartControllers = [];
  List<TextEditingController> timeSlotsTimeEndControllers = [];

  List<TextEditingController> categoryControllers = [];
  final validator = Validator();

  bool isVerified = false;
  bool isSubmitting = false;

  late String usertoken;
  var provider;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isFormSubmitted = false;
  bool isCertSubmitted = false;
  bool isExpSubmitted = false;
  bool isTimeSubmitted = false;



  List<CategoryModel> categories = [];
  List<CategoryModel> selectedCategories = [];
  List<CategoryModel> displayedCategories = [];

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    // Fetch categories from the service
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categoriesService = CategoriesService();
      final fetchedCategories =
          await categoriesService.fetchCategories(usertoken);
      setState(() {
        categories = fetchedCategories;
        categories.add(CategoryModel(
            id: "0", name: "Others", icon: "")); // Add "Others" manually
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load categories'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // API endpoint for creating a mentor
  final String apiUrl =
      "http://localhost:8080/api/mentors"; // Replace with your actual API URL

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Format to "HH:mm:ss"
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final timeString = "$hour:$minute:00"; // Adding seconds as 00
      controller.text = timeString;
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      controller.text =
          "${picked.toLocal()}".split(' ')[0]; // Format it to "YYYY-MM-DD"
    }
  }

  // Show dialog to enter custom category if "Others" is selected
  void _showOthersCategoryField() {
    TextEditingController othersCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Custom Category"),
          content: TextField(
            controller: othersCategoryController,
            decoration: const InputDecoration(
              labelText: "Custom Category Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (othersCategoryController.text.isNotEmpty) {
                    // Add the custom category to both selected and displayed categories
                    final customCategory = CategoryModel(
                      id: "0",
                      name: othersCategoryController.text,
                      icon: "",
                    );
                    selectedCategories.add(customCategory);
                    displayedCategories = List.from(selectedCategories);
                  }

                  Navigator.of(context).pop(); // Close the dialog
                });
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Method to handle form submission
  Future<void> submitMentor() async {
    if (isSubmitting) return; // Prevent duplicate submissions

    

    setState(() {
      isSubmitting = true;
    });

    List<CategoryModel> filteredCategories = selectedCategories
        .where((category) => category.name != "Others")
        .toList();

    // Prepare the mentor data to be sent
    Map<String, dynamic> mentorData = {
      "name": nameController.text,
      "email": emailController.text,
      "avatarUrl": avatarUrlController.text,
      "bio": bioController.text,
      "role": roleController.text,
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
          "imageUrl":
              "https://example.com/certificate${index + 1}.jpg", // Placeholder image
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
      "timeSlots": List.generate(timeSlotsTimeStartControllers.length, (index) {
        return {
          "timeStart": timeSlotsTimeStartControllers[index].text,
          "timeEnd": timeSlotsTimeEndControllers[index].text,
        };
      }),
      "categories": filteredCategories.map((category) {
        return {"name": category.name};
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $usertoken',
          "Content-Type": "application/json",
        },
        body: json.encode(mentorData),
      );

      if (response.statusCode == 201) {
        // Mentor created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mentor created successfully!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        // Clear the form after success
        _clearForm();
        // Redirect to admin page
        // context.go(AppRoutes.adminPage);
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create mentor. Please try again.'),
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
    } finally {
      setState(() {
        isSubmitting = false; // Reset submission state
      });
    }
  }

  // Clear all form fields after submission
  void _clearForm() {
    nameController.clear();
    emailController.clear();
    avatarUrlController.clear();
    bioController.clear();
    roleController.clear();
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
    timeSlotsTimeStartControllers.clear();
    timeSlotsTimeEndControllers.clear();
    setState(() {
      isVerified = false;
      isSubmitting = false;
    });
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
      timeSlotsTimeStartControllers.add(TextEditingController());
      timeSlotsTimeEndControllers
          .add(TextEditingController()); // Default value for "booked" status
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
      appBar: AppBar(title: const Text("Create Mentor Form",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;

          if (isWideScreen) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildFormFields(),
                      ),
                    ),
                    // Image
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "M",
                                  style: TextStyle(
                                    fontSize: 62,
                                    fontFamily: "Lobster",
                                    fontWeight: FontWeight.w400, // Weight: 400
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: 62 / 48,
                                  ),
                                ),
                                Text(
                                  "entorboosters",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: "Epilogue",
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: 42 / 32,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    ".",
                                    style: TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: "Epilogue",
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      height: 42 / 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  'assets/images/admin.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildFormFields(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Welcome Text Section
          const Row(
            children: [
              Column(
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: "Lobster",
                      fontWeight: FontWeight.w400,
                      height: 62 / 48,
                    ),
                  ),
                  Text(
                    'Create Mentors!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Input Fields with Validation
          InputField(
            controller: nameController,
            labelText: "Name",
            prefixIcon: const Icon(Icons.person),
            validator: (value) => value == null || value.isEmpty
                ? 'Name is required'
                : null,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: emailController,
            labelText: "Email Id",
            prefixIcon: const Icon(Icons.email),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          InputField(
            controller: avatarUrlController,
            labelText: "Avatar URL",
            prefixIcon: const Icon(Icons.image),
            validator: (value) => value == null || value.isEmpty
                ? 'Avatar URL is required'
                : null,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: bioController,
            labelText: "Bio",
            maxLines: 3,
            prefixIcon: const Icon(Icons.info),
            validator: (value) => value == null || value.isEmpty
                ? 'Bio is required'
                : null,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: roleController,
            labelText: "Role",
            prefixIcon: const Icon(Icons.work),
            validator: (value) => value == null || value.isEmpty
                ? 'Role is required'
                : null,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: rateController,
            labelText: "Rate (1-5)",
            prefixIcon: const Icon(Icons.star),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Rate is required';
              }
              final rate = int.tryParse(value);
              if (rate == null || rate < 1 || rate > 5) {
                return 'Enter a rate between 1 and 5';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          InputField(
            controller: freePriceController,
            labelText: "Free Price",
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money),
            validator: (value) => value == null || value.isEmpty
                ? 'Free price is required'
                : null,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: freeUnitController,
            labelText: "Free Unit (e.g. hour)",
            prefixIcon: const Icon(Icons.timer),
            validator: (value) => value == null || value.isEmpty
                ? 'Free unit is required'
                : null,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: numberOfMentoreeController,
            labelText: "Number of Mentees",
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.group),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Number of mentees is required';
              }
              if (int.tryParse(value) == null) {
                return 'Enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CheckboxListTile on the left
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.dark
                      ?  Colors.transparent
                      : const Color.fromARGB(255, 249, 245, 252),
                ),
                child: CheckboxListTile(
                  title: const Text("Verified Mentor"),
                  value: isVerified,
                  onChanged: (bool? value) {
                    setState(() {
                      isVerified = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(width: 20), // Add spacing between the two widgets

            // MultiSelectDialogField on the right
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MultiSelectDialogField<CategoryModel>(
                    items: categories
                        .map((category) =>
                            MultiSelectItem(category, category.name))
                        .toList(),
                    title: const Text("Select Categories"),
                    selectedColor: Colors.blue,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    buttonText: Text(
                      "Select Categories",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (values) {
                      setState(() {
                        selectedCategories = values;

                        if (selectedCategories
                            .any((category) => category.name == "Others")) {
                          // Remove "Others" from the selected categories temporarily
                          selectedCategories.removeWhere(
                              (category) => category.name == "Others");

                          // Prevent chipDisplay from showing categories yet
                          displayedCategories = [];

                          // Show a dialog for the custom category
                          _showOthersCategoryField();
                        } else {
                          // If "Others" was not selected, immediately update displayedCategories
                          displayedCategories = List.from(selectedCategories);
                        }
                      });
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      // Use the new displayedCategories variable instead of selectedCategories
                      items: displayedCategories
                          .map((category) =>
                              MultiSelectItem(category, category.name))
                          .toList(),
                      onTap: (value) {
                        setState(() {
                          selectedCategories.remove(value);
                          displayedCategories.remove(value);
                        });
                      },
                      textStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (isFormSubmitted && selectedCategories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select at least one category.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),

        // Certificates Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(certificateNameControllers.length, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
                    controller: certificateNameControllers[index],
                    labelText: "Certificate Name",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
                  ),
                  if (isCertSubmitted &&
                      certificateNameControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Certificate Name is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputField(
                    controller: certificateProviderControllers[index],
                    labelText: "Certificate Provider",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
                  ),
                  if (isCertSubmitted &&
                      certificateProviderControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Certificate Provider is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller: certificateDateControllers[index],
                     decoration:
                         const InputDecoration(labelText: "Certificate Date YYYY-MM-DD",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                     onTap: () => _selectDate(
                         context, certificateDateControllers[index]),
                     readOnly: true,
                  ),
                  if (isCertSubmitted &&
                      certificateDateControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Certificate Date is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              );
            }),
            CustomButton(
                minWidth: MediaQuery.of(context).size.width,
                borderRadius: 4,
                onPressed: _addCertificate,
                label: "Add Certificate"),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        // Experiences Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(experienceRoleControllers.length, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
                    controller: experienceRoleControllers[index],
                    labelText: "Role",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
                  ),
                  if (isExpSubmitted && experienceRoleControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Role is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputField(
                    controller: experienceCompanyControllers[index],
                    labelText: "Company",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
                  ),
                  if (isExpSubmitted && experienceCompanyControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Company is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),

                  InputField(
                    controller: experienceDescriptionControllers[index],
                    labelText: "Description",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
                  ),
                  if (isExpSubmitted && experienceDescriptionControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Description is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: experienceStartDateControllers[index],
                    decoration: const InputDecoration(
                        labelText: "Start Date YYYY-MM-DD",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    onTap: () => _selectDate(
                        context, experienceStartDateControllers[index]),
                    readOnly: true,
                  ),
                  if (isExpSubmitted && experienceStartDateControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Start Date is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller: experienceEndDateControllers[index],
                    decoration:
                        const InputDecoration(labelText: "End Date YYYY-MM-DD",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    onTap: () => _selectDate(
                        context, experienceEndDateControllers[index]),
                    readOnly: true,
                  ),
                  if (isExpSubmitted && experienceEndDateControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'End Date is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              );
            }),
            
            CustomButton(
                minWidth: MediaQuery.of(context).size.width,
                borderRadius: 4,
                onPressed: _addExperience,
                label: "Add Experience"),
           
          ],
        ),
        const SizedBox(
          height: 20,
        ),

        // Add Teaching Schedules Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(timeSlotsTimeStartControllers.length, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: timeSlotsTimeStartControllers[index],
                    decoration: const InputDecoration(
                        labelText: "Start Time (HH:mm:ss)",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                    onTap: () => _selectTime(
                        context, timeSlotsTimeStartControllers[index]),
                    readOnly: true,
                  ),
                  if (isTimeSubmitted && timeSlotsTimeStartControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Start Time is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: timeSlotsTimeEndControllers[index],
                    decoration:
                        const InputDecoration(labelText: "End Time (HH:mm:ss)",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                    onTap: () => _selectTime(
                        context, timeSlotsTimeEndControllers[index]),
                    readOnly: true,
                  ),
                  if (isTimeSubmitted && timeSlotsTimeEndControllers[index].text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'End Time is required.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            }),
              const SizedBox(
                    height: 20,
                  ),
            CustomButton(
                minWidth: MediaQuery.of(context).size.width,
                borderRadius: 4,
                onPressed: _addTeachingSchedule,
                label: "Add TimeSlots"),
          ],
        ),
        const SizedBox(
          height: 20,
        ),


        // Submit Button
        CustomButton(
          minWidth: MediaQuery.of(context).size.width,
          borderRadius: 4,
          onPressed: () {
            // First, validate the form using the form key
            if (_formKey.currentState!.validate()) {
              // Category validation
              setState(() {
                isFormSubmitted = true;
              });

              if (selectedCategories.isEmpty) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select at least one category.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Certificate validation
              setState(() {
                isCertSubmitted = true;
              });

              // Check if certificates have been added
              if (certificateNameControllers.isEmpty) {
                // Show a message if no certificates have been added
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add at least one certificate.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              bool isCertValid = true;
              for (int i = 0; i < certificateNameControllers.length; i++) {
                if (certificateNameControllers[i].text.trim().isEmpty ||
                    certificateProviderControllers[i].text.trim().isEmpty ||
                    certificateDateControllers[i].text.trim().isEmpty) {
                  isCertValid = false;
                  break;
                }
              }

              if (!isCertValid) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All certificate fields are required.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Experience validation
              setState(() {
                isExpSubmitted = true;
              });

              // Check if experiences have been added
              if (experienceRoleControllers.isEmpty) {
                // Show a message if no experiences have been added
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add at least one experience.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              bool isExpValid = true;
              for (int i = 0; i < experienceRoleControllers.length; i++) {
                if (experienceRoleControllers[i].text.trim().isEmpty ||
                    experienceCompanyControllers[i].text.trim().isEmpty ||
                    experienceDescriptionControllers[i].text.trim().isEmpty ||
                    experienceStartDateControllers[i].text.trim().isEmpty ||
                    experienceEndDateControllers[i].text.trim().isEmpty) {
                  isExpValid = false;
                  break;
                }
              }

              if (!isExpValid) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All experience fields (Role, Company, Description, Start Date, End Date) are required.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Time validation
              setState(() {
                isTimeSubmitted = true;
              });

              // Check if teaching schedules have been added
              if (timeSlotsTimeStartControllers.isEmpty) {
                // Show a message if no teaching schedules have been added
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add at least one time slot.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              bool isTimeValid = true;
              for (int i = 0; i < timeSlotsTimeStartControllers.length; i++) {
                if (timeSlotsTimeStartControllers[i].text.trim().isEmpty ||
                    timeSlotsTimeEndControllers[i].text.trim().isEmpty) {
                  isTimeValid = false;
                  break;
                }
              }

              if (!isTimeValid) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All time slot fields (Start Time, End Time) are required.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Finally, call the submit function if all validations pass
              submitMentor();
            } else {
              // If form is not valid, return early
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all required fields.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          label: isSubmitting ? "Submitting..." : "Submit Mentor",
        ),
        const SizedBox(height: 40),
        ],
      ),
    );
  }


  // Widget _buildFormFields() {
  //   return Column(
  //     children: [
  //       const Row(
  //         children: [
  //           Column(
  //             children: [
  //               Text(
  //                 'Welcome',
  //                 style: TextStyle(
  //                   fontSize: 40,
  //                   fontFamily: "Lobster",
  //                   fontWeight: FontWeight.w400,
  //                   height: 62 / 48,
  //                 ),
  //               ),
  //               Text(
  //                 'Create Mentors!',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 20,
  //       ),
  //       InputField(
  //         controller: nameController,
  //         labelText: "Name",
  //         prefixIcon: const Icon(Icons.person),
  //         validator: (value) => value == null || value.isEmpty
  //             ? 'Name is required'
  //             : null,
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: emailController,
  //         labelText: "Email Id",
  //         prefixIcon: const Icon(Icons.email),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: avatarUrlController,
  //         labelText: "Avatar URL",
  //         prefixIcon: const Icon(Icons.image),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: bioController,
  //         maxLines: 3,
  //         labelText: "Bio",
  //         prefixIcon: const Icon(Icons.info),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: roleController,
  //         labelText: "Role",
  //         prefixIcon: const Icon(Icons.work),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: rateController,
  //         labelText: "Rate (1-5)",
  //         prefixIcon: const Icon(Icons.star),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: freePriceController,
  //         keyboardType: TextInputType.number,
  //         labelText: "Free Price",
  //         prefixIcon: const Icon(Icons.attach_money),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: freeUnitController,
  //         labelText: "Free Unit (e.g. hour)",
  //         prefixIcon: const Icon(Icons.timer),
  //       ),
  //       const SizedBox(height: 20),
  //       InputField(
  //         controller: numberOfMentoreeController,
  //         keyboardType: TextInputType.number,
  //         labelText: "Number of Mentees",
  //         prefixIcon: const Icon(Icons.group),
  //       ),
  //       const SizedBox(height: 20),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // CheckboxListTile on the left
  //           Expanded(
  //             flex: 2,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 border: Border.all(
  //                   width: 1,
  //                 ),
  //                 borderRadius: BorderRadius.circular(10),
  //                 color: Theme.of(context).brightness == Brightness.dark
  //                     ?  Colors.transparent
  //                     : const Color.fromARGB(255, 249, 245, 252),
  //               ),
  //               child: CheckboxListTile(
  //                 title: const Text("Verified Mentor"),
  //                 value: isVerified,
  //                 onChanged: (bool? value) {
  //                   setState(() {
  //                     isVerified = value!;
  //                   });
  //                 },
  //               ),
  //             ),
  //           ),

  //           const SizedBox(width: 20), // Add spacing between the two widgets

  //           // MultiSelectDialogField on the right
  //           Expanded(
  //             flex: 3,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 MultiSelectDialogField<CategoryModel>(
  //                   items: categories
  //                       .map((category) =>
  //                           MultiSelectItem(category, category.name))
  //                       .toList(),
  //                   title: const Text("Select Categories"),
  //                   selectedColor: Colors.blue,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(
  //                       width: 1,
  //                     ),
  //                   ),
  //                   buttonIcon: Icon(
  //                     Icons.arrow_drop_down,
  //                     color: Theme.of(context).brightness == Brightness.dark
  //                         ? Colors.white
  //                         : Colors.black,
  //                   ),
  //                   buttonText: Text(
  //                     "Select Categories",
  //                     style: TextStyle(
  //                       color: Theme.of(context).brightness == Brightness.dark
  //                           ? Colors.white
  //                           : Colors.black,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                   onConfirm: (values) {
  //                     setState(() {
  //                       selectedCategories = values;

  //                       if (selectedCategories
  //                           .any((category) => category.name == "Others")) {
  //                         // Remove "Others" from the selected categories temporarily
  //                         selectedCategories.removeWhere(
  //                             (category) => category.name == "Others");

  //                         // Prevent chipDisplay from showing categories yet
  //                         displayedCategories = [];

  //                         // Show a dialog for the custom category
  //                         _showOthersCategoryField();
  //                       } else {
  //                         // If "Others" was not selected, immediately update displayedCategories
  //                         displayedCategories = List.from(selectedCategories);
  //                       }
  //                     });
  //                   },
  //                   chipDisplay: MultiSelectChipDisplay(
  //                     // Use the new displayedCategories variable instead of selectedCategories
  //                     items: displayedCategories
  //                         .map((category) =>
  //                             MultiSelectItem(category, category.name))
  //                         .toList(),
  //                     onTap: (value) {
  //                       setState(() {
  //                         selectedCategories.remove(value);
  //                         displayedCategories.remove(value);
  //                       });
  //                     },
  //                     textStyle: TextStyle(
  //                       color: Theme.of(context).brightness == Brightness.dark
  //                           ? Colors.white
  //                           : Colors.black,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 20,
  //       ),

  //       // Certificates Section
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ...List.generate(certificateNameControllers.length, (index) {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 InputField(
  //                   controller: certificateNameControllers[index],
  //                   labelText: "Certificate Name",
  //                   prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 InputField(
  //                   controller: certificateProviderControllers[index],
  //                   labelText: "Certificate Provider",
  //                   prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),

  //                 InputField(
  //                   controller: certificateDateControllers[index],
  //                   labelText: "Certificate Date YYYY-MM-DD",
  //                   prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 )
  //                 // TextField(
  //                 //   controller: certificateNameControllers[index],
  //                 //   decoration: const InputDecoration(
  //                 //       labelText: ""),
  //                 // ),
  //                 // TextField(
  //                 //   controller: certificateProviderControllers[index],
  //                 //   decoration: const InputDecoration(
  //                 //       labelText: "Certificate Provider"),
  //                 // ),
  //                 // TextField(
  //                 //   controller: certificateDateControllers[index],
  //                 //   decoration: const InputDecoration(
  //                 //       labelText: "Certificate Date YYYY-MM-DD"),
  //                 //   onTap: () => _selectDate(
  //                 //       context, certificateDateControllers[index]),
  //                 //   readOnly: true,
  //                 // ),
  //               ],
  //             );
  //           }),
  //           CustomButton(
  //               minWidth: MediaQuery.of(context).size.width,
  //               borderRadius: 4,
  //               onPressed: _addCertificate,
  //               label: "Add Certificate"),

  //           // ElevatedButton(
  //           //   onPressed: _addCertificate,
  //           //   child: const Text("Add Certificate"),
  //           // ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 20,
  //       ),
  //       // Experiences Section
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ...List.generate(experienceRoleControllers.length, (index) {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 InputField(
  //                   controller: experienceRoleControllers[index],
  //                   labelText: "Role",
  //                   prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 InputField(
  //                   controller: experienceCompanyControllers[index],
  //                   labelText: "Company",
  //                   prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),

  //                 InputField(
  //                   controller: experienceDescriptionControllers[index],
  //                   labelText: "Description",
  //                   prefixIcon: const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 ),
  //                 // InkWell(
  //                 //   onTap: () => _selectDate(
  //                 //       context, experienceStartDateControllers[index]),
  //                 //   child: InputField(
  //                 //     controller: experienceStartDateControllers[index],
  //                 //     labelText: "Start Date YYYY-MM-DD",
  //                 //     prefixIcon:
  //                 //         const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 //     readOnly: true,
  //                 //   ),
  //                 // ),
  //                 // InkWell(
  //                 //    onTap: () => _selectDate(
  //                 //       context, experienceEndDateControllers[index]),
  //                 //   child: InputField(
  //                 //     controller: experienceEndDateControllers[index],
  //                 //     labelText: "End Date YYYY-MM-DD",
  //                 //     prefixIcon:
  //                 //         const Icon(HugeIcons.strokeRoundedMessageAdd02),
  //                 //     readOnly: true,
  //                 //   ),
  //                 // ),
  //                 // TextField(
  //                 //   controller: experienceRoleControllers[index],
  //                 //   decoration: const InputDecoration(labelText: "Role"),
  //                 // ),
  //                 // TextField(
  //                 //   controller: experienceCompanyControllers[index],
  //                 //   decoration: const InputDecoration(labelText: "Company"),
  //                 // ),
  //                 // TextField(
  //                 //   controller: experienceDescriptionControllers[index],
  //                 //   decoration: const InputDecoration(labelText: "Description"),
  //                 //),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 TextField(
  //                   controller: experienceStartDateControllers[index],
  //                   decoration: const InputDecoration(
  //                       labelText: "Start Date YYYY-MM-DD",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
  //                   onTap: () => _selectDate(
  //                       context, experienceStartDateControllers[index]),
  //                   readOnly: true,
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),

  //                 TextField(
  //                   controller: experienceEndDateControllers[index],
  //                   decoration:
  //                       const InputDecoration(labelText: "End Date YYYY-MM-DD",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
  //                   onTap: () => _selectDate(
  //                       context, experienceEndDateControllers[index]),
  //                   readOnly: true,
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 )
  //               ],
  //             );
  //           }),
            
  //           CustomButton(
  //               minWidth: MediaQuery.of(context).size.width,
  //               borderRadius: 4,
  //               onPressed: _addExperience,
  //               label: "Add Experience"),
  //           // ElevatedButton(
  //           //   onPressed: _addExperience,
  //           //   child: const Text("Add Experience"),
  //           // ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 20,
  //       ),

  //       // Add Teaching Schedules Section
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ...List.generate(timeSlotsTimeStartControllers.length, (index) {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 TextField(
  //                   controller: timeSlotsTimeStartControllers[index],
  //                   decoration: const InputDecoration(
  //                       labelText: "Start Time (HH:mm:ss)",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
  //                   onTap: () => _selectTime(
  //                       context, timeSlotsTimeStartControllers[index]),
  //                   readOnly: true,
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 TextField(
  //                   controller: timeSlotsTimeEndControllers[index],
  //                   decoration:
  //                       const InputDecoration(labelText: "End Time (HH:mm:ss)",border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
  //                   onTap: () => _selectTime(
  //                       context, timeSlotsTimeEndControllers[index]),
  //                   readOnly: true,
  //                 ),
  //               ],
  //             );
  //           }),
  //             const SizedBox(
  //                   height: 20,
  //                 ),
  //           CustomButton(
  //               minWidth: MediaQuery.of(context).size.width,
  //               borderRadius: 4,
  //               onPressed: _addTeachingSchedule,
  //               label: "Add TimeSlots"),

  //           // ElevatedButton(
  //           //   onPressed: _addTeachingSchedule,
  //           //   child: const Text("Add TimeSlots"),
  //           // ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 20,
  //       ),
  //       CustomButton(
  //           minWidth: MediaQuery.of(context).size.width,
  //           borderRadius: 4,
  //           onPressed: submitMentor,
  //           label: isSubmitting ? "Submitting..." : "Submit Mentor"),
  //       // Submit Button
  //       // ElevatedButton(
  //       //   onPressed: submitMentor,
  //       //   child: Text(isSubmitting ? "Submitting..." : "Submit Mentor"),
  //       // ),
  //       const SizedBox(
  //         height: 40,
  //       ),
  //       // if(Get.width >800)
  //       // const Expanded(
  //       //   child: Text("kjnsdkncs"),
  //       // )
  //     ],
  //   );
  // }
}