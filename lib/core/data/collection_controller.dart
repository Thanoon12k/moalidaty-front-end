import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import 'app_error.dart';
import 'backend.dart';
import 'data_source.dart';
import 'local_cache.dart';

/// Base for the list controllers: loading state, Arabic errors, and falling
/// back to the last downloaded copy when the device is offline.
abstract class CollectionController<T> extends GetxController {
  final items = <T>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  /// True while [items] comes from the device cache (no connection).
  final isOffline = false.obs;

  DataSource get ds => Get.find<Backend>().source;

  String get cacheName;
  Future<List<T>> fetch();
  T fromRow(Map<String, dynamic> row);
  Map<String, dynamic> toRow(T item);

  int? get _generatorId => Get.find<AuthController>().profile.value?.generatorId;

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await fetch();
      items.assignAll(list);
      isOffline.value = false;
      final gid = _generatorId;
      if (gid != null && !ds.isDemo) {
        await LocalCache.saveList(gid, cacheName, list.map(toRow).toList());
      }
    } catch (e) {
      error.value = describeError(e);
      final gid = _generatorId;
      if (isNetworkError(e) && gid != null) {
        final cached = await LocalCache.readList(gid, cacheName);
        if (cached != null) {
          items.assignAll(cached.map(fromRow));
          isOffline.value = true;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    items.clear();
    error.value = null;
    isOffline.value = false;
  }
}
