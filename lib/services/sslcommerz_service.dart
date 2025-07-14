import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SSLCommerzService {
  static const String _storeId = 'maste679cfa8ec592d';
  static const String _storePass = 'maste679cfa8ec592d@ssl';
  static const bool _isSandbox = true;

  // Base URLs
  static String get _baseUrl =>
      _isSandbox
          ? 'https://sandbox.sslcommerz.com'
          : 'https://securepay.sslcommerz.com';

  static String get _apiUrl =>
      _isSandbox
          ? 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php'
          : 'https://securepay.sslcommerz.com/gwprocess/v4/api.php';

  /// Initialize payment with SSLCommerz
  static Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String successUrl,
    required String failUrl,
    required String cancelUrl,
  }) async {
    try {
      // Generate unique transaction ID
      final transactionId = _generateTransactionId();

      // Calculate discount amount (5% for advance payment)
      final discountAmount = amount * 0.05;
      final finalAmount = amount - discountAmount;

      // Prepare payment data
      final paymentData = {
        'store_id': _storeId,
        'store_passwd': _storePass,
        'total_amount': finalAmount.toStringAsFixed(2),
        'currency': 'BDT',
        'tran_id': transactionId,
        'product_category': 'service',
        'success_url': successUrl,
        'fail_url': failUrl,
        'cancel_url': cancelUrl,
        'ipn_url': '', // Optional: Instant Payment Notification URL
        'cus_name': customerName,
        'cus_email': customerEmail,
        'cus_add1': customerAddress,
        'cus_phone': customerPhone,
        'cus_city': 'Dhaka',
        'cus_country': 'Bangladesh',
        'shipping_method': 'NO',
        'product_name': 'Home Service Booking',
        'product_profile': 'service',
        'product_amount': finalAmount.toStringAsFixed(2),
        'discount_amount': discountAmount.toStringAsFixed(2),
        'value_a': orderId, // Store order ID for reference
        'value_b': 'advance_payment',
        'value_c': 'helpmate_app',
      };

      // Make API request to SSLCommerz
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: paymentData,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'VALID' ||
            responseData['status'] == 'SUCCESS') {
          return {
            'success': true,
            'payment_url': responseData['GatewayPageURL'],
            'transaction_id': transactionId,
            'session_key': responseData['sessionkey'],
            'amount': finalAmount,
            'discount_amount': discountAmount,
          };
        } else {
          return {
            'success': false,
            'error':
                responseData['failedreason'] ?? 'Payment initialization failed',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Network error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Payment initialization error: $e'};
    }
  }

  /// Verify payment status
  static Future<Map<String, dynamic>> verifyPayment({
    required String transactionId,
    required String sessionKey,
  }) async {
    try {
      final verificationData = {
        'store_id': _storeId,
        'store_passwd': _storePass,
        'tran_id': transactionId,
        'sessionkey': sessionKey,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/validator/api/validationserverAPI.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: verificationData,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'VALID' ||
            responseData['status'] == 'VALIDATED') {
          return {
            'success': true,
            'status': 'success',
            'transaction_id': responseData['tran_id'],
            'amount': responseData['amount'],
            'currency': responseData['currency'],
            'payment_date': responseData['tran_date'],
          };
        } else {
          return {
            'success': false,
            'status': 'failed',
            'error': responseData['error'] ?? 'Payment verification failed',
          };
        }
      } else {
        return {
          'success': false,
          'status': 'failed',
          'error': 'Verification network error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'status': 'failed',
        'error': 'Verification error: $e',
      };
    }
  }

  /// Launch payment URL in browser
  static Future<bool> launchPaymentUrl(String paymentUrl) async {
    try {
      final uri = Uri.parse(paymentUrl);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }

  /// Generate unique transaction ID
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'TXN_${timestamp}_$random';
  }

  /// Format amount for display
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Calculate discount amount
  static double calculateDiscount(double amount) {
    return amount * 0.05; // 5% discount
  }
}
