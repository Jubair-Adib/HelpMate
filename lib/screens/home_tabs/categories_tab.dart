import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../services/api_service.dart';
import '../../models/category.dart';
import '../worker_list_screen.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final categoriesData = await _apiService.getCategories();
      final categories =
          categoriesData.map((json) => Category.fromJson(json)).toList();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Categories'), elevation: 0),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: AppTheme.spacingM),
            Text('Error loading categories', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('No categories available', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Check back later for available services',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingL,
          mainAxisSpacing: AppTheme.spacingL,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkerListScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  size: 30,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Category Name
              Text(
                category.name,
                style: AppTheme.heading4,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingS),

              // Category Description
              Text(
                category.description,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('plumbing')) return Icons.plumbing;
    if (name.contains('electrical')) return Icons.electrical_services;
    if (name.contains('cleaning')) return Icons.cleaning_services;
    if (name.contains('carpentry')) return Icons.handyman;
    if (name.contains('painting')) return Icons.format_paint;
    if (name.contains('gardening')) return Icons.yard;
    if (name.contains('moving')) return Icons.local_shipping;
    if (name.contains('repair')) return Icons.build;
    return Icons.category;
  }
}
