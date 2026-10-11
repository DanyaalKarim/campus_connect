import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== POSTER IMAGE ====================
            _buildPoster(),

            // ==================== CONTENT ====================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  _buildCategoryBadge(),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Date + Time
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: '${event.formattedDate} • ${event.time}',
                  ),

                  const SizedBox(height: 6),

                  // Venue
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    text: event.venue,
                  ),

                  const SizedBox(height: 12),

                  // Registration Progress
                  _buildProgressBar(),

                  const SizedBox(height: 12),

                  // Bottom Row: Seats + Status
                  _buildBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== POSTER ====================
  Widget _buildPoster() {
    if (event.posterUrl.isEmpty) {
      // Placeholder with gradient
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            _getCategoryIcon(event.category),
            size: 60,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Image.network(
      event.posterUrl,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 140,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: const Center(
            child: Icon(Icons.broken_image, size: 50),
          ),
        );
      },
    );
  }

  // ==================== CATEGORY BADGE ====================
  Widget _buildCategoryBadge() {
    final color = _getCategoryColor(event.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        event.category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ==================== INFO ROW ====================
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ==================== PROGRESS BAR ====================
  Widget _buildProgressBar() {
    final progress = event.registrationProgress;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${event.registeredCount} / ${event.capacity} registered',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                color: progress >= 0.9
                    ? AppColors.error
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
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
    );
  }

  // ==================== BOTTOM ROW ====================
  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Seats available
        Row(
          children: [
            Icon(
              Icons.event_seat_outlined,
              size: 16,
              color: event.availableSeats > 0
                  ? AppColors.success
                  : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              event.availableSeats > 0
                  ? '${event.availableSeats} seats left'
                  : 'Full',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: event.availableSeats > 0
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ],
        ),

        // Status Badge
        _buildStatusBadge(),
      ],
    );
  }

  // ==================== STATUS BADGE ====================
  Widget _buildStatusBadge() {
    if (event.isPast) {
      return _badge(
        text: 'Completed',
        color: AppColors.textSecondary,
      );
    }

    if (event.isFull) {
      return _badge(
        text: 'Full',
        color: AppColors.error,
      );
    }

    if (event.isDeadlinePassed) {
      return _badge(
        text: 'Closed',
        color: AppColors.warning,
      );
    }

    return _badge(
      text: 'Open',
      color: AppColors.success,
    );
  }

  Widget _badge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ==================== CATEGORY ICON ====================
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

  // ==================== CATEGORY COLOR ====================
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