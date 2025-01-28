import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:mentor/shared/models/all_mentors.model.dart';
import 'package:intl/intl.dart';
import 'package:mentor/shared/services/categories.service.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../shared/services/token.service.dart';

class EditMentorScreen extends StatefulWidget {
  final AllMentors mentor;

  const EditMentorScreen({required this.mentor});

  @override
  _EditMentorScreenState createState() => _EditMentorScreenState();
}

class _EditMentorScreenState extends State<EditMentorScreen> {
  late AllMentors mentorData;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController roleController;
  late TextEditingController bioController;
  late TextEditingController avatarUrlController;
  late TextEditingController numberOfMentoreesController;
  late TextEditingController rateController;
  late TextEditingController freePriceController;
  late TextEditingController freeUnitController;

  List<TextEditingController> categoryControllers = [];
  List<TextEditingController> certificateNameControllers = [];
  List<TextEditingController> certificateProvidedByControllers = [];
  List<TextEditingController> certificateImageUrlControllers = [];
  List<TextEditingController> certificateDateControllers = [];
  
  List<TextEditingController> timeSlotsTimeStartControllers = [];
  List<TextEditingController> timeSlotsTimeEndControllers = [];

  List<TextEditingController> experienceRoleControllers = [];
  List<TextEditingController> experienceCompanyControllers = [];
  List<TextEditingController> experienceStartDateControllers = [];
  List<TextEditingController> experienceEndDateControllers = [];
  List<TextEditingController> experienceDescriptionControllers = [];

  late String usertoken;
  var provider;

  List<Category> allCategories = []; // List to hold all fetched categories

  @override
  void initState() {
    super.initState();
    mentorData = widget.mentor;
    
    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    _fetchCategories(); // Fetch categories on initialization

    nameController = TextEditingController(text: mentorData.name);
    emailController = TextEditingController(text: mentorData.email);
    roleController = TextEditingController(text: mentorData.role);
    bioController = TextEditingController(text: mentorData.bio);
    avatarUrlController = TextEditingController(text: mentorData.avatarUrl);
    numberOfMentoreesController = TextEditingController(text: mentorData.numberOfMentoree.toString());
    rateController = TextEditingController(text: mentorData.rate.toString());
    freePriceController = TextEditingController(text: mentorData.free.price.toString());
    freeUnitController = TextEditingController(text: mentorData.free.unit.name);
    
    categoryControllers = mentorData.categories
      .map((category) => TextEditingController(text: category.name))
      .toList();

    // Initialize controllers for certificates
    certificateNameControllers = mentorData.certificates
      .map((cert) => TextEditingController(text: cert.name))
      .toList();
    certificateProvidedByControllers = mentorData.certificates
      .map((cert) => TextEditingController(text: cert.provideBy))
      .toList();
    certificateDateControllers = mentorData.certificates
      .map((cert) => TextEditingController(
          text: cert.createDate != null
              ? DateFormat('yyyy-MM-dd').format(cert.createDate!)
              : ''))
      .toList();
    certificateImageUrlControllers = mentorData.certificates
      .map((cert) => TextEditingController(text: cert.imageUrl))
      .toList();

    // Initialize controllers for teaching schedules
  

    timeSlotsTimeStartControllers = mentorData.timeSlots
        .map((schedule) => TextEditingController(text: schedule.timeStart))
        .toList();

    timeSlotsTimeEndControllers = mentorData.timeSlots
        .map((schedule) => TextEditingController(text: schedule.timeEnd))
        .toList();



    // Initialize controllers for experiences
    experienceRoleControllers = mentorData.experiences
        .map((experience) => TextEditingController(text: experience.role))
        .toList();
    experienceCompanyControllers = mentorData.experiences
        .map((experience) => TextEditingController(text: experience.companyName))
        .toList();
    experienceStartDateControllers = mentorData.experiences
        .map((experience) => TextEditingController(
            text: experience.startDate != null
                ? DateFormat('yyyy-MM-dd').format(experience.startDate!)
                : ''))
        .toList();
    experienceEndDateControllers = mentorData.experiences
        .map((experience) => TextEditingController(
            text: experience.endDate != null
                ? DateFormat('yyyy-MM-dd').format(experience.endDate!)
                : ''))
        .toList();
    experienceDescriptionControllers = mentorData.experiences
        .map((experience) => TextEditingController(text: experience.description))
        .toList();     
    }
   

  
  @override
  void dispose() {
    // Dispose of all TextEditingController instances

    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    bioController.dispose();
    avatarUrlController.dispose();
    numberOfMentoreesController.dispose();
    rateController.dispose();
    freePriceController.dispose();
    freeUnitController.dispose();

    for (var controller in [
      ...categoryControllers,
      ...certificateNameControllers,
      ...certificateProvidedByControllers,
      ...certificateImageUrlControllers,
      ...certificateDateControllers,
      ...timeSlotsTimeStartControllers,
      ...timeSlotsTimeEndControllers,
      ...experienceRoleControllers,
      ...experienceCompanyControllers,
      ...experienceStartDateControllers,
      ...experienceEndDateControllers,
      ...experienceDescriptionControllers,
    ]) {
      controller.dispose();
    }
    
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final categoriesService = CategoriesService();
    final fetchedCategories =
        await categoriesService.fetchCategories(usertoken);

    setState(() {
      allCategories = fetchedCategories.map((categoryModel) => Category(
        id: categoryModel.id,
        name: categoryModel.name,
        icon: categoryModel.icon,
      )).toList();
    });
  }

  void _addCategories(List<Category> selectedCategories) {
    setState(() {
      for (var category in selectedCategories) {
        if (!mentorData.categories.any((c) => c.id == category.id)) {
          mentorData.categories.add(category);
        }
      }
    });
  }

  void _removeCategory(Category category) {
    setState(() {
      mentorData.categories.removeWhere((c) => c.id == category.id);
    });
  }

  // Method to handle saving updated mentor data
  Future<void> saveMentor() async {

    // Name validation
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if name is empty
    }

    // Email validation
    if (!(emailController.text.contains('@') && emailController.text.contains('.'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email format.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if email is invalid
    }

    // Role validation
    if (roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Role cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if role is empty
    }

    // Bio validation
    if (bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bio cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if bio is empty
    }

    // Avatar URL validation
  if (avatarUrlController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar URL cannot be empty.'),
        backgroundColor: Colors.red,
      ),
    );
    return; // Exit if Avatar URL is empty
  }

    // Number of Mentees validation
    int? numberOfMentees = int.tryParse(numberOfMentoreesController.text);
    if (numberOfMentees == null || numberOfMentees < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of mentees.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if number of mentees is invalid
    }

    // Rate validation
    if (rateController.text.isEmpty || double.tryParse(rateController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid rate input. Please enter a valid number.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if rate is invalid
    }

    // Free Price validation
    if (freePriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free Price cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if free price is empty
    }

    // Free Unit validation
    if (freeUnitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free Unit cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if free unit is empty
    }



    // Check if at least one category is selected
    if (mentorData.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one category.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the method if no category is selected
    }

    // Check if at least one experience is provided and all experience fields are filled
    if (mentorData.experiences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one experience.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the method if no experience is selected
    }

    for (var experience in mentorData.experiences) {
      if (experience.role.isEmpty ||
          experience.companyName.isEmpty ||
          experience.startDate == null ||
          experience.endDate == null ||
          (experience.description?.isEmpty ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields in experience must be filled.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the method if any experience field is empty
      }
    }

    // Check if at least one certificate exists and all certificate fields are filled
    if (mentorData.certificates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one certificate.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the method if no certificate is added
    }

    // Validate each certificate's fields (all fields should be filled)
    for (int i = 0; i < mentorData.certificates.length; i++) {
      final certificate = mentorData.certificates[i];

      if (certificate.name.isEmpty || certificate.provideBy.isEmpty ||
          certificate.createDate == null || certificate.imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields for certificate ${i + 1}.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the method if any field is empty
      }
    }

    // Check if at least one time slot is provided
    if (mentorData.timeSlots.isEmpty || timeSlotsTimeStartControllers.isEmpty || timeSlotsTimeEndControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one time slot.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the method if no time slot is selected
    }

    // Check if all time slots have both time start and time end filled
    for (int i = 0; i < timeSlotsTimeStartControllers.length; i++) {
      if (timeSlotsTimeStartControllers[i].text.isEmpty || timeSlotsTimeEndControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields in the time slots must be filled.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the method if any time slot has empty fields
      }
    }
    

    final updatedData = {
      'id': mentorData.id,
      'name': mentorData.name,
      'email': mentorData.email,
      'avatarUrl': mentorData.avatarUrl,
      'bio': mentorData.bio,
      'role': mentorData.role,
      'freePrice': mentorData.free.price.toDouble(),
      'freeUnit': mentorData.free.unit.name,
      'verified': mentorData.verified,
      'rate': mentorData.rate,
      'numberOfMentoree': mentorData.numberOfMentoree,
      'certificates': mentorData.certificates.map((certificate) {
        return {
          'id': certificate.id,
          'name': certificate.name,
          'provideBy': certificate.provideBy,
          'createDate': certificate.createDate != null
              ? DateFormat('yyyy-MM-dd').format(certificate.createDate!)
              : null,  // Ensure createDate is not null before formatting
          'imageUrl': certificate.imageUrl,
        };
      }).toList(),
      'experiences': mentorData.experiences.map((experience) {
        return {
          'id': experience.id,
          'role': experience.role,
          'companyName': experience.companyName,
          'startDate': experience.startDate != null
              ? DateFormat('yyyy-MM-dd').format(experience.startDate!)
              : null,  // Ensure startDate is not null before formatting
          'endDate': experience.endDate != null
              ? DateFormat('yyyy-MM-dd').format(experience.endDate!)
              : null,  // Ensure endDate is not null before formatting
          'description': experience.description,
        };
      }).toList(),
      'timeSlots': mentorData.timeSlots.map((schedule) {
        return {
          'id': schedule.id,
          'timeStart': schedule.timeStart,
          'timeEnd': schedule.timeEnd,
        };  
      }).toList(),
      'categories': mentorData.categories.map((category) {
        return {
          'id': category.id,
          'name': category.name,
        };
      }).toList(),
    };

    // Check if token has expired
    bool isExpired = JwtDecoder.isExpired(usertoken);
    if (isExpired) {
      final tokenService = TokenService();
      tokenService.checkToken(usertoken, context);
    } else {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/mentors/${mentorData.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $usertoken',
          },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mentor updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop the current screen and return 'true' to notify the admin page to reload
        Navigator.pop(context, true);  // This triggers the reload in the admin page
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update mentor.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }


  void updateField(String field, dynamic value, {int? index}) {
    setState(() {
      switch (field) {
        case 'name':
          mentorData = mentorData.copyWith(name: value);
          break;
        case 'email':
          mentorData = mentorData.copyWith(email: value);
          break;
        case 'role':
          mentorData = mentorData.copyWith(role: value);
          break;
        case 'avatarUrl':
          mentorData = mentorData.copyWith(avatarUrl: value);
          break;
        case 'bio':
          mentorData = mentorData.copyWith(bio: value);
          break;
        case 'rate':
          mentorData = mentorData.copyWith(rate: double.tryParse(value) ?? mentorData.rate);
          break;
        case 'numberOfMentoree':
          mentorData = mentorData.copyWith(numberOfMentoree: value is num ? value.toInt() : mentorData.numberOfMentoree);
          break;
        case 'freePrice':
          mentorData = mentorData.copyWith(free: mentorData.free.copyWith(price: (double.tryParse(value) ?? mentorData.free.price).toInt()));
          break;
        case 'freeUnit':
          mentorData = mentorData.copyWith(free: mentorData.free.copyWith(unit: value));
          break;
        case 'categories':
          if (index != null) {
            mentorData.categories[index] = mentorData.categories[index].copyWith(name: value);
          }
          break;
        case 'timeSlots':
          if (index != null) {
            mentorData.timeSlots[index] = mentorData.timeSlots[index].copyWith(
              timeStart: timeSlotsTimeStartControllers[index].text,
              timeEnd: timeSlotsTimeEndControllers[index].text,
            );
          }
          break;
        case 'verified':
          mentorData = mentorData.copyWith(verified: value);
          break;
        case 'experiences':
          if (index != null) {
            final updatedExperience = mentorData.experiences[index].copyWith(
              role: experienceRoleControllers[index].text,
              companyName: experienceCompanyControllers[index].text,
              startDate: DateTime.tryParse(experienceStartDateControllers[index].text) ?? mentorData.experiences[index].startDate,
              endDate: DateTime.tryParse(experienceEndDateControllers[index].text) ?? mentorData.experiences[index].endDate,
              description: experienceDescriptionControllers[index].text,
            );
            mentorData.experiences[index] = updatedExperience;
          }
          break;
        case 'certificates':
          if (index != null) {
            mentorData.certificates[index] = mentorData.certificates[index].copyWith(
              name: value['name'] ?? mentorData.certificates[index].name,
              provideBy: value['provideBy'] ?? mentorData.certificates[index].provideBy,
              createDate: value['createDate'] != null
                  ? DateTime.tryParse(value['createDate'])
                  : mentorData.certificates[index].createDate,
              imageUrl: value['imageUrl'] ?? mentorData.certificates[index].imageUrl,
            );
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mentor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) => updateField('name', value),
            ),
            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => updateField('email', value),
            ),
            // Role
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
              onChanged: (value) => updateField('role', value),
            ),

            // Bio
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              onChanged: (value) => updateField('bio', value),
            ),

            // Avatar URL
            TextField(
              controller: avatarUrlController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
              onChanged: (value) => updateField('avatarUrl', value),
            ),

            // Number of Mentorees
            TextField(
              controller: numberOfMentoreesController,
              decoration: const InputDecoration(labelText: 'Number of Mentees'),
              onChanged: (value) => updateField('numberOfMentoree', int.tryParse(value)),
            ),

            // Rate
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Rate'),
              onChanged: (value) => updateField('rate', value),
            ),

            // Free Price
            TextField(
              controller: freePriceController,
              decoration: const InputDecoration(labelText: 'Free Price'),
              onChanged: (value) => updateField('freePrice', value),
            ),

            // Free Unit
            TextField(
              controller: freeUnitController,
              decoration: const InputDecoration(labelText: 'Free Unit'),
              onChanged: (value) => updateField('freeUnit', value),
            ),

            // Verified
            Row(
              children: [
                const Text('Verified'),
                Checkbox(
                  value: mentorData.verified,
                  onChanged: (value) => updateField('verified', value),
                ),
              ],
            ),
            // Categories section
            const SizedBox(height: 16),
            const Text('Categories:'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: mentorData.categories.map((category) {
                return Chip(
                  label: Text(category.name),
                  onDeleted: () => _removeCategory(category),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final selectedCategories = await showDialog<List<Category>>(
                  context: context,
                  builder: (_) => MultiSelectDialog<Category>(
                    items: allCategories
                        .map((category) => MultiSelectItem<Category>(
                            category, category.name))
                        .toList(),
                    initialValue: mentorData.categories,
                    title: const Text("Select Categories"),
                    selectedColor: Colors.blue,
                    itemsTextStyle: const TextStyle(
                      color: Colors.blue, // Uniform color for all dropdown items
                    ),
                  ),
                );

                if (selectedCategories != null) {
                  _addCategories(selectedCategories);
                }
              },
              child: const Text('Add Categories'),
            ),
            // Experiences section
            // Experiences section
            const SizedBox(height: 16),
            const Text('Experiences:'),
            Column(
              children: [
                ...mentorData.experiences.asMap().entries.map((entry) {
                  final index = entry.key;
                  final experience = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Optional: Add vertical spacing
                    child: Container(
                      color: Colors.transparent, // Remove background color
                      padding: const EdgeInsets.all(8.0), // Optional: Add padding inside
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role
                          TextField(
                            controller: experienceRoleControllers[index],
                            decoration: const InputDecoration(labelText: 'Role'),
                            onChanged: (value) => updateField('experiences', {
                              'role': value,
                              'companyName': experience.companyName,
                              'startDate': experience.startDate,
                              'endDate': experience.endDate,
                              'description': experience.description,
                            }, index: index),
                          ),
                          // Company Name
                          TextField(
                            controller: experienceCompanyControllers[index],
                            decoration: const InputDecoration(labelText: 'Company Name'),
                            onChanged: (value) => updateField('experiences', {
                              'role': experience.role,
                              'companyName': value,
                              'startDate': experience.startDate,
                              'endDate': experience.endDate,
                              'description': experience.description,
                            }, index: index),
                          ),
                          // Description
                          TextField(
                            controller: experienceDescriptionControllers[index],
                            decoration: const InputDecoration(labelText: 'Description'),
                            onChanged: (value) => updateField('experiences', {
                              'role': experience.role,
                              'companyName': experience.companyName,
                              'startDate': experience.startDate,
                              'endDate': experience.endDate,
                              'description': value,
                            }, index: index),
                          ),
                          // Start Date Field
                          TextField(
                            controller: experienceStartDateControllers[index],
                            decoration: const InputDecoration(labelText: 'Start Date YYYY-MM-DD'),
                            readOnly: true, // Prevent manual editing
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), // Current date
                                firstDate: DateTime(1900), // Earliest possible date
                                lastDate: DateTime(2100), // Latest possible date
                              );

                              if (pickedDate != null) {
                                // Update the controller with the selected date
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                experienceStartDateControllers[index].text = formattedDate;

                                // Update the experience data
                                updateField('experiences', {
                                  'role': experience.role,
                                  'companyName': experience.companyName,
                                  'startDate': pickedDate.toIso8601String(),
                                  'endDate': experience.endDate,
                                  'description': experience.description,
                                }, index: index);
                              }
                            },
                          ),

                          // End Date Field
                          TextField(
                            controller: experienceEndDateControllers[index],
                            decoration: const InputDecoration(labelText: 'End Date YYYY-MM-DD'),
                            readOnly: true, // Prevent manual editing
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), // Current date
                                firstDate: DateTime(1900), // Earliest possible date
                                lastDate: DateTime(2100), // Latest possible date
                              );

                              if (pickedDate != null) {
                                // Update the controller with the selected date
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                experienceEndDateControllers[index].text = formattedDate;

                                // Update the experience data
                                updateField('experiences', {
                                  'role': experience.role,
                                  'companyName': experience.companyName,
                                  'startDate': experience.startDate,
                                  'endDate': pickedDate.toIso8601String(),
                                  'description': experience.description,
                                }, index: index);
                              }
                            },
                          ),
                          // Delete Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  mentorData.experiences.removeAt(index);
                                  experienceRoleControllers.removeAt(index);
                                  experienceCompanyControllers.removeAt(index);
                                  experienceStartDateControllers.removeAt(index);
                                  experienceEndDateControllers.removeAt(index);
                                  experienceDescriptionControllers.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Add New Experience Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Experience'),
                    onPressed: () {
                      setState(() {
                        mentorData.experiences.add(Experience(
                          id: 0,
                          mentorId: mentorData.id,
                          role: '',
                          companyName: '',
                          startDate: null,
                          endDate: null,
                          description: '',
                        ));
                        experienceRoleControllers.add(TextEditingController());
                        experienceCompanyControllers.add(TextEditingController());
                        experienceStartDateControllers.add(TextEditingController());
                        experienceEndDateControllers.add(TextEditingController());
                        experienceDescriptionControllers.add(TextEditingController());
                      });
                    },
                  ),
                ),
              ],
            ),
            // Certificates section
            const SizedBox(height: 16),
            const Text('Certificates:'),
            Column(
              children: [
                ...mentorData.certificates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final certificate = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Optional: Add vertical spacing
                    child: Container(
                      color: Colors.transparent, // Remove background color
                      padding: const EdgeInsets.all(8.0), // Optional: Add padding inside
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Certificate Name
                          TextField(
                            controller: certificateNameControllers[index],
                            decoration: const InputDecoration(labelText: 'Certificate Name'),
                            onChanged: (value) => updateField('certificates', {
                              'name': value,
                              'provideBy': certificate.provideBy ?? '',
                              'createDate': certificate.createDate?.toIso8601String(),
                              'imageUrl': certificate.imageUrl ?? '',
                            }, index: index),
                          ),
                          // Provided By
                          TextField(
                            controller: certificateProvidedByControllers[index],
                            decoration: const InputDecoration(labelText: 'Provided By'),
                            onChanged: (value) => updateField('certificates', {
                              'name': certificate.name,
                              'provideBy': value,
                              'createDate': certificate.createDate?.toIso8601String(),
                              'imageUrl': certificate.imageUrl,
                            }, index: index),
                          ),
                          // Create Date
                          TextField(
                            controller: certificateDateControllers[index],
                            decoration: const InputDecoration(labelText: 'Create Date YYYY-MM-DD'),
                            readOnly: true, // Prevent manual editing
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), // Current date
                                firstDate: DateTime(1900), // Earliest possible date
                                lastDate: DateTime(2100), // Latest possible date
                              );

                              if (pickedDate != null) {
                                // Update the controller with the selected date
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                certificateDateControllers[index].text = formattedDate;

                                // Update the mentor data
                                updateField('certificates', {
                                  'name': certificate.name,
                                  'provideBy': certificate.provideBy,
                                  'createDate': pickedDate.toIso8601String(),
                                  'imageUrl': certificate.imageUrl,
                                }, index: index);
                              }
                            },
                          ),
                          // Image URL
                          TextField(
                            controller: certificateImageUrlControllers[index],
                            decoration: const InputDecoration(labelText: 'Image URL'),
                            onChanged: (value) => updateField('certificates', {
                              'name': certificate.name,
                              'provideBy': certificate.provideBy,
                              'createDate': certificate.createDate?.toIso8601String(),
                              'imageUrl': value,
                            }, index: index),
                          ),
                          // Delete Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  mentorData.certificates.removeAt(index);
                                  certificateNameControllers.removeAt(index);
                                  certificateProvidedByControllers.removeAt(index);
                                  certificateDateControllers.removeAt(index);
                                  certificateImageUrlControllers.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Add New Certificate Button (if needed)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Certificate'),
                    onPressed: () {
                      setState(() {
                        mentorData.certificates.add(Certificate(
                          id: 0,
                          mentorId: mentorData.id,
                          name: '', // Default values
                          provideBy: '', // Default values
                          createDate: null, // Default values
                          imageUrl: '', // Default values
                        ));
                        certificateNameControllers.add(TextEditingController());
                        certificateProvidedByControllers.add(TextEditingController());
                        certificateDateControllers.add(TextEditingController());
                        certificateImageUrlControllers.add(TextEditingController());
                      });
                    },
                  ),
                ),
              ],
            ),
            // Time Slots section
            const SizedBox(height: 16),
            const Text('Time Slots:'),
            Column(
              children: [
                ...mentorData.timeSlots.asMap().entries.map((entry) {
                  final index = entry.key;
                  final schedule = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Optional: Add vertical spacing
                    child: Container(
                      color: Colors.transparent, // Remove background color
                      padding: const EdgeInsets.all(8.0), // Optional: Add padding inside
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time Start Field
                          TextField(
                            controller: timeSlotsTimeStartControllers[index],
                            decoration: const InputDecoration(labelText: 'Time Start HH:MM:SS'),
                            readOnly: true, // Prevent manual editing
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(), // Current time
                              );

                              if (pickedTime != null) {
                                // Format the time as HH:mm:ss
                                final now = DateTime.now();
                                String formattedTime = DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
                                );

                                timeSlotsTimeStartControllers[index].text = formattedTime;

                                // Update the time slot data
                                updateField('timeSlots', {
                                  'timeStart': formattedTime,
                                  'timeEnd': schedule.timeEnd,
                                }, index: index);
                              }
                            },
                          ),

                          // Time End Field
                          TextField(
                            controller: timeSlotsTimeEndControllers[index],
                            decoration: const InputDecoration(labelText: 'Time End HH:MM:SS'),
                            readOnly: true, // Prevent manual editing
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(), // Current time
                              );

                              if (pickedTime != null) {
                                // Format the time as HH:mm:ss
                                final now = DateTime.now();
                                String formattedTime = DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
                                );

                                timeSlotsTimeEndControllers[index].text = formattedTime;

                                // Update the time slot data
                                updateField('timeSlots', {
                                  'timeStart': schedule.timeStart,
                                  'timeEnd': formattedTime,
                                }, index: index);
                              }
                            },
                          ),
                          // Delete Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  mentorData.timeSlots.removeAt(index);
                                  timeSlotsTimeStartControllers.removeAt(index);
                                  timeSlotsTimeEndControllers.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Add New Time Slot Button (if needed)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Time Slot'),
                    onPressed: () {
                      setState(() {
                        mentorData.timeSlots.add(FixedTimeSlot(id:0,mentorId: mentorData.id,timeStart: '', timeEnd: ''));
                        timeSlotsTimeStartControllers.add(TextEditingController());
                        timeSlotsTimeEndControllers.add(TextEditingController());
                      });
                    },
                  ),
                ),
              ],
            ),
            // Save button
            ElevatedButton(
              onPressed: saveMentor,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}