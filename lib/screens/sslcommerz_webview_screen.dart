import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../constants/theme.dart';
import 'service_history_screen.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SslcommerzWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final double totalAmount;
  final double discountAmount;

  const SslcommerzWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.totalAmount,
    required this.discountAmount,
  });

  @override
  State<SslcommerzWebViewScreen> createState() =>
      _SslcommerzWebViewScreenState();
}

class _SslcommerzWebViewScreenState extends State<SslcommerzWebViewScreen> {
  bool _isLoading = true;
  late final WebViewController _controller;

  // These should match the URLs you set in the payment request
  final String _successUrl = 'http://10.0.2.2:8000/payment/success';
  final String _failUrl = 'http://10.0.2.2:8000/payment/fail';
  final String _cancelUrl = 'http://10.0.2.2:8000/payment/cancel';

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (_) {
                setState(() => _isLoading = false);
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith(_successUrl)) {
                  _onPaymentSuccess();
                  return NavigationDecision.prevent;
                } else if (request.url.startsWith(_failUrl) ||
                    request.url.startsWith(_cancelUrl)) {
                  _onPaymentFailed();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSLCommerz Payment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _onPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 40,
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text('Payment Successful!', textAlign: TextAlign.center),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  'You saved BDT ${widget.discountAmount.toStringAsFixed(2)} with advance payment.',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Show green SnackBar and navigate to correct home
                  Future.delayed(Duration.zero, () async {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final authenticated =
                        await authProvider.refreshAuthAndUserType();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
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

  void _onPaymentFailed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                const SizedBox(width: AppTheme.spacingS),
                const Text('Payment Failed'),
              ],
            ),
            content: const Text(
              'Your payment was not successful. You can try again from your order history.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const ServiceHistoryScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Orders'),
              ),
            ],
          ),
    );
  }
}
