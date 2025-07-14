import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';
import '../models/worker.dart';
import '../models/service.dart';
import 'chat_screen.dart';
import 'booking_confirmation_screen.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;
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
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;
  List<Service> _services = [];
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _checkFavoriteStatus();
    _loadServices();
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

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _apiService.checkFavorite(widget.worker.id);
      setState(() {
        _isFavorite = isFavorite;
        _isLoadingFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _apiService.removeFromFavorites(widget.worker.id);
        setState(() {
          _isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await _apiService.addToFavorites(widget.worker.id);
        setState(() {
          _isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoadingServices = true;
    });
    try {
      final serviceList = await _apiService.getServices(
        workerId: widget.worker.id,
      );
      setState(() {
        _services = serviceList.map((json) => Service.fromJson(json)).toList();
        _isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: AppTheme.warningColor, size: 20),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                '${widget.worker.rating.toStringAsFixed(1)} (${widget.worker.totalReviews} reviews)',
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
              color:
                  widget.worker.isAvailable
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Text(
              widget.worker.isAvailable
                  ? 'Available for Work'
                  : 'Not Available',
              style: AppTheme.bodyMedium.copyWith(
                color:
                    widget.worker.isAvailable
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
          _buildInfoRow(
            'Skills',
            widget.worker.skills != null && widget.worker.skills!.isNotEmpty
                ? widget.worker.skills!.join(', ')
                : 'No skills listed',
          ),
          _buildInfoRow('Hourly Rate', '\$${widget.worker.hourlyRate ?? 0}/hr'),
          _buildInfoRow('Location', widget.worker.address ?? 'Not specified'),
          _buildInfoRow('Phone', widget.worker.phoneNumber ?? 'Not specified'),
          _buildInfoRow('Member Since', _formatDate(widget.worker.createdAt)),
          if (widget.worker.bio != null && widget.worker.bio!.isNotEmpty)
            _buildInfoRow('Bio', widget.worker.bio!),
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
                                    review['user']?['full_name'] ?? 'Anonymous',
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

          // Favorites button
          if (!_isLoadingFavorite)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: ElevatedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                ),
                label: Text(
                  _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFavorite
                          ? Colors.red[100]
                          : AppTheme.primaryColor.withOpacity(0.1),
                  foregroundColor:
                      _isFavorite ? Colors.red[700] : AppTheme.primaryColor,
                  side: BorderSide(
                    color:
                        _isFavorite ? Colors.red[300]! : AppTheme.primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingM,
                  ),
                ),
              ),
            ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      widget.worker.isAvailable
                          ? () => _showHireDialog()
                          : null,
                  icon: const Icon(Icons.work),
                  label: Text(
                    widget.worker.isAvailable ? 'Hire Now' : 'Not Available',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.worker.isAvailable
                            ? AppTheme.primaryColor
                            : Colors.grey,
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
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.assignment, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text('Service Details', style: AppTheme.heading3),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  content:
                      _isLoadingServices
                          ? const Center(child: CircularProgressIndicator())
                          : _services.isEmpty
                          ? const Text('No services available for this worker.')
                          : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Description
                                const Text(
                                  'What do you need?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.description),
                                    labelText: 'Description',
                                    hintText: 'Describe your service needs...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                // Hours
                                const Text(
                                  'How many hours?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: hoursController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.access_time),
                                    labelText: 'Hours',
                                    hintText: 'e.g. 2',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                // Date & Time
                                const Text(
                                  'When do you need it?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: dateController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                    labelText: 'Scheduled Date & Time',
                                    hintText: 'YYYY-MM-DD HH:MM (optional)',
                                    helperText:
                                        'Leave empty for immediate booking',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Divider(),
                                // Summary
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'You can choose to pay in advance or in person on the next page.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _isLoadingServices || _services.isEmpty
                              ? null
                              : () async {
                                try {
                                  final orderData = await _apiService
                                      .createOrder({
                                        'service_id': _services[0].id,
                                        'description':
                                            descriptionController.text,
                                        'hours':
                                            int.tryParse(
                                              hoursController.text,
                                            ) ??
                                            1,
                                        'payment_method': 'pay_in_person',
                                        'scheduled_date':
                                            dateController.text.isNotEmpty
                                                ? dateController.text
                                                : null,
                                      });

                                  Navigator.of(context).pop(); // Close dialog

                                  // Navigate to confirmation screen
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => BookingConfirmationScreen(
                                            orderDetails: orderData,
                                            workerName: widget.worker.fullName,
                                            totalAmount:
                                                orderData['total_amount']
                                                    ?.toDouble() ??
                                                0.0,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  String errorMessage = 'Error creating order';
                                  if (e.toString().contains(
                                    'already booked at this time',
                                  )) {
                                    errorMessage =
                                        'Sorry, the worker is already booked at this time. Please choose another date and time.';
                                  } else if (e.toString().contains(
                                    'not available for booking',
                                  )) {
                                    errorMessage =
                                        'Worker is currently not available for booking.';
                                  } else if (e.toString().contains(
                                    'Service not found',
                                  )) {
                                    errorMessage =
                                        'Service not found. Please try again.';
                                  } else if (e.toString().contains(
                                    'Worker not found',
                                  )) {
                                    errorMessage =
                                        'Worker not found. Please try again.';
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                      child: const Text('Hire'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _startChat() async {
    try {
      final chat = await _apiService.createChat(widget.worker.id);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                chatId: chat['id'],
                workerName: widget.worker.fullName,
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
