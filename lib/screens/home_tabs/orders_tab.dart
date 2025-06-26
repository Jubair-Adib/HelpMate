import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/user.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final ordersData = await _apiService.getOrders(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      final orders = ordersData.map((json) => Order.fromJson(json)).toList();

      setState(() {
        _orders = orders;
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(user is Worker ? 'My Jobs' : 'My Orders'),
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                  _loadOrders();
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: 'all', child: Text('All')),
                      const PopupMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'accepted',
                        child: Text('Accepted'),
                      ),
                      const PopupMenuItem(
                        value: 'in_progress',
                        child: Text('In Progress'),
                      ),
                      const PopupMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                child: const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingM),
                  child: Icon(Icons.filter_list),
                ),
              ),
            ],
          ),
          body: _buildBody(),
        );
      },
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
            Text('Error loading orders', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('No orders found', style: AppTheme.heading4),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _selectedStatus == 'all'
                  ? 'You haven\'t placed any orders yet'
                  : 'No orders with status: $_selectedStatus',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order.id}', style: AppTheme.heading4),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        'Scheduled: ${_formatDate(order.scheduledDate)}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Order Details
            Text(
              order.description,
              style: AppTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Order Footer
            Row(
              children: [
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                if (_canUpdateStatus(order.status))
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(order),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                    ),
                    child: Text(_getNextStatusText(order.status)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = AppTheme.warningColor;
        text = 'Pending';
        break;
      case 'accepted':
        color = AppTheme.primaryColor;
        text = 'Accepted';
        break;
      case 'in_progress':
        color = AppTheme.accentColor;
        text = 'In Progress';
        break;
      case 'completed':
        color = AppTheme.successColor;
        text = 'Completed';
        break;
      case 'cancelled':
        color = AppTheme.errorColor;
        text = 'Cancelled';
        break;
      default:
        color = AppTheme.textSecondaryColor;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _canUpdateStatus(String status) {
    return status == 'pending' ||
        status == 'accepted' ||
        status == 'in_progress';
  }

  String _getNextStatusText(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'Accept';
      case 'accepted':
        return 'Start';
      case 'in_progress':
        return 'Complete';
      default:
        return 'Update';
    }
  }

  Future<void> _updateOrderStatus(Order order) async {
    String newStatus;

    switch (order.status) {
      case 'pending':
        newStatus = 'accepted';
        break;
      case 'accepted':
        newStatus = 'in_progress';
        break;
      case 'in_progress':
        newStatus = 'completed';
        break;
      default:
        return;
    }

    try {
      await _apiService.updateOrderStatus(order.id, newStatus);
      _loadOrders(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
