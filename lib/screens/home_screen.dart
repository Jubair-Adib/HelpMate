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

  // Dummy workers for each category
  final Map<String, List<Worker>> _dummyWorkers = {
    'Babysitting': [
      Worker(
        id: 1,
        email: 'jane.babysit@example.com',
        fullName: 'Jane Babysitter',
        phone: '123-456-7890',
        address: '123 Main St',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'Child care, First Aid',
        hourlyRate: 15.0,
        lookingForWork: true,
        rating: 4.8,
        totalReviews: 22,
      ),
      Worker(
        id: 2,
        email: 'john.smith@example.com',
        fullName: 'John Smith',
        phone: '555-123-4567',
        address: '456 Oak Ave',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'Babysitting, Homework Help',
        hourlyRate: 13.0,
        lookingForWork: true,
        rating: 4.5,
        totalReviews: 10,
      ),
    ],
    'AC Repair': [
      Worker(
        id: 3,
        email: 'ac.pro@example.com',
        fullName: 'Alex Coolman',
        phone: '222-333-4444',
        address: '789 Pine Rd',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'AC Installation, Repair',
        hourlyRate: 25.0,
        lookingForWork: true,
        rating: 4.9,
        totalReviews: 30,
      ),
    ],
    'Tutoring': [
      Worker(
        id: 4,
        email: 'tutor.jane@example.com',
        fullName: 'Jane Tutor',
        phone: '111-222-3333',
        address: '321 Elm St',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'Math, Science, English',
        hourlyRate: 20.0,
        lookingForWork: true,
        rating: 4.7,
        totalReviews: 18,
      ),
    ],
    'Physician': [
      Worker(
        id: 5,
        email: 'dr.smith@example.com',
        fullName: 'Dr. Smith',
        phone: '444-555-6666',
        address: '654 Maple Ave',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'General Medicine',
        hourlyRate: 50.0,
        lookingForWork: true,
        rating: 5.0,
        totalReviews: 8,
      ),
    ],
    'Cleaner': [
      Worker(
        id: 6,
        email: 'cleaner.anna@example.com',
        fullName: 'Anna Clean',
        phone: '777-888-9999',
        address: '987 Cedar Blvd',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'House Cleaning, Deep Cleaning',
        hourlyRate: 18.0,
        lookingForWork: true,
        rating: 4.6,
        totalReviews: 15,
      ),
    ],
    'Plumber': [
      Worker(
        id: 7,
        email: 'plumber.joe@example.com',
        fullName: 'Joe Plumb',
        phone: '333-444-5555',
        address: '246 Spruce St',
        userType: 'worker',
        createdAt: DateTime.now(),
        skills: 'Pipes, Leak Repair',
        hourlyRate: 22.0,
        lookingForWork: true,
        rating: 4.4,
        totalReviews: 12,
      ),
    ],
  };

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
    return GestureDetector(
      onTap: () {
        // Navigate to worker list with dummy data
        final cat = Category(
          id: _categories.indexOf(category) + 1,
          name: category['name'],
          description: '${category['name']} services',
          icon: null,
        );
        final workers = _dummyWorkers[category['name']] ?? [];
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
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.category,
                size: 32,
                color: Color(0xFF1565C0),
              ),
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
}
