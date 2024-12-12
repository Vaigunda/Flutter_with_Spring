// import 'dart:convert';

class AllMentors {
  final int id;
  final String name;
  final String email;
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
  final List<FixedTimeSlot> timeSlots;
  final Free free;

  AllMentors({
    required this.id,
    required this.name,
    required this.email,
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
    required this.timeSlots,
    required this.free,
  });

  AllMentors copyWith({                                                                                               
    int? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    bool? verified,
    String? bio,
    double? rate,
    int? numberOfMentoree,
    List<Experience>? experiences,
    List<Review>? reviews,
    List<Certificate>? certificates,
    List<Category>? categories,
    List<FixedTimeSlot>? timeSlots,  // Added this
    Free? free,
  }) {
    return AllMentors(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
      rate: rate ?? this.rate,
      numberOfMentoree: numberOfMentoree ?? this.numberOfMentoree,
      experiences: experiences ?? this.experiences,
      reviews: reviews ?? this.reviews,
      certificates: certificates ?? this.certificates,
      categories: categories ?? this.categories,
      timeSlots: timeSlots ?? this.timeSlots, // Added this
      free: free ?? this.free,
    );
  }

  // Factory method to create a ProfileMentor object from a JSON map
  factory AllMentors.fromJson(Map<String, dynamic> json) {
    return AllMentors(
      id: json['id'],
      name: json['name'],
      email: json['email'],
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
      timeSlots: (json['timeSlots'] as List)
          .map((e) => FixedTimeSlot.fromJson(e))
          .toList(),    
      free: Free.fromJson(json['free']),
    );
  }

  // Convert the ProfileMentor instance to a Map for sending via HTTP requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'verified': verified,
      'bio': bio,
      'rate': rate,
      'numberOfMentoree': numberOfMentoree,
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'timeSlots': timeSlots.map((e) => e.toJson()).toList(),
      'free': free.toJson(),
    };
  }

  // Method to retrieve mentor by ID from a list
  static AllMentors? getMentorById(List<AllMentors> mentors, int mentorId) {
  try {
    return mentors.firstWhere((mentor) => mentor.id == mentorId);
  } catch (e) {
    return null; // Return null if no mentor is found
  }
}
}


class FixedTimeSlot {
  final int id;
  final String timeStart;
  final String timeEnd;
  final int mentorId;

  FixedTimeSlot({
    required this.id,
    required this.timeStart,
    required this.timeEnd,
    required this.mentorId,
  });

  // Factory method to create a FixedTimeSlot from JSON
  factory FixedTimeSlot.fromJson(Map<String, dynamic> json) {
    return FixedTimeSlot(
      id: json['id'],
      timeStart: json['timeStart'], // Assuming these are strings
      timeEnd: json['timeEnd'],     // Assuming these are strings
      mentorId: json['mentorId'],
    );
  }

  // CopyWith Method
  FixedTimeSlot copyWith({
    int? id,
    String? timeStart,
    String? timeEnd,
    int? mentorId,
  }) {
    return FixedTimeSlot(
      id: id ?? this.id,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      mentorId: mentorId ?? this.mentorId,
    );
  }

  // Convert FixedTimeSlot to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time_start': timeStart, // Assuming these are already formatted strings
      'time_end': timeEnd,     // Assuming these are already formatted strings
      'mentor_id': mentorId,
    };
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

  // toJson method to convert to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'role': role,
      'company_name': companyName,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
    };
  }


  Experience copyWith({
    int? id,
    int? mentorId,
    String? role,
    String? companyName,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
  }) {
    return Experience(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      role: role ?? this.role,
      companyName: companyName ?? this.companyName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }

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

  // toJson method to convert to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'message': message,
      'create_date': createDate?.toIso8601String(),
      'created_by_id': createdById,
    };
  }

  // CopyWith Method
  Review copyWith({
    int? id,
    int? mentorId,
    String? message,
    DateTime? createDate,
    String? createdById,
  }) {
    return Review(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      message: message ?? this.message,
      createDate: createDate ?? this.createDate,
      createdById: createdById ?? this.createdById,
    );
  }

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

  // toJson method to convert to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'name': name,
      'provide_by': provideBy,
      'create_date': createDate?.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  Certificate copyWith({
    int? id,
    int? mentorId,
    String? name,
    String? provideBy,
    DateTime? createDate,
    String? imageUrl,
  }) {
    return Certificate(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      name: name ?? this.name,
      provideBy: provideBy ?? this.provideBy,
      createDate: createDate ?? this.createDate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

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

  // toJson method to convert to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

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

   // toJson method to convert to a map
  Map<String, dynamic> toJson() {
    return {
      'unit': unit.toJson(),
      'price': price,
    };
  }

  Free copyWith({
    Unit? unit,
    int? price,
  }) {
    return Free(
      unit: unit ?? this.unit,
      price: price ?? this.price,
    );
  }

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

  // toJson method to convert to a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  Unit copyWith({
    String? name,
  }) {
    return Unit(
      name: name ?? this.name,
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      name: json['name'],
    );
  }
}
