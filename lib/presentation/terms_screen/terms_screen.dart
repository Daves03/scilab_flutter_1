import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: RawScrollbar(
                  thumbColor: Colors.grey.withOpacity(0.5),
                  radius: const Radius.circular(4),
                  thickness: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to SciLab AR! By using this application, you agree to the following terms and conditions. Please read them carefully before proceeding.',
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle(theme, '1. Educational Simulation Only'),
                        _buildSectionContent(theme, 'SciLab AR is an Augmented Reality (AR) tool designed solely for educational and visualization purposes. While the simulations aim to be realistic, they are virtual representations and may not perfectly reflect the unpredictability of real-world chemical reactions. This app should be used as a supplementary learning tool and not as a substitute for actual laboratory training.'),
                        
                        _buildSectionTitle(theme, '2. Safety Warning (Real-World Experiments)'),
                        _buildSectionContent(theme, 'Chemistry experiments involve real risks. The experiments demonstrated in this app (such as Elephant Toothpaste and Silver Nitrate tests) involve chemicals that can be hazardous if mishandled.'),
                        _buildBulletPoint(theme, 'DO NOT attempt to replicate these experiments in the real world without the direct supervision of a qualified science teacher or professional.'),
                        _buildBulletPoint(theme, 'The developers and Cavite State University - Bacoor City Campus are not liable for any accidents, injuries, or damages resulting from the unsupervised or improper replication of these simulations.'),
                        
                        _buildSectionTitle(theme, '3. Health & Safety (AR Usage)'),
                        _buildSectionContent(theme, 'Extended use of Augmented Reality may cause motion sickness, dizziness, or eye strain for some users.'),
                        _buildBulletPoint(theme, 'Please use the app in a safe environment.'),
                        _buildBulletPoint(theme, 'Be aware of your surroundings to avoid tripping or bumping into real-world objects while focusing on the screen.'),
                        _buildBulletPoint(theme, 'If you experience discomfort, discontinue use immediately.'),
                        
                        _buildSectionTitle(theme, '4. Device & Environment Requirements'),
                        _buildSectionContent(theme, 'To ensure the app functions correctly, please ensure your device meets the minimum hardware requirements (Android, ARCore/Vuforia compatible). The app requires a well-lit environment to detect markers accurately. Poor lighting or reflective surfaces may affect performance.'),
                        
                        _buildSectionTitle(theme, '5. Data Privacy (Offline Storage)'),
                        _buildSectionContent(theme, 'SciLab AR operates as an offline application. All user data, including names, progress logs, and experiment records, are stored locally on your device.'),
                        _buildBulletPoint(theme, 'We do not collect, transmit, or store your personal information on external servers.'),
                        _buildBulletPoint(theme, 'You are responsible for your device\'s security. Uninstalling the app may result in the permanent loss of your saved progress.'),
                        
                        _buildSectionTitle(theme, '6. Intellectual Property & Copyright'),
                        _buildSectionContent(theme, 'All content included in this application, such as text, graphics, logos, 3D models, animations, user interfaces, and software code, is the property of the developers and Cavite State University - Bacoor City Campus or its content suppliers and is protected by copyright laws.'),
                        _buildBulletPoint(theme, 'Third-Party Assets: Certain assets (e.g., Unity engine components, Vuforia SDK) are used under license from their respective owners.'),
                        _buildBulletPoint(theme, 'Restrictions: You may not copy, reproduce, distribute, reverse engineer, or create derivative works from this application without express written permission from the copyright holders.'),
                        
                        _buildSectionTitle(theme, '7. Acceptance of Terms'),
                        _buildSectionContent(theme, 'By clicking "Accept" or continuing to use SciLab AR, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.'),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Copyright © 2026 SciLab AR. All Rights Reserved. Cavite State University - Bacoor City Campus',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final auth = AuthService.instance;
                        await auth.logout();
                        if (context.mounted) {
                          context.go(AppRoutes.signUpLoginScreen);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('DISAGREE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final auth = AuthService.instance;
                        await auth.acceptTerms();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF00FF88),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('AGREE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(ThemeData theme, String content) {
    return Text(
      content,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.brightness == Brightness.dark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.brightness == Brightness.dark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
