import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mentor/shared/models/all_mentors.model.dart';
import 'package:intl/intl.dart';


class EditMentorScreen extends StatefulWidget {
  final AllMentors mentor;

  const EditMentorScreen({required this.mentor});

  @override
  _EditMentorScreenState createState() => _EditMentorScreenState();
}

class _EditMentorScreenState extends State<EditMentorScreen> {
  late AllMentors mentorData;

  late TextEditingController nameController;
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
  List<TextEditingController> teachingScheduleDateStartControllers = [];
  List<TextEditingController> teachingScheduleTimeStartControllers = [];
  List<TextEditingController> teachingScheduleTimeEndControllers = [];
  List<TextEditingController> teachingScheduleBookedControllers = [];
  List<TextEditingController> experienceRoleControllers = [];
  List<TextEditingController> experienceCompanyControllers = [];
  List<TextEditingController> experienceStartDateControllers = [];
  List<TextEditingController> experienceEndDateControllers = [];
  List<TextEditingController> experienceDescriptionControllers = [];

  @override
  void initState() {
    super.initState();
    mentorData = widget.mentor;
    print(widget.mentor.teachingSchedules);

    nameController = TextEditingController(text: mentorData.name);
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
    teachingScheduleDateStartControllers = mentorData.teachingSchedules
        .map((schedule) => TextEditingController(
            text: schedule.dateStart != null
                ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(schedule.dateStart)
                : ''))
        .toList();

    teachingScheduleTimeStartControllers = mentorData.teachingSchedules
        .map((schedule) => TextEditingController(
            text: schedule.timeStart != null
                ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(schedule.timeStart)
                : ''))
        .toList();

    teachingScheduleTimeEndControllers = mentorData.teachingSchedules
        .map((schedule) => TextEditingController(
            text: schedule.timeEnd != null
                ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(schedule.timeEnd)
                : ''))
        .toList();

    teachingScheduleBookedControllers = mentorData.teachingSchedules
        .map((schedule) => TextEditingController(
            text: schedule.booked != null
                ? schedule.booked.toString()
                : ''))
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
      ...teachingScheduleDateStartControllers,
      ...teachingScheduleTimeStartControllers,
      ...teachingScheduleTimeEndControllers,
      ...teachingScheduleBookedControllers,
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

  // Method to handle saving updated mentor data
  Future<void> saveMentor() async {
    final updatedData = {
      'name': mentorData.name,
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
      'teachingSchedules': mentorData.teachingSchedules.map((schedule) {
        return {
          'dateStart': schedule.dateStart != null
              ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(schedule.dateStart)
              : null,
          'timeStart': schedule.timeStart != null
              ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(schedule.timeStart)
              : null,
          'timeEnd': schedule.timeEnd != null
              ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(schedule.timeEnd)
              : null,
          'booked': schedule.booked,
        };
      }).toList(),
      'categories': mentorData.categories.map((category) {
        return {
          'name': category.name,
        };
      }).toList(),
    };

    print('Request Body: ${json.encode(updatedData)}');

    final response = await http.put(
      Uri.parse('http://localhost:8080/api/mentors/${mentorData.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Return success to the admin page
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


  void updateField(String field, dynamic value, {int? index}) {
    setState(() {
      switch (field) {
        case 'name':
          mentorData = mentorData.copyWith(name: value);
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
        case 'teachingSchedules':
          if (index != null) {
            mentorData.teachingSchedules[index] = mentorData.teachingSchedules[index].copyWith(
              dateStart: DateTime.tryParse(value['dateStart']) ?? mentorData.teachingSchedules[index].dateStart,
              timeStart: DateTime.tryParse(value['timeStart']) ?? mentorData.teachingSchedules[index].timeStart,
              timeEnd: DateTime.tryParse(value['timeEnd']) ?? mentorData.teachingSchedules[index].timeEnd,
              booked: value['booked'] ?? mentorData.teachingSchedules[index].booked,
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
              name: value['name'],
              provideBy: value['provideBy'],
              createDate: DateTime.tryParse(value['createDate']) ?? mentorData.certificates[index].createDate,
              imageUrl: value['imageUrl'],
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
              decoration: const InputDecoration(labelText: 'Number of Mentorees'),
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
            ...mentorData.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = categoryControllers[index];

              return TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Category Name'),
                onChanged: (value) => updateField('categories', value, index: index),
              );
            }),
            // Experiences section
            // Experiences section
            const SizedBox(height: 16),
            const Text('Experiences:'),
            ...mentorData.experiences.asMap().entries.map((entry) {
              final index = entry.key;
              final experience = entry.value;

              return ListTile(
                title: Column(
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
                    // Start Date
                    TextField(
                      controller: experienceStartDateControllers[index],
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      onChanged: (value) => updateField('experiences', {
                        'role': experience.role,
                        'companyName': experience.companyName,
                        'startDate': value,
                        'endDate': experience.endDate,
                        'description': experience.description,
                      }, index: index),
                    ),
                    // End Date
                    TextField(
                      controller: experienceEndDateControllers[index],
                      decoration: const InputDecoration(labelText: 'End Date'),
                      onChanged: (value) => updateField('experiences', {
                        'role': experience.role,
                        'companyName': experience.companyName,
                        'startDate': experience.startDate,
                        'endDate': value,
                        'description': experience.description,
                      }, index: index),
                    ),
                  ],
                ),
              );
            }),
            // Certificates section
            // Certificates section
            const SizedBox(height: 16),
            const Text('Certificates:'),
            ...mentorData.certificates.asMap().entries.map((entry) {
              final index = entry.key;
              final certificate = entry.value;

              return ListTile(
                title: Column(
                  children: [
                    TextField(
                      controller: certificateNameControllers[index],
                      decoration: const InputDecoration(labelText: 'Certificate Name'),
                      onChanged: (value) => updateField('certificates', {
                        'name': value,
                        'provideBy': certificate.provideBy,
                        'createDate': certificate.createDate?.toIso8601String(),
                        'imageUrl': certificate.imageUrl,
                      }, index: index),
                    ),
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
                    TextField(
                      controller: certificateDateControllers[index],
                      decoration: const InputDecoration(labelText: 'Create Date'),
                      onChanged: (value) => updateField('certificates', {
                        'name': certificate.name,
                        'provideBy': certificate.provideBy,
                        'createDate': DateTime.tryParse(value)?.toIso8601String(),
                        'imageUrl': certificate.imageUrl,
                      }, index: index),
                    ),
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
                  ],
                ),
              );
            }),

            // Teaching Schedules section
            // Teaching Schedules section
            const SizedBox(height: 16),
            const Text('Teaching Schedules:'),
            ...mentorData.teachingSchedules.asMap().entries.map((entry) {
              final index = entry.key;
              final schedule = entry.value;

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: teachingScheduleDateStartControllers[index],
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      onChanged: (value) {
                        updateField('teachingSchedules', {
                          'dateStart': value,
                          'timeStart': schedule.timeStart.toIso8601String(),
                          'timeEnd': schedule.timeEnd.toIso8601String(),
                          'booked': schedule.booked,
                        }, index: index);
                      },
                    ),
                    TextField(
                      controller: teachingScheduleTimeStartControllers[index],
                      decoration: const InputDecoration(labelText: 'Time Start'),
                      onChanged: (value) {
                        updateField('teachingSchedules', {
                          'dateStart': schedule.dateStart.toIso8601String(),
                          'timeStart': value,
                          'timeEnd': schedule.timeEnd.toIso8601String(),
                          'booked': schedule.booked,
                        }, index: index);
                      },
                    ),
                    TextField(
                      controller: teachingScheduleTimeEndControllers[index],
                      decoration: const InputDecoration(labelText: 'Time End'),
                      onChanged: (value) {
                        updateField('teachingSchedules', {
                          'dateStart': schedule.dateStart.toIso8601String(),
                          'timeStart': schedule.timeStart.toIso8601String(),
                          'timeEnd': value,
                          'booked': schedule.booked,
                        }, index: index);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booked'),
                        Switch(
                          value: schedule.booked,
                          onChanged: (value) {
                            updateField('teachingSchedules', {
                              'dateStart': schedule.dateStart.toIso8601String(),
                              'timeStart': schedule.timeStart.toIso8601String(),
                              'timeEnd': schedule.timeEnd.toIso8601String(),
                              'booked': value,
                            }, index: index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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
