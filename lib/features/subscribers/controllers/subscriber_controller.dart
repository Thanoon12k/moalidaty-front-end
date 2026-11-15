import '../../../core/data/collection_controller.dart';
import '../models/subscriber.dart';

class SubscriberController extends CollectionController<Subscriber> {
  @override
  String get cacheName => 'subscribers';

  @override
  Future<List<Subscriber>> fetch() => ds.fetchSubscribers();

  @override
  Subscriber fromRow(Map<String, dynamic> row) => Subscriber.fromRow(row);

  @override
  Map<String, dynamic> toRow(Subscriber item) => item.toRow();

  Subscriber? byId(int id) => items.where((s) => s.id == id).firstOrNull;

  Future<Subscriber> add(SubscriberInput input) async {
    final s = await ds.addSubscriber(input);
    items.add(s);
    _sort();
    return s;
  }

  Future<Subscriber> edit(int id, SubscriberInput input) async {
    final s = await ds.updateSubscriber(id, input);
    final i = items.indexWhere((x) => x.id == id);
    if (i >= 0) items[i] = s;
    _sort();
    return s;
  }

  /// Soft delete: the subscriber disappears from lists, receipts are kept.
  Future<void> archive(int id) async {
    await ds.archiveSubscriber(id);
    items.removeWhere((s) => s.id == id);
  }

  void _sort() => items.sort((a, b) => a.name.compareTo(b.name));
}

