// Add this external widget class:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/main.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final dynamic error;

  const ErrorDisplayWidget({super.key, required this.error});

  bool get isNetworkError =>
      error.toString().toLowerCase().contains('socket') ||
      error.toString().toLowerCase().contains('network') ||
      error.toString().toLowerCase().contains('connection') ||
      error.toString().toLowerCase().contains('timeout');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isNetworkError ? Colors.orange.shade50 : Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon with Animation
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isNetworkError
                              ? Colors.orange.shade100
                              : Colors.red.shade100,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isNetworkError ? Colors.orange : Colors.red)
                                      .withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isNetworkError ? Icons.wifi_off : Icons.error_outline,
                          size: 64,
                          color: isNetworkError
                              ? Colors.orange.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 32),

                // Error Title
                Text(
                  isNetworkError ? 'مشكلة في الاتصال' : 'خطأ في النظام',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                // Error Message
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNetworkError
                          ? Colors.orange.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Text(
                    isNetworkError
                        ? 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى'
                        : 'حدث خطأ في تحميل البيانات، يرجى المحاولة مرة أخرى',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 32),

                // Action Buttons
                Column(
                  children: [
                    // Primary Retry Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.offAll(() => const StartupScreen());
                        },
                        icon: Icon(Icons.refresh),
                        label: Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isNetworkError
                              ? Colors.orange.shade600
                              : Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    if (isNetworkError) ...[
                      SizedBox(height: 12),
                      // Network Help Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            _showNetworkTips(context);
                          },
                          icon: Icon(Icons.help_outline),
                          label: Text('نصائح للاتصال'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 24),

                // Technical Details (Collapsible)
                ExpansionTile(
                  title: Text(
                    'التفاصيل التقنية',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNetworkTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Text('نصائح لحل مشاكل الاتصال'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tipItem('تأكد من تشغيل الواي فاي أو البيانات المتنقلة'),
            _tipItem('جرب الاتصال بشبكة واي فاي أخرى'),
            _tipItem('أعد تشغيل الراوتر أو الجهاز'),
            _tipItem('تحقق من رصيد البيانات المتنقلة'),
            _tipItem('تأكد من عدم وجود مشاكل في الخدمة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6, left: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
