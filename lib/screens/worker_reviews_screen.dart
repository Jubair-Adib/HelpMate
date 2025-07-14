import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';

class WorkerReviewsScreen extends StatefulWidget {
  const WorkerReviewsScreen({super.key});

  @override
  State<WorkerReviewsScreen> createState() => _WorkerReviewsScreenState();
}

class _WorkerReviewsScreenState extends State<WorkerReviewsScreen> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    final worker = Provider.of<AuthProvider>(context, listen: false).worker;
    _reviewsFuture = ApiService().getWorkerReviews(worker?.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }
          final reviews = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final review = reviews[i];
              return _buildReviewCard(review);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
            backgroundImage:
                review.userImage != null && review.userImage!.isNotEmpty
                    ? NetworkImage(review.userImage!)
                    : null,
            child:
                (review.userImage == null || review.userImage!.isEmpty)
                    ? const Icon(
                      Icons.person,
                      size: 28,
                      color: Color(0xFF1565C0),
                    )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRatingStars(review.rating),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(review.comment, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
