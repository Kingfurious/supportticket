/// Ticket model representing a support ticket
class Ticket {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;

  Ticket({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  // Convert from JSON (from API/Firestore)
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      status: TicketStatus.fromString(json['status'] ?? 'Open'),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as DateTime),
    );
  }

  // Convert to JSON (for API calls)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Ticket status enum
enum TicketStatus {
  open,
  inProgress,
  closed;

  // Create from string
  static TicketStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'in progress':
        return TicketStatus.inProgress;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  // Convert to string for display
  @override
  String toString() {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  // Get color for status badge
  String get colorHex {
    switch (this) {
      case TicketStatus.open:
        return '#FF6B6B'; // Red
      case TicketStatus.inProgress:
        return '#4ECDC4'; // Teal
      case TicketStatus.closed:
        return '#95E1D3'; // Green
    }
  }
}

