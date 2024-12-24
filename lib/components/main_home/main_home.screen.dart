import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/components/main_home/widgets/top_rated.dart';
import 'package:mentor/components/main_home/widgets/verified.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/models/verified.model.dart';
import 'package:mentor/shared/services/verified.service.dart';
import 'package:mentor/provider/user_data_provider.dart';
import '../../shared/services/top_rated_mentor.service.dart';
import '../../shared/services/top_mentor.service.dart';
import '../../shared/models/top_rated_mentor.model.dart';
import '../../shared/models/top_mentor.model.dart';
import '../../shared/views/brightness_toggle.dart';
import '../splash/aboutus.dart';
import 'widgets/categories.dart';
import 'widgets/explore.dart';
import 'widgets/top_mentors.dart';
import 'package:provider/provider.dart';

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

  var provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;
    name = provider.name;

    // Fetch data from the API
    topRatedMentors = MentorService().fetchTopRatedMentors(usertoken);
    topMentors = TopMentorService().fetchTopMentors(usertoken);
    verifiedMentors = VerifiedService().fetchVerifiedMentors(usertoken);
  }

  void signOut() async {
    final userDataProvider = context.read<UserDataProvider>();

    await userDataProvider.setUserDataAsync(
      usertoken: '',
      userid: '',
      name: '',
      usertype: '',
    );
    
  context.go(AppRoutes.signin);
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (builderContext, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 0, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userid.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      TextButton(onPressed: () async {
                        signOut();
                        //context.pop();
                      },
                      child: const Text('Sign Out'))
                    ],),
                  ),
                Row(
                  children: [
                    if (userid.isEmpty)
                      TextButton(
                        onPressed: () => context.go(AppRoutes.signin),
                        child: const Text("Sign in"),
                      )
                    else // If logged in, show welcome message
                      Text(
                        "Welcome, $name", // Use the name from provider
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutUs(),
                                ),
                              );
                            },
                            child: const Text(
                              'About Us',
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),
                            ),
                          ),

                          const SizedBox(
                            width: 40,
                          ),
                          // Mentorboosters logo (aligned with baseline)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "m",
                                  style: TextStyle(
                                    fontSize: 48, // Size: 48px
                                    fontFamily:
                                        "Lobster", // Font Family: Lobster
                                    fontWeight: FontWeight.w400, // Weight: 400
                                    color: Color(
                                        0xFF4ABFE2), // Color: rgb(74, 191, 226)
                                    height: 62 /
                                        48, // Line Height: 62px / 48px = ~1.29
                                  ),
                                ),
                                Text(
                                  "entorboosters",
                                  style: TextStyle(
                                    fontSize: 32, // Size: 32px
                                    fontWeight: FontWeight.w900, // Weight: 800
                                    fontFamily:
                                        "Epilogue", // Font Family: Epilogue, sans-serif
                                    color: Color(
                                        0xFF4ABFE2), // Color: rgb(74, 191, 226)
                                    height: 42 /
                                        32, // Line Height: 42px / 32px = ~1.31
                                  ),
                                ),
                                Text(
                                  ".",
                                  style: TextStyle(
                                    fontSize: 72, // Font size for the dot
                                    fontWeight: FontWeight
                                        .w800, // Match the same weight as text
                                    fontFamily: "Epilogue", // Font Family
                                    color: Color(0xFF4ABFE2), // Match the color
                                    height: 1, // Default height
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const SizedBox(width: 10),
                                // Brightness toggle (aligned with baseline)
                                const BrightnessToggle(),
                                const SizedBox(width: 10),

                                // Notification icon (aligned with baseline)
                                // Wrap the IconButton in a Row with baseline alignment
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          context.push(AppRoutes.notifications),
                                      icon: const Icon(FontAwesomeIcons.bell),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
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
                HomeVerified(verifiedMentors: verifiedMentors),
                const SizedBox(height: 30),
                HomeTopRated(
                  topRatedMentors: topRatedMentors,
                )
                // Pass the future data for top-rated mentors
              ],
            ),
          ),
        );
      }),
    );
  }
}