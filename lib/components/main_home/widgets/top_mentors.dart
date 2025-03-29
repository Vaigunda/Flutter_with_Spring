// lib/screens/home/home_top_mentors.dart
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/constants/ui.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/models/top_mentor.model.dart';
import 'package:mentor/shared/services/top_mentor.service.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class HomeTopMentors extends StatefulWidget {
  final Future<List<TopMentorModel>>? topMentors;
  const HomeTopMentors({super.key, required this.topMentors});

  @override
  State<HomeTopMentors> createState() => _HomeTopMentorsState();
}

class _HomeTopMentorsState extends State<HomeTopMentors> {
  late Future<List<TopMentorModel>> topMentors;

  late String usertoken;
  var provider;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    topMentors =
        widget.topMentors ?? TopMentorService().fetchTopMentors(usertoken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TopMentorModel>>(
      future: topMentors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Log the error to console
          debugPrint('Error: ${snapshot.error}');
          // Continue to show "No mentors found" in UI
          return _buildContent(context, false);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildContent(context, false);
        } else {
          final mentors = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text("Top Mentors",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: mentors.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 800 ? 3 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 300.0,
                  ),
                  itemBuilder: (context, index) =>
                      _customCard(context, mentors[index]),
                ),
              ],
            ),
          );
        }
      },
    );
  }



  Widget _buildContent(BuildContext context, bool hasMentors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Top Mentors", style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 10),
        if (!hasMentors)
          const Padding(
            padding: EdgeInsets.only(left: 1.0), // Align with the title's start
            child: Text('No top mentors found'),
          ),
      ],
    );
  }

  Widget _customCard(BuildContext context, TopMentorModel mentor) {
    return InkWell(
      onTap: () {
        if (usertoken.isNotEmpty) {
          context.push('${AppRoutes.profileMentor}/${mentor.id}');
        } else {
          // Show scaffold message and redirect to login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please login to view mentor details')),
          );
          context.go(AppRoutes.signin);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: HoverableContainer(
          context: context,
          hover: false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor:
                        Colors.grey[300], // Optional: Placeholder background
                    child: ClipOval(
                      child: Image.asset(
                        mentor.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            mentor.gender == 'male'
                                ? 'assets/images/malepic.jpg' // Male fallback
                                : 'assets/images/femalepic.jpg', // Female fallback
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _buildDetails(mentor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(TopMentorModel mentor) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(mentor.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blue[900],
                      )),
                ),
                const SizedBox(height: 5),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text("Role:  ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text(mentor.categories.join(", "),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text("Mentors:  ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text(" ${mentor.numberOfMentoree} mentees",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Text("Ratings:  ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text("${mentor.rate}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber[600],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mentor/navigation/router.dart';
// import 'package:mentor/shared/utils/extensions.dart';

// import '../../../shared/models/mentor.model.dart';

// class HomeTopMentors extends StatefulWidget {
//   const HomeTopMentors({super.key, required this.mentors});
//   final Iterable<MentorModel> mentors;
//   @override
//   State<HomeTopMentors> createState() => _HomeTopMentorsState();
// }

// class _HomeTopMentorsState extends State<HomeTopMentors> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [
//           Text(
//             "Top Mentors",
//             style: context.headlineSmall,
//           )
//         ]),
//         const SizedBox(
//           height: 10,
//         ),
//         GridView.builder(
//           shrinkWrap: true,
//           itemCount: widget.mentors.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//               mainAxisExtent: 300.0),
//           itemBuilder: (context, index) =>
//               _customCard(context, widget.mentors.elementAt(index)),
//         ),
//       ],
//     );
//   }

//   Widget _customCard(BuildContext context, MentorModel mentor) {
//     return InkWell(
//         onTap: () => context.push('${AppRoutes.profileMentor}/${mentor.id}'),
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: const BorderRadius.all(Radius.circular(16))),
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Center(
//                   child: CircleAvatar(
//                     radius: 80,
//                     backgroundImage: AssetImage(mentor.avatarUrl),
//                   ),
//                 ),
//                 _buildDetails(mentor)
//               ]),
//         ));
//   }

//   Widget _buildDetails(MentorModel mentor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         const SizedBox(
//           height: 10,
//         ),
//         Text(
//           mentor.name,
//           style: context.titleMedium,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//           textAlign: TextAlign.start,
//         ),
//         Text(
//           mentor.categories.map((e) => e.name).join(", "),
//           style: context.bodyMedium,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//           textAlign: TextAlign.start,
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Text(
//           "${mentor.numberOfMentoree} mentee",
//           style: context.bodySmall,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//           textAlign: TextAlign.start,
//         ),
//         Row(
//           children: [
//             const Icon(
//               FontAwesomeIcons.star,
//               size: 12,
//             ),
//             const SizedBox(
//               width: 6,
//             ),
//             Text(
//               "${mentor.rate}",
//               style: context.bodySmall,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               textAlign: TextAlign.start,
//             )
//           ],
//         )
//       ],
//     );
//   }
// }
