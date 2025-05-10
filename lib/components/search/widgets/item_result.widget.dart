import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mentor/shared/shared.dart';
import 'package:go_router/go_router.dart'; 
import 'package:mentor/navigation/router.dart';

import '../model/item_search_result.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class ItemResult extends StatelessWidget {
  const ItemResult({super.key, required this.item});
  final ItemSearchResult item;

  Future<bool> checkBooking(String userId, String mentorId, String userToken) async {
    if (userToken.isEmpty) {
      return false; // Return false immediately if user is not logged in
    }
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/bookings/check?userId=$userId&mentorId=$mentorId'),
      headers: {
        'Authorization': 'Bearer $userToken', // Add Authorization header
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool; // Convert response to bool
    } else {
      return false; // Default to false on error
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.read<UserDataProvider>();
    String userId = provider.userid;
    String userToken = provider.usertoken;  // Fetch the user token

    return FutureBuilder<bool>(
      future: checkBooking(userId, item.mentorId.toString(), userToken),
      builder: (context, snapshot) {
        bool hasBooking = snapshot.data ?? false;

        return MouseRegion(
          cursor: SystemMouseCursors.click, // Changes cursor to a pointer
          child: GestureDetector(
            onTap: () {
              if (userId.isNotEmpty) {
                context.push('${AppRoutes.profileMentor}/${item.mentorId}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login!'), backgroundColor: Colors.red),
                );
                context.go(AppRoutes.signin);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(item.avatar),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_outline_rounded,
                                size: 25,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.rating.toString(),
                                style: context.headlineMedium,
                              ),
                            ],
                          ),
                          Text(
                            "${item.mentees} mentees",
                            style: context.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.role ?? "",
                                style: context.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: context.titleMedium,
                  ),
                  const SizedBox(height: 5),

                  // Show "Send Message" only if the API response is true
                  if (hasBooking)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 18),
                        const SizedBox(width: 5),
                        TextButton(
                          onPressed: () {
                            //TODO: Go to inbox ${item.mentorId}
                          },
                          child: Text("Send Message", style: context.bodySmall),
                        ),
                      ],
                    ),

                  const SizedBox(height: 5),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: item.skills
                        .map((skill) => Text(
                              skill,
                              style: context.bodyMedium!.copyWith(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:mentor/shared/shared.dart';

// import '../model/item_search_result.dart';

// class ItemResult extends StatelessWidget {
//   const ItemResult({super.key, required this.item});
//   final ItemSearchResult item;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.onSecondary,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CircleAvatar(
//                 radius: 40,
//                 backgroundImage: AssetImage(item.avatar), // Add avatar image
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.star_outline_rounded,
//                         size: 25,
//                         color: Theme.of(context).colorScheme.outline,
//                       ),
//                       const SizedBox(width: 10),
//                       Text(
//                         item.rating.toString(),
//                         style: context.headlineMedium,
//                       ),
//                     ],
//                   ),
//                   Text(
//                     "${item.mentees} mentees", // Replaced 'reviewers' with 'mentees'
//                     style: context.bodySmall,
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         item.role ?? "", // Role might be null
//                         style: context.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             item.name,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//             style: context.titleMedium,
//           ),
//           const SizedBox(height: 5),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.inbox_outlined, size: 18),
//               const SizedBox(width: 5),
//               TextButton(
//                 onPressed: () {
//                   //TODO: Go to inbox ${item.mentorId}
//                 },
//                 child: Text("Send Message", style: context.bodySmall),
//               ),
//             ],
//           ),
//           const SizedBox(height: 5),
//           Divider(height: 1, color: Theme.of(context).colorScheme.outline),
//           const SizedBox(height: 5),
//           Wrap(
//             spacing: 10,
//             runSpacing: 8,
//             children: item.skills
//                 .map((skill) => Text(
//                       skill,
//                       style: context.bodyMedium!.copyWith(
//                         decoration: TextDecoration.underline,
//                         decorationStyle: TextDecorationStyle.dashed,
//                       ),
//                     ))
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mentor/shared/shared.dart';

// import '../model/item_search_result.dart';

// class ItemResult extends StatelessWidget {
//   const ItemResult({super.key, required this.item});
//   final ItemSearchResult item;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.onSecondary,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
//                 spreadRadius: 1,
//                 blurRadius: 10,
//                 offset: const Offset(0, 1), // changes position of shadow
//               ),
//             ]),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const CircleAvatar(
//                 radius: 40,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.star_outline_rounded,
//                           size: 25,
//                           color: Theme.of(context).colorScheme.outline),
//                       const SizedBox(width: 10),
//                       Text(
//                         item.rating.toString(),
//                         style: context.headlineMedium,
//                       )
//                     ],
//                   ),
//                   Text(
//                     "${item.reviewers} reviewers / ${item.sessions} sessions",
//                     style: context.bodySmall,
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                           item.price == 0
//                               ? "Free"
//                               : "\$${item.price} / ${item.unit!.name}",
//                           style: context.labelMedium!
//                               .copyWith(color: context.colors.primary)),
//                       const SizedBox(width: 5),
//                       Icon(Icons.credit_card,
//                           color: Theme.of(context).colorScheme.outline)
//                     ],
//                   )
//                 ],
//               )
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(item.name,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: context.titleMedium),
//           Text(item.role ?? "", style: context.bodyMedium),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.inbox_outlined, size: 18),
//               const SizedBox(width: 5),
//               TextButton(
//                 onPressed: () {
//                   //TODO: Go to inbox ${item.mentorId}
//                 },
//                 child: Text("Send Message", style: context.bodySmall),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               const Icon(Icons.fact_check, size: 18),
//               const SizedBox(width: 5),
//               Expanded(
//                   child: Text(
//                       "Next available - ${DateFormat('MM/dd/yyyy hh:mm a').format(item.nextAvailable)}",
//                       style: context.bodySmall))
//             ],
//           ),
//           const SizedBox(height: 5),
//           Divider(height: 1, color: Theme.of(context).colorScheme.outline),
//           const SizedBox(height: 5),
//           Wrap(
//             spacing: 10,
//             runSpacing: 8,
//             children: item.skills
//                 .map((skill) => Text(
//                       skill,
//                       style: context.bodyMedium!.copyWith(
//                           decoration: TextDecoration.underline,
//                           decorationStyle: TextDecorationStyle.dashed),
//                     ))
//                 .toList(),
//           ),
//         ]));
//   }
// }
