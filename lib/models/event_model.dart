import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String time;
  final String venue;
  final int capacity;
  final int registeredCount;
  final String organizerId;
  final String organizerName;
  final String posterUrl;
  final String speaker;
  final DateTime registrationDeadline;
  final String status;
  final DateTime createdAt;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.venue,
    required this.capacity,
    required this.registeredCount,
    required this.organizerId,
    required this.organizerName,
    required this.posterUrl,
    required this.speaker,
    required this.registrationDeadline,
    required this.status,
    required this.createdAt,
  });

  // ==================== FROM FIRESTORE ====================
  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      eventId: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      date: _parseDate(map['date']),
      time: map['time'] ?? '',
      venue: map['venue'] ?? '',
      capacity: _parseInt(map['capacity']),
      registeredCount: _parseInt(map['registeredCount']),
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      posterUrl: map['posterUrl'] ?? '',
      speaker: map['speaker'] ?? '',
      registrationDeadline: _parseDate(map['registrationDeadline']),
      status: map['status'] ?? 'pending',
      createdAt: _parseDate(map['createdAt']),
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'time': time,
      'venue': venue,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'posterUrl': posterUrl,
      'speaker': speaker,
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ==================== HELPERS ====================
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ==================== COMPUTED PROPERTIES ====================
  bool get isRegistrationOpen {
    return DateTime.now().isBefore(registrationDeadline) &&
        registeredCount < capacity &&
        status == 'approved';
  }

  bool get isFull {
    return registeredCount >= capacity;
  }

  bool get isDeadlinePassed {
    return DateTime.now().isAfter(registrationDeadline);
  }

  bool get isUpcoming {
    return date.isAfter(DateTime.now());
  }

  bool get isPast {
    return date.isBefore(DateTime.now());
  }

  double get registrationProgress {
    if (capacity == 0) return 0;
    return registeredCount / capacity;
  }

  int get availableSeats {
    return capacity - registeredCount;
  }

  // ==================== DISPLAY HELPERS ====================
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedDeadline {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${registrationDeadline.day} ${months[registrationDeadline.month - 1]} ${registrationDeadline.year}';
  }
}