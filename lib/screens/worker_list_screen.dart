import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/user.dart';
import 'worker_detail_screen.dart';

class WorkerListScreen extends StatefulWidget {
  final Category category;

  const WorkerListScreen({super.key, required this.category});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  final ApiService _apiService = ApiService();
  List<Worker> _workers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final workersData = await _apiService.getWorkers(
        categoryId: widget.category.id.toString(),
      );
      final workers = workersData.map((json) => Worker.fromJson(json)).toList();

      setState(() {
        _workers = workers;
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
      appBar: AppBar(title: Text(widget.category.name), elevation: 0),
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
            Text('Error loading workers', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(onPressed: _loadWorkers, child: const Text('Retry')),
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
              Icons.people_outline,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('No workers available', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'No workers found for ${widget.category.name}',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        itemCount: _workers.length,
        itemBuilder: (context, index) {
          final worker = _workers[index];
          return _buildWorkerCard(worker);
        },
      ),
    );
  }

  Widget _buildWorkerCard(Worker worker) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkerDetailScreen(worker: worker),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              // Worker Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  worker.fullName.split(' ').map((e) => e[0]).join(''),
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),

              // Worker Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.fullName, style: AppTheme.heading4),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      worker.skills,
                      style: AppTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          worker.rating?.toStringAsFixed(1) ?? 'No rating',
                          style: AppTheme.bodySmall,
                        ),
                        if (worker.totalReviews != null) ...[
                          Text(
                            ' (${worker.totalReviews} reviews)',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '\$${worker.hourlyRate}/hr',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Availability Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color:
                      worker.lookingForWork
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  worker.lookingForWork ? 'Available' : 'Busy',
                  style: AppTheme.caption.copyWith(
                    color:
                        worker.lookingForWork
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
