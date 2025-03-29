

// ignore_for_file: prefer_typing_uninitialized_variables

// categories.dart
import 'package:flutter/material.dart';
import 'package:mentor/shared/models/category.model.dart';
import 'package:mentor/shared/services/categories.service.dart';
import 'package:mentor/shared/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key});

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  late Future<List<CategoryModel>> categoriesFuture;

  late String usertoken;
  var provider;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    categoriesFuture = CategoriesService().fetchCategories(usertoken); // Fetch categories on widget init
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Categories",
              style: context.headlineSmall,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder<List<CategoryModel>>(
          future: categoriesFuture, // Use the fetched data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint('Error fetching categories: ${snapshot.error}');
              return _buildNoCategoriesMessage(context);
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoCategoriesMessage(context);
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                spacing: 10, // Horizontal spacing
                runSpacing: 15, // Vertical spacing
                children: snapshot.data!
                    .map((cat) => _chip(cat, context))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoCategoriesMessage(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 1.0), // Align with the title
      child: Text('No categories found'),
    );
  }



  Widget _chip(CategoryModel cat, BuildContext context) {
    return Chip(
      autofocus: true,
      label: Text(
        cat.name,
        style: context.titleSmall,
      ),
      avatar: Icon(cat.getIcon()), // Use the getIcon() method
    );
  }
}
