import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/announcement_model.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../announcements/announcements_screen.dart';
import '../auth/login_screen.dart';
import '../events/event_details_screen.dart';
import '../events/events_screen.dart';
import '../my_events/my_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
      context.read<AnnouncementProvider>().loadAnnouncements();
    });
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(
        onLogout: _handleLogout,
        onViewAllEvents: () => _switchTab(1),
        onViewAllAnnouncements: () => _switchTab(2),
      ),
      const EventsScreen(),
      const AnnouncementsScreen(),
      const MyEventsScreen(),
      _PlaceholderTab(
        icon: Icons.person_outline,
        title: 'Profile',
        subtitle: 'Coming Soon',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== HOME TAB ====================
class _HomeTab extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onViewAllEvents;
  final VoidCallback onViewAllAnnouncements;

  const _HomeTab({
    required this.onLogout,
    required this.onViewAllEvents,
    required this.onViewAllAnnouncements,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final announcementProvider = context.watch<AnnouncementProvider>();

    final userName = authProvider.getUserName();
    final upcomingEvents = eventProvider.getUpcomingEvents(limit: 3);
    final recentAnnouncements =
    announcementProvider.getRecentAnnouncements(limit: 3);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ==================== APP BAR ====================
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, $userName!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Welcome to CampusConnect',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout,
              ),
            ],
          ),

          // ==================== WELCOME CARD ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildWelcomeCard(),
            ),
          ),

          // ==================== UPCOMING EVENTS HEADER ====================
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'Upcoming Events',
              onViewAll: onViewAllEvents,
            ),
          ),

          // ==================== UPCOMING EVENTS LIST ====================
          if (eventProvider.isLoading && eventProvider.events.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (upcomingEvents.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyCard(
                icon: Icons.event_busy_outlined,
                title: 'No upcoming events',
                subtitle: 'Check back later',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final event = upcomingEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventDetailsScreen(eventId: event.eventId),
                        ),
                      );
                    },
                  );
                },
                childCount: upcomingEvents.length,
              ),
            ),

          // ==================== ANNOUNCEMENTS HEADER ====================
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'Latest Announcements',
              onViewAll: onViewAllAnnouncements,
            ),
          ),

          // ==================== ANNOUNCEMENTS LIST ====================
          if (announcementProvider.isLoading &&
              announcementProvider.announcements.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (recentAnnouncements.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyCard(
                icon: Icons.campaign_outlined,
                title: 'No announcements yet',
                subtitle: 'Check back later',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final announcement = recentAnnouncements[index];
                  return _buildAnnouncementMiniCard(announcement);
                },
                childCount: recentAnnouncements.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  // ==================== WELCOME CARD ====================
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse and register for upcoming events at your university',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ANNOUNCEMENT MINI CARD ====================
  Widget _buildAnnouncementMiniCard(AnnouncementModel announcement) {
    final color = _getCategoryColor(announcement.category);
    final icon = _getCategoryIcon(announcement.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: announcement.isImportant
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.divider,
          width: announcement.isImportant ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
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
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (announcement.isImportant) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'IMPORTANT',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  announcement.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            announcement.timeAgo,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY CARD ====================
  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 50,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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

// ==================== PLACEHOLDER TAB ====================
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}