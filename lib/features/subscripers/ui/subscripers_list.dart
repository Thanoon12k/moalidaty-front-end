import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/subscripers/ui/add_subscriper_dialoge.dart';
import 'package:moalidaty/features/subscripers/ui/display_subscriper.dart';

class SubscripersListPage extends StatelessWidget {
  SubscripersListPage({super.key});
  TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final subsService = Get.find<SubscribersService>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "قائمة المشتركين",
        font_size: 28,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'البحث',
            onPressed: () {
              subsService.showSearch.value = !subsService.showSearch.value;
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'refresh') {
                await subsService.getSubscripers();
                Get.snackbar(
                  'تم التحديث',
                  'تم تحميل المشتركين من جديد',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green[400],
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.grey[700]),
                    SizedBox(width: 12),
                    Text('تحديث القائمة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (subsService.subscribersList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            if (subsService.showSearch.value)
              _searchBox(
                subsService: subsService,
                searchTextController: searchTextController,
              ),

            _buildHeaderStats(subsService.filteredSubscripers.length),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await subsService.getSubscripers();
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: subsService.filteredSubscripers.length,
                  itemBuilder: (context, index) {
                    final sub = subsService.filteredSubscripers[index];
                    return _buildSubscriberCard(
                      context,
                      subsService,
                      sub,
                      index,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => AddSubscriberDialoge());
        },
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: Text('إضافة مشترك', style: TextStyle(fontSize: 16)),
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
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'لا يوجد مشتركون',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'ابدأ بإضافة أول مشترك',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: Get.context!,
                builder: (_) => AddSubscriberDialoge(),
              );
            },
            icon: Icon(Icons.add),
            label: Text('إضافة مشترك جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
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

  Widget _buildHeaderStats(int count) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[300]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
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
            child: Icon(Icons.people, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي المشتركين',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberCard(
    BuildContext context,
    subsService,
    Subscriper sub,
    int index,
  ) {
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
            displaySubscriperDialoge(context, subsService, sub);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSubscriberAvatar(sub.name, index),
                SizedBox(width: 16),
                Expanded(child: _buildSubscriberInfo(sub)),
                // _buildActionButtons(context, subsService, sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _searchBox extends StatelessWidget {
  const _searchBox({
    required this.subsService,
    required this.searchTextController,
  });

  final SubscribersService subsService;
  final TextEditingController searchTextController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 18),
        controller: searchTextController,
        decoration: InputDecoration(
          hintText: 'ابحث عن مشترك...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: subsService.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    subsService.searchQuery.value = '';
                    searchTextController.text = '';
                  },

                  tooltip: 'مسح البحث',
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          subsService.searchQuery.value = value;
        },
      ),
    );
  }
}

Widget _buildSubscriberAvatar(String name, int index) {
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

Widget _buildSubscriberInfo(dynamic sub) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        sub.name,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
        ),
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Icon(Icons.flash_on, size: 20, color: Colors.green[600]),
          SizedBox(width: 8),
          Text(
            '${sub.amber} أمبير',
            style: TextStyle(fontSize: 18, color: Colors.green[700]),
          ),
        ],
      ),
      SizedBox(height: 6),
      Row(
        children: [
          Icon(Icons.electric_bolt, size: 20, color: Colors.blue[600]),
          SizedBox(width: 8),
          Text(
            'الجوزة: ${sub.circuit_number}',
            style: TextStyle(fontSize: 18, color: Colors.blue[700]),
          ),
        ],
      ),
      SizedBox(height: 6),
      if (sub.phone != null && sub.phone.isNotEmpty)
        Row(
          children: [
            Icon(Icons.phone, size: 20, color: Colors.orange[600]),
            SizedBox(width: 8),
            Text(
              sub.phone,
              style: TextStyle(fontSize: 18, color: Colors.orange[700]),
            ),
          ],
        ),
    ],
  );
}

Widget _buildActionButtons(BuildContext context, subsService, dynamic sub) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: () {
          displaySubscriperDialoge(context, subsService, sub);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.remove_red_eye, color: Colors.blue[800], size: 26),
              SizedBox(width: 8),
              Text(
                'تفاصيل المستخدم',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: 8),
    ],
  );
}
