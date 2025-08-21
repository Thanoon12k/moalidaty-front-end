import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/reciepts/services/service.dart';
import 'package:moalidaty1/features/reciepts/repositories/repository.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([RecieptRepository])
import 'reciept_service_test.mocks.dart';

void main() {
  group('RecieptServices Tests', () {
    late RecieptServices recieptService;
    late MockRecieptRepository mockRepository;
    late Subscriper testSubscriper;
    late Gen_Worker testWorker;

    setUp(() {
      mockRepository = MockRecieptRepository();
      recieptService = RecieptServices();
      
      testSubscriper = Subscriper(
        id: 1,
        name: 'Test Subscriber',
        amber: 5,
        circuit_number: 'C001',
        phone: '07712345678',
      );
      
      testWorker = Gen_Worker(
        id: 1,
        name: 'Test Worker',
        phone: '07798765432',
        salary: '500.0',
      );
      
      // Reset GetX state
      Get.reset();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize service successfully', () async {
      // Arrange
      final testReceipts = [
        Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
        ),
        Reciept(
          id: 2,
          date: DateTime(2025, 1, 16),
          subscriper: testSubscriper,
          amber_price: 8.0,
          amount_paid: 40.0,
        ),
      ];
      
      when(mockRepository.fetchReciepts()).thenAnswer((_) async => testReceipts);

      // Act
      final result = await recieptService.init();

      // Assert
      expect(result, isA<RecieptServices>());
      expect(recieptService.list_rcpts.length, equals(2));
    });

    test('should get receipts successfully', () async {
      // Arrange
      final testReceipts = [
        Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
          worker: testWorker,
        ),
        Reciept(
          id: 2,
          date: DateTime(2025, 1, 16),
          subscriper: testSubscriper,
          amber_price: 8.0,
          amount_paid: 40.0,
        ),
      ];
      
      when(mockRepository.fetchReciepts()).thenAnswer((_) async => testReceipts);

      // Act
      await recieptService.getReciepts();

      // Assert
      expect(recieptService.list_rcpts.length, equals(2));
      expect(recieptService.list_rcpts[0].id, equals(1));
      expect(recieptService.list_rcpts[1].id, equals(2));
      verify(mockRepository.fetchReciepts()).called(1);
    });

    test('should handle get receipts error gracefully', () async {
      // Arrange
      when(mockRepository.fetchReciepts()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => recieptService.getReciepts(), returnsNormally);
      expect(recieptService.list_rcpts.length, equals(0));
    });

    test('should add receipt successfully', () async {
      // Arrange
      final newReceipt = Reciept(
        id: 3,
        date: DateTime(2025, 1, 17),
        subscriper: testSubscriper,
        amber_price: 12.0,
        amount_paid: 60.0,
        worker: testWorker,
      );
      
      when(mockRepository.createReciept(newReceipt)).thenAnswer((_) async => null);

      // Act
      await recieptService.addReciept(newReceipt);

      // Assert
      expect(recieptService.list_rcpts.length, equals(1));
      expect(recieptService.list_rcpts[0].id, equals(3));
      expect(recieptService.list_rcpts[0].amber_price, equals(12.0));
      verify(mockRepository.createReciept(newReceipt)).called(1);
    });

    test('should delete receipt successfully', () async {
      // Arrange
      final receipt = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      recieptService.list_rcpts.add(receipt);
      
      when(mockRepository.destroyReciept(1)).thenAnswer((_) async => null);

      // Act
      await recieptService.deleteReciept(receipt);

      // Assert
      expect(recieptService.list_rcpts.length, equals(0));
      verify(mockRepository.destroyReciept(1)).called(1);
    });

    test('should edit receipt successfully', () async {
      // Arrange
      final receipt = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      recieptService.list_rcpts.add(receipt);
      
      final updatedReceipt = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 15.0,
        amount_paid: 75.0,
        worker: testWorker,
      );
      
      when(mockRepository.updateReciept(updatedReceipt)).thenAnswer((_) async => null);

      // Act
      await recieptService.editReciept(updatedReceipt);

      // Assert
      expect(recieptService.list_rcpts[0].amber_price, equals(15.0));
      expect(recieptService.list_rcpts[0].amount_paid, equals(75.0));
      expect(recieptService.list_rcpts[0].worker, equals(testWorker));
      verify(mockRepository.updateReciept(updatedReceipt)).called(1);
    });

    test('should handle edit receipt not found gracefully', () async {
      // Arrange
      final receipt = Reciept(
        id: 999,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      
      when(mockRepository.updateReciept(receipt)).thenAnswer((_) async => null);

      // Act
      await recieptService.editReciept(receipt);

      // Assert
      expect(recieptService.list_rcpts.length, equals(0));
      verify(mockRepository.updateReciept(receipt)).called(1);
    });

    test('should handle edit receipt error gracefully', () async {
      // Arrange
      final receipt = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      recieptService.list_rcpts.add(receipt);
      
      when(mockRepository.updateReciept(receipt))
          .thenThrow(Exception('Update failed'));

      // Act
      await recieptService.editReciept(receipt);

      // Assert
      expect(recieptService.list_rcpts[0].amber_price, equals(10.0)); // Should remain unchanged
      verify(mockRepository.updateReciept(receipt)).called(1);
    });

    test('should handle multiple operations correctly', () async {
      // Arrange
      final receipt1 = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      final receipt2 = Reciept(
        id: 2,
        date: DateTime(2025, 1, 16),
        subscriper: testSubscriper,
        amber_price: 8.0,
        amount_paid: 40.0,
      );
      final receipt3 = Reciept(
        id: 3,
        date: DateTime(2025, 1, 17),
        subscriper: testSubscriper,
        amber_price: 12.0,
        amount_paid: 60.0,
      );
      
      when(mockRepository.createReciept(any)).thenAnswer((_) async => null);
      when(mockRepository.destroyReciept(any)).thenAnswer((_) async => null);

      // Act
      await recieptService.addReciept(receipt1);
      await recieptService.addReciept(receipt2);
      await recieptService.addReciept(receipt3);
      
      expect(recieptService.list_rcpts.length, equals(3));
      
      await recieptService.deleteReciept(receipt2);
      
      // Assert
      expect(recieptService.list_rcpts.length, equals(2));
      expect(recieptService.list_rcpts[0].id, equals(1));
      expect(recieptService.list_rcpts[1].id, equals(3));
    });

    test('should maintain receipt list state correctly', () async {
      // Arrange
      final initialReceipts = [
        Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
        ),
        Reciept(
          id: 2,
          date: DateTime(2025, 1, 16),
          subscriper: testSubscriper,
          amber_price: 8.0,
          amount_paid: 40.0,
        ),
      ];
      
      when(mockRepository.fetchReciepts()).thenAnswer((_) async => initialReceipts);

      // Act
      await recieptService.getReciepts();
      
      // Assert
      expect(recieptService.list_rcpts.length, equals(2));
      expect(recieptService.list_rcpts[0].amber_price, equals(10.0));
      expect(recieptService.list_rcpts[1].amber_price, equals(8.0));
    });

    test('should handle empty receipt list', () async {
      // Arrange
      when(mockRepository.fetchReciepts()).thenAnswer((_) async => []);

      // Act
      await recieptService.getReciepts();

      // Assert
      expect(recieptService.list_rcpts.length, equals(0));
      expect(recieptService.list_rcpts, isEmpty);
    });

    test('should handle receipt with different dates', () async {
      // Arrange
      final receipt1 = Reciept(
        id: 1,
        date: DateTime(2025, 1, 1),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      final receipt2 = Reciept(
        id: 2,
        date: DateTime(2025, 12, 31),
        subscriper: testSubscriper,
        amber_price: 8.0,
        amount_paid: 40.0,
      );
      
      when(mockRepository.createReciept(any)).thenAnswer((_) async => null);

      // Act
      await recieptService.addReciept(receipt1);
      await recieptService.addReciept(receipt2);

      // Assert
      expect(recieptService.list_rcpts[0].date, equals(DateTime(2025, 1, 1)));
      expect(recieptService.list_rcpts[1].date, equals(DateTime(2025, 12, 31)));
    });

    test('should handle receipt with different amounts', () async {
      // Arrange
      final receipt1 = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 0.0,
        amount_paid: 0.0,
      );
      final receipt2 = Reciept(
        id: 2,
        date: DateTime(2025, 1, 16),
        subscriper: testSubscriper,
        amber_price: 999.99,
        amount_paid: 4999.95,
      );
      
      when(mockRepository.createReciept(any)).thenAnswer((_) async => null);

      // Act
      await recieptService.addReciept(receipt1);
      await recieptService.addReciept(receipt2);

      // Assert
      expect(recieptService.list_rcpts[0].amber_price, equals(0.0));
      expect(recieptService.list_rcpts[0].amount_paid, equals(0.0));
      expect(recieptService.list_rcpts[1].amber_price, equals(999.99));
      expect(recieptService.list_rcpts[1].amount_paid, equals(4999.95));
    });

    test('should handle receipt with and without worker', () async {
      // Arrange
      final receiptWithWorker = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
        worker: testWorker,
      );
      final receiptWithoutWorker = Reciept(
        id: 2,
        date: DateTime(2025, 1, 16),
        subscriper: testSubscriper,
        amber_price: 8.0,
        amount_paid: 40.0,
      );
      
      when(mockRepository.createReciept(any)).thenAnswer((_) async => null);

      // Act
      await recieptService.addReciept(receiptWithWorker);
      await recieptService.addReciept(receiptWithoutWorker);

      // Assert
      expect(recieptService.list_rcpts[0].worker, equals(testWorker));
      expect(recieptService.list_rcpts[1].worker, isNull);
    });

    test('should handle receipt with image', () async {
      // Arrange
      final receiptWithImage = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        image: 'path/to/image.jpg',
        amber_price: 10.0,
        amount_paid: 50.0,
      );
      
      when(mockRepository.createReciept(receiptWithImage)).thenAnswer((_) async => null);

      // Act
      await recieptService.addReciept(receiptWithImage);

      // Assert
      expect(recieptService.list_rcpts[0].image, equals('path/to/image.jpg'));
    });
  });
}
