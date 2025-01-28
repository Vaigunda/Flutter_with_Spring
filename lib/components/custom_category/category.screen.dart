import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentor/shared/models/category.model.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:mentor/shared/services/token.service.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late String usertoken;
  late var provider;

  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;

    _fetchCategories(); // Fetch categories on init
  }

  Future<void> _fetchCategories() async {
    try {
      // Check if token has expired
      bool isExpired = JwtDecoder.isExpired(usertoken);
      if (isExpired) {
        final tokenService = TokenService();
        tokenService.checkToken(usertoken, context);
      } else {
        final url = Uri.parse('http://localhost:8080/api/mentors/categories');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $usertoken',
          },
        );

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            categories = data.map((item) => CategoryModel.fromJson(item)).toList();
          });
        } else {
          throw Exception('Failed to fetch categories');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: ${e.toString()}')),
      );
    }
  }

  Future<void> _addCategory(String name) async {
    try {
      // Check if token has expired
      bool isExpired = JwtDecoder.isExpired(usertoken);
      if (isExpired) {
        final tokenService = TokenService();
        tokenService.checkToken(usertoken, context);
      } else {
        final url = Uri.parse('http://localhost:8080/api/categories/add');
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $usertoken',
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "name": name,
            "icon": "FontAwesomeIcons.code", // Add a default icon if none is provided
          }),
        );

        if (response.statusCode == 200) {
          // Category successfully added
          _fetchCategories(); // Refresh the category list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully')),
          );
        } else if (response.statusCode == 400) {
          // Category already exists
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category already exists')),
          );
        } else {
          // Other errors
          throw Exception('Failed to add category');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding category'),duration: Duration(seconds: 2),),
      );
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      // Check if token has expired
      bool isExpired = JwtDecoder.isExpired(usertoken);
      if (isExpired) {
        final tokenService = TokenService();
        tokenService.checkToken(usertoken, context);
      } else {
        final url = Uri.parse('http://localhost:8080/api/categories/delete/$id');
        final response = await http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $usertoken',
          },
        );

        if (response.statusCode == 200) {
          _fetchCategories(); // Refresh the category list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully'),duration: Duration(seconds: 2),),
          );
          
        } else {
          throw Exception('Failed to delete category');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting category'),duration: Duration(seconds: 2),),
      );
    }
  }

  Future<void> _editCategory(String id, String newName) async {
    try {
      // Check if token has expired
      bool isExpired = JwtDecoder.isExpired(usertoken);
      if (isExpired) {
        final tokenService = TokenService();
        tokenService.checkToken(usertoken, context);
      } else {
        final url = Uri.parse('http://localhost:8080/api/categories/edit/$id');
        final response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $usertoken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': newName,
          }),
        );

        if (response.statusCode == 200) {
          _fetchCategories(); // Refresh the category list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category edited successfully'),
            duration: Duration(seconds: 2),),
          );
        } else if (response.statusCode == 400) {
          // Category already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category already exists')),
          );
        } else {
          throw Exception('Failed to edit category');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error editing category'),duration: Duration(seconds: 2),),
      );
    }
  }

  void _showAddCategoryDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addCategory(nameController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(String id, String currentName) {
    TextEditingController nameController = TextEditingController();
    nameController.text = currentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editCategory(id, nameController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: Text('No categories found'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                IconData categoryIcon = category.getIcon();
                return ListTile(
                  leading: Icon(categoryIcon),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditCategoryDialog(
                          category.id,
                          category.name,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCategory(category.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
