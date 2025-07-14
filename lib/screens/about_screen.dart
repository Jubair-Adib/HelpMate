import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/helpmate_logo.png'),
              ),
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'Helpmate',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 8),
            // Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            // Description
            const Text(
              'Helpmate is your trusted platform for finding and hiring reliable service providers for your everyday needs. Whether you need a babysitter, cleaner, tutor, or more, Helpmate connects you with skilled professionals quickly and securely.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            // Legal/Disclaimer
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Legal & Disclaimer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All information provided in this app is for general informational purposes only. Helpmate and its team are not responsible for any direct or indirect damages arising from the use of this app.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            // Presented by
            const Text(
              'Presented by Team Mechabytes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 32),
            // About our team
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About our team',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Team member cards
            Column(
              children: [
                _TeamMemberCard(
                  name: 'Farhana Alam',
                  university: 'University of Dhaka',
                  email: 'falam3399@gmail.com',
                  github: 'https://www.github.com/mastermind-fa',
                  linkedin: 'https://www.linkedin.com/in/mastermindfa',
                  imagePath: 'assets/images/farhana.png', // Add photo here
                ),
                _TeamMemberCard(
                  name: 'Jubair Ahammed Akter',
                  university: 'University of Dhaka',
                  email: 'akteradib007@gmail.com',
                  github: 'https://www.github.com/Jubair-Adib',
                  linkedin:
                      'https://www.linkedin.com/in/jubair-ahammad-akter-0b0aa3316/',
                  imagePath: 'assets/images/jubair.png', // Add photo here
                ),
                _TeamMemberCard(
                  name: 'NMR Masum',
                  university: 'University of Dhaka',
                  email: 'nmrmasumbdkk531@gmail.com',
                  github: 'https://www.github.com/masum',
                  linkedin: 'https://www.linkedin.com/in/nmr-masum-778a3b2a0/',
                  imagePath: 'assets/images/masum.png', // Add photo here
                ),
                _TeamMemberCard(
                  name: 'Shakin Reza Kabbo',
                  university: 'University of Dhaka',
                  email: 'kabboshakin088@gmail.com',
                  github: 'https://github.com/shakinalamkabbo',
                  linkedin:
                      'https://www.linkedin.com/in/shakin-alam-kabbo-102a69372/',
                  imagePath: 'assets/images/kabbo.png', // Add photo here
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    this.name = 'Full Name',
    this.university = 'University Name',
    this.email = 'email@example.com',
    this.github = 'github.com/username',
    this.linkedin = 'linkedin.com/in/username',
    this.imagePath,
  });

  final String name;
  final String university;
  final String email;
  final String github;
  final String linkedin;
  final String? imagePath;

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team member photo
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  imagePath != null ? AssetImage(imagePath!) : null,
              child:
                  imagePath == null
                      ? const Icon(Icons.person, size: 32, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    university,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.code, size: 18, color: Colors.black45),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _launchUrl(github),
                        child: const Text(
                          'GitHub',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.business,
                        size: 18,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _launchUrl(linkedin),
                        child: const Text(
                          'LinkedIn',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
