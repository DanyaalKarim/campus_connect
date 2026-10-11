import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement_model.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== STATE ====================
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> _filteredAnnouncements = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';

  // ==================== GETTERS ====================
  List<AnnouncementModel> get announcements => _announcements;
  List<AnnouncementModel> get filteredAnnouncements =>
      _filteredAnnouncements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // ==================== CATEGORIES ====================
  static const List<String> categories = [
    'All',
    'University',
    'Department',
    'Society',
    'Academic',
    'Event',
    'Important',
  ];

  // ==================== LOAD ANNOUNCEMENTS ====================
  Future<void> loadAnnouncements() async {
    _setLoading(true);
    _clearError();

    try {
      _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
          _announcements = snapshot.docs
              .map((doc) => AnnouncementModel.fromMap(
            doc.data(),
            doc.id,
          ))
              .toList();
          _applyFilters();
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load announcements');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Something went wrong');
      _setLoading(false);
    }
  }

  // ==================== FILTER BY CATEGORY ====================
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // ==================== APPLY FILTERS ====================
  void _applyFilters() {
    if (_selectedCategory == 'All') {
      _filteredAnnouncements = List.from(_announcements);
    } else {
      _filteredAnnouncements = _announcements
          .where((a) => a.category == _selectedCategory)
          .toList();
    }

    // Sort by priority and date
    _filteredAnnouncements.sort((a, b) {
      // Important first
      if (a.isImportant && !b.isImportant) return -1;
      if (!a.isImportant && b.isImportant) return 1;
      // Then by date
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // ==================== RECENT ====================
  List<AnnouncementModel> getRecentAnnouncements({int limit = 3}) {
    return _announcements.take(limit).toList();
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
  Future<void> refreshAnnouncements() async {
    _announcements = [];
    _filteredAnnouncements = [];
    await loadAnnouncements();
  }
}