import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:mentor/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/shared/models/all_mentors.model.dart';
import 'package:mentor/components/admin/edit_mentor.screen.dart';
import 'package:mentor/components/admin/view_mentor.screen.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

import '../../shared/services/token.service.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isListView = true;
  List<dynamic> mentors = [];

  late String usertoken;

  var provider;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    fetchMentors();
  }

  // Fetch mentors from the API
  Future<void> fetchMentors() async {
    // Check if token has expired
    bool isExpired = JwtDecoder.isExpired(usertoken);
    if (isExpired) {
      final tokenService = TokenService();
      tokenService.checkToken(usertoken, context);
    } else {
      final url = Uri.parse('http://localhost:8080/api/mentors/all');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response into a list of ProfileMentor objects
        List<dynamic> mentorList = json.decode(response.body);
        setState(() {
          // Convert each item in the list to a ProfileMentor object using the factory constructor
          mentors = mentorList
              .map((mentorJson) => AllMentors.fromJson(mentorJson))
              .toList();
        });
      } else {
        throw Exception('Failed to load mentors');
      }
    }
  }

  // Updated deleteMentor function
  Future<void> deleteMentor(int id) async {
    // Check if token has expired
    bool isExpired = JwtDecoder.isExpired(usertoken);
    if (isExpired) {
      final tokenService = TokenService();
      tokenService.checkToken(usertoken, context);
    } else {
      final url = Uri.parse('http://localhost:8080/api/mentors/$id');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          mentors.removeWhere(
              (mentor) => mentor.id == id); // Access id as an object property
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mentor deleted successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Handle errors (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete mentor. Please try again.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to ViewMentorScreen to view mentor details
  void viewMentor(AllMentors mentor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewMentorScreen(
            mentor: mentor), // Pass the ProfileMentor object directly
      ),
    );
  }

  // Navigate to edit screen
  void editMentor(AllMentors mentor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMentorScreen(mentor: mentor),
      ),
    );

    // If the result is true, reload the mentor list to reflect changes
    if (result == true) {
      fetchMentors(); // Reload mentor data after successful update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Admin Page')),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.createMentor),
            icon: const Icon(Icons.add),
            tooltip: 'Create Mentor',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isListView = !isListView;
              });
            },
            icon:
                isListView ? const Icon(Icons.list) : const Icon(Icons.grid_on),
          ),
        ],
      ),
      body: mentors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : isListView
              ? ListView.builder(
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentors[index];
                    return Card(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(mentor.name),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mentor.role ?? ""),
                              Text(mentor.bio),
                            ]),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage(
                            mentor.avatarUrl,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => viewMentor(mentor),
                              tooltip: 'View',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editMentor(mentor),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteMentor(mentor.id),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 40),
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(context),
                        childAspectRatio:
                            MediaQuery.of(context).size.width > 600 ? 0.8 : 1.3,
                      ),
                      itemCount: mentors.length,
                      itemBuilder: (context, index) {
                        final mentor = mentors[index];
                        return Card(
                          elevation: 10,
                          shadowColor: Colors.black,
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.orange,
                                radius: 80,
                                child: CircleAvatar(
                                  radius: 78,
                                  backgroundImage: AssetImage(
                                    mentor.avatarUrl,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mentor.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      mentor.role ?? "",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Text(
                                      mentor.bio,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ]),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => viewMentor(mentor),
                                    tooltip: 'View',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => editMentor(mentor),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteMentor(mentor.id),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ),
    );
  }

  int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return 4;
    } else if (width > 800) {
      return 2;
    } else {
      return 1;
    }
  }
}