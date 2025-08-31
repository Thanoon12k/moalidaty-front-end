
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/common_widgets/network_error.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/budgets/ui/budgets_list.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty1/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/subscripers/ui/subscripers_list.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';
import 'package:moalidaty1/features/workers/ui/list_workers.dart';
import 'package:moalidaty1/routes/routes.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              _buildHeader(),

              // Quick Stats Cards
              _buildStatsSection(),

              // Main Menu Grid
              Expanded(child: _buildMenuGrid()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add quick action like adding new receipt
          Get.to(() => RecieptsListPage());
        },
        icon: Icon(Icons.add),
        label: Text('إيصال جديد'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة المولدة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'نظام إدارة شامل',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.power, size: 28, color: Colors.blue.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'المشتركين',
              value: '${Get.find<SubscribersService>().subscribersList.length}',
              icon: Icons.people,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'الإيصالات',
              value: '${Get.find<ReceiptServices>().receiptsList.length}',
              icon: Icons.receipt_long,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'المشغلين',
              value: '${Get.find<WorkerService>().workersList.length}',
              icon: Icons.engineering,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'الخدمات الرئيسية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _ModernMenuTile(
                  title: 'إدارة المشتركين',
                  subtitle: 'عرض وإدارة المشتركين',
                  icon: Icons.people,
                  gradient: [Colors.blue.shade400, Colors.blue.shade600],
                  onTap: () => Get.to(() => SubscripersListPage()),
                ),
                _ModernMenuTile(
                  title: 'إدارة الإيصالات',
                  subtitle: 'تتبع المدفوعات والإيصالات',
                  icon: Icons.receipt_long,
                  gradient: [Colors.green.shade400, Colors.green.shade600],
                  onTap: () => Get.to(() => RecieptsListPage()),
                ),
                _ModernMenuTile(
                  title: 'إدارة المشغلين',
                  subtitle: 'متابعة العمال والمشغلين',
                  icon: Icons.engineering,
                  gradient: [Colors.orange.shade400, Colors.orange.shade600],
                  onTap: () => Get.to(() => WorkersListPage()),
                ),
                _ModernMenuTile(
                  title: 'إدارة المبالغ',
                  subtitle: 'متابعة الميزانيات والمبالغ',
                  icon: Icons.account_balance_wallet,
                  gradient: [Colors.purple.shade400, Colors.purple.shade600],
                  onTap: () => Get.to(() => BudgetsListPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ModernMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ModernMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
