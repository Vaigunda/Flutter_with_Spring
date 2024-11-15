// import 'dart:convert';

class ProfileMentor {
  final int id;
  final String name;
  final String role;
  final String avatarUrl;
  final bool verified;
  final String bio;
  final double rate;
  final int numberOfMentoree;
  final List<Experience> experiences;
  final List<Review> reviews;
  final List<Certificate> certificates;
  final List<Category> categories;
  final Free free;

  ProfileMentor({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.verified,
    required this.bio,
    required this.rate,
    required this.numberOfMentoree,
    required this.experiences,
    required this.reviews,
    required this.certificates,
    required this.categories,
    required this.free,
  });

  // Factory method to create a ProfileMentor object from a JSON map
  factory ProfileMentor.fromJson(Map<String, dynamic> json) {
    return ProfileMentor(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
      verified: json['verified'],
      bio: json['bio'],
      rate: json['rate'].toDouble(),
      numberOfMentoree: json['numberOfMentoree'],
      experiences: (json['experiences'] as List)
          .map((e) => Experience.fromJson(e))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((e) => Review.fromJson(e))
          .toList(),
      certificates: (json['certificates'] as List)
          .map((e) => Certificate.fromJson(e))
          .toList(),
      categories: (json['categories'] as List)
          .map((e) => Category.fromJson(e))
          .toList(),
      free: Free.fromJson(json['free']),
    );
  }

  // Method to retrieve mentor by ID from a list
  static ProfileMentor? getMentorById(List<ProfileMentor> mentors, int mentorId) {
  try {
    return mentors.firstWhere((mentor) => mentor.id == mentorId);
  } catch (e) {
    return null; // Return null if no mentor is found
  }
}
}

class Experience {
  final int id;
  final int mentorId;
  final String role;
  final String companyName;
  final DateTime? startDate;  // Change String? to DateTime?
  final DateTime? endDate;    // Change String? to DateTime?
  final String? description;

  Experience({
    required this.id,
    required this.mentorId,
    required this.role,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      mentorId: json['mentor_id'],
      role: json['role'],
      companyName: json['company_name'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      description: json['description'],
    );
  }
}

class Review {
  final int id;
  final int mentorId;
  final String message;
  final DateTime? createDate;
  final String createdById;

  Review({
    required this.id,
    required this.mentorId,
    required this.message,
    required this.createDate,
    required this.createdById,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      mentorId: json['mentor_id'],
      message: json['message'],
      createDate: json['create_date'] != null
          ? DateTime.parse(json['create_date']) // Parse the string into DateTime
          : null,
      createdById: json['created_by_id'],
    );
  }
}

class Certificate {
  final int id;
  final int mentorId;
  final String name;
  final String provideBy;
  final DateTime? createDate;
  final String imageUrl;

  Certificate({
    required this.id,
    required this.mentorId,
    required this.name,
    required this.provideBy,
    required this.createDate,
    required this.imageUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      mentorId: json['mentor_id'],
      name: json['name'],
      provideBy: json['provide_by'],
      createDate: json['create_date'] != null
          ? DateTime.parse(json['create_date']) // Parse the string into DateTime
          : null,  // Handle null case if create_date is missing
      imageUrl: json['image_url'],
    );
  }
}

class Category {
  final String id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class Free {
  final Unit unit;
  final int price;

  Free({
    required this.unit,
    required this.price,
  });

  factory Free.fromJson(Map<String, dynamic> json) {
    return Free(
      unit: Unit.fromJson(json['unit']),
      price: json['price'],
    );
  }
}

class Unit {
  final String name;

  Unit({
    required this.name,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      name: json['name'],
    );
  }
}
