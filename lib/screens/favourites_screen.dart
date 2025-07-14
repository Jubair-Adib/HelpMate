import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/worker.dart';
import 'worker_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _favourites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final favs = await _apiService.getFavorites();
      setState(() {
        _favourites = favs;
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
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _favourites.isEmpty
              ? const Center(child: Text('No favourites yet.'))
              : RefreshIndicator(
                onRefresh: _loadFavourites,
                child: ListView.builder(
                  itemCount: _favourites.length,
                  itemBuilder: (context, index) {
                    final fav = _favourites[index];
                    final worker = fav['worker'] ?? {};
                    final workerModel = Worker.fromJson(worker);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    WorkerDetailScreen(worker: workerModel),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with initials
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(
                                  0xFF1565C0,
                                ).withOpacity(0.15),
                                child: Text(
                                  (worker['full_name'] ?? 'W')
                                      .split(' ')
                                      .map((e) => e.isNotEmpty ? e[0] : '')
                                      .join()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      worker['full_name'] ?? 'Worker',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      worker['email'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber[700],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (worker['rating'] ?? 0)
                                              .toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${worker['total_reviews'] ?? 0} reviews',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (worker['skills'] != null &&
                                        worker['skills'] is List &&
                                        (worker['skills'] as List).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Skills: ${(worker['skills'] as List).join(', ')}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          worker['is_available'] == true
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color:
                                              worker['is_available'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          worker['is_available'] == true
                                              ? 'Available'
                                              : 'Not Available',
                                          style: TextStyle(
                                            color:
                                                worker['is_available'] == true
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Remove button
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await _apiService.removeFromFavorites(
                                    worker['id'],
                                  );
                                  _loadFavourites();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
