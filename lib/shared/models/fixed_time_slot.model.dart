class FixedTimeSlotModel {
  final String id;
  final String timeStart;
  final String timeEnd;
  final String status;

  FixedTimeSlotModel({
    required this.id,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
  });

  factory FixedTimeSlotModel.fromJson(Map<String, dynamic> json) {
    return FixedTimeSlotModel(
      id: json['id'].toString(),
      timeStart: json['timeStart'], // String "HH:mm" format
      timeEnd: json['timeEnd'],    // String "HH:mm" format
      status: json['status'],      // String "available" or "occupied"
    );
  }
}
