class TeachingScheduleModel {
  final String id;
  final DateTime dateStart;
  final DateTime timeStart;
  final DateTime timeEnd;
  final bool booked;

  // Constructor for the model
  const TeachingScheduleModel({
    required this.id,
    required this.dateStart,
    required this.timeStart,
    required this.timeEnd,
    required this.booked,
  });

  // Factory method to create an instance from JSON data
  factory TeachingScheduleModel.fromJson(Map<String, dynamic> json) {
    return TeachingScheduleModel(
      id: json['id'],
      dateStart: DateTime.parse(json['dateStart']).toUtc(),
      timeStart: DateTime.parse(json['timeStart']).toUtc(),
      timeEnd: DateTime.parse(json['timeEnd']).toUtc(),
      booked: json['booked'],
    );
  }

  // Method to convert the model instance to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateStart': dateStart.toIso8601String(),
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'booked': booked,
    };
  }

  @override
  String toString() {
    return 'TeachingScheduleModel(dateStart: $dateStart, timeStart: $timeStart, timeEnd: $timeEnd)';
  }
}
