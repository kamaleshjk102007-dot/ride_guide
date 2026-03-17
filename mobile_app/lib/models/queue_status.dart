class QueueStatus {
  QueueStatus({
    required this.id,
    required this.rideName,
    required this.rideId,
    required this.rideImage,
    required this.rideType,
    required this.capacity,
    required this.duration,
    required this.peopleInQueue,
    required this.currentWaitTime,
    required this.status,
  });

  final String id;
  final String rideName;
  final String rideId;
  final String rideImage;
  final String rideType;
  final int capacity;
  final int duration;
  final int peopleInQueue;
  final int currentWaitTime;
  final String status;

  factory QueueStatus.fromJson(Map<String, dynamic> json) => QueueStatus(
        id: json['_id'] ?? '',
        rideName: json['ride_id']?['ride_name'] ?? '',
        rideId: json['ride_id']?['_id'] ?? '',
        rideImage: json['ride_id']?['image'] ?? '',
        rideType: json['ride_id']?['type'] ?? '',
        capacity: json['ride_id']?['capacity'] ?? 0,
        duration: json['ride_id']?['duration'] ?? 0,
        peopleInQueue: json['people_in_queue'] ?? 0,
        currentWaitTime: json['current_wait_time'] ?? 0,
        status: json['ride_id']?['status'] ?? '',
      );
}
