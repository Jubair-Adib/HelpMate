import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../services/api_service.dart';
import '../../models/user.dart' as user_models;
import '../../models/worker.dart';
import '../../models/category.dart';
import '../worker_list_screen.dart';
import '../worker_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Category> _categories = [];
  List<Worker> _workers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await _apiService.getCategories();
      final categories =
          categoriesData.map((json) => Category.fromJson(json)).toList();

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Handle error silently for categories
    }
  }

  Future<void> _searchWorkers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _workers = [];
        _searchQuery = '';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _searchQuery = query;
      });

      final workersData = await _apiService.getWorkers();
      final allWorkers = workersData;

      // Filter workers based on search query
      final filteredWorkers =
          allWorkers.where((worker) {
            final searchLower = query.toLowerCase();
            return worker.fullName.toLowerCase().contains(searchLower) ||
                (worker.skills != null &&
                    worker.skills!
                        .join(', ')
                        .toLowerCase()
                        .contains(searchLower)) ||
                (worker.address != null &&
                    worker.address!.toLowerCase().contains(searchLower));
          }).toList();

      setState(() {
        _workers = filteredWorkers;
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
      appBar: AppBar(title: const Text('Search'), elevation: 0),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for workers or services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchWorkers('');
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                _searchWorkers(value);
              },
            ),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchQuery.isEmpty) {
      return _buildQuickAccess();
    }

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
            Text('Error searching', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('No results found', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Try different keywords or browse categories',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _workers.length,
      itemBuilder: (context, index) {
        final worker = _workers[index];
        return _buildWorkerCard(worker);
      },
    );
  }

  Widget _buildQuickAccess() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Access', style: AppTheme.heading3),
          const SizedBox(height: AppTheme.spacingL),

          Text('Popular Categories', style: AppTheme.heading4),
          const SizedBox(height: AppTheme.spacingM),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingM,
              mainAxisSpacing: AppTheme.spacingM,
              childAspectRatio: 1.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
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
              Icon(
                _getCategoryIcon(category.name),
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                category.name,
                style: AppTheme.bodyMedium,
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

  Widget _buildWorkerCard(Worker worker) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          backgroundImage:
              (worker.image != null && worker.image!.isNotEmpty)
                  ? NetworkImage(worker.image!)
                  : null,
          child:
              (worker.image == null || worker.image!.isEmpty)
                  ? Text(
                    worker.fullName.split(' ').map((e) => e[0]).join(''),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                  : null,
        ),
        title: Text(worker.fullName, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              worker.skills != null && worker.skills!.isNotEmpty
                  ? worker.skills!.join(', ')
                  : 'No skills listed',
              style: AppTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: AppTheme.warningColor),
                const SizedBox(width: AppTheme.spacingXS),
                Text(worker.rating.toStringAsFixed(1), style: AppTheme.caption),
                const Spacer(),
                Text(
                  '\$${worker.hourlyRate ?? 0}/hr',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: AppTheme.spacingXS,
          ),
          decoration: BoxDecoration(
            color:
                worker.isAvailable
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Text(
            worker.isAvailable ? 'Available' : 'Busy',
            style: AppTheme.caption.copyWith(
              color:
                  worker.isAvailable
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => WorkerDetailScreen(worker: worker, isDummy: false),
            ),
          );
        },
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
