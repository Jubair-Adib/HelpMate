import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/sslcommerz_service.dart';
import '../services/api_service.dart';
import 'service_history_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final String workerName;
  final double totalAmount;

  const PaymentProcessingScreen({
    super.key,
    required this.orderDetails,
    required this.workerName,
    required this.totalAmount,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final ApiService _apiService = ApiService();
  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _error;
  Map<String, dynamic>? _paymentData;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      setState(() {
        _isInitializing = true;
        _error = null;
      });

      // Get user profile for payment details
      final userProfile = await _apiService.getUserProfile();

      // Calculate discount
      final discountAmount = SSLCommerzService.calculateDiscount(
        widget.totalAmount,
      );
      final finalAmount = widget.totalAmount - discountAmount;

      // Initialize SSLCommerz payment
      final result = await SSLCommerzService.initializePayment(
        orderId: widget.orderDetails['id'].toString(),
        amount: widget.totalAmount,
        customerName: userProfile['full_name'] ?? 'Customer',
        customerEmail: userProfile['email'] ?? 'customer@example.com',
        customerPhone: userProfile['phone_number'] ?? '01700000000',
        customerAddress: userProfile['address'] ?? 'Dhaka, Bangladesh',
        successUrl: 'https://helpmate.com/payment/success',
        failUrl: 'https://helpmate.com/payment/fail',
        cancelUrl: 'https://helpmate.com/payment/cancel',
      );

      if (result['success']) {
        setState(() {
          _paymentData = result;
          _isInitializing = false;
        });
      } else {
        setState(() {
          _error = result['error'];
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Payment initialization failed: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_paymentData == null) return;

    try {
      setState(() {
        _isProcessing = true;
        _error = null;
      });

      // Launch payment URL
      final launched = await SSLCommerzService.launchPaymentUrl(
        _paymentData!['payment_url'],
      );

      if (launched) {
        // Show success message and navigate to home
        _showPaymentSuccessDialog();
      } else {
        setState(() {
          _error = 'Could not launch payment page. Please try again.';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Payment processing failed: $e';
        _isProcessing = false;
      });
    }
  }

  void _showPaymentSuccessDialog() {
    final discountAmount = SSLCommerzService.calculateDiscount(
      widget.totalAmount,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingS),
                const Text('Payment Successful!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your payment was processed successfully!',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'You saved \$${discountAmount.toStringAsFixed(2)} with advance payment.',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Transaction ID: ${_paymentData!['transaction_id']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(
                    context,
                  ).popUntil((route) => route.isFirst); // Go to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _navigateToServiceHistory() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Processing'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return _buildLoadingState('Initializing Payment...');
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_isProcessing) {
      return _buildLoadingState('Processing Payment...');
    }

    return _buildPaymentDetails();
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            message,
            style: AppTheme.heading4.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Please wait while we process your payment...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Payment Error',
              style: AppTheme.heading3.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              _error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _initializePayment,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _navigateToServiceHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                    child: const Text('View Orders'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    final discountAmount = SSLCommerzService.calculateDiscount(
      widget.totalAmount,
    );
    final finalAmount = widget.totalAmount - discountAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPaymentSummary(discountAmount, finalAmount),
          const SizedBox(height: AppTheme.spacingXL),
          _buildPaymentButton(),
          const SizedBox(height: AppTheme.spacingL),
          _buildPaymentInfo(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(double discountAmount, double finalAmount) {
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
            'Payment Summary',
            style: AppTheme.heading4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildSummaryRow(
            'Original Amount',
            '\$${widget.totalAmount.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Discount (5%)',
            '-\$${discountAmount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          const Divider(),
          _buildSummaryRow(
            'Final Amount',
            '\$${finalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.savings, size: 16, color: AppTheme.successColor),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'You save \$${discountAmount.toStringAsFixed(2)} with advance payment!',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color:
                  isDiscount
                      ? AppTheme.successColor
                      : (isTotal ? AppTheme.primaryColor : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return ElevatedButton.icon(
      onPressed: _processPayment,
      icon: const Icon(Icons.payment),
      label: const Text('Proceed to Payment'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Payment Information',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '• You will be redirected to SSLCommerz secure payment gateway\n'
            '• Your payment information is encrypted and secure\n'
            '• You can pay using any major credit/debit card or mobile banking\n'
            '• After successful payment, you will be redirected back to the app',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
