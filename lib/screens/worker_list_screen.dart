import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/worker.dart';
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

      final workers = await _apiService.getWorkers(
        categoryId: widget.category.id.toString(),
      );
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('Error loading workers', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingM),
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

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _workers.length,
      itemBuilder: (context, index) {
        final worker = _workers[index];
        return _buildWorkerCard(worker);
      },
    );
  }

  Widget _buildWorkerCard(Worker worker) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => WorkerDetailScreen(worker: worker, isDummy: false),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              // Worker Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage:
                    (worker.image != null && worker.image!.isNotEmpty)
                        ? NetworkImage(worker.image!)
                        : null,
                child:
                    (worker.image == null || worker.image!.isEmpty)
                        ? Text(
                          worker.fullName.split(' ').map((e) => e[0]).join(''),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 18),

              // Worker Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worker.skills != null && worker.skills!.isNotEmpty
                          ? worker.skills!.join(', ')
                          : 'No skills listed',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          worker.rating.toString(),
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          ' (${worker.totalReviews} reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'BDT ${worker.hourlyRate ?? 0}/hr',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
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
      ),
    );
  }
}
