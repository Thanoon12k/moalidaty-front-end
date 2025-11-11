import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';

class BudgetAPI {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Budget>> fetchBudgets() async {
    String fetchUrl = "$baseUrl/budgets/";
    List<Budget> budgetList = [];
    final response = await http.get(Uri.parse(fetchUrl));
    

    if (response.statusCode == 200) {
      List<dynamic> listData = json.decode(response.body);
      budgetList = listData.map((jsonRow) => Budget.fromJson(jsonRow)).toList();
    }
    debugPrint(
      "Fetched budgets status: ${response.statusCode} got (${budgetList.length}) items",
    );
    return budgetList;
  }

  Future<Budget> fetchBudgetDetail(int id) async {
    String fetchUrl = "$baseUrl/budgets/$id/";

    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      return Budget.fromJson(jsonData);
    } else {
      throw Exception(
        "Failed to fetch budget detail from $fetchUrl. Status: ${response.statusCode}",
      );
    }
  }

  Future<Budget> createBudget(Budget budget) async {
    String createUrl = "$baseUrl/budgets/";

    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(budget.toJson()),
    );

    if (response.statusCode == 201) {
      final createdBudget = Budget.fromJson(json.decode(response.body));
      return createdBudget;
    } else {
      throw Exception(
        'Failed to create budget. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception('Error in creating budget: $e');
    // }
  }

  Future<Budget> updateBudget(int id, Budget budget) async {
    String updateUrl = "$baseUrl/budgets/$id/";

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(budget.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedBudget = Budget.fromJson(json.decode(response.body));
      return updatedBudget;
    } else {
      throw Exception(
        'Failed to update budget. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception('Error in updating budget: $e');
    // }
  }

  Future<bool> destroyBudget(int id) async {
    String deleteUrl = "$baseUrl/budgets/$id/";

    final response = await http.delete(Uri.parse(deleteUrl));

    return response.statusCode == 204;
  }
}
