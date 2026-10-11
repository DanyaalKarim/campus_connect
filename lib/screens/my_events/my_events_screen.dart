import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_theme.dart';
import 'qr_ticket_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Events'),
        centerTitle: false,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: userId == null
          ? _buildNotLoggedIn()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildRegistrationsList(userId, isUpcoming: true),
          _buildRegistrationsList(userId, isUpcoming: false),
        ],
      ),
    );
  }

  // ==================== NOT LOGGED IN ====================
  Widget _buildNotLoggedIn() {
    return const Center(
      child: Text(
        'Please login to view your events',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // ==================== REGISTRATIONS LIST ====================
  Widget _buildRegistrationsList(String userId,
      {required bool isUpcoming}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('registrations')
          .where('studentId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError('Failed to load registrations');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmpty(isUpcoming);
        }

        final now = DateTime.now();
        final registrations = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final registeredAt = data['registeredAt'];
          DateTime? eventDate;

          if (registeredAt is Timestamp) {
            eventDate = registeredAt.toDate();
          }

          if (eventDate == null) return false;

          return isUpcoming
              ? eventDate.isAfter(now) || eventDate.isAtSameMomentAs(now)
              : eventDate.isBefore(now);
        }).toList();

        if (registrations.isEmpty) {
          return _buildEmpty(isUpcoming);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: registrations.length,
          itemBuilder: (context, index) {
            final regDoc = registrations[index];
            final data = regDoc.data() as Map<String, dynamic>;
            return _buildRegistrationCard(
              context,
              registrationId: regDoc.id,
              data: data,
              isUpcoming: isUpcoming,
            );
          },
        );
      },
    );
  }

  // ==================== REGISTRATION CARD ====================
  Widget _buildRegistrationCard(
      BuildContext context, {
        required String registrationId,
        required Map<String, dynamic> data,
        required bool isUpcoming,
      }) {
    final eventTitle = data['eventTitle'] ?? 'Event';
    final status = data['status'] ?? 'registered';
    final qrCode = data['qrCode'] ?? '';
    final eventId = data['eventId'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QrTicketScreen(
                registrationId: registrationId,
                eventId: eventId,
                eventTitle: eventTitle,
                qrCode: qrCode,
                studentName: data['studentName'] ?? '',
                studentNumber: data['studentNumber'] ?? '',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUpcoming
                      ? Icons.qr_code_2
                      : Icons.workspace_premium_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatusBadge(status),
                        const SizedBox(width: 8),
                        if (isUpcoming)
                          const Text(
                            'Tap to view ticket',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STATUS BADGE ====================
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'attended':
        color = AppColors.success;
        label = 'Attended';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Cancelled';
        break;
      default:
        color = AppColors.primary;
        label = 'Registered';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmpty(bool isUpcoming) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming
                  ? Icons.event_note_outlined
                  : Icons.history_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming events'
                  : 'No completed events',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Register for events to see them here'
                  : 'Your completed events will appear here',
              textAlign: TextAlign.center,
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

  // ==================== ERROR ====================
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