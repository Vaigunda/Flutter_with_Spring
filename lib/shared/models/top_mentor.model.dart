// lib/shared/models/top_mentor.model.dart

class TopMentorModel {
  const TopMentorModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.avatarUrl,
    required this.rate,
    required this.numberOfMentoree,
    required this.categories,
  });

  final String id;
  final String name;
  final String gender;
  final String avatarUrl;
  final double rate;
  final int numberOfMentoree;
  final List<String> categories;

  // Factory constructor to create a TopMentorModel from JSON
  factory TopMentorModel.fromJson(Map<String, dynamic> json) {
    return TopMentorModel(
      id: json['id'], // Assuming you have an 'id' or can generate it.
      name: json['name'],
      gender: json['gender'],
      avatarUrl: json['avatar_url'],
      rate: json['rate'].toDouble(),
      numberOfMentoree: json['number_of_mentoree'],
      categories: List<String>.from(json['category_names']),
    );
  }
  // Method to create a new instance with some fields modified (copyWith)
  TopMentorModel copyWith({
    String? id,
    String? name,
    String? gender,
    String? avatarUrl,
    double? rate,
    int? numberOfMentoree,
    List<String>? categories,
  }) {
    return TopMentorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rate: rate ?? this.rate,
      numberOfMentoree: numberOfMentoree ?? this.numberOfMentoree,
      categories: categories ?? this.categories,
    );
  }
}
