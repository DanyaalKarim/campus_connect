import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // ==================== SUPPORT CONTACT INFO ====================
  static const String supportEmail = 'danyaalkarim0@gmail.com';
  static const String supportPhone = '+923318662407';
  static const String supportWhatsApp = '923140522407';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== HEADER ====================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We are here to help!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reach out to us through any channel below',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ==================== CONTACT OPTIONS ====================
          const Text(
            'CONTACT US',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Email
          _buildContactCard(
            context,
            iconAsset: 'assets/icons/gmail_icon.png',
            title: 'Email Support',
            subtitle: supportEmail,
            onTap: () => _launchEmail(context, supportEmail),
          ),
          const SizedBox(height: 10),

          // WhatsApp
          _buildContactCard(
            context,
            iconAsset: 'assets/icons/whatsapp_icon.png',
            title: 'WhatsApp',
            subtitle: 'Chat with our support team',
            onTap: () => _launchWhatsApp(context, supportWhatsApp),
          ),
          const SizedBox(height: 10),

          // Call
          _buildContactCard(
            context,
            iconAsset: 'assets/icons/phone_icon.png',
            title: 'Call Us',
            subtitle: supportPhone,
            onTap: () => _launchPhone(context, supportPhone),
          ),

          const SizedBox(height: 24),

          // ==================== FAQ ====================
          const Text(
            'FREQUENTLY ASKED QUESTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          _buildFAQ(
            'How do I register for an event?',
            'Go to Events → Select an event → Tap "Register Now". '
                'You will receive a QR ticket immediately.',
          ),
          _buildFAQ(
            'Where can I find my QR ticket?',
            'Go to My Events → Upcoming tab → Tap on the event. '
                'Your QR ticket will be displayed.',
          ),
          _buildFAQ(
            'How do I get my certificate?',
            'After attending an event and having your QR scanned, '
                'the certificate will appear in Profile → Certificates.',
          ),
          _buildFAQ(
            'Can I cancel my registration?',
            'Yes, go to My Events → Upcoming → Tap on the event → '
                'Cancel Registration.',
          ),
          _buildFAQ(
            'How do I submit feedback?',
            'After attending an event, go to My Events → Completed → '
                'Tap "Give Feedback".',
          ),
          _buildFAQ(
            'The app is not loading data',
            'Please check your internet connection. If the issue '
                'persists, try restarting the app.',
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==================== CONTACT CARD (FIXED) ====================
  Widget _buildContactCard(
      BuildContext context, {
        required String iconAsset,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Image.asset(
                  iconAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FAQ ====================
  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LAUNCH EMAIL ====================
  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=CampusConnect Support Request',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) _showError(context, 'No email app found');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Could not open email app');
    }
  }

  // ==================== LAUNCH WHATSAPP ====================
  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) _showError(context, 'WhatsApp not installed');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Could not open WhatsApp');
    }
  }

  // ==================== LAUNCH PHONE ====================
  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) _showError(context, 'No phone app found');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Could not open dialer');
    }
  }

  // ==================== SHOW ERROR ====================
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}