// lib/screens/home/home_top_mentors.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    topMentors = widget.topMentors ??
        TopMentorService().fetchTopMentors(usertoken);
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Top Mentors", style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                itemCount: mentors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 300.0,
                ),
                itemBuilder: (context, index) => _customCard(context, mentors[index]),
              ),
            ],
          );
        }
      },
    );
  }

//   class _HomeTopMentorsState extends State<HomeTopMentors> {
//   late Future<List<TopMentorModel>> _topMentors;
//   late String _userToken;

//   @override
//   void initState() {
//     super.initState();

//     // Get the user token once during initialization
//     final provider = context.read<UserDataProvider>();
//     _userToken = provider.usertoken;

//     // Cache the Future for top mentors
//     _topMentors = widget.topMentors ?? TopMentorService().fetchTopMentors(_userToken);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Reuse the cached Future to avoid repeated API calls
//         return FutureBuilder<List<TopMentorModel>>(
//           future: _topMentors,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               // Log the error to console
//               debugPrint('Error: ${snapshot.error}');
//               // Show fallback UI
//               return _buildContent(context, false);
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return _buildContent(context, false);
//             } else {
//               final mentors = snapshot.data!;
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text("Top Mentors", style: Theme.of(context).textTheme.titleLarge),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     itemCount: mentors.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 10,
//                       crossAxisSpacing: 10,
//                       mainAxisExtent: 300.0,
//                     ),
//                     itemBuilder: (context, index) => _customCard(context, mentors[index]),
//                   ),
//                 ],
//               );
//             }
//           },
//         );
//       },
//     );
//   }
// }


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
            padding: EdgeInsets.only(left: 16.0), // Align with the title's start
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
            const SnackBar(content: Text('Please login to view mentor details')),
          );
          context.go(AppRoutes.signin);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(mentor.avatarUrl), // Use AssetImage for local images
              ),
            ),
            _buildDetails(mentor),
          ],
        ),
      ),
    );
  }


  Widget _buildDetails(TopMentorModel mentor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mentor.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 5),
        Text(mentor.categories.join(", "), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 5),
        Text("${mentor.numberOfMentoree} mentees", style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.star, size: 12),
            const SizedBox(width: 6),
            Text("${mentor.rate}", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
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
