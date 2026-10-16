import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';

class MyFeedbackScreen extends StatelessWidget {
  const MyFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Feedback'),
        centerTitle: false,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text('Please login to view feedback'))
          : _buildFeedbackList(userId),
    );
  }

  Widget _buildFeedbackList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .where('studentId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError('Failed to load feedback');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmpty();
        }

        final feedbacks = snapshot.data!.docs.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final data = feedbacks[index].data() as Map<String, dynamic>;
            return _buildFeedbackCard(data);
          },
        );
      },
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> data) {
    final rating = (data['rating'] ?? 0).toDouble();
    final eventTitle = data['eventTitle'] ?? 'Event';
    final comment = data['comment'] ?? '';
    final organizerName = data['organizerName'] ?? 'CampusConnect';
    final createdAt = data['createdAt'];

    String dateStr = '';
    if (createdAt is Timestamp) {
      dateStr = DateFormat('MMM dd, yyyy').format(createdAt.toDate());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'By $organizerName',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 22,
                  color: i < rating
                      ? const Color(0xFFFFB300)
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${rating.toStringAsFixed(0)}/5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$comment"',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No feedback yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Attend events to give feedback',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}