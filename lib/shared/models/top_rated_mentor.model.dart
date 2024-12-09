// lib/shared/models/top_rated_mentor.model.dart

class TopRatedMentorModel {
  const TopRatedMentorModel({
    required this.avatarUrl,
    required this.rate,
    required this.numberOfMentoree,
    required this.name,
    required this.categories,
  });

  final String avatarUrl;
  final double rate;
  final int numberOfMentoree;
  final String name;
  final List<String> categories;

  // Factory constructor to create a TopRatedMentorModel from JSON
  factory TopRatedMentorModel.fromJson(Map<String, dynamic> json) {
    return TopRatedMentorModel(
      avatarUrl: json['avatar_url'],
      rate: (json['rate'] ?? 0).toDouble(),
      numberOfMentoree: json['number_of_mentoree'] ?? 0,
      name: json['name'],
      categories: List<String>.from(json['category_names'] ?? []),
    );
  }
}
