import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'payment_processing_screen.dart';
import '../providers/auth_provider.dart'; // Added import for AuthProvider
import '../screens/home_screen.dart'; // Added import for HomeScreen
import 'package:provider/provider.dart'; // Added import for Provider
import '../screens/login_screen.dart'; // Added import for LoginScreen

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> orderDetails;
  final String workerName;
  final double totalAmount;

  const BookingConfirmationScreen({
    super.key,
    required this.orderDetails,
    required this.workerName,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildOrderDetails(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildPaymentSection(context),
            const SizedBox(height: AppTheme.spacingXL),
            _buildNextSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 32),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Booking Confirmed!',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Your service has been successfully booked',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: AppTheme.heading4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildDetailRow('Worker', workerName),
          _buildDetailRow(
            'Service',
            orderDetails['description'] ?? 'Not specified',
          ),
          _buildDetailRow('Hours', '${orderDetails['hours']} hour(s)'),
          _buildDetailRow(
            'Total Amount',
            'BDT${totalAmount.toStringAsFixed(2)}',
          ),
          if (orderDetails['scheduled_date'] != null)
            _buildDetailRow('Scheduled Date', orderDetails['scheduled_date']),
          _buildDetailRow('Order ID', '#${orderDetails['id']}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Options',
            style: AppTheme.heading4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Choose how you would like to pay for this service:',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildPaymentOption(
            context,
            'Pay in Advance',
            'Pay now and get 5% discount',
            Icons.payment,
            AppTheme.primaryColor,
            () => _handlePayment(context, 'pay_in_advance'),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildPaymentOption(
            context,
            'Pay in Person',
            'Pay after service completion',
            Icons.person,
            AppTheme.secondaryColor,
            () => _handlePayment(context, 'pay_in_person'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Next?',
            style: AppTheme.heading4.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildNextStepItem(
            '1',
            'Worker will contact you',
            'Your worker will reach out to confirm details',
          ),
          _buildNextStepItem(
            '2',
            'Service completion',
            'Worker will complete the service as scheduled',
          ),
          _buildNextStepItem(
            '3',
            'Payment & Review',
            'Complete payment and leave a review',
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, String paymentMethod) {
    if (paymentMethod == 'pay_in_advance') {
      // Navigate to SSLCommerz payment processing screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => PaymentProcessingScreen(
                orderDetails: orderDetails,
                workerName: workerName,
                totalAmount: totalAmount,
              ),
        ),
      );
    } else {
      // Show payment processing dialog for pay in person
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Payment Setup'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppTheme.spacingM),
                  const Text(
                    'Setting up payment for after service completion...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
      );

      // Simulate payment setup
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment option set for after service completion'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to correct home/dashboard
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.refreshAuthAndUserType().then((authenticated) {
          if (!authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            );
          }
        });
      });
    }
  }
}
