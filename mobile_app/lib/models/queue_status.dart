class QueueStatus {
  QueueStatus({
    required this.id,
    required this.rideName,
    required this.peopleInQueue,
    required this.currentWaitTime,
    required this.status,
  });

  final String id;
  final String rideName;
  final int peopleInQueue;
  final int currentWaitTime;
  final String status;

  factory QueueStatus.fromJson(Map<String, dynamic> json) => QueueStatus(
        id: json['_id'] ?? '',
        rideName: json['ride_id']?['ride_name'] ?? '',
        peopleInQueue: json['people_in_queue'] ?? 0,
        currentWaitTime: json['current_wait_time'] ?? 0,
        status: json['ride_id']?['status'] ?? '',
      );
}
