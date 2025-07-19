import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';

class ReviewDialogScreen extends StatefulWidget {
  final int orderId;
  final String workerName;
  final int workerId;

  const ReviewDialogScreen({
    super.key,
    required this.orderId,
    required this.workerName,
    required this.workerId,
  });

  @override
  State<ReviewDialogScreen> createState() => _ReviewDialogScreenState();
}

class _ReviewDialogScreenState extends State<ReviewDialogScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating between 1 and 5'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.createOrderReview(widget.orderId, {
        'rating': _rating,
        'comment': _commentController.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.rate_review, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'Review ${widget.workerName}',
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Rating
            Text(
              'How would you rate this service?',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppTheme.warningColor,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Comment
            Text(
              'Share your experience (optional)',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.spacingS),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
