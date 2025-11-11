import 'package:flutter/material.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/features/Managers/api/auth_api.dart';
import 'package:moalidaty/features/Managers/models/models.dart';

class DevelopmentPage extends StatefulWidget {
  const DevelopmentPage({super.key});

  @override
  State<DevelopmentPage> createState() => _DevelopmentPageState();
}

class _DevelopmentPageState extends State<DevelopmentPage> {
  late Future<List<Account>?> _future;
  @override
  void initState() {
    super.initState();
    _refershData();
  }

  void _refershData() {
    setState(() {
      _future = ManagerApi().fetchManagers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "تطوير"),
      body: Column(
        children: [
          ElevatedButton(
            child: Text("button 1"),
            onPressed: () {
              _refershData();
            },
          ),

          FutureBuilder<List<Account>?>(
            future: _future,

            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  "${snapshot.error}",
                  style: TextStyle(fontSize: 18),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,

                itemBuilder: (context, index) {
                  return ListTile(title: Text(snapshot.data![index].name));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
