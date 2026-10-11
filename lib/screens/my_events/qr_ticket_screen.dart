import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/app_theme.dart';

class QrTicketScreen extends StatelessWidget {
  final String registrationId;
  final String eventId;
  final String eventTitle;
  final String qrCode;
  final String studentName;
  final String studentNumber;

  const QrTicketScreen({
    super.key,
    required this.registrationId,
    required this.eventId,
    required this.eventTitle,
    required this.qrCode,
    required this.studentName,
    required this.studentNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Ticket'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ==================== TICKET CARD ====================
              _buildTicketCard(),

              const SizedBox(height: 20),

              // ==================== INFO ====================
              _buildInfoBox(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TICKET CARD ====================
  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==================== HEADER ====================
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CAMPUSCONNECT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eventTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================== BODY ====================
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Student Info
                _buildInfoRow(label: 'NAME', value: studentName),
                const SizedBox(height: 14),
                _buildInfoRow(label: 'STUDENT ID', value: studentNumber),
                const SizedBox(height: 20),

                // Divider with notches
                _buildDashedDivider(),

                const SizedBox(height: 20),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: QrImageView(
                    data: qrCode,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Ticket Code
                Text(
                  qrCode,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'REGISTERED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== INFO ROW ====================
  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DASHED DIVIDER ====================
  Widget _buildDashedDivider() {
    return Row(
      children: [
        // Left notch
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        ),

        // Dashed line
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dashCount = (constraints.maxWidth / 8).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (index) {
                  return Container(
                    width: 4,
                    height: 1.5,
                    color: AppColors.divider,
                  );
                }),
              );
            },
          ),
        ),

        // Right notch
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // ==================== INFO BOX ====================
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Show this QR code at the event entrance for attendance scanning',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}