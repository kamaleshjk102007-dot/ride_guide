import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/queue_status.dart';
import '../models/ride.dart';
import '../models/ticket.dart';

class ApiService {
  ApiService({this.baseUrl = AppConfig.apiBaseUrl});

  final String baseUrl;

  Future<List<Ride>> getRides() async {
    final response = await http.get(Uri.parse('$baseUrl/rides'));
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Ride.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> bookTicket({
    required String visitorId,
    required String rideId,
    required double price,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'visitor_id': visitorId,
        'ride_id': rideId,
        'price': price,
      }),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Ticket>> getTickets(String visitorId) async {
    final response = await http.get(Uri.parse('$baseUrl/tickets/$visitorId'));
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Ticket.fromJson(item)).toList();
  }

  Future<List<QueueStatus>> getQueue() async {
    final response = await http.get(Uri.parse('$baseUrl/queue'));
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => QueueStatus.fromJson(item)).toList();
  }

  Future<void> makePayment({
    required String ticketId,
    required String visitorId,
    required double amount,
    required String paymentMethod,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ticket_id': ticketId,
        'visitor_id': visitorId,
        'amount': amount,
        'payment_method': paymentMethod,
      }),
    );
  }

  Future<void> submitFeedback({
    required String visitorId,
    required String rideId,
    required int rating,
    required String comment,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'visitor_id': visitorId,
        'ride_id': rideId,
        'rating': rating,
        'comment': comment,
      }),
    );
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(Uri.parse('$baseUrl/analytics/dashboard'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getRidePopularity() async {
    final response = await http.get(Uri.parse('$baseUrl/analytics/ride-popularity'));
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getVisitorStats() async {
    final response = await http.get(Uri.parse('$baseUrl/analytics/visitor-stats'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getStaff() async {
    final response = await http.get(Uri.parse('$baseUrl/staff'));
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<List<dynamic>> getMaintenance() async {
    final response = await http.get(Uri.parse('$baseUrl/maintenance'));
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateRide({
    required String rideId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rides/$rideId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
