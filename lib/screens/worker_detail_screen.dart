import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

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
      final reviewsData = await _apiService.getWorkerReviews(widget.worker.id);
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
      appBar: AppBar(title: Text(widget.worker.fullName), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildHeader(), _buildInfo(), _buildReviews()],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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
            child: Text(
              widget.worker.fullName.split(' ').map((e) => e[0]).join(''),
              style: AppTheme.heading1.copyWith(color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Name
          Text(widget.worker.fullName, style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacingS),

          // Rating
          if (widget.worker.rating != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  '${widget.worker.rating!.toStringAsFixed(1)} (${widget.worker.totalReviews ?? 0} reviews)',
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
          ],

          // Availability
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color:
                  widget.worker.lookingForWork
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Text(
              widget.worker.lookingForWork
                  ? 'Available for Work'
                  : 'Currently Busy',
              style: AppTheme.bodyMedium.copyWith(
                color:
                    widget.worker.lookingForWork
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
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

          _buildInfoRow('Skills', widget.worker.skills),
          _buildInfoRow('Hourly Rate', '\$${widget.worker.hourlyRate}/hr'),
          _buildInfoRow('Location', widget.worker.address),
          _buildInfoRow('Phone', widget.worker.phone),
          _buildInfoRow('Member Since', _formatDate(widget.worker.createdAt)),
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hourly Rate', style: AppTheme.bodySmall),
                Text(
                  '\$${widget.worker.hourlyRate}/hr',
                  style: AppTheme.heading4.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed:
                widget.worker.lookingForWork
                    ? () {
                      // TODO: Navigate to booking screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking ${widget.worker.fullName}'),
                        ),
                      );
                    }
                    : null,
            child: Text(
              widget.worker.lookingForWork ? 'Book Now' : 'Not Available',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
