import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';

class SubscriperRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Subscriper>> fetchSubscribers() async {
    String fetchUrl = "$baseUrl/subscribers";

    List<Subscriper> subs = [];
    try {
      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        List listData = json.decode(response.body);
        subs =
            listData.map((jsonRow) => Subscriper.fromJson(jsonRow)).toList();
        return subs;
      } else {
        throw Exception("Failed to Fetch  subscribers from $fetchUrl");
      }
    } catch (e) {
      throw Exception("error in fetching subs )($e)");
    }
  }

  Future<void> destroySubscriper(int id) async {
    final String destroyUrl = "$baseUrl/subscribers/$id/";
    final response = await http.delete(Uri.parse(destroyUrl));
    print("delete-$destroyUrl-response ${response.statusCode}");
    print("delete body${response.body}");

    if (response.statusCode != 204) {
      throw Exception("Failed to Fetch  subscribers from $destroyUrl");
    }
  }

  Future<Subscriper> createSubscriper(Subscriper sub) async {
    final String createUrl = "$baseUrl/subscribers/";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sub.toJson()),
    );

    print('Create response: ${response.statusCode}');
    print('Create response body: ${response.body}');
    print('sub to create: ${sub.toJson()}');
    if (response.statusCode == 201) {
      return sub;
    } else {
      throw Exception('Failed to create subscriper $sub');
    }
  }

  Future<Subscriper> updateSubscriper(sub) async {
    final String updateUrl =
        "$baseUrl/subscribers/${sub.id}/"; // ✅ trailing slash

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sub.toJson()),
    );
    print('update to url <<$updateUrl>>response: ${response.statusCode}');
    print('update response body: ${response.body}');
    // print('sub to update: ${sub.toJson()}');
    if (response.statusCode == 200) {
      return sub;
    } else {
      throw Exception('Failed to update subscriper $sub');
    }
  }
}
