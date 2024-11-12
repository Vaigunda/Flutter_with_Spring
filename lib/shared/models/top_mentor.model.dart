// lib/shared/models/top_mentor.model.dart

class TopMentorModel {
  const TopMentorModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rate,
    required this.numberOfMentoree,
    required this.categories,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final double rate;
  final int numberOfMentoree;
  final List<String> categories;

  // Factory constructor to create a TopMentorModel from JSON
  factory TopMentorModel.fromJson(Map<String, dynamic> json) {
    return TopMentorModel(
      id: json['id'] ?? '', // Assuming you have an 'id' or can generate it.
      name: json['name'],
      avatarUrl: json['avatar_url'],
      rate: json['rate'].toDouble(),
      numberOfMentoree: json['number_of_mentoree'],
      categories: List<String>.from(json['category_names']),
    );
  }
}
