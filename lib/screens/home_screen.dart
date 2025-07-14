import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'home_tabs/categories_tab.dart';
import 'home_tabs/search_tab.dart';
import 'home_tabs/orders_tab.dart';
import 'profile_tab.dart';
import 'worker_list_screen.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  late List<Widget> _tabs;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _initializeTabs();
    _fetchCategories();
  }

  void _initializeTabs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user is Worker) {
      // Worker tabs
      _tabs = [const SearchTab(), const OrdersTab(), const ProfileTab()];
    } else {
      // User tabs
      _tabs = [
        const CategoriesTab(),
        const SearchTab(),
        const OrdersTab(),
        const ProfileTab(),
      ];
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService().getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'User';
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with greeting and profile
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileTab(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _search = val),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Categories Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _categories.isEmpty
                              ? const Center(child: Text('No categories found'))
                              : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.1,
                                    ),
                                itemCount:
                                    _categories
                                        .where(
                                          (cat) => cat['name']
                                              .toString()
                                              .toLowerCase()
                                              .contains(_search.toLowerCase()),
                                        )
                                        .length,
                                itemBuilder: (context, index) {
                                  final filtered =
                                      _categories
                                          .where(
                                            (cat) => cat['name']
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                  _search.toLowerCase(),
                                                ),
                                          )
                                          .toList();
                                  final category = filtered[index];
                                  return _buildCategoryCard(category);
                                },
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final iconData = _getCategoryIcon(category['name']);
    final color = _getCategoryColor(category['name']);
    return GestureDetector(
      onTap: () {
        // Navigate to worker list with dummy data
        final cat = Category(
          id: _categories.indexOf(category) + 1,
          name: category['name'],
          description: '${category['name']} services',
          icon: null,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => WorkerListScreen(
                  category: cat,
                  // Pass dummy workers to the screen (requires a small change in WorkerListScreen)
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.contains('babysit')) return Icons.child_care;
    if (n.contains('ac repair')) return Icons.ac_unit;
    if (n.contains('tutor')) return Icons.school;
    if (n.contains('physician') ||
        n.contains('doctor') ||
        n.contains('medical'))
      return Icons.medical_services;
    if (n.contains('clean')) return Icons.cleaning_services;
    if (n.contains('plumb')) return Icons.plumbing;
    if (n.contains('electric')) return Icons.electrical_services;
    if (n.contains('carpent') || n.contains('wood')) return Icons.handyman;
    if (n.contains('garden')) return Icons.eco;
    if (n.contains('cook') || n.contains('chef') || n.contains('food'))
      return Icons.restaurant;
    if (n.contains('driver') || n.contains('drive')) return Icons.drive_eta;
    if (n.contains('security') || n.contains('guard')) return Icons.security;
    return Icons.category;
  }

  Color _getCategoryColor(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.contains('babysit')) return Colors.pink;
    if (n.contains('ac repair')) return Colors.blue;
    if (n.contains('tutor')) return Colors.orange;
    if (n.contains('physician') ||
        n.contains('doctor') ||
        n.contains('medical'))
      return Colors.red;
    if (n.contains('clean')) return Colors.green;
    if (n.contains('plumb')) return Colors.indigo;
    if (n.contains('electric')) return Colors.amber;
    if (n.contains('carpent') || n.contains('wood')) return Colors.brown;
    if (n.contains('garden')) return Colors.lightGreen;
    if (n.contains('cook') || n.contains('chef') || n.contains('food'))
      return Colors.deepOrange;
    if (n.contains('driver') || n.contains('drive')) return Colors.teal;
    if (n.contains('security') || n.contains('guard')) return Colors.grey;
    return const Color(0xFF1565C0);
  }
}
