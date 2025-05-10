import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/item_search_result.dart';
import 'item_result.widget.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key, required this.keyword});
  final String keyword;

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  List<ItemSearchResult> result = [];
  bool isLoading = true;

  late String usertoken;
  var provider;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final url = Uri.parse('http://localhost:8080/api/mentors/search?keyword=${widget.keyword}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          result = data.map((e) => ItemSearchResult.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children: [...result.map((item) => ItemResult(item: item))],
                )
              else
                const Text("No results found."),
            ],
          );
  }
}



// import 'package:flutter/material.dart';
// import 'package:mentor/components/search/model/item_search_result.dart';
// import 'package:mentor/shared/utils/extensions.dart';

// import '../../../shared/enums/unit.enum.dart';
// import 'item_result.widget.dart';

// class SearchResult extends StatefulWidget {
//   const SearchResult({super.key, this.keyword});
//   final String? keyword;

//   @override
//   State<SearchResult> createState() => _SearchResultState();
// }

// class _SearchResultState extends State<SearchResult> {
//   int total = 23;
//   List<ItemSearchResult> result = [
//     ItemSearchResult(
//         reviewers: 245,
//         sessions: 123,
//         price: 0,
//         avatar: '',
//         rating: 4.99,
//         name: "Foti Panagiotakopulos",
//         role: "Founder @ GrowthMentor",
//         mentorId: "uuid",
//         nextAvailable: DateTime.now(),
//         unit: Unit.hour,
//         skills: [
//           "Designer",
//           "Development Web",
//           "Mobile App",
//           "Trading",
//           "AI - Machine learning",
//           "Marketing",
//           "Content Creator"
//         ]),
//     ItemSearchResult(
//         reviewers: 245,
//         sessions: 123,
//         price: 12,
//         avatar: '',
//         rating: 4.99,
//         nextAvailable: DateTime.now(),
//         name: "Foti Panagiotakopulos",
//         role: "Founder @ GrowthMentor",
//         mentorId: "uuid",
//         unit: Unit.hour,
//         skills: [
//           "Designer",
//           "Development Web",
//           "Mobile App",
//           "Trading",
//           "AI - Machine learning",
//           "Marketing",
//           "Content Creator"
//         ])
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             RichText(
//                 text: TextSpan(children: [
//               TextSpan(
//                   text: "Result's for ",
//                   style: context.labelLarge!.copyWith(
//                       color: Theme.of(context).colorScheme.onSurface)),
//               TextSpan(
//                   text: "“${widget.keyword ?? ''}”",
//                   style: context.labelLarge!
//                       .copyWith(color: Theme.of(context).colorScheme.primary))
//             ])),
//             Text("$total found",
//                 style: context.labelLarge!
//                     .copyWith(color: Theme.of(context).colorScheme.primary))
//           ],
//         ),
//         const SizedBox(height: 24),
//         Wrap(
//           spacing: 10,
//           children: [...result.map((item) => ItemResult(item: item))],
//         )
//       ],
//     );
//   }
// }
