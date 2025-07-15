import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'personal_info_screen.dart';
import 'service_history_screen.dart';
import 'about_screen.dart';
import 'favourites_screen.dart';
import 'help_support_screen.dart';
import 'privacy_security_screen.dart';
import 'admin_panel_screen.dart';
import '../models/user.dart';
import '../models/worker.dart' as worker_models;
import 'notification_screen.dart';
import '../providers/notification_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    // Refresh user profile to get latest data including image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    String name = 'User';
    String email = '';
    String? image;
    bool isAdmin = false;
    if (user != null) {
      if (user is User) {
        name = user.fullName.isNotEmpty ? user.fullName : 'User';
        email = user.email;
        image = user.image;
        isAdmin = user.isAdmin;
      } else if (user is worker_models.Worker) {
        name = user.fullName.isNotEmpty ? user.fullName : 'User';
        email = user.email;
        image = user.image;
        // If you want to treat workers as admin, add logic here
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (image != null && image.isNotEmpty == true)
                            ? NetworkImage(image)
                            : null,
                    child:
                        (image == null || image.isEmpty != false)
                            ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF1565C0),
                            )
                            : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            // Profile Options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (isAdmin == true)
                    _buildProfileOption(
                      icon: Icons.admin_panel_settings,
                      title: 'Admin Panel',
                      subtitle: 'Manage categories, users, workers, orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPanelScreen(),
                          ),
                        );
                      },
                    ),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Edit your profile details',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    subtitle: 'Manage your addresses',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage your payment options',
                    onTap: () {},
                  ),
                  // Show Service History only for users, not workers
                  if (user is User)
                    _buildProfileOption(
                      icon: Icons.history,
                      title: 'Service History',
                      subtitle: 'View your past services',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ServiceHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  // Show Favorites only for users, not workers
                  if (user is User)
                    _buildProfileOption(
                      icon: Icons.favorite_outline,
                      title: 'Favorites',
                      subtitle: 'Your saved service providers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavouritesScreen(),
                          ),
                        );
                      },
                    ),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage your notifications',
                    onTap: () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChangeNotifierProvider(
                                create:
                                    (_) => NotificationProvider(authProvider),
                                child: const NotificationScreen(),
                              ),
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
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
                    icon: Icons.info_outline,
                    title: 'About HelpMate',
                    subtitle: 'Learn more about the app',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
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
