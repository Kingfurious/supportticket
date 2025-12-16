import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ticket.dart';
import 'auth_service.dart';

/// Service for handling ticket API calls
class TicketService {
  static const String baseUrl = ApiConfig.baseUrl;

  final AuthService _authService = AuthService();

  /// Get authorization headers with Firebase ID token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Create a new ticket
  Future<Ticket> createTicket({
    required String title,
    required String description,
  }) async {
    try {
      final headers = await _getHeaders();
      final userId = _authService.currentUser?.uid;
      
      if (userId == null) {
        throw 'User not authenticated';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw 'Failed to create ticket: ${response.body}';
      }
    } catch (e) {
      throw 'Error creating ticket: ${e.toString()}';
    }
  }

  /// Get all tickets for the current user
  Future<List<Ticket>> getTickets() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw 'Failed to fetch tickets: ${response.body}';
      }
    } catch (e) {
      throw 'Error fetching tickets: ${e.toString()}';
    }
  }

  /// Get ticket details by ID
  Future<Ticket> getTicketById(String ticketId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw 'Failed to fetch ticket: ${response.body}';
      }
    } catch (e) {
      throw 'Error fetching ticket: ${e.toString()}';
    }
  }

  /// Update ticket status
  Future<Ticket> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/tickets/$ticketId/status'),
        headers: headers,
        body: jsonEncode({
          'status': status.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw 'Failed to update ticket status: ${response.body}';
      }
    } catch (e) {
      throw 'Error updating ticket status: ${e.toString()}';
    }
  }
}

