import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const Text(
                        'John Doe',
                        style: TextStyle(
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
                          builder: (context) => const ProfilePage(),
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
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: serviceCategories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(serviceCategories[index]);
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

  Widget _buildCategoryCard(ServiceCategory category) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category specific page
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
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, size: 32, color: category.color),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
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

class ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;

  ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

final List<ServiceCategory> serviceCategories = [
  ServiceCategory(
    name: 'Babysitting',
    icon: Icons.child_care,
    color: Colors.pink,
  ),
  ServiceCategory(name: 'AC Repair', icon: Icons.ac_unit, color: Colors.blue),
  ServiceCategory(name: 'Tutoring', icon: Icons.school, color: Colors.orange),
  ServiceCategory(
    name: 'Physician',
    icon: Icons.medical_services,
    color: Colors.red,
  ),
  ServiceCategory(
    name: 'Cleaner',
    icon: Icons.cleaning_services,
    color: Colors.green,
  ),
  ServiceCategory(name: 'Plumber', icon: Icons.plumbing, color: Colors.indigo),
  ServiceCategory(
    name: 'Electrician',
    icon: Icons.electrical_services,
    color: Colors.amber,
  ),
  ServiceCategory(name: 'Carpenter', icon: Icons.handyman, color: Colors.brown),
  ServiceCategory(name: 'Gardener', icon: Icons.eco, color: Colors.lightGreen),
  ServiceCategory(
    name: 'Cook',
    icon: Icons.restaurant,
    color: Colors.deepOrange,
  ),
  ServiceCategory(name: 'Driver', icon: Icons.drive_eta, color: Colors.teal),
  ServiceCategory(name: 'Security', icon: Icons.security, color: Colors.grey),
];
