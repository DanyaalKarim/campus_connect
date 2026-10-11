import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String announcementId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String createdBy;
  final String createdByName;
  final String targetEventId;
  final DateTime createdAt;

  AnnouncementModel({
    required this.announcementId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.createdBy,
    required this.createdByName,
    required this.targetEventId,
    required this.createdAt,
  });

  // ==================== FROM FIRESTORE ====================
  factory AnnouncementModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    return AnnouncementModel(
      announcementId: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'University',
      priority: map['priority'] ?? 'medium',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      targetEventId: map['targetEventId'] ?? '',
      createdAt: _parseDate(map['createdAt']),
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'targetEventId': targetEventId,
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

  // ==================== COMPUTED PROPERTIES ====================
  bool get isImportant {
    return priority == 'high' || category == 'Important';
  }

  bool get isRecent {
    final difference = DateTime.now().difference(createdAt);
    return difference.inHours < 24;
  }

  bool get isNew {
    final difference = DateTime.now().difference(createdAt);
    return difference.inDays < 3;
  }

  // ==================== DISPLAY HELPERS ====================
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String get formattedDateTime {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = createdAt.hour > 12
        ? createdAt.hour - 12
        : createdAt.hour == 0
        ? 12
        : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}, $hour:$minute $period';
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return formattedDate;
    }
  }
}