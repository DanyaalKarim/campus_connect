import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String organizerName;

  const FeedbackScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.organizerName = 'CampusConnect',
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _alreadySubmitted = false;

  @override
  void initState() {
    super.initState();
    _checkExistingFeedback();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ==================== CHECK EXISTING FEEDBACK ====================
  Future<void> _checkExistingFeedback() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final existing = await FirebaseFirestore.instance
          .collection('feedback')
          .where('eventId', isEqualTo: widget.eventId)
          .where('studentId', isEqualTo: userId)
          .get();

      if (!mounted) return;

      if (existing.docs.isNotEmpty) {
        final data = existing.docs.first.data();
        setState(() {
          _rating = data['rating'] ?? 0;
          _commentController.text = data['comment'] ?? '';
          _alreadySubmitted = true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ==================== SUBMIT FEEDBACK ====================
  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      _showError('Please select a rating');
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showError('Please login to submit feedback');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get student name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final studentName = userDoc.data()?['name'] ?? 'Student';

      if (_alreadySubmitted) {
        // Update existing feedback
        final existing = await FirebaseFirestore.instance
            .collection('feedback')
            .where('eventId', isEqualTo: widget.eventId)
            .where('studentId', isEqualTo: userId)
            .get();

        await existing.docs.first.reference.update({
          'rating': _rating,
          'comment': _commentController.text.trim(),
          'organizerName': widget.organizerName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new feedback
        await FirebaseFirestore.instance.collection('feedback').add({
          'eventId': widget.eventId,
          'eventTitle': widget.eventTitle,
          'organizerName': widget.organizerName,
          'studentId': userId,
          'studentName': studentName,
          'rating': _rating,
          'comment': _commentController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update registration to mark feedback submitted
        final regSnapshot = await FirebaseFirestore.instance
            .collection('registrations')
            .where('eventId', isEqualTo: widget.eventId)
            .where('studentId', isEqualTo: userId)
            .get();

        if (regSnapshot.docs.isNotEmpty) {
          await regSnapshot.docs.first.reference.update({
            'hasFeedback': true,
          });
        }
      }

      if (!mounted) return;

      _showSuccess('Thank you for your feedback!');

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to submit feedback. Try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ==================== SHOW ERROR ====================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== SHOW SUCCESS ====================
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Give Feedback'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== EVENT INFO ====================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EVENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.eventTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${widget.organizerName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================== RATING ====================
            const Text(
              'How was the event?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Tap to rate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _rating = starIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starIndex <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 48,
                      color: starIndex <= _rating
                          ? const Color(0xFFFFB300)
                          : AppColors.textSecondary.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // Rating Label
            Center(
              child: Text(
                _getRatingLabel(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _rating > 0
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ==================== COMMENT ====================
            const Text(
              'Additional Comments (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'What did you like about the event?',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================== SUBMIT BUTTON ====================
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
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
                    Icon(
                      _alreadySubmitted
                          ? Icons.update
                          : Icons.send_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _alreadySubmitted
                          ? 'Update Feedback'
                          : 'Submit Feedback',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== RATING LABEL ====================
  String _getRatingLabel() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Not rated';
    }
  }
}