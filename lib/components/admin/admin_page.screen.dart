import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mentor/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/shared/models/all_mentors.model.dart';
import 'package:mentor/components/admin/edit_mentor.screen.dart';
import 'package:mentor/components/admin/view_mentor.screen.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
        mentors = mentorList.map((mentorJson) => AllMentors.fromJson(mentorJson)).toList();
      });
    } else {
      throw Exception('Failed to load mentors');
    }
  }

  // Updated deleteMentor function
  Future<void> deleteMentor(int id) async {
    final url = Uri.parse('http://localhost:8080/api/mentors/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $usertoken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        mentors.removeWhere((mentor) => mentor.id == id); // Access `id` as an object property
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

  // Navigate to ViewMentorScreen to view mentor details
  void viewMentor(AllMentors mentor) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewMentorScreen(mentor: mentor), // Pass the ProfileMentor object directly
    ),
  );
}

  // Navigate to edit screen
  void editMentor(AllMentors mentor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMentorScreen(mentor: mentor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.createMentor),
            icon: const Icon(Icons.add),
            tooltip: 'Create Mentor',
          ),
        ],
      ),
      body: mentors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final mentor = mentors[index];
                return Card(
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
            ),
    );
  }
}
