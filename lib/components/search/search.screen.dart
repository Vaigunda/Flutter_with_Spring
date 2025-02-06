import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mentor/shared/utils/extensions.dart';

import '../../shared/models/category.model.dart';
import 'model/popular_search.dart';
import 'widgets/search_result.widget.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  late FocusNode focusNode = FocusNode();
  bool showResults = false;
  List<PopularSearch> popularList = [
    PopularSearch(id: 1, totalResult: 980, title: "Figma"),
    PopularSearch(id: 2, totalResult: 489, title: "Webflow"),
    PopularSearch(id: 3, totalResult: 567, title: "Graffiti")
  ];

  List<CategoryModel> categories = [];

  List<bool> _isChecked = List<bool>.filled(5, false);

  late String usertoken;
  var provider;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    getCategories();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    focusNode.dispose();
  }

  getCategories() async {
    var response = await http.get(Uri.parse('http://localhost:8080/api/mentors/categories'));
        if (response.statusCode == 200) {
           List<dynamic> data = json.decode(response.body);
           categories = data.map((item) => CategoryModel.fromJson(item)).toList();
        }
        setState(() {
          categories = categories; // Enable displaying results
        });
  }

  void handleSearch() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        showResults = true; // Enable displaying results
      });
    }
  }
  void _handleEnterKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (searchController.text.isNotEmpty) {
        handleSearch();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  return SafeArea(
    child: RawKeyboardListener(
        focusNode: focusNode,
        onKey: _handleEnterKey,
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                //focusNode: focusNode,
                controller: searchController,
                decoration: InputDecoration(
                  filled: focusNode.hasFocus,
                  fillColor: focusNode.hasFocus
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                  prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  /*suffixIcon: Container(
                      decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Theme.of(context).colorScheme.outline)),
                      ),
                      child: RotatedBox(
                          quarterTurns: 1,
                          child: IconButton(
                              onPressed: () =>
                                  {context.push(AppRoutes.filter)},
                              icon: const Icon(FontAwesomeIcons.sliders)))),*/
                  focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary)),
                  isDense: true,
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  hintText: 'Enter a search term',
                ),
              ),
              const SizedBox(height: 8), // Space between the TextField and button
              ElevatedButton(
                onPressed: handleSearch,
                child: const Text('Search'),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                children: [
                  if (!showResults) ...[
                    // Show Popular List and Categories if not searching
                    //const SizedBox(height: 32),
                    //renderPopularList(context),
                    const SizedBox(height: 23),
                    renderCategories(),
                  ] else ...[
                    // Show search results when the Search button is pressed
                    const SizedBox(height: 24),
                    SearchResult(
                      key: ValueKey(searchController.text), // Key forces widget rebuild
                      keyword: searchController.text,
                    ),
                  ],
                ],
              )))
            ],
          ))));
}

  Widget renderPopularList(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Popular Searchs", style: context.titleMedium),
      const SizedBox(height: 16),
      ...popularList
          .map((item) => ListTile(
                tileColor: Colors.transparent,
                dense: true,
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                minLeadingWidth: 10,
                contentPadding: const EdgeInsets.all(0),
                trailing: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () {},
                ),
                title: Row(children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.titleSmall),
                  const SizedBox(width: 5),
                  Text("(${item.totalResult} searches)",
                      maxLines: 1, style: context.bodySmall)
                ]),
              ))
          
    ]);
  }

  Widget renderCategories() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Browse Categories", style: context.titleMedium),
      const SizedBox(height: 16),
      ...categories.asMap().entries.map((entry) {
        int index = entry.key;
        CategoryModel item = entry.value;

        // Ensure _isChecked has the correct size
        if (_isChecked.length < categories.length) {
          _isChecked = List<bool>.filled(categories.length, false);
        }

        return ListTile(
          tileColor: Colors.transparent,
          dense: true,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          minLeadingWidth: 10,
          contentPadding: const EdgeInsets.all(0),
          trailing: Checkbox(
            value: _isChecked[index],
            onChanged: (bool? value) {
              setState(() {
                _isChecked[index] = value!;
              });
            },
          ),
          leading: Icon(item.getIcon(),
              color: Theme.of(context).colorScheme.onSurface),
          title: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.titleSmall,
          ),
          /*onTap: () {
            // Toggle checkbox when tapping the tile
            setState(() {
              _isChecked[index] = !_isChecked[index];
              searchController.text = searchController.text.isNotEmpty ? "${searchController.text}, ${categories[index].name}" :
                                      categories[index].name;
            });
          },*/
          onTap: () {
            setState(() {
              _isChecked[index] = !_isChecked[index];
              if (!_isChecked[index]) {
                List<String> currentTerms = searchController.text.split(',');
                currentTerms.remove(categories[index].name);
                searchController.text = currentTerms.join(',');
              } else {
                searchController.text = searchController.text.isNotEmpty
                    ? "${searchController.text},${categories[index].name}"
                    : categories[index].name;
              }
            }
          );
        },
        );
      }),
    ],
  );
}

}
