import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';

class RecieptRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Reciept>> fetchReciepts() async {
    String fetchUrl = "$baseUrl/receipts/";
    
    try {
      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        print('Receipt API Response Status: ${response.statusCode}');
        // print('Receipt API Response Body: ${response.body}');
        
        final dynamic responseData = json.decode(response.body);
        print('Receipt API Parsed Response Type: ${responseData.runtimeType}');
        
        // Handle both wrapped response structure and direct array response
        List listData;
        if (responseData is Map<String, dynamic> && responseData.containsKey('value')) {
          // Wrapped response: {"value": [...]}
          print('Receipt API: Using wrapped response structure');
          listData = responseData['value'] as List;
        } else if (responseData is List) {
          // Direct array response: [...]
          print('Receipt API: Using direct array response structure');
          listData = responseData;
        } else {
          throw Exception("Unexpected response format: ${responseData.runtimeType}");
        }
        
        print('Receipt API: Found ${listData.length} receipts');
        return listData.map((jsonRow) => Reciept.fromJson(jsonRow)).toList();
      } else {
        throw Exception("Failed to fetch receipts from $fetchUrl. Status: ${response.statusCode}");
      }
    } catch (e) {
        throw Exception("Failed to fetch receipts from $fetchUrl. because: $e");
    }
  }

  Future<Reciept> createReciept(Reciept reciept) async {
    String createUrl = "$baseUrl/receipts/";
    
    try {
      final response = await http.post(
        Uri.parse(createUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reciept.toJson()),
      );

      if (response.statusCode == 201) {
        final createdReceipt = Reciept.fromJson(json.decode(response.body));
        return createdReceipt;
      } else {
        throw Exception('Failed to create receipt. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in creating receipt: $e');
    }
  }

  Future<void> destroyReciept(int id) async {
    String deleteUrl = "$baseUrl/receipts/$id/";
    
    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode != 204) {
        throw Exception("Failed to delete receipt from $deleteUrl. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error in deleting receipt: $e");
    }
  }

  Future<Reciept> updateReciept(Reciept reciept) async {
    String updateUrl = "$baseUrl/receipts/${reciept.id}/";
    
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reciept.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedReceipt = Reciept.fromJson(json.decode(response.body));
        return updatedReceipt;
      } else {
        throw Exception('Failed to update receipt. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in updating receipt: $e');
    }
  }
}
