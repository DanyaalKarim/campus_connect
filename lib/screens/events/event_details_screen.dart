import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  EventModel? _event;
  bool _isLoading = true;
  bool _isRegistering = false;
  bool _isAlreadyRegistered = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final event = await _firestoreService.getEventById(widget.eventId);

      if (!mounted) return;

      if (event == null) {
        setState(() {
          _errorMessage = 'Event not found';
          _isLoading = false;
        });
        return;
      }

      // Check if user already registered
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      bool isRegistered = false;
      if (user != null) {
        isRegistered = await _firestoreService.isUserRegistered(
          eventId: widget.eventId,
          studentId: user.uid,
        );
      }

      if (!mounted) return;

      setState(() {
        _event = event;
        _isAlreadyRegistered = isRegistered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load event';
        _isLoading = false;
      });
    }
  }

  // ==================== SHOW CONFIRMATION DIALOG ====================
  Future<void> _showRegistrationConfirmation() async {
    if (_event == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_reg_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Registration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to register for:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event!.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDialogInfoRow(
                      Icons.calendar_today_outlined,
                      '${_event!.formattedDate} • ${_event!.time}',
                    ),
                    const SizedBox(height: 4),
                    _buildDialogInfoRow(
                      Icons.location_on_outlined,
                      _event!.venue,
                    ),
                    if (_event!.organizerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildDialogInfoRow(
                        Icons.people_outline,
                        _event!.organizerName,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Yes, Register',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _registerForEvent();
    }
  }

  Widget _buildDialogInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REGISTER ====================
  Future<void> _registerForEvent() async {
    if (_event == null) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final userData = authProvider.userData;

    if (user == null || userData == null) {
      _showError('Please login to register');
      return;
    }

    setState(() => _isRegistering = true);

    final eventProvider = context.read<EventProvider>();

    final error = await eventProvider.registerForEvent(
      eventId: _event!.eventId,
      studentId: user.uid,
      studentName: userData['name'] ?? 'Student',
      studentEmail: userData['email'] ?? '',
      studentNumber: userData['studentId'] ?? '',
    );

    if (!mounted) return;

    setState(() => _isRegistering = false);

    if (error != null) {
      _showError(error);
    } else {
      setState(() => _isAlreadyRegistered = true);
      _showSuccess('Registered successfully!');
    }
  }

  // ==================== CANCEL REGISTRATION ====================
  Future<void> _showCancelConfirmation() async {
    if (_event == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cancel Registration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to cancel your registration for:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event!.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDialogInfoRow(
                      Icons.calendar_today_outlined,
                      '${_event!.formattedDate} • ${_event!.time}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep Registration'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _cancelRegistration();
    }
  }

  Future<void> _cancelRegistration() async {
    if (_event == null) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      _showError('Please login first');
      return;
    }

    setState(() => _isRegistering = true);

    final eventProvider = context.read<EventProvider>();

    final error = await eventProvider.cancelRegistration(
      eventId: _event!.eventId,
      studentId: user.uid,
    );

    if (!mounted) return;

    setState(() => _isRegistering = false);

    if (error != null) {
      _showError(error);
    } else {
      setState(() => _isAlreadyRegistered = false);
      _showSuccess('Registration cancelled successfully');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Event not found',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadEvent,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildPosterHeader(event),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(event.category),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date & Time',
                    value: '${event.formattedDate} • ${event.time}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Venue',
                    value: event.venue,
                  ),
                  if (event.speaker.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      label: 'Speaker',
                      value: event.speaker,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.people_outline,
                    label: 'Organizer',
                    value: event.organizerName,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRegistrationStats(event),
                  const SizedBox(height: 24),
                  _buildDeadlineInfo(event),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(event),
    );
  }

  Widget _buildPosterHeader(EventModel event) {
    if (event.posterUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            _getCategoryIcon(event.category),
            size: 80,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return Image.network(
      event.posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.primary,
          child: const Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBadge(String category) {
    final color = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationStats(EventModel event) {
    final progress = event.registrationProgress;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$percentage% Full',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: progress >= 0.9
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatItem(
                value: '${event.registeredCount}',
                label: 'Registered',
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                value: '${event.availableSeats}',
                label: 'Seats Left',
                color: AppColors.success,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                value: '${event.capacity}',
                label: 'Capacity',
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.9
                    ? AppColors.error
                    : progress >= 0.7
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineInfo(EventModel event) {
    final isPassed = event.isDeadlinePassed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPassed
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPassed
              ? AppColors.error.withValues(alpha: 0.2)
              : AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPassed ? Icons.event_busy : Icons.timer_outlined,
            size: 20,
            color: isPassed ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPassed ? 'Registration Closed' : 'Registration Deadline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPassed ? AppColors.error : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.formattedDeadline,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM BUTTON ====================
  Widget _buildBottomButton(EventModel event) {
    String buttonText;
    bool isEnabled;
    Color buttonColor;
    IconData buttonIcon;
    VoidCallback? onPressed;

    if (_isAlreadyRegistered) {
      buttonText = 'Cancel Registration';
      isEnabled = true;
      buttonColor = AppColors.error;
      buttonIcon = Icons.cancel_outlined;
      onPressed = _showCancelConfirmation;
    } else if (event.isPast) {
      buttonText = 'Event Completed';
      isEnabled = false;
      buttonColor = AppColors.textSecondary;
      buttonIcon = Icons.event_busy_outlined;
      onPressed = null;
    } else if (event.isFull) {
      buttonText = 'Event Full';
      isEnabled = false;
      buttonColor = AppColors.error;
      buttonIcon = Icons.block;
      onPressed = null;
    } else if (event.isDeadlinePassed) {
      buttonText = 'Registration Closed';
      isEnabled = false;
      buttonColor = AppColors.error;
      buttonIcon = Icons.timer_off_outlined;
      onPressed = null;
    } else {
      buttonText = 'Register Now';
      isEnabled = true;
      buttonColor = AppColors.primary;
      buttonIcon = Icons.how_to_reg_outlined;
      onPressed = _showRegistrationConfirmation;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (isEnabled && !_isRegistering) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isRegistering
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(buttonIcon, size: 20),
                const SizedBox(width: 8),
                Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Seminars':
        return Icons.mic_none_rounded;
      case 'Workshops':
        return Icons.build_outlined;
      case 'Competitions':
        return Icons.emoji_events_outlined;
      case 'Sports':
        return Icons.sports_basketball_outlined;
      case 'Career':
        return Icons.work_outline_rounded;
      case 'Academic':
        return Icons.school_outlined;
      case 'Society':
        return Icons.groups_outlined;
      case 'Cultural':
        return Icons.theater_comedy_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Seminars':
        return const Color(0xFF3F51B5);
      case 'Workshops':
        return const Color(0xFF009688);
      case 'Competitions':
        return const Color(0xFFFF5722);
      case 'Sports':
        return const Color(0xFF4CAF50);
      case 'Career':
        return const Color(0xFF9C27B0);
      case 'Academic':
        return const Color(0xFF2196F3);
      case 'Society':
        return const Color(0xFFFF9800);
      case 'Cultural':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF607D8B);
    }
  }
}