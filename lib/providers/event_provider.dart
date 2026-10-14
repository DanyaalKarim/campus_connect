import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ==================== STATE ====================
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  EventModel? _selectedEvent;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // ==================== GETTERS ====================
  List<EventModel> get events => _events;
  List<EventModel> get filteredEvents => _filteredEvents;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // ==================== CATEGORIES ====================
  static const List<String> categories = [
    'All',
    'Seminars',
    'Workshops',
    'Competitions',
    'Sports',
    'Career',
    'Academic',
    'Society',
    'Cultural',
    'Other',
  ];

  // ==================== LOAD EVENTS ====================
  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();

    try {
      _firestoreService.getApprovedEvents().listen(
            (events) {
          _events = events;
          _applyFilters();
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load events: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Something went wrong: $e');
      _setLoading(false);
    }
  }

  // ==================== LOAD SINGLE EVENT ====================
  Future<void> loadEventById(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedEvent = await _firestoreService.getEventById(eventId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load event: $e');
      _setLoading(false);
    }
  }

  // ==================== FILTER BY CATEGORY ====================
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // ==================== SEARCH ====================
  void searchEvents(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ==================== CLEAR SEARCH ====================
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // ==================== APPLY FILTERS ====================
  void _applyFilters() {
    List<EventModel> result = List.from(_events);

    if (_selectedCategory != 'All') {
      result = result
          .where((event) => event.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((event) {
        return event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.venue.toLowerCase().contains(query);
      }).toList();
    }

    result.sort((a, b) => a.date.compareTo(b.date));

    _filteredEvents = result;
  }

  // ==================== UPCOMING EVENTS ====================
  List<EventModel> getUpcomingEvents({int limit = 5}) {
    final now = DateTime.now();
    return _events
        .where((event) => event.date.isAfter(now))
        .take(limit)
        .toList();
  }

  // ==================== FEATURED EVENTS ====================
  List<EventModel> getFeaturedEvents({int limit = 3}) {
    final events = List<EventModel>.from(_events);
    events.sort((a, b) => b.registeredCount.compareTo(a.registeredCount));
    return events.take(limit).toList();
  }

  // ==================== REGISTER FOR EVENT ====================
  Future<String?> registerForEvent({
    required String eventId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String studentNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final error = await _firestoreService.registerForEvent(
        eventId: eventId,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        studentNumber: studentNumber,
      );

      _setLoading(false);

      if (error != null) {
        _setError(error);
        return error;
      }

      return null;
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return 'Registration failed';
    }
  }

  // ==================== CHECK REGISTRATION ====================
  Future<bool> isUserRegistered({
    required String eventId,
    required String studentId,
  }) async {
    return await _firestoreService.isUserRegistered(
      eventId: eventId,
      studentId: studentId,
    );
  }

  // ==================== GET USER REGISTRATIONS ====================
  Stream getUserRegistrations(String studentId) {
    return _firestoreService.getUserRegistrations(studentId);
  }

  // ==================== CANCEL REGISTRATION (BY EVENT + STUDENT) ====================
  Future<String?> cancelRegistration({
    required String eventId,
    required String studentId,
  }) async {
    _setLoading(true);

    try {
      final error = await _firestoreService.cancelRegistrationByEventAndStudent(
        eventId: eventId,
        studentId: studentId,
      );
      _setLoading(false);

      if (error != null) {
        _setError(error);
        return error;
      }

      return null;
    } catch (e) {
      _setError('Cancellation failed: $e');
      _setLoading(false);
      return 'Cancellation failed';
    }
  }

  // ==================== HELPERS ====================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== REFRESH ====================
  Future<void> refreshEvents() async {
    _events = [];
    _filteredEvents = [];
    await loadEvents();
  }
}