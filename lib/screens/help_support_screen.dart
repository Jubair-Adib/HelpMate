import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            // Friendly header
            const Icon(Icons.support_agent, size: 64, color: Color(0xFF1565C0)),
            const SizedBox(height: 16),
            const Text(
              'Need help or want to support us?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We are here to help! Reach out for any support, feedback, or suggestions.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Contact info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: falam3399@gmail.com',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Phone: +880 1552-316249',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Donation
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Support Us with a Donation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If you like our work, consider donating to help us keep improving.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'bKash Number:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '01552-316249',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Star the repo
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Love Helpmate?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please consider starring our project on GitHub to support us!',
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap:
                          () => _launchUrl(
                            'https://github.com/mastermind-fa/HOME_SERVICE',
                          ),
                      child: const Text(
                        '⭐ Star on GitHub',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
