import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/announcement_model.dart';
import '../../providers/announcement_provider.dart';
import '../../theme/app_theme.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();

    // Load announcements on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcements'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ==================== CATEGORY CHIPS ====================
          _buildCategoryChips(provider),

          // ==================== ANNOUNCEMENTS LIST ====================
          Expanded(
            child: _buildAnnouncementsList(provider),
          ),
        ],
      ),
    );
  }

  // ==================== CATEGORY CHIPS ====================
  Widget _buildCategoryChips(AnnouncementProvider provider) {
    return Container(
      color: AppColors.surface,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: AnnouncementProvider.categories.length,
        itemBuilder: (context, index) {
          final category = AnnouncementProvider.categories[index];
          final isSelected = provider.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => provider.filterByCategory(category),
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // ==================== ANNOUNCEMENTS LIST ====================
  Widget _buildAnnouncementsList(AnnouncementProvider provider) {
    // Loading
    if (provider.isLoading && provider.announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (provider.errorMessage != null &&
        provider.announcements.isEmpty) {
      return _buildError(provider);
    }

    // Empty
    if (provider.filteredAnnouncements.isEmpty) {
      return _buildEmpty(provider);
    }

    // List
    return RefreshIndicator(
      onRefresh: () async => await provider.refreshAnnouncements(),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: provider.filteredAnnouncements.length,
        itemBuilder: (context, index) {
          final announcement = provider.filteredAnnouncements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  // ==================== ANNOUNCEMENT CARD ====================
  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    final categoryColor = _getCategoryColor(announcement.category);
    final categoryIcon = _getCategoryIcon(announcement.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: announcement.isImportant
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.divider,
          width: announcement.isImportant ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Category Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 20,
                    color: categoryColor,
                  ),
                ),

                const SizedBox(width: 12),

                // Category + Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            announcement.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (announcement.isImportant) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'IMPORTANT',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        announcement.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // New Badge
                if (announcement.isNew && !announcement.isImportant)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Title
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              announcement.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    announcement.createdByName.isEmpty
                        ? 'Admin'
                        : announcement.createdByName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  announcement.formattedDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY ====================
  Widget _buildEmpty(AnnouncementProvider provider) {
    final hasFilter = provider.selectedCategory != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter
                  ? Icons.filter_alt_off_outlined
                  : Icons.campaign_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No ${provider.selectedCategory} announcements'
                  : 'No announcements yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for updates',
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

  // ==================== ERROR ====================
  Widget _buildError(AnnouncementProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load announcements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.refreshAnnouncements();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CATEGORY ICON ====================
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'University':
        return Icons.school_outlined;
      case 'Department':
        return Icons.business_outlined;
      case 'Society':
        return Icons.groups_outlined;
      case 'Academic':
        return Icons.menu_book_outlined;
      case 'Event':
        return Icons.event_outlined;
      case 'Important':
        return Icons.warning_amber_rounded;
      default:
        return Icons.campaign_outlined;
    }
  }

  // ==================== CATEGORY COLOR ====================
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'University':
        return const Color(0xFF3F51B5);
      case 'Department':
        return const Color(0xFF009688);
      case 'Society':
        return const Color(0xFFFF9800);
      case 'Academic':
        return const Color(0xFF2196F3);
      case 'Event':
        return const Color(0xFF9C27B0);
      case 'Important':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF607D8B);
    }
  }
}