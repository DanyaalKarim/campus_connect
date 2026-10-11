import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateModel {
  final String certificateId;
  final String certificateNumber;
  final String eventId;
  final String eventTitle;
  final String studentId;
  final String studentName;
  final String certificateUrl;
  final DateTime issuedAt;
  final DateTime? downloadedAt;

  CertificateModel({
    required this.certificateId,
    required this.certificateNumber,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
    required this.studentName,
    required this.certificateUrl,
    required this.issuedAt,
    this.downloadedAt,
  });

  // ==================== FROM FIRESTORE ====================
  factory CertificateModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    return CertificateModel(
      certificateId: documentId,
      certificateNumber: map['certificateNumber'] ?? '',
      eventId: map['eventId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      certificateUrl: map['certificateUrl'] ?? '',
      issuedAt: _parseDate(map['issuedAt']),
      downloadedAt: map['downloadedAt'] != null
          ? _parseDate(map['downloadedAt'])
          : null,
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toMap() {
    return {
      'certificateNumber': certificateNumber,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'studentId': studentId,
      'studentName': studentName,
      'certificateUrl': certificateUrl,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'downloadedAt': downloadedAt != null
          ? Timestamp.fromDate(downloadedAt!)
          : null,
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
  bool get isDownloaded {
    return downloadedAt != null;
  }

  bool get hasUrl {
    return certificateUrl.isNotEmpty;
  }

  // ==================== DISPLAY HELPERS ====================
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${issuedAt.day} ${months[issuedAt.month - 1]} ${issuedAt.year}';
  }

  String get formattedDateTime {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = issuedAt.hour > 12
        ? issuedAt.hour - 12
        : issuedAt.hour == 0
        ? 12
        : issuedAt.hour;
    final period = issuedAt.hour >= 12 ? 'PM' : 'AM';
    final minute = issuedAt.minute.toString().padLeft(2, '0');
    return '${issuedAt.day} ${months[issuedAt.month - 1]} ${issuedAt.year}, $hour:$minute $period';
  }

  String get shortCertificateNumber {
    if (certificateNumber.isEmpty) return 'N/A';
    if (certificateNumber.length <= 15) return certificateNumber;
    return '${certificateNumber.substring(0, 12)}...';
  }
}