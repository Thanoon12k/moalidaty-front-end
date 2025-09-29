import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/common_widgets/delete_dialoge.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/budgets/ui/add_budget_dialoge.dart';
import 'package:moalidaty/features/budgets/ui/subscriber_budgets_page.dart';

class BudgetsListPage extends StatelessWidget {
  BudgetsListPage({super.key});
  final budget_service = Get.find<BudgetService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "قائمة الميزانيات",
        font_size: 28,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'البحث والتصفية',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'خيارات العرض',
            onPressed: () {
              _showViewOptionsDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث الميزانيات',
            onPressed: () async {
              await budget_service.getBudgets();
              Get.snackbar(
                'تم التحديث',
                'تم تحميل الميزانيات من جديد',
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
        if (budget_service.filtered_budgets.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildHeaderStats(),
            if (budget_service.showSearch.value)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'ابحث في الميزانيات...',
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: budget_service.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              budget_service.searchQuery.value = '';
                              budget_service.searchBudgets('');
                            },
                            tooltip: 'مسح البحث',
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    budget_service.searchBudgets(value);
                  },
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await budget_service.getBudgets();
                },
                child: _buildBudgetsList(context),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => AddBudgetDialoge());
        },
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('إضافة ميزانية', style: TextStyle(fontSize: 16)),
      ),
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
              Icons.account_balance_wallet_outlined,
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
            'ابدأ بإضافة أول ميزانية',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: Get.context!,
                builder: (_) => AddBudgetDialoge(),
              );
            },
            icon: Icon(Icons.add),
            label: Text('إضافة ميزانية جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    final stats = budget_service.getBudgetStatistics();
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[300]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget_service.currentFilter.value.isNotEmpty
                      ? 'الميزانيات المفلترة'
                      : 'إجمالي الميزانيات',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${stats['total_budgets']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (budget_service.currentFilter.value.isNotEmpty)
                  Text(
                    '${budget_service.BudgetList.length} إجمالي',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'إجمالي المبلغ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),

              Text(
                '${stats['total_amount'].toStringAsFixed(2)} د.ع',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _navigateToSubscriberBudgets(Get.context!),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'ميزانية المشتركين',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsList(context) {
    // Group budgets by year
    Map<int, List<Budget>> groupedBudgets = budget_service
        .getBudgetsGroupedByYear();

    List<int> sortedYears = groupedBudgets.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupedBudgets.length,
      itemBuilder: (context, index) {
        int year = sortedYears[index];
        List<Budget> yearBudgets = groupedBudgets[year]!;

        return _buildYearGroup(context, year, yearBudgets);
      },
    );
  }

  Widget _buildYearGroup(context, int year, List<Budget> yearBudgets) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'سنة $year',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(height: 12),
          ...yearBudgets.map((budget) => _buildBudgetCard(context, budget)),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(context, Budget budget) {
    final paidSubs = budget.getPaidSubsObjects();
    final unpaidSubs = budget.getUnpaidSubsObjects();
    final totalPaid = paidSubs.fold(
      0.0,
      (sum, sub) => sum + (sub.amber * budget.amber_price),
    );
    final totalUnpaid = unpaidSubs.fold(
      0.0,
      (sum, sub) => sum + (sub.amber * budget.amber_price),
    );

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
            _showBudgetDetails(context, budget);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[300]!, Colors.green[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ميزانية ${budget.year_month}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'سعر الأمبير: ${budget.amber_price.toStringAsFixed(2)} د.ع',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIndicator(paidSubs.length, unpaidSubs.length),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'المدفوع',
                        '${paidSubs.length}',
                        totalPaid.toStringAsFixed(2),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        'غير المدفوع',
                        '${unpaidSubs.length}',
                        totalUnpaid.toStringAsFixed(2),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      budget,
                      Icons.visibility,
                      'عرض التفاصيل',
                      Colors.blue,
                      () => _showBudgetDetails(context, budget),
                    ),
                    _buildActionButton(
                      context,
                      budget,
                      Icons.edit,
                      'تعديل',
                      Colors.orange,
                      () => _editBudget(context, budget),
                    ),
                    _buildActionButton(
                      context,
                      budget,
                      Icons.delete,
                      'حذف',
                      Colors.red,
                      () => showDialog(
                        context: context,
                        builder: (context) => DeleteYesNoBox(instance: budget),
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

  Widget _buildStatusIndicator(int paidCount, int unpaidCount) {
    final total = paidCount + unpaidCount;
    final paidPercentage = total > 0 ? (paidCount / total) : 0.0;

    Color statusColor;
    IconData statusIcon;

    if (paidPercentage >= 0.8) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (paidPercentage >= 0.5) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(statusIcon, color: statusColor, size: 20),
    );
  }

  Widget _buildStatItem(
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
            '$amount د.ع',
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Budget budget,
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خيارات البحث والتصفية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.search),
              title: Text('البحث في الميزانيات'),
              subtitle: Text('البحث حسب السنة أو الشهر'),
              onTap: () {
                Navigator.pop(context);
                budget_service.showSearch.value =
                    !budget_service.showSearch.value;
              },
            ),
            ListTile(
              leading: Icon(Icons.filter_list),
              title: Text('تصفية حسب السنة'),
              subtitle: Text('عرض ميزانيات سنة معينة'),
              onTap: () {
                Navigator.pop(context);
                _showYearFilterDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('تصفية حسب حالة الدفع'),
              subtitle: Text('عرض حسب حالة المدفوعات'),
              onTap: () {
                Navigator.pop(context);
                _showPaymentStatusFilterDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sort),
              title: Text('ترتيب الميزانيات'),
              subtitle: Text('ترتيب حسب التاريخ أو المبلغ'),
              onTap: () {
                Navigator.pop(context);
                _showSortDialog(context);
              },
            ),
            if (budget_service.currentFilter.value.isNotEmpty)
              ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('مسح جميع الفلاتر'),
                subtitle: Text('إعادة تعيين جميع التصفيات'),
                onTap: () {
                  Navigator.pop(context);
                  budget_service.clearFilters();
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

  void _showPaymentStatusFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية حسب حالة الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('ميزانيات مدفوعة بالكامل'),
              subtitle: Text('جميع المشتركين دفعوا'),
              onTap: () {
                Navigator.pop(context);
                budget_service.filterByPaymentStatus('paid');
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('ميزانيات غير مدفوعة'),
              subtitle: Text('لا يوجد مدفوعات'),
              onTap: () {
                Navigator.pop(context);
                budget_service.filterByPaymentStatus('unpaid');
              },
            ),
            ListTile(
              leading: Icon(Icons.compare_arrows_sharp, color: Colors.orange),
              title: Text('ميزانيات مختلطة'),
              subtitle: Text('بعض المشتركين دفعوا'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                budget_service.filterByPaymentStatus('mixed');
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

  void _showYearFilterDialog(BuildContext context) {
    final years = budget_service.BudgetList.map((b) => b.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية حسب السنة'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('عرض جميع السنوات'),
                  subtitle: Text('إلغاء التصفية'),
                  onTap: () {
                    Navigator.pop(context);
                    budget_service.filterByYear(null);
                  },
                );
              }
              final year = years[index - 1];
              return ListTile(
                title: Text('سنة $year'),
                trailing: Text(
                  '${budget_service.getBudgetsByYear(year).length} ميزانية',
                ),
                onTap: () {
                  Navigator.pop(context);
                  budget_service.filterByYear(year);
                },
              );
            },
          ),
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

  void _showViewOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خيارات العرض'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('عرض قائمة'),
              subtitle: Text('عرض بسيط للميزانيات'),
              onTap: () {
                Navigator.pop(context);
                // Implement list view
              },
            ),
            ListTile(
              leading: Icon(Icons.grid_view),
              title: Text('عرض شبكي'),
              subtitle: Text('عرض شبكي للميزانيات'),
              onTap: () {
                Navigator.pop(context);
                // Implement grid view
              },
            ),
            ListTile(
              leading: Icon(Icons.timeline),
              title: Text('عرض زمني'),
              subtitle: Text('عرض حسب التسلسل الزمني'),
              onTap: () {
                Navigator.pop(context);
                // Implement timeline view
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

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ترتيب الميزانيات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('ترتيب حسب التاريخ (الأحدث)'),
              subtitle: Text('الأحدث أولاً'),
              onTap: () {
                Navigator.pop(context);
                budget_service.sortBudgets('date_desc');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('ترتيب حسب التاريخ (الأقدم)'),
              subtitle: Text('الأقدم أولاً'),
              onTap: () {
                Navigator.pop(context);
                budget_service.sortBudgets('date_asc');
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('ترتيب حسب المبلغ (الأكبر)'),
              subtitle: Text('الأكبر أولاً'),
              onTap: () {
                Navigator.pop(context);
                budget_service.sortBudgets('amount_desc');
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('ترتيب حسب المبلغ (الأصغر)'),
              subtitle: Text('الأصغر أولاً'),
              onTap: () {
                Navigator.pop(context);
                budget_service.sortBudgets('amount_asc');
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('ترتيب حسب عدد المشتركين (الأكثر)'),
              subtitle: Text('الأكثر مشتركين أولاً'),
              onTap: () {
                Navigator.pop(context);
                budget_service.sortBudgets('subscribers_desc');
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('ترتيب حسب عدد المشتركين (الأقل)'),
              subtitle: Text('الأقل مشتركين أولاً'),
              onTap: () {
                Navigator.pop(context);
                budget_service.sortBudgets('subscribers_asc');
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

  void _editBudget(BuildContext context, Budget budget) {
    // TODO: Implement edit budget functionality
    Get.snackbar(
      'تعديل الميزانية',
      'سيتم إضافة وظيفة التعديل قريباً',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange[400],
      colorText: Colors.white,
    );
  }

  void _showBudgetDetails(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => ViewBudgetDetailsDialoge(budget),
    );
  }

  void _navigateToSubscriberBudgets(BuildContext context) {
    Get.to(() => SubscriberBudgetsPage());
  }
}

class ViewBudgetDetailsDialoge extends StatelessWidget {
  final Budget bu;
  const ViewBudgetDetailsDialoge(this.bu, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[100],
      title: Column(
        children: [
          const Icon(Icons.receipt_long, size: 40, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            'تفاصيل ميزانية ${bu.year_month}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _infoCard(
              title: 'المعلومات الأساسية',
              items: [
                _infoTile('السنة', bu.year.toString()),
                _infoTile('الشهر', bu.month.toString()),
                _infoTile('سعر الأمبير', bu.amber_price.toStringAsFixed(2)),
              ],
            ),
            _infoCard(
              title: 'الإجماليات',
              items: [
                _infoTile(
                  'إجمالي الواصل',
                  calculateTotalPaid().toStringAsFixed(2),
                ),
                _infoTile(
                  'إجمالي غير الواصل',
                  calculateTotalUnpaid().toStringAsFixed(2),
                ),
                _infoTile(
                  'عدد المشتركين الكلي',
                  '${bu.paid_subs.length + bu.unpaid_subs.length}',
                ),
              ],
            ),
            _infoCard(
              title: 'المشتركين الواصل (${bu.paid_subs.length})',
              items: bu.getPaidSubsObjects().map((sub) {
                final total = (sub.amber * bu.amber_price).toStringAsFixed(2);
                return _infoTile(sub.name, '${sub.amber} أمبير — $total');
              }).toList(),
            ),
            _infoCard(
              title: 'المشتركين غير الواصل (${bu.unpaid_subs.length})',
              items: bu.getUnpaidSubsObjects().map((sub) {
                final total = (sub.amber * bu.amber_price).toStringAsFixed(2);
                return _infoTile(sub.name, ' (${sub.amber} أمبير ) — $total');
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('رجوع'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required String title, required List<Widget> items}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.right,
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  double calculateTotalPaid() {
    final paid = bu.getPaidSubsObjects();
    return paid.fold(0.0, (sum, sub) => sum + sub.amber * bu.amber_price);
  }

  double calculateTotalUnpaid() {
    final unpaid = bu.getUnpaidSubsObjects();
    return unpaid.fold(0.0, (sum, sub) => sum + sub.amber * bu.amber_price);
  }
}

// delete budget dialoge
