import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';

class SubscriberBudgetsPage extends StatelessWidget {
  SubscriberBudgetsPage({super.key});
  final budget_service = Get.find<BudgetService>();
  final subscriber_service = Get.find<SubscribersService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "ميزانية المشتركين",
        font_size: 28,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'تصفية المشتركين',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث البيانات',
            onPressed: () async {
              await budget_service.getBudgets();
              await subscriber_service.getSubscripers();
              Get.snackbar(
                'تم التحديث',
                'تم تحميل البيانات من جديد',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green[400],
                colorText: Colors.white,
                duration: Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (budget_service.BudgetList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildHeaderStats(),
            _buildSearchAndFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await budget_service.getBudgets();
                  await subscriber_service.getSubscripers();
                },
                child: _buildSubscribersList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'لا توجد ميزانيات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'يجب إنشاء ميزانيات أولاً لعرض معلومات المشتركين',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    final stats = _calculateSubscriberStats();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people, color: Colors.white, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إحصائيات المشتركين',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${stats['total_subscribers']} مشترك إجمالي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المدفوعون',
                  '${stats['paid_subscribers']}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'غير المدفوعين',
                  '${stats['unpaid_subscribers']}',
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'الميزانيات',
                  '${budget_service.BudgetList.length}',
                  Colors.orange,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          TextField(
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'ابحث باسم المشترك...',
              hintTextDirection: TextDirection.rtl,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (value) {
              _searchSubscribers(value);
            },
          ),
          SizedBox(height: 12),
          // Month/Year Selection
          Row(
            children: [
              Expanded(child: _buildMonthYearSelector()),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showFilterDialog(Get.context!),
                icon: Icon(Icons.filter_list, size: 18),
                label: Text('تصفية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);
    final months = [
      {'name': 'يناير', 'value': 1},
      {'name': 'فبراير', 'value': 2},
      {'name': 'مارس', 'value': 3},
      {'name': 'أبريل', 'value': 4},
      {'name': 'مايو', 'value': 5},
      {'name': 'يونيو', 'value': 6},
      {'name': 'يوليو', 'value': 7},
      {'name': 'أغسطس', 'value': 8},
      {'name': 'سبتمبر', 'value': 9},
      {'name': 'أكتوبر', 'value': 10},
      {'name': 'نوفمبر', 'value': 11},
      {'name': 'ديسمبر', 'value': 12},
    ];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'السنة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            initialValue: _selectedYear.value,
            items: years.map((year) {
              return DropdownMenuItem(value: year, child: Text('$year'));
            }).toList(),
            onChanged: (value) {
              _selectedYear.value = value ?? currentYear;
              _filterByMonthYear();
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'الشهر',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            initialValue: _selectedMonth.value,
            items: months.map((month) {
              return DropdownMenuItem(
                value: month['value'] as int,
                child: Text(month['name'] as String),
              );
            }).toList(),
            onChanged: (value) {
              _selectedMonth.value = value ?? DateTime.now().month;
              _filterByMonthYear();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribersList() {
    final subscribers = _getFilteredSubscribers();
    final subscriberStats = _calculateSubscriberPaymentStats();

    if (subscribers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'لا يوجد مشتركين',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'جرب تغيير معايير البحث أو التصفية',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: subscribers.length,
      itemBuilder: (context, index) {
        final subscriber = subscribers[index];
        final stats =
            subscriberStats[subscriber.id] ??
            {
              'months_paid': 0,
              'months_unpaid': 0,
              'total_paid': 0.0,
              'total_unpaid': 0.0,
              'last_payment_month': null,
              'payment_percentage': 0.0,
            };

        return _buildSubscriberCard(context, subscriber, stats);
      },
    );
  }

  Widget _buildSubscriberCard(
    context,
    Subscriper subscriber,
    Map<String, dynamic> stats,
  ) {
    final paymentPercentage = stats['payment_percentage'] as double;
    final monthsPaid = stats['months_paid'] as int;
    final monthsUnpaid = stats['months_unpaid'] as int;
    final totalPaid = stats['total_paid'] as double;
    final totalUnpaid = stats['total_unpaid'] as double;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showSubscriberDetails(context, subscriber, stats);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSubscriberAvatar(subscriber.name),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscriber.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${subscriber.amber} أمبير - الجوزة: ${subscriber.circuit_number}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (subscriber.phone.isNotEmpty)
                            Text(
                              subscriber.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildPaymentStatusIndicator(paymentPercentage),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentStatItem(
                        'أشهر مدفوعة',
                        '$monthsPaid',
                        '${totalPaid.toStringAsFixed(2)} د.ع',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentStatItem(
                        'أشهر غير مدفوعة',
                        '$monthsUnpaid',
                        '${totalUnpaid.toStringAsFixed(2)} د.ع',
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: paymentPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    paymentPercentage >= 80
                        ? Colors.green
                        : paymentPercentage >= 50
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'نسبة الدفع: ${paymentPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriberAvatar(String name) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '؟',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusIndicator(double percentage) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (percentage >= 80) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'ممتاز';
    } else if (percentage >= 50) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'جيد';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'ضعيف';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          SizedBox(height: 2),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatItem(
    String label,
    String count,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateSubscriberStats() {
    final subscribers = subscriber_service.subscribersList;
    int paidSubscribers = 0;
    int unpaidSubscribers = 0;

    for (var subscriber in subscribers) {
      final stats = _calculateSubscriberPaymentStats()[subscriber.id];
      if (stats != null && stats['payment_percentage'] > 0) {
        paidSubscribers++;
      } else {
        unpaidSubscribers++;
      }
    }

    return {
      'total_subscribers': subscribers.length,
      'paid_subscribers': paidSubscribers,
      'unpaid_subscribers': unpaidSubscribers,
    };
  }

  Map<int, Map<String, dynamic>> _calculateSubscriberPaymentStats() {
    final subscribers = subscriber_service.subscribersList;
    final budgets = budget_service.BudgetList;
    Map<int, Map<String, dynamic>> subscriberStats = {};

    for (var subscriber in subscribers) {
      int monthsPaid = 0;
      int monthsUnpaid = 0;
      double totalPaid = 0.0;
      double totalUnpaid = 0.0;
      DateTime? lastPaymentMonth;

      for (var budget in budgets) {
        final paidSubs = budget.getPaidSubsObjects();
        final unpaidSubs = budget.getUnpaidSubsObjects();

        if (paidSubs.any((sub) => sub.id == subscriber.id)) {
          monthsPaid++;
          totalPaid += subscriber.amber * budget.amber_price;
          lastPaymentMonth = DateTime(budget.year, budget.month);
        } else if (unpaidSubs.any((sub) => sub.id == subscriber.id)) {
          monthsUnpaid++;
          totalUnpaid += subscriber.amber * budget.amber_price;
        }
      }

      final totalMonths = monthsPaid + monthsUnpaid;
      final paymentPercentage = totalMonths > 0
          ? (monthsPaid / totalMonths) * 100
          : 0.0;

      subscriberStats[subscriber.id] = {
        'months_paid': monthsPaid,
        'months_unpaid': monthsUnpaid,
        'total_paid': totalPaid,
        'total_unpaid': totalUnpaid,
        'last_payment_month': lastPaymentMonth,
        'payment_percentage': paymentPercentage,
      };
    }

    return subscriberStats;
  }

  void _showSubscriberDetails(
    BuildContext context,
    Subscriper subscriber,
    Map<String, dynamic> stats,
  ) {
    final monthsPaid = stats['months_paid'] as int;
    final monthsUnpaid = stats['months_unpaid'] as int;
    final totalPaid = stats['total_paid'] as double;
    final totalUnpaid = stats['total_unpaid'] as double;
    final lastPaymentMonth = stats['last_payment_month'] as DateTime?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                _buildSubscriberAvatar(subscriber.name),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscriber.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${subscriber.amber} أمبير - الجوزة: ${subscriber.circuit_number}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildDetailRow(
              'إجمالي الأشهر',
              '${monthsPaid + monthsUnpaid}',
              Icons.calendar_today,
            ),
            _buildDetailRow(
              'الأشهر المدفوعة',
              '$monthsPaid',
              Icons.check_circle,
              Colors.green,
            ),
            _buildDetailRow(
              'الأشهر غير المدفوعة',
              '$monthsUnpaid',
              Icons.cancel,
              Colors.red,
            ),
            _buildDetailRow(
              'إجمالي المدفوع',
              '${totalPaid.toStringAsFixed(2)} د.ع',
              Icons.attach_money,
              Colors.green,
            ),
            _buildDetailRow(
              'إجمالي غير المدفوع',
              '${totalUnpaid.toStringAsFixed(2)} د.ع',
              Icons.money_off,
              Colors.red,
            ),
            if (lastPaymentMonth != null)
              _buildDetailRow(
                'آخر دفع',
                '${lastPaymentMonth.month}/${lastPaymentMonth.year}',
                Icons.schedule,
                Colors.blue,
              ),
            SizedBox(height: 24),
            LinearProgressIndicator(
              value: stats['payment_percentage'] / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                stats['payment_percentage'] >= 80
                    ? Colors.green
                    : stats['payment_percentage'] >= 50
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'نسبة الدفع: ${stats['payment_percentage'].toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showSubscriberMonthDetails(context, subscriber);
                },
                icon: Icon(Icons.calendar_month),
                label: Text('عرض تفاصيل الأشهر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showSubscriberMonthDetails(
    BuildContext context,
    Subscriper subscriber,
  ) {
    final budgets = budget_service.BudgetList;
    final monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    // Group budgets by year
    final Map<int, List<Budget>> budgetsByYear = {};
    for (var budget in budgets) {
      if (!budgetsByYear.containsKey(budget.year)) {
        budgetsByYear[budget.year] = [];
      }
      budgetsByYear[budget.year]!.add(budget);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.person, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              'تفاصيل أشهر ${subscriber.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ...(() {
                final years = budgetsByYear.keys.toList();
                years.sort((a, b) => b.compareTo(a));
                return years.map((year) {
                  final yearBudgets = budgetsByYear[year]!;
                  yearBudgets.sort((a, b) => a.month.compareTo(b.month));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'سنة $year',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...yearBudgets.map((budget) {
                        final paidSubs = budget.getPaidSubsObjects();
                        final unpaidSubs = budget.getUnpaidSubsObjects();
                        final isPaid = paidSubs.any(
                          (s) => s.id == subscriber.id,
                        );
                        final isUnpaid = unpaidSubs.any(
                          (s) => s.id == subscriber.id,
                        );

                        if (!isPaid && !isUnpaid) return SizedBox.shrink();

                        final amount = subscriber.amber * budget.amber_price;
                        final monthName = monthNames[budget.month - 1];

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPaid
                                  ? Colors.green[300]!
                                  : Colors.red[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPaid ? Icons.check_circle : Icons.cancel,
                                color: isPaid ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$monthName $year',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      '${subscriber.amber} أمبير',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${amount.toStringAsFixed(2)} د.ع',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isPaid
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList();
              })(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey[600]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية المشتركين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('المشتركين المدفوعين'),
              subtitle: Text('عرض المشتركين الذين دفعوا'),
              onTap: () {
                Navigator.pop(context);
                _filterByPaymentStatus('paid');
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('المشتركين غير المدفوعين'),
              subtitle: Text('عرض المشتركين الذين لم يدفعوا'),
              onTap: () {
                Navigator.pop(context);
                _filterByPaymentStatus('unpaid');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('عرض شهر محدد'),
              subtitle: Text('عرض تفاصيل الشهر المحدد'),
              onTap: () {
                Navigator.pop(context);
                _showMonthDetails(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sort, color: Colors.blue),
              title: Text('ترتيب حسب نسبة الدفع'),
              subtitle: Text('ترتيب من الأعلى إلى الأقل'),
              onTap: () {
                Navigator.pop(context);
                _sortByPaymentPercentage();
              },
            ),
            ListTile(
              leading: Icon(Icons.clear_all, color: Colors.grey),
              title: Text('إلغاء التصفية'),
              subtitle: Text('عرض جميع المشتركين'),
              onTap: () {
                Navigator.pop(context);
                _clearFilters();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showMonthDetails(BuildContext context) {
    final selectedYear = _selectedYear.value;
    final selectedMonth = _selectedMonth.value;

    // Get the budget for the selected month/year
    final budgets = budget_service.BudgetList;
    final targetBudget = budgets
        .where(
          (budget) =>
              budget.year == selectedYear && budget.month == selectedMonth,
        )
        .firstOrNull;

    if (targetBudget == null) {
      Get.snackbar(
        'لا توجد ميزانية',
        'لا توجد ميزانية للشهر والسنة المحددين',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[400],
        colorText: Colors.white,
      );
      return;
    }

    final paidSubs = targetBudget.getPaidSubsObjects();
    final unpaidSubs = targetBudget.getUnpaidSubsObjects();
    final monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.calendar_month, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              'ميزانية ${monthNames[selectedMonth - 1]} $selectedYear',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthStatCard(
                'المشتركين المدفوعين',
                paidSubs.length.toString(),
                '${_calculateTotalAmount(paidSubs, targetBudget.amber_price).toStringAsFixed(2)} د.ع',
                Colors.green,
                Icons.check_circle,
              ),
              SizedBox(height: 12),
              _buildMonthStatCard(
                'المشتركين غير المدفوعين',
                unpaidSubs.length.toString(),
                '${_calculateTotalAmount(unpaidSubs, targetBudget.amber_price).toStringAsFixed(2)} د.ع',
                Colors.red,
                Icons.cancel,
              ),
              SizedBox(height: 20),
              if (paidSubs.isNotEmpty) ...[
                Text(
                  'المشتركين المدفوعين:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 8),
                ...paidSubs.map(
                  (sub) => _buildSubscriberListItem(
                    sub.name,
                    '${sub.amber} أمبير',
                    '${(sub.amber * targetBudget.amber_price).toStringAsFixed(2)} د.ع',
                    Colors.green,
                  ),
                ),
                SizedBox(height: 16),
              ],
              if (unpaidSubs.isNotEmpty) ...[
                Text(
                  'المشتركين غير المدفوعين:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                ...unpaidSubs.map(
                  (sub) => _buildSubscriberListItem(
                    sub.name,
                    '${sub.amber} أمبير',
                    '${(sub.amber * targetBudget.amber_price).toStringAsFixed(2)} د.ع',
                    Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStatCard(
    String title,
    String count,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '$count مشترك',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberListItem(
    String name,
    String amber,
    String amount,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(amber, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(width: 16),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalAmount(
    List<Subscriper> subscribers,
    double amberPrice,
  ) {
    return subscribers.fold(0.0, (sum, sub) => sum + (sub.amber * amberPrice));
  }

  // State variables for filtering
  final RxInt _selectedYear = DateTime.now().year.obs;
  final RxInt _selectedMonth = DateTime.now().month.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _currentFilter = ''.obs;
  final RxBool _isFiltered = false.obs;

  // Filter methods
  void _searchSubscribers(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void _filterByMonthYear() {
    _isFiltered.value = true;
    _applyFilters();
  }

  void _filterByPaymentStatus(String status) {
    _currentFilter.value = status;
    _isFiltered.value = true;
    _applyFilters();
  }

  void _sortByPaymentPercentage() {
    // Implement sorting logic
    _applyFilters();
  }

  void _clearFilters() {
    _searchQuery.value = '';
    _currentFilter.value = '';
    _isFiltered.value = false;
    _selectedYear.value = DateTime.now().year;
    _selectedMonth.value = DateTime.now().month;
    _applyFilters();
  }

  void _applyFilters() {
    // This will trigger the Obx to rebuild the list
  }

  List<Subscriper> _getFilteredSubscribers() {
    var subscribers = subscriber_service.subscribersList;

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      subscribers.value = subscribers
          .where(
            (sub) => sub.name.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    // Apply month/year filter
    if (_isFiltered.value) {
      subscribers.value = subscribers.where((sub) {
        final stats = _calculateSubscriberPaymentStats()[sub.id];
        if (stats == null) return false;

        // Check if subscriber has any activity in selected month/year
        final budgets = budget_service.BudgetList;
        for (var budget in budgets) {
          if (budget.year == _selectedYear.value &&
              budget.month == _selectedMonth.value) {
            final paidSubs = budget.getPaidSubsObjects();
            final unpaidSubs = budget.getUnpaidSubsObjects();

            if (paidSubs.any((s) => s.id == sub.id) ||
                unpaidSubs.any((s) => s.id == sub.id)) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }

    // Apply payment status filter
    if (_currentFilter.value.isNotEmpty) {
      subscribers.value = subscribers.where((sub) {
        final stats = _calculateSubscriberPaymentStats()[sub.id];
        if (stats == null) return false;

        switch (_currentFilter.value) {
          case 'paid':
            return stats['payment_percentage'] > 0;
          case 'unpaid':
            return stats['payment_percentage'] == 0;
          default:
            return true;
        }
      }).toList();
    }

    return subscribers;
  }
}
