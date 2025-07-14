import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../edit_profile_screen.dart';
import '../login_screen.dart';

class AboutHelpmateScreen extends StatelessWidget {
  const AboutHelpmateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Helpmate'), elevation: 0),
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
            const SizedBox(height: 24),
            // App Description
            const Text(
              'Helpmate is your trusted platform for finding and hiring reliable service providers for your everyday needs. Whether you need a babysitter, cleaner, tutor, or more, Helpmate connects you with skilled professionals quickly and securely.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
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
            Column(children: List.generate(4, (index) => _TeamMemberCard())),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Placeholder for photo
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              backgroundImage: null, // Replace with AssetImage or NetworkImage
              child: const Icon(Icons.person, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Full Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'University Name',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'email@example.com',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.code, size: 18, color: Colors.black45),
                      SizedBox(width: 6),
                      Text(
                        'github.com/username',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business, size: 18, color: Colors.black45),
                      SizedBox(width: 6),
                      Text(
                        'linkedin.com/in/username',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
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

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context, authProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                _buildProfileHeader(user as User),
                const SizedBox(height: AppTheme.spacingXL),
                _buildProfileActions(context, user as User),
                const SizedBox(height: AppTheme.spacingXL),
                _buildProfileInfo(user as User),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                user.fullName.split(' ').map((e) => e[0]).join(''),
                style: AppTheme.heading1.copyWith(color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // User Name
            Text(user.fullName, style: AppTheme.heading2),
            const SizedBox(height: AppTheme.spacingS),

            // User Type
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Text(
                user is Worker ? 'Service Provider' : 'Service Seeker',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context, User user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: user),
                ),
              );
            },
          ),
          if (user is Worker) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('My Services'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to services screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Services management coming soon!'),
                  ),
                );
              },
            ),
          ],
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutHelpmateScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingL),

            _buildInfoRow('Email', user.email),
            _buildInfoRow('Phone', user.phone),
            _buildInfoRow('Address', user.address),

            if (user is Worker) ...[
              const SizedBox(height: AppTheme.spacingM),
              _buildInfoRow('Skills', user.skills),
              _buildInfoRow('Hourly Rate', '\$${user.hourlyRate}/hr'),
              _buildInfoRow(
                'Availability',
                user.lookingForWork ? 'Available' : 'Busy',
              ),
              if (user.rating != null) ...[
                _buildInfoRow('Rating', '${user.rating!.toStringAsFixed(1)} ⭐'),
                if (user.totalReviews != null)
                  _buildInfoRow('Reviews', '${user.totalReviews} reviews'),
              ],
            ],

            const SizedBox(height: AppTheme.spacingM),
            _buildInfoRow('Member Since', _formatDate(user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
