// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:mentor/shared/utils/extensions.dart';

// import '../../../shared/models/mentor.model.dart';

// class HomeVerified extends StatefulWidget {
//   const HomeVerified({super.key, required this.mentors});
//   final Iterable<MentorModel> mentors;

//   @override
//   State<HomeVerified> createState() => _HomeVerifiedState();
// }

// class _HomeVerifiedState extends State<HomeVerified> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [
//           Text(
//             "Verified",
//             style: context.headlineSmall,
//           )
//         ]),
//         const SizedBox(
//           height: 10,
//         ),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Wrap(
//             spacing: 16,
//             children: [
//               for (final mentor in widget.mentors) _customCard(mentor),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget _customCard(MentorModel mentor) {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: const BorderRadius.all(Radius.circular(16))),
//       child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Image.asset(
//                 mentor.avatarUrl,
//                 fit: BoxFit.cover,
//                 height: 127,
//                 width: 182,
//               ),
//             ),
//             _buildDetails(mentor)
//           ]),
//     );
//   }

//   Widget _buildDetails(MentorModel mentor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         const SizedBox(
//           height: 10,
//         ),
//         Row(
//           children: [
//             Text(
//               mentor.name,
//               style: context.titleMedium,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               textAlign: TextAlign.start,
//             ),
//             if (mentor.verified)
//               const SizedBox(
//                 width: 4,
//               ),
//             if (mentor.verified)
//               Icon(
//                 FontAwesomeIcons.circleCheck,
//                 size: 12,
//                 color: context.colors.primary,
//               ),
//           ],
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
//         const SizedBox(
//           height: 10,
//         )
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mentor/shared/models/verified.model.dart';
import 'package:mentor/shared/services/verified.service.dart';
import 'package:mentor/shared/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class HomeVerified extends StatefulWidget {
  final Future<List<VerifiedMentor>>? verifiedMentors;

  const HomeVerified({super.key, required this.verifiedMentors});

  @override
  State<HomeVerified> createState() => _HomeVerifiedState();
}

class _HomeVerifiedState extends State<HomeVerified> {
  late Future<List<VerifiedMentor>> verifiedMentors;

 late String usertoken;
  var provider;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    // If the widget has provided mentors, use that; otherwise, fetch from the service
    verifiedMentors = widget.verifiedMentors ?? VerifiedService().fetchVerifiedMentors(usertoken);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Verified",
              style: context.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<VerifiedMentor>>(
          future: verifiedMentors,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator
            } else if (snapshot.hasError) {
              // Log the error to the console for debugging
              debugPrint('Error fetching verified mentors: ${snapshot.error}');
              // Show "No mentors found" in UI
              return const Text("No verified mentors found");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No verified mentors found");
            }

            final mentors = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 16,
                children: mentors.map(_customCard).toList(),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _customCard(VerifiedMentor mentor) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              mentor.avatarUrl,
              fit: BoxFit.cover,
              height: 127,
              width: 182,
            ),
          ),
          _buildDetails(mentor),
        ],
      ),
    );
  }

  Widget _buildDetails(VerifiedMentor mentor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              mentor.name,
              style: context.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.start,
            ),
            const SizedBox(width: 4),
            Icon(
              FontAwesomeIcons.circleCheck,
              size: 12,
              color: context.colors.primary,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          mentor.categories.join(", "),
          style: context.bodyMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 5),
        Text(
          "${mentor.numberOfMentoree} mentees",
          style: context.bodySmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
