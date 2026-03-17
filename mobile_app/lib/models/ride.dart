class Ride {
  Ride({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.image,
    required this.minAge,
    required this.capacity,
    required this.duration,
    required this.status,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final String image;
  final int minAge;
  final int capacity;
  final int duration;
  final String status;

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['_id'] ?? '',
        name: json['ride_name'] ?? '',
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        image: json['image'] ?? '',
        minAge: json['min_age'] ?? 0,
        capacity: json['capacity'] ?? 0,
        duration: json['duration'] ?? 0,
        status: json['status'] ?? '',
      );
}
