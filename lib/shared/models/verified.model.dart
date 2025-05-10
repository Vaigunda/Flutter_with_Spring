class VerifiedMentor { 
  final String avatarUrl;
  final gender;
  final int numberOfMentoree;
  final String name;
  final List<String> categories; // Field name remains "categories"

  VerifiedMentor({
    required this.avatarUrl,
    required this.gender,
    required this.numberOfMentoree,
    required this.name,
    required this.categories,
  });

  // Factory method to create a VerifiedMentor instance from JSON
  factory VerifiedMentor.fromJson(Map<String, dynamic> json) {
    return VerifiedMentor(
      avatarUrl: json['avatar_url'] ?? '', // Default to an empty string if null
      gender: json['gender'] ?? '',
      numberOfMentoree: json['number_of_mentoree'] ?? 0, // Default to 0 if null
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if null
      categories: List<String>.from(json['category_names'] ?? []), // Updated to match "category_names"
    );
  }
}
