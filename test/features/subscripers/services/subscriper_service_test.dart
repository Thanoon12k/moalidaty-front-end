import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/services/service.dart';
import 'package:moalidaty1/features/subscripers/repositories/repository.dart';
import 'package:moalidaty1/utils/dummy_data.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([SubscriperRepository, DummyData])
import 'subscriper_service_test.mocks.dart';

void main() {
  group('subscripersService Tests', () {
    late subscripersService subscriperService;
    late MockSubscriperRepository mockRepository;
    late MockDummyData mockDummyData;

    setUp(() {
      mockRepository = MockSubscriperRepository();
      mockDummyData = MockDummyData();
      subscriperService = subscripersService();
      // Reset GetX state
      Get.reset();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize service successfully', () async {
      // Arrange
      final testSubscribers = [
        Subscriper(id: 1, name: 'Test Subscriber 1', amber: 5),
        Subscriper(id: 2, name: 'Test Subscriber 2', amber: 3),
      ];
      
      when(mockDummyData.getDummySubs()).thenAnswer((_) async => testSubscribers);

      // Act
      final result = await subscriperService.init();

      // Assert
      expect(result, isA<subscripersService>());
      expect(subscriperService.list_subs.length, equals(2));
    });

    test('should get subscribers successfully', () async {
      // Arrange
      final testSubscribers = [
        Subscriper(
          id: 1,
          name: 'Subscriber 1',
          amber: 5,
          circuit_number: 'C001',
          phone: '07711111111',
        ),
        Subscriper(
          id: 2,
          name: 'Subscriber 2',
          amber: 3,
          circuit_number: 'C002',
          phone: '07722222222',
        ),
      ];
      
      when(mockDummyData.getDummySubs()).thenAnswer((_) async => testSubscribers);

      // Act
      await subscriperService.getSubscripers();

      // Assert
      expect(subscriperService.list_subs.length, equals(2));
      expect(subscriperService.list_subs[0].name, equals('Subscriber 1'));
      expect(subscriperService.list_subs[1].name, equals('Subscriber 2'));
    });

    test('should handle get subscribers error gracefully', () async {
      // Arrange
      when(mockDummyData.getDummySubs()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => subscriperService.getSubscripers(), returnsNormally);
      expect(subscriperService.list_subs.length, equals(0));
    });

    test('should add subscriber successfully', () async {
      // Arrange
      final newSubscriber = Subscriper(
        id: 3,
        name: 'New Subscriber',
        amber: 7,
        circuit_number: 'C003',
        phone: '07733333333',
      );
      
      when(mockRepository.createSubscriper(newSubscriber)).thenAnswer((_) async => null);

      // Act
      await subscriperService.addSubsciper(newSubscriber);

      // Assert
      expect(subscriperService.list_subs.length, equals(1));
      expect(subscriperService.list_subs[0].name, equals('New Subscriber'));
      verify(mockRepository.createSubscriper(newSubscriber)).called(1);
    });

    test('should delete subscriber successfully', () async {
      // Arrange
      final subscriber = Subscriper(
        id: 1,
        name: 'Subscriber to Delete',
        amber: 4,
      );
      subscriperService.list_subs.add(subscriber);
      
      when(mockRepository.destroySubscriper(1)).thenAnswer((_) async => null);

      // Act
      await subscriperService.deleteSubscriper(subscriber);

      // Assert
      expect(subscriperService.list_subs.length, equals(0));
      verify(mockRepository.destroySubscriper(1)).called(1);
    });

    test('should edit subscriber successfully', () async {
      // Arrange
      final subscriber = Subscriper(
        id: 1,
        name: 'Old Name',
        amber: 5,
      );
      subscriperService.list_subs.add(subscriber);
      
      final updatedSubscriber = Subscriper(
        id: 1,
        name: 'New Name',
        amber: 6,
      );
      
      when(mockRepository.updateSubscriper(updatedSubscriber)).thenAnswer((_) async => null);

      // Act
      await subscriperService.editSubscriper(updatedSubscriber);

      // Assert
      expect(subscriperService.list_subs[0].name, equals('New Name'));
      expect(subscriperService.list_subs[0].amber, equals(6));
      verify(mockRepository.updateSubscriper(updatedSubscriber)).called(1);
    });

    test('should handle edit subscriber not found gracefully', () async {
      // Arrange
      final subscriber = Subscriper(
        id: 999,
        name: 'Non-existent Subscriber',
        amber: 5,
      );
      
      when(mockRepository.updateSubscriper(subscriber)).thenAnswer((_) async => null);

      // Act
      await subscriperService.editSubscriper(subscriber);

      // Assert
      expect(subscriperService.list_subs.length, equals(0));
      verify(mockRepository.updateSubscriper(subscriber)).called(1);
    });

    test('should handle edit subscriber error gracefully', () async {
      // Arrange
      final subscriber = Subscriper(
        id: 1,
        name: 'Error Subscriber',
        amber: 5,
      );
      subscriperService.list_subs.add(subscriber);
      
      when(mockRepository.updateSubscriper(subscriber))
          .thenThrow(Exception('Update failed'));

      // Act
      await subscriperService.editSubscriper(subscriber);

      // Assert
      expect(subscriperService.list_subs[0].name, equals('Error Subscriber')); // Should remain unchanged
      verify(mockRepository.updateSubscriper(subscriber)).called(1);
    });

    test('should handle multiple operations correctly', () async {
      // Arrange
      final subscriber1 = Subscriper(id: 1, name: 'Subscriber 1', amber: 5);
      final subscriber2 = Subscriper(id: 2, name: 'Subscriber 2', amber: 3);
      final subscriber3 = Subscriper(id: 3, name: 'Subscriber 3', amber: 7);
      
      when(mockRepository.createSubscriper(any)).thenAnswer((_) async => null);
      when(mockRepository.destroySubscriper(any)).thenAnswer((_) async => null);

      // Act
      await subscriperService.addSubsciper(subscriber1);
      await subscriperService.addSubsciper(subscriber2);
      await subscriperService.addSubsciper(subscriber3);
      
      expect(subscriperService.list_subs.length, equals(3));
      
      await subscriperService.deleteSubscriper(subscriber2);
      
      // Assert
      expect(subscriperService.list_subs.length, equals(2));
      expect(subscriperService.list_subs[0].name, equals('Subscriber 1'));
      expect(subscriperService.list_subs[1].name, equals('Subscriber 3'));
    });

    test('should maintain subscriber list state correctly', () async {
      // Arrange
      final initialSubscribers = [
        Subscriper(id: 1, name: 'Initial Subscriber 1', amber: 5),
        Subscriper(id: 2, name: 'Initial Subscriber 2', amber: 3),
      ];
      
      when(mockDummyData.getDummySubs()).thenAnswer((_) async => initialSubscribers);

      // Act
      await subscriperService.getSubscripers();
      
      // Assert
      expect(subscriperService.list_subs.length, equals(2));
      expect(subscriperService.list_subs[0].name, equals('Initial Subscriber 1'));
      expect(subscriperService.list_subs[1].name, equals('Initial Subscriber 2'));
    });

    test('should handle empty subscriber list', () async {
      // Arrange
      when(mockDummyData.getDummySubs()).thenAnswer((_) async => []);

      // Act
      await subscriperService.getSubscripers();

      // Assert
      expect(subscriperService.list_subs.length, equals(0));
      expect(subscriperService.list_subs, isEmpty);
    });

    test('should handle subscriber with different amber values', () async {
      // Arrange
      final subscriber1 = Subscriper(id: 1, name: 'Low Amber', amber: 1);
      final subscriber2 = Subscriper(id: 2, name: 'High Amber', amber: 10);
      
      when(mockRepository.createSubscriper(any)).thenAnswer((_) async => null);

      // Act
      await subscriperService.addSubsciper(subscriber1);
      await subscriperService.addSubsciper(subscriber2);

      // Assert
      expect(subscriperService.list_subs[0].amber, equals(1));
      expect(subscriperService.list_subs[1].amber, equals(10));
    });

    test('should handle subscriber with different circuit numbers', () async {
      // Arrange
      final subscriber1 = Subscriper(
        id: 1,
        name: 'Circuit 1',
        amber: 5,
        circuit_number: 'C001',
      );
      final subscriber2 = Subscriper(
        id: 2,
        name: 'Circuit 2',
        amber: 3,
        circuit_number: 'C999',
      );
      
      when(mockRepository.createSubscriper(any)).thenAnswer((_) async => null);

      // Act
      await subscriperService.addSubsciper(subscriber1);
      await subscriperService.addSubsciper(subscriber2);

      // Assert
      expect(subscriperService.list_subs[0].circuit_number, equals('C001'));
      expect(subscriperService.list_subs[1].circuit_number, equals('C999'));
    });
  });
}
