import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/reciepts/models/receipt_model.dart';

class RecieptAPI {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Reciept>> fetchReciepts() async {
    String fetchUrl = "$baseUrl/receipts/";
    List<Reciept> recieptList = [];
    // ttry {
    final response = await http.get(Uri.parse(fetchUrl));
    if (response.statusCode == 200) {
      List<dynamic> listData = json.decode(response.body);
      recieptList =
          listData.map((jsonRow) => Reciept.fromJson(jsonRow)).toList();
    }
    debugPrint(
      "Fetched Receipts status: ${response.statusCode} got (${recieptList.length}) items",
    );
    return recieptList;
  }

  Future<Reciept> createReciept(Reciept reciept) async {
    final uri = Uri.parse('$baseUrl/receipts/');
    final request = http.MultipartRequest('POST', uri);

    // Add form fields
    request.fields['year'] = reciept.year.toString();
    request.fields['month'] = reciept.month.toString();
    request.fields['amber_price'] = reciept.amberPrice.toStringAsFixed(2);
    request.fields['amount_paid'] = reciept.amountPaid.toStringAsFixed(2);
    request.fields['subscriber'] = reciept.subscriber.toString();
    if (reciept.worker != null) {
      request.fields['worker'] = reciept.worker.toString();
    }
    if (reciept.dateReceived != null) {
      request.fields['date_received'] = reciept.dateReceived!.toIso8601String();
    }

    // Attach image file if available
    if (reciept.imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', reciept.imageFile!.path),
      );
    }

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return Reciept.fromJson(responseData);
    } else {
      throw Exception(
        '❌ Failed to create receipt.\nStatus: ${response.statusCode}\nBody: ${response.body}',
      );
    }
  }

  Future<void> destroyReciept(int id) async {
    String deleteUrl = "$baseUrl/receipts/$id/";

    // ttry {
    final response = await http.delete(Uri.parse(deleteUrl));

    if (response.statusCode != 204) {
      throw Exception(
        "Failed to delete receipt from $deleteUrl. Status: ${response.statusCode}",
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception("Error in deleting receipt: $e");
    // }
  }

  Future<Reciept> updateReciept(Reciept reciept) async {
    String updateUrl = "$baseUrl/receipts/${reciept.id}/";

    // ttry {
    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reciept.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedReceipt = Reciept.fromJson(json.decode(response.body));
      return updatedReceipt;
    } else {
      throw Exception(
        'Failed to update receipt. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception('Error in updating receipt: $e');
    // }
  }
}
