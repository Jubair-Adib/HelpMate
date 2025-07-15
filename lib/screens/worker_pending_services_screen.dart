import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class WorkerPendingServicesScreen extends StatefulWidget {
  const WorkerPendingServicesScreen({super.key});

  @override
  State<WorkerPendingServicesScreen> createState() =>
      _WorkerPendingServicesScreenState();
}

class _WorkerPendingServicesScreenState
    extends State<WorkerPendingServicesScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService().getWorkerPendingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Pending Services',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1565C0),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading pending services...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading services',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending_actions_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Services',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You don\'t have any pending services at the moment.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final orders = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final order = orders[i];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        'Created: ${_formatDateTime(order.createdAt)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Service details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service information
                if (order.service != null) ...[
                  _buildInfoRow(
                    icon: Icons.work,
                    label: 'Service',
                    value: order.service!.title,
                    color: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.category,
                    label: 'Category',
                    value: order.service!.categoryName ?? 'N/A',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                ],
                // Description
                if (order.description != null && order.description!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: order.description!,
                    color: Colors.purple,
                  ),
                if (order.description != null && order.description!.isNotEmpty)
                  const SizedBox(height: 8),
                // Hours and amount
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.schedule,
                        label: 'Hours',
                        value:
                            '${order.hours} hour${order.hours > 1 ? 's' : ''}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'Total Amount',
                        value: 'BDT ${order.totalAmount.toStringAsFixed(2)}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Scheduled date
                if (order.scheduledDate != null)
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Scheduled Date',
                    value: _formatDate(order.scheduledDate!),
                    color: Colors.blue,
                  ),
                if (order.scheduledDate != null) const SizedBox(height: 8),
                // Payment method
                _buildInfoRow(
                  icon: Icons.payment,
                  label: 'Payment Method',
                  value: _formatPaymentMethod(order.paymentMethod),
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                // Client information
                if (order.user != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: const Color(0xFF1565C0),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Client Information',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1565C0),
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Name: ${order.user!.fullName}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          'Phone: ${order.user!.phone}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          'Address: ${order.user!.address}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.grey[700],
            fontFamily: 'Montserrat',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPaymentMethod(String? method) {
    if (method == null) return 'N/A';
    switch (method.toLowerCase()) {
      case 'pay_in_person':
        return 'Pay in Person';
      case 'online':
        return 'Online Payment';
      default:
        return method.replaceAll('_', ' ').toUpperCase();
    }
  }
}
