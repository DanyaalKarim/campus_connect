import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/certificate_model.dart';
import '../../services/certificate_service.dart';
import '../../theme/app_theme.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Certificates'),
        centerTitle: false,
        elevation: 0,
      ),
      body: userId == null
          ? _buildNotLoggedIn()
          : _buildCertificatesList(userId),
    );
  }

  // ==================== NOT LOGGED IN ====================
  Widget _buildNotLoggedIn() {
    return const Center(
      child: Text(
        'Please login to view certificates',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // ==================== CERTIFICATES LIST ====================
  Widget _buildCertificatesList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('certificates')
          .where('studentId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError('Failed to load certificates');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmpty();
        }

        final certificates = snapshot.data!.docs
            .map((doc) => CertificateModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        ))
            .toList();

        // Sort by issue date (latest first)
        certificates.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: certificates.length,
          itemBuilder: (context, index) {
            final certificate = certificates[index];
            return _buildCertificateCard(context, certificate);
          },
        );
      },
    );
  }

  // ==================== CERTIFICATE CARD ====================
  Widget _buildCertificateCard(
      BuildContext context,
      CertificateModel certificate,
      ) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CERTIFICATE OF PARTICIPATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate.eventTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Certificate Details
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: certificate.studentName,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Certificate No.',
              value: certificate.shortCertificateNumber,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Issued',
              value: certificate.formattedDate,
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // View / Download Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleViewCertificate(
                      context,
                      certificate,
                    ),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text(
                      'View / Download',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Share Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => _handleShareCertificate(
                      context,
                      certificate,
                    ),
                    icon: Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Share',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DETAIL ROW ====================
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ==================== VIEW / DOWNLOAD CERTIFICATE (PDF) ====================
  Future<void> _handleViewCertificate(
      BuildContext context,
      CertificateModel certificate,
      ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final service = CertificateService();

      // Get student ID from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      final studentId = user?.uid.substring(0, 8).toUpperCase() ?? 'N/A';

      // Format date
      final dateFormat = DateFormat('MMMM dd, yyyy');
      final eventDate = dateFormat.format(certificate.issuedAt);

      // Generate and print/save PDF
      await service.printCertificate(
        studentName: certificate.studentName,
        studentId: studentId,
        eventTitle: certificate.eventTitle,
        eventDate: eventDate,
        organizerName: 'CampusConnect',
        certificateType: 'PARTICIPATION',
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Certificate ready!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to generate certificate: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ==================== SHARE CERTIFICATE ====================
  Future<void> _handleShareCertificate(
      BuildContext context,
      CertificateModel certificate,
      ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final service = CertificateService();

      final user = FirebaseAuth.instance.currentUser;
      final studentId = user?.uid.substring(0, 8).toUpperCase() ?? 'N/A';

      final dateFormat = DateFormat('MMMM dd, yyyy');
      final eventDate = dateFormat.format(certificate.issuedAt);

      await service.shareCertificate(
        studentName: certificate.studentName,
        studentId: studentId,
        eventTitle: certificate.eventTitle,
        eventDate: eventDate,
        organizerName: 'CampusConnect',
        certificateType: 'PARTICIPATION',
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to share: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No certificates yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Attend events to earn certificates',
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