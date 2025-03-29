import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/components/main_home/widgets/top_rated.dart';
import 'package:mentor/components/main_home/widgets/verified.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/models/verified.model.dart';
import 'package:mentor/shared/services/verified.service.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:mentor/shared/shared.dart';
import 'package:mentor/shared/widgets/gradient_button.dart';
import '../../components/schedule/chat.box.dart';
import '../../shared/services/top_rated_mentor.service.dart';
import '../../shared/services/top_mentor.service.dart';
import '../../shared/models/top_rated_mentor.model.dart';
import '../../shared/models/top_mentor.model.dart';
import '../splash/aboutus.dart';
import 'widgets/categories.dart';
import 'widgets/explore.dart';
import 'widgets/top_mentors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late Future<List<TopRatedMentorModel>> topRatedMentors;
  late Future<List<TopMentorModel>> topMentors;
  late Future<List<VerifiedMentor>> verifiedMentors;

  late String usertoken;
  late String userid;
  late String name;
  late String usertype;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var provider;

  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;
    name = provider.name;
    usertype = provider.usertype;

    // Fetch data from the API
    topRatedMentors = MentorService().fetchTopRatedMentors(usertoken);
    topMentors = TopMentorService().fetchTopMentors(usertoken);
    verifiedMentors = VerifiedService().fetchVerifiedMentors(usertoken);

    if (usertype == 'Admin') {
      loadAdminNotification();
    } else if (usertype == 'Mentor') {
      loadMentorNotification();
    } else {
      loadUserNotification();
    }
  }

  loadAdminNotification() async {
    if (userid.isNotEmpty) {
      final url = Uri.parse('https://www.mentorboosters.com/api/notify/getAll');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );
      if (response.statusCode == 200) {
        var parsed = response.body;
        List<dynamic> notifications = jsonDecode(parsed);

        setState(() {
          notificationCount = notifications.length;
        });
      }
    }
  }

  loadMentorNotification() async {
    if (userid.isNotEmpty) {
      int userId = int.parse(userid);
      final url = Uri.parse(
          'https://www.mentorboosters.com/api/notify/getAllNotificationByMentorId?mentorId=$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );
      if (response.statusCode == 200) {
        var parsed = response.body;
        List<dynamic> notifications = jsonDecode(parsed);

        setState(() {
          notificationCount = notifications.length;
        });
      }
    }
  }

  loadUserNotification() async {
    if (userid.isNotEmpty) {
      int userId = int.parse(userid);
      final url = Uri.parse(
          'https://www.mentorboosters.com/api/notify/getAllNotificationByUserId?recipientId=$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );
      if (response.statusCode == 200) {
        var parsed = response.body;
        List<dynamic> notifications = jsonDecode(parsed);

        setState(() {
          notificationCount = notifications.length;
        });
      }
    }
  }

  void signOut() async {
    final userDataProvider = context.read<UserDataProvider>();

    if (ChatBox.isChatBoxOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please closed the Chat Box.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await userDataProvider.setUserDataAsync(
        usertoken: '',
        userid: '',
        name: '',
        usertype: '',
      );

      context.go(AppRoutes.signin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "m",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 48 : 26,
                    fontFamily: "Lobster", // Font Family: Lobster
                    fontWeight: FontWeight.w400, // Weight: 400
                    color: Color(0xFF4ABFE2), // Color: rgb(74, 191, 226)
                    height: 62 / 48, // Line Height: 62px / 48px = ~1.29
                  ),
                ),
                Text(
                  "entorboosters",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 32
                        : 18, // Size: 32px
                    fontWeight: FontWeight.w900, // Weight: 800
                    fontFamily: "Epilogue", // Font Family: Epilogue, sans-serif
                    color: Color(0xFF4ABFE2), // Color: rgb(74, 191, 226)
                    height: 42 / 32, // Line Height: 42px / 32px = ~1.31
                  ),
                ),
                Text(
                  ".",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 72 : 40,
                    fontWeight:
                        FontWeight.w800, // Match the same weight as text
                    fontFamily: "Epilogue", // Font Family
                    color: Color(0xFF4ABFE2), // Match the color
                    height: 1, // Default height
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                userid.isEmpty
                    ? TextButton(
                        onPressed: () => context.go(AppRoutes.signin),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : SizedBox()
              ],
            ),
            if (userid.isNotEmpty)
            MediaQuery.of(context).size.width > 600 ?
              TextButton(
                  onPressed: () async {
                    signOut();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  )):IconButton(
              onPressed: () async {
                signOut();
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out', // ✅ Added tooltip for better accessibility
            ),
            SizedBox(width: MediaQuery.of(context).size.width > 600 ? 10 : 5),
            const BrightnessToggle(),
            SizedBox(width: MediaQuery.of(context).size.width > 600 ? 10 : 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.notifications),
                  icon: const Icon(FontAwesomeIcons.bell),
                ),
                // Badge to display the number
                if (notificationCount > 0 && usertype != 'Admin')
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: LayoutBuilder(builder: (builderContext, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (userid.isEmpty)
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signin),
                          child: const Text(
                            "",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        )
                      else
                        Text(
                          "Welcome, $name", // Use the name from provider
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(height: 10),
                  const ExploreMentor(),
                  const SizedBox(height: 10),
                  const HomeCategories(),
                  const SizedBox(height: 30),
                  HomeTopMentors(topMentors: topMentors),
                  const SizedBox(height: 30),
                  if (userid
                      .isEmpty) // Show button only if user is not logged in
                    Center(
                      child: Container(
                        width: 240,
                        alignment: Alignment.center,
                        child: GradientButton(
                          label: Text(
                            "Discover More Mentors",
                            style: context.labelLarge!
                                .copyWith(fontWeight: FontWeight.w900),
                          ),
                          onPressed: () {
                            context.go(AppRoutes.signin);
                          },
                          trailingIcon: Icon(
                            FontAwesomeIcons.arrowRight,
                            color: Theme.of(context).cardColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                  HomeVerified(verifiedMentors: verifiedMentors),
                  const SizedBox(height: 30),
                  HomeTopRated(
                    topRatedMentors: topRatedMentors,
                  ),
                  // Pass the future data for top-rated mentors
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
