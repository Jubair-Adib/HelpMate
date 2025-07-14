import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker.dart' as worker_models;
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'personal_info_screen.dart';
import 'service_history_screen.dart';
import 'about_screen.dart';
import 'favourites_screen.dart';
import 'help_support_screen.dart';
import 'privacy_security_screen.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    worker_models.Worker worker = user as worker_models.Worker;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: Text(
          'Hi, ${worker.fullName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (worker.image != null && worker.image!.isNotEmpty)
                              ? NetworkImage(worker.image!)
                              : null,
                      child:
                          (worker.image == null || worker.image!.isEmpty)
                              ? const Icon(
                                Icons.person,
                                size: 36,
                                color: Color(0xFF1565C0),
                              )
                              : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker.address ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(user: worker),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Dashboard Sections
            _SectionCard(
              title: 'Pending Services',
              icon: Icons.pending_actions,
              child: const Center(
                child: Text('Pending services will appear here.'),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Completed Services',
              icon: Icons.check_circle_outline,
              child: const Center(
                child: Text('Completed services will appear here.'),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Chats with Clients',
              icon: Icons.chat_bubble_outline,
              child: const Center(child: Text('Chats will appear here.')),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'My Reviews',
              icon: Icons.reviews,
              child: const Center(
                child: Text('Your reviews will appear here.'),
              ),
            ),
            const SizedBox(height: 24),
            // Profile Options (reuse from ProfileTab)
            _ProfileOptions(),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1565C0)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProfileOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Removed: Personal Information, Address, Payment Methods, Service History, Favourites
        _buildProfileOption(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          onTap: () {},
        ),
        _buildProfileOption(
          context,
          icon: Icons.security,
          title: 'Privacy & Security',
          subtitle: 'Manage your account security',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacySecurityScreen(),
              ),
            );
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.info_outline,
          title: 'About HelpMate',
          subtitle: 'Learn more about the app',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontFamily: 'Montserrat',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
