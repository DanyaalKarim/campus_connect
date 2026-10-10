class AppConstants {
  // ==================== APP INFO ====================
  static const String appName = 'CampusConnect';
  static const String appTagline = 'University Digital Platform';
  static const String appVersion = '1.0.0';

  // ==================== FIRESTORE COLLECTIONS ====================
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String registrationsCollection = 'registrations';
  static const String announcementsCollection = 'announcements';
  static const String attendanceCollection = 'attendance';
  static const String feedbackCollection = 'feedback';
  static const String societiesCollection = 'societies';
  static const String certificatesCollection = 'certificates';

  // ==================== CLOUDINARY ====================
  static const String cloudinaryCloudName = 'nkdxoqjp';
  static const String cloudinaryUploadPreset = 'campus_connect_preset';
  static const String eventPostersFolder = 'event_posters';
  static const String profileImagesFolder = 'profile_images';
  static const String eventPhotosFolder = 'event_photos';

  // ==================== USER ROLES ====================
  static const String roleStudent = 'student';
  static const String roleOrganizer = 'organizer';
  static const String roleAdmin = 'admin';

  // ==================== EVENT STATUS ====================
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusCompleted = 'completed';

  // ==================== REGISTRATION STATUS ====================
  static const String regStatusRegistered = 'registered';
  static const String regStatusAttended = 'attended';
  static const String regStatusCancelled = 'cancelled';

  // ==================== ANNOUNCEMENT CATEGORIES ====================
  static const List<String> announcementCategories = [
    'University',
    'Department',
    'Society',
    'Academic',
    'Event',
    'Important',
  ];

  // ==================== EVENT CATEGORIES ====================
  static const List<String> eventCategories = [
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

  // ==================== DEPARTMENTS ====================
  static const List<String> departments = [
    'Computer Science',
    'Software Engineering',
    'Electrical Engineering',
    'Business Administration',
    'Mathematics',
    'Physics',
    'Other',
  ];

  // ==================== VALIDATION ====================
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 2000;

  // ==================== UI CONSTANTS ====================
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 50.0;

  // ==================== DATE FORMATS ====================
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // ==================== ERROR MESSAGES ====================
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Please check your internet connection.';
  static const String errorEmailInUse = 'An account already exists with this email.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorUserNotFound = 'No account found with this email.';
  static const String errorWrongPassword = 'Incorrect password. Please try again.';
  static const String errorTooManyRequests = 'Too many attempts. Please try again later.';

  // ==================== SUCCESS MESSAGES ====================
  static const String successSignup = 'Account created successfully!';
  static const String successLogin = 'Logged in successfully!';
  static const String successLogout = 'Logged out successfully!';
  static const String successRegistration = 'Registered for event successfully!';
  static const String successFeedback = 'Thank you for your feedback!';
}