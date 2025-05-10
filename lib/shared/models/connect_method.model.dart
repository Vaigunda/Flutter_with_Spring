class ConnectMethodModel {
  const ConnectMethodModel({required this.id, required this.name});

  final String id;
  final String name;

  // Factory constructor to create an instance of ConnectMethodModel from JSON
  factory ConnectMethodModel.fromJson(Map<String, dynamic> json) {
    return ConnectMethodModel(
      id: json['id'] as String, // Parsing the id
      name: json['name'] as String, // Parsing the name
    );
  }
}
