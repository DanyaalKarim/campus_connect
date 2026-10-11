import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COLLECTIONS ====================
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String registrationsCollection = 'registrations';
  static const String announcementsCollection = 'announcements';
  static const String attendanceCollection = 'attendance';
  static const String feedbackCollection = 'feedback';
  static const String societiesCollection = 'societies';
  static const String certificatesCollection = 'certificates';

  // ==================== EVENTS ====================

  /// Get all approved events (real-time stream)
  Stream<List<EventModel>> getApprovedEvents() {
    return _firestore
        .collection(eventsCollection)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
        doc.data(),
        doc.id,
      ))
          .toList();

      // Sort by date (earliest first)
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  /// Get all events (real-time stream)
  Stream<List<EventModel>> getAllEvents() {
    return _firestore
        .collection(eventsCollection)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
        doc.data(),
        doc.id,
      ))
          .toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  /// Get events by category
  Stream<List<EventModel>> getEventsByCategory(String category) {
    if (category == 'All') {
      return getApprovedEvents();
    }

    return _firestore
        .collection(eventsCollection)
        .where('status', isEqualTo: 'approved')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
        doc.data(),
        doc.id,
      ))
          .toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  /// Get single event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(eventsCollection).doc(eventId).get();

      if (!doc.exists) return null;

      return EventModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get upcoming events (limit)
  Stream<List<EventModel>> getUpcomingEvents({int limit = 5}) {
    return _firestore
        .collection(eventsCollection)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
        doc.data(),
        doc.id,
      ))
          .where((event) => event.date.isAfter(now))
          .toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events.take(limit).toList();
    });
  }

  /// Get featured events (limit)
  Stream<List<EventModel>> getFeaturedEvents({int limit = 3}) {
    return _firestore
        .collection(eventsCollection)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
        doc.data(),
        doc.id,
      ))
          .toList();

      // Sort by registration count (most popular first)
      events.sort(
              (a, b) => b.registeredCount.compareTo(a.registeredCount));
      return events.take(limit).toList();
    });
  }

  /// Search events by title
  Stream<List<EventModel>> searchEvents(String query) {
    return _firestore
        .collection(eventsCollection)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(
        doc.data(),
        doc.id,
      ))
          .where((event) {
        final title = event.title.toLowerCase();
        final description = event.description.toLowerCase();
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  /// Create new event
  Future<String?> createEvent(EventModel event) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .add(event.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Update event
  Future<String?> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .update(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Delete event
  Future<String?> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==================== REGISTRATIONS ====================

  /// Register for event
  Future<String?> registerForEvent({
    required String eventId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String studentNumber,
  }) async {
    try {
      // Check if already registered
      QuerySnapshot existing = await _firestore
          .collection(registrationsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (existing.docs.isNotEmpty) {
        return 'You are already registered for this event';
      }

      // Check if event is full
      DocumentSnapshot eventDoc = await _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .get();

      if (!eventDoc.exists) {
        return 'Event not found';
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final capacity = eventData['capacity'] ?? 0;
      final registeredCount = eventData['registeredCount'] ?? 0;

      if (registeredCount >= capacity) {
        return 'Event is full';
      }

      // Generate unique QR code
      final qrCode =
          'CC-${DateTime.now().millisecondsSinceEpoch}-${studentId.substring(0, 4)}';

      // Create registration
      await _firestore.collection(registrationsCollection).add({
        'eventId': eventId,
        'eventTitle': eventData['title'] ?? '',
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'studentNumber': studentNumber,
        'status': 'registered',
        'qrCode': qrCode,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      // Increment registered count
      await _firestore.collection(eventsCollection).doc(eventId).update({
        'registeredCount': FieldValue.increment(1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Get user registrations
  Stream<QuerySnapshot> getUserRegistrations(String studentId) {
    return _firestore
        .collection(registrationsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots();
  }

  /// Check if user is registered for event
  Future<bool> isUserRegistered({
    required String eventId,
    required String studentId,
  }) async {
    try {
      QuerySnapshot result = await _firestore
          .collection(registrationsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('studentId', isEqualTo: studentId)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Cancel registration
  Future<String?> cancelRegistration(String registrationId) async {
    try {
      DocumentSnapshot regDoc = await _firestore
          .collection(registrationsCollection)
          .doc(registrationId)
          .get();

      if (!regDoc.exists) return 'Registration not found';

      final regData = regDoc.data() as Map<String, dynamic>;
      final eventId = regData['eventId'];

      await _firestore
          .collection(registrationsCollection)
          .doc(registrationId)
          .delete();

      // Decrement registered count
      await _firestore.collection(eventsCollection).doc(eventId).update({
        'registeredCount': FieldValue.increment(-1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}