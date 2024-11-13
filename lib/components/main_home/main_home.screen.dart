// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mentor/components/main_home/widgets/verified.dart';
// import 'package:mentor/components/main_home/widgets/top_rated.dart';
// import 'package:mentor/navigation/router.dart';
// import '../../shared/providers/mentors.provider.dart';
// import '../../shared/views/brightness_toggle.dart';
// import 'widgets/categories.dart';
// import 'widgets/explore.dart';
// import 'widgets/top_mentors.dart';

// class MainHomeScreen extends StatefulWidget {
//   const MainHomeScreen({super.key});

//   @override
//   State<MainHomeScreen> createState() => _MainHomeScreenState();
// }

// class _MainHomeScreenState extends State<MainHomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: LayoutBuilder(builder: (builderContext, constraints) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 25, 0, 10),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 TextButton(
//                     onPressed: () => context.go(AppRoutes.signin),
//                     child: const Text("Sign in")),
//                 Expanded(
//                     child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     const BrightnessToggle(),
//                     const SizedBox(width: 10),
//                     IconButton(
//                         onPressed: () => context.push(AppRoutes.notifications),
//                         icon: const Icon(FontAwesomeIcons.bell)),
//                     const SizedBox(width: 10),
//                   ],
//                 ))
//               ]),
//               const SizedBox(height: 30),
//               const ExploreMentor(),
//               const SizedBox(height: 10),
//               const HomeCategories(),
//               const SizedBox(height: 30),
//               HomeTopMentors(mentors: MentorsProvider.shared.topMentorees(6).toList()), // Fixed the Iterable to List
//               const SizedBox(height: 30),
//               HomeVerified(mentors: MentorsProvider.shared.verified(4)),
//               const SizedBox(height: 30),
//               HomeTopRated(mentors: MentorsProvider.shared.topRated(5))
//             ]),
//           ),
//         );
//       }),
//     );
//   }
// }


// 2nd change
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mentor/components/main_home/widgets/verified.dart';
// import 'package:mentor/components/main_home/widgets/top_rated.dart';
// import 'package:mentor/navigation/router.dart';

// import '../../shared/providers/mentors.provider.dart';
// import '../../shared/views/brightness_toggle.dart';
// import 'widgets/categories.dart';
// import 'widgets/explore.dart';
// import 'widgets/top_mentors.dart';

// class MainHomeScreen extends StatefulWidget {
//   const MainHomeScreen({super.key});

//   @override
//   State<MainHomeScreen> createState() => _MainHomeScreenState();
// }

// class _MainHomeScreenState extends State<MainHomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: LayoutBuilder(builder: (builderContext, constraints) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 25, 0, 10),
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 TextButton(
//                     onPressed: () => context.go(AppRoutes.signin),
//                     child: const Text("Sign in")),
//                 Expanded(
//                     child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     const BrightnessToggle(),
//                     const SizedBox(width: 10),
//                     IconButton(
//                         onPressed: () => context.push(AppRoutes.notifications),
//                         icon: const Icon(FontAwesomeIcons.bell)),
//                     const SizedBox(width: 10),
//                   ],
//                 ))
//               ]),
//               const SizedBox(height: 30),
//               const ExploreMentor(),
//               const SizedBox(height: 10),
//               const HomeCategories(),
//               const SizedBox(height: 30),
//               HomeTopMentors(mentors: MentorsProvider.shared.topMentorees(6)),
//               const SizedBox(height: 30),
//               HomeVerified(mentors: MentorsProvider.shared.verified(4)),
//               // const SizedBox(height: 30),
//               // HomeMentors(mentors: MentorsProvider.shared.topMentorees(6)),
//               const SizedBox(height: 30),
//               HomeTopRated(mentors: MentorsProvider.shared.topRated(5))
//             ]),
//           ),
//         );
//       }),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/components/main_home/widgets/verified.dart';
import 'package:mentor/components/main_home/widgets/top_rated.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/models/verified.model.dart';
import 'package:mentor/shared/services/verified.service.dart';
import '../../shared/services/top_rated_mentor.service.dart';
import '../../shared/services/top_mentor.service.dart';
import '../../shared/providers/mentors.provider.dart';
import '../../shared/models/top_rated_mentor.model.dart';
import '../../shared/models/top_mentor.model.dart';
import '../../shared/views/brightness_toggle.dart';
import 'widgets/categories.dart';
import 'widgets/explore.dart';
import 'widgets/top_mentors.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late Future<List<TopRatedMentorModel>> topRatedMentors;
  late Future<List<TopMentorModel>> topMentors;
  late Future<List<VerifiedMentor>> verifiedMentors;

  @override
  void initState() {
    super.initState();
    // Fetch data from the API
    topRatedMentors = MentorService().fetchTopRatedMentors();
    topMentors = TopMentorService().fetchTopMentors();
    verifiedMentors= VerifiedService().fetchVerifiedMentors();
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
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.go(AppRoutes.signin),
                      child: const Text("Sign in"),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const BrightnessToggle(),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () =>
                                context.push(AppRoutes.notifications),
                            icon: const Icon(FontAwesomeIcons.bell),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const ExploreMentor(),
                const SizedBox(height: 10),
                const HomeCategories(),
                const SizedBox(height: 30),
                HomeTopMentors(topMentors: topMentors),
                const SizedBox(height: 30),
                HomeVerified(verifiedMentors: verifiedMentors),
                const SizedBox(height: 30),
                // Pass the future data for top-rated mentors
                HomeTopRated(topRatedMentors: topRatedMentors),
              ],
            ),
          ),
        );
      }),
    );
  }
}
