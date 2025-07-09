import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class WorkerDetailScreen extends StatefulWidget {
  final dynamic worker;
  final bool isDummy;

  const WorkerDetailScreen({
    super.key,
    required this.worker,
    this.isDummy = false,
  });

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final workerId =
          widget.isDummy ? widget.worker['id'] : widget.worker['id'];
      final reviewsData = await _apiService.getWorkerReviews(workerId);
      setState(() {
        _reviews = reviewsData;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDummy
              ? widget.worker['name']
              : widget.worker['full_name'] ?? 'Worker',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildInfo(),
            if (!widget.isDummy) _buildReviews(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage:
                widget.isDummy ? NetworkImage(widget.worker['avatar']) : null,
            child:
                widget.isDummy
                    ? null
                    : Text(
                      (widget.worker['full_name'] ?? 'Worker')
                          .split(' ')
                          .map((e) => e[0])
                          .join(''),
                      style: AppTheme.heading1.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Name
          Text(
            widget.isDummy
                ? widget.worker['name']
                : widget.worker['full_name'] ?? 'Worker',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacingS),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: AppTheme.warningColor, size: 20),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                widget.isDummy
                    ? '${widget.worker['rating']} (${widget.worker['reviews']} reviews)'
                    : '${(widget.worker['rating'] ?? 0.0).toStringAsFixed(1)} (${widget.worker['total_reviews'] ?? 0} reviews)',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),

          // Availability
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Text(
              'Available for Work',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Information', style: AppTheme.heading4),
          const SizedBox(height: AppTheme.spacingM),
          _buildInfoRow(
            'Skills',
            widget.isDummy
                ? widget.worker['skills']
                : (widget.worker['skills'] != null
                    ? (widget.worker['skills'] as List).join(', ')
                    : 'No skills listed'),
          ),
          _buildInfoRow(
            'Hourly Rate',
            widget.isDummy
                ? '\$${widget.worker['hourlyRate']}/hr'
                : '\$${widget.worker['hourly_rate'] ?? 0}/hr',
          ),
          _buildInfoRow(
            'Location',
            widget.isDummy
                ? widget.worker['address']
                : widget.worker['address'] ?? 'Not specified',
          ),
          _buildInfoRow(
            'Phone',
            widget.isDummy
                ? widget.worker['phone']
                : widget.worker['phone_number'] ?? 'Not specified',
          ),
          _buildInfoRow(
            'Member Since',
            widget.isDummy
                ? widget.worker['since']
                : _formatDate(DateTime.parse(widget.worker['created_at'])),
          ),
        ],
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

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: AppTheme.heading4),
          const SizedBox(height: AppTheme.spacingM),

          if (_isLoadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text('No reviews yet', style: AppTheme.bodyMedium),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryColor
                                  .withOpacity(0.1),
                              child: Text(
                                review['user_name']
                                        ?.split(' ')
                                        .map((e) => e[0])
                                        .join('') ??
                                    'U',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['user_name'] ?? 'Anonymous',
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppTheme.warningColor,
                                      ),
                                      const SizedBox(width: AppTheme.spacingXS),
                                      Text(
                                        '${review['rating']}',
                                        style: AppTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          review['comment'] ?? '',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Actions', style: AppTheme.heading4),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showHireDialog(),
                  icon: const Icon(Icons.work),
                  label: const Text('Hire Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startChat(),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHireDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController hoursController = TextEditingController(
      text: '1',
    );
    final TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hire Worker'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what you need...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    hintText: 'Number of hours',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Date',
                    hintText: 'YYYY-MM-DD HH:MM',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final workerId =
                        widget.isDummy
                            ? widget.worker['id']
                            : widget.worker['id'];
                    final serviceId =
                        1; // Default service ID, you might want to get this from the worker's services

                    await _apiService.createOrder({
                      'service_id': serviceId,
                      'description': descriptionController.text,
                      'hours': int.tryParse(hoursController.text) ?? 1,
                      'scheduled_date':
                          dateController.text.isNotEmpty
                              ? dateController.text
                              : null,
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order created successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Hire'),
              ),
            ],
          ),
    );
  }

  void _startChat() async {
    try {
      final workerId =
          widget.isDummy ? widget.worker['id'] : widget.worker['id'];
      final chat = await _apiService.createChat(workerId);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                chatId: chat['id'],
                workerName:
                    widget.isDummy
                        ? widget.worker['name']
                        : widget.worker['full_name'],
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
