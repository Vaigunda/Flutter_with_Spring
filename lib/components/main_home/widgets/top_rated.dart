// lib/components/main_home/widgets/home_top_rated.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mentor/shared/models/top_rated_mentor.model.dart';
import 'package:mentor/shared/services/top_rated_mentor.service.dart';

class HomeTopRated extends StatefulWidget {
  final Future<List<TopRatedMentorModel>>? topRatedMentors;

  const HomeTopRated({super.key, this.topRatedMentors});

  @override
  State<HomeTopRated> createState() => _HomeTopRatedState();
}

class _HomeTopRatedState extends State<HomeTopRated> {
  late Future<List<TopRatedMentorModel>> topRatedMentors;

  @override
  void initState() {
    super.initState();
    // If the widget has provided mentors, use that; otherwise, fetch from the service
    topRatedMentors = widget.topRatedMentors ??
        MentorService().fetchTopRatedMentors();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Top Rated", style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<TopRatedMentorModel>>(
          future: topRatedMentors,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No top-rated mentors available.');
            } else {
              final mentors = snapshot.data!;
              return Wrap(
                spacing: 16,
                direction: Axis.vertical,
                children: [for (final mentor in mentors) _info(mentor)],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _info(TopRatedMentorModel mentor) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                mentor.avatarUrl,
                fit: BoxFit.cover,
                height: 88,
                width: 88,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mentor.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      mentor.categories.join(", "),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${mentor.numberOfMentoree} mentees",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        const Icon(FontAwesomeIcons.star, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          "${mentor.rate}",
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:mentor/shared/utils/extensions.dart';

// import '../../../shared/models/mentor.model.dart';

// class HomeTopRated extends StatefulWidget {
//   const HomeTopRated({super.key, required this.mentors});
//   final Iterable<MentorModel> mentors;
//   @override
//   State<HomeTopRated> createState() => _HomeTopRatedState();
// }

// class _HomeTopRatedState extends State<HomeTopRated> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [
//           Text(
//             "Top Rated",
//             style: context.headlineSmall,
//           )
//         ]),
//         const SizedBox(
//           height: 10,
//         ),
//         Wrap(
//           spacing: 16,
//           direction: Axis.vertical,
//           children: [for (final mentor in widget.mentors) _info(mentor)],
//         )
//       ],
//     );
//   }

//   Widget _info(MentorModel mentor) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(maxWidth: 400),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: const BorderRadius.all(Radius.circular(16))),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset(
//                 mentor.avatarUrl,
//                 fit: BoxFit.cover,
//                 height: 88,
//                 width: 88,
//               ),
//             ),
//             Expanded(
//                 child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     mentor.name,
//                     style: context.titleMedium,
//                   ),
//                   const SizedBox(
//                     height: 6,
//                   ),
//                   Text(
//                     mentor.categories.map((e) => e.name).join(", "),
//                     style: context.bodySmall,
//                   ),
//                   const SizedBox(
//                     height: 6,
//                   ),
//                   Text(
//                     "${mentor.numberOfMentoree} mentee",
//                     style: context.bodySmall,
//                   ),
//                   Row(
//                     children: [
//                       const Icon(
//                         FontAwesomeIcons.star,
//                         size: 12,
//                       ),
//                       const SizedBox(
//                         width: 6,
//                       ),
//                       Text(
//                         "${mentor.rate}",
//                         style: context.bodySmall,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                         textAlign: TextAlign.start,
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ))
//           ],
//         ),
//       ),
//     );
//   }
// }
