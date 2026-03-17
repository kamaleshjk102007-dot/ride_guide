class Ticket {
  Ticket({
    required this.id,
    required this.rideName,
    required this.bookingDate,
    required this.price,
    required this.status,
    required this.qrCodeData,
  });

  final String id;
  final String rideName;
  final String bookingDate;
  final double price;
  final String status;
  final String qrCodeData;

  factory Ticket.fromJson(Map<String, dynamic> json, {String qrCodeData = ''}) => Ticket(
        id: json['_id'] ?? '',
        rideName: json['ride_id']?['ride_name'] ?? 'Ride',
        bookingDate: json['booking_date'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        status: json['status'] ?? '',
        qrCodeData: qrCodeData,
      );
}
