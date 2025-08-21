import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/reciepts/repositories/repository.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'reciept_repository_test.mocks.dart';

void main() {
  group('RecieptRepository Tests', () {
    late RecieptRepository recieptRepository;
    late MockClient mockHttpClient;
    late Subscriper testSubscriper;
    late Gen_Worker testWorker;

    setUp(() {
      mockHttpClient = MockClient();
      recieptRepository = RecieptRepository();
      
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
    });

    group('fetchReciepts', () {
      test('should return list of receipts when HTTP call completes successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          [
            {
              "id": 1,
              "date": "2025-01-15T10:00:00.000",
              "subscriper": {"id": 1, "name": "Subscriber 1", "Ambers": 5, "circuit_number": "C001", "phone": "07711111111"},
              "image": "path/to/image1.jpg",
              "amber_price": 10.0,
              "amount_paid": 50.0,
              "worker": {"id": 1, "name": "Worker 1", "phone": "07711111111", "salary": "500.0"}
            },
            {
              "id": 2,
              "date": "2025-01-16T10:00:00.000",
              "subscriper": {"id": 2, "name": "Subscriber 2", "Ambers": 3, "circuit_number": "C002", "phone": "07722222222"},
              "image": null,
              "amber_price": 8.0,
              "amount_paid": 40.0,
              "worker": null
            }
          ]
        ''');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final receipts = await recieptRepository.fetchReciepts();

        // Assert
        expect(receipts, isA<List<Reciept>>());
        expect(receipts.length, equals(2));
        expect(receipts[0].id, equals(1));
        expect(receipts[0].subscriper.name, equals('Subscriber 1'));
        expect(receipts[0].amber_price, equals(10.0));
        expect(receipts[0].worker, isNotNull);
        expect(receipts[1].id, equals(2));
        expect(receipts[1].subscriper.name, equals('Subscriber 2'));
        expect(receipts[1].amber_price, equals(8.0));
        expect(receipts[1].worker, isNull);
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should throw exception when HTTP call fails', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.body).thenReturn('Internal Server Error');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => recieptRepository.fetchReciepts(),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should handle empty response body', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('[]');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final receipts = await recieptRepository.fetchReciepts();

        // Assert
        expect(receipts, isEmpty);
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should handle malformed JSON gracefully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('invalid json');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => recieptRepository.fetchReciepts(),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should handle network error gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => throw Exception('Network error'));

        // Act & Assert
        expect(
          () => recieptRepository.fetchReciepts(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createReciept', () {
      test('should create receipt successfully', () async {
        // Arrange
        final receipt = Reciept(
          id: 3,
          date: DateTime(2025, 1, 17),
          subscriper: testSubscriper,
          image: 'path/to/new_image.jpg',
          amber_price: 12.0,
          amount_paid: 60.0,
          worker: testWorker,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {
            "id": 3,
            "date": "2025-01-17T10:00:00.000",
            "subscriper": {"id": 1, "name": "Test Subscriber", "Ambers": 5, "circuit_number": "C001", "phone": "07712345678"},
            "image": "path/to/new_image.jpg",
            "amber_price": 12.0,
            "amount_paid": 60.0,
            "worker": {"id": 1, "name": "Test Worker", "phone": "07798765432", "salary": "500.0"}
          }
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdReceipt = await recieptRepository.createReciept(receipt);

        // Assert
        expect(createdReceipt, isA<Reciept>());
        expect(createdReceipt.id, equals(3));
        expect(createdReceipt.amber_price, equals(12.0));
        expect(createdReceipt.amount_paid, equals(60.0));
        expect(createdReceipt.worker, isNotNull);
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should throw exception when creation fails', () async {
        // Arrange
        final receipt = Reciept(
          date: DateTime(2025, 1, 17),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(400);
        when(mockResponse.body).thenReturn('Bad Request');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => recieptRepository.createReciept(receipt),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should handle receipt with null image', () async {
        // Arrange
        final receipt = Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          image: null,
          amber_price: 10.0,
          amount_paid: 50.0,
          worker: null,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {
            "id": 1,
            "date": "2025-01-15T10:00:00.000",
            "subscriper": {"id": 1, "name": "Test Subscriber", "Ambers": 5, "circuit_number": "C001", "phone": "07712345678"},
            "image": null,
            "amber_price": 10.0,
            "amount_paid": 50.0,
            "worker": null
          }
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdReceipt = await recieptRepository.createReciept(receipt);

        // Assert
        expect(createdReceipt.image, isNull);
        expect(createdReceipt.worker, isNull);
      });
    });

    group('updateReciept', () {
      test('should update receipt successfully', () async {
        // Arrange
        final receipt = Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          image: 'path/to/updated_image.jpg',
          amber_price: 15.0,
          amount_paid: 75.0,
          worker: testWorker,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          {
            "id": 1,
            "date": "2025-01-15T10:00:00.000",
            "subscriper": {"id": 1, "name": "Test Subscriber", "Ambers": 5, "circuit_number": "C001", "phone": "07712345678"},
            "image": "path/to/updated_image.jpg",
            "amber_price": 15.0,
            "amount_paid": 75.0,
            "worker": {"id": 1, "name": "Test Worker", "phone": "07798765432", "salary": "500.0"}
          }
        ''');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final updatedReceipt = await recieptRepository.updateReciept(receipt);

        // Assert
        expect(updatedReceipt, isA<Reciept>());
        expect(updatedReceipt.id, equals(1));
        expect(updatedReceipt.amber_price, equals(15.0));
        expect(updatedReceipt.amount_paid, equals(75.0));
        expect(updatedReceipt.image, equals('path/to/updated_image.jpg'));
        verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        final receipt = Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.body).thenReturn('Internal Server Error');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => recieptRepository.updateReciept(receipt),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });
    });

    group('destroyReciept', () {
      test('should delete receipt successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(204);
        when(mockResponse.body).thenReturn('');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recieptRepository.destroyReciept(1);

        // Assert
        verify(mockHttpClient.delete(any)).called(1);
      });

      test('should throw exception when deletion fails', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(404);
        when(mockResponse.body).thenReturn('Receipt not found');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => recieptRepository.destroyReciept(999),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.delete(any)).called(1);
      });

      test('should handle different status codes for deletion', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.body).thenReturn('Internal Server Error');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => recieptRepository.destroyReciept(1),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.delete(any)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle receipt with zero amounts', () async {
        // Arrange
        final receipt = Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 0.0,
          amount_paid: 0.0,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {
            "id": 1,
            "date": "2025-01-15T10:00:00.000",
            "subscriper": {"id": 1, "name": "Test Subscriber", "Ambers": 5, "circuit_number": "C001", "phone": "07712345678"},
            "image": null,
            "amber_price": 0.0,
            "amount_paid": 0.0,
            "worker": null
          }
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdReceipt = await recieptRepository.createReciept(receipt);

        // Assert
        expect(createdReceipt.amber_price, equals(0.0));
        expect(createdReceipt.amount_paid, equals(0.0));
      });

      test('should handle receipt with large amounts', () async {
        // Arrange
        final receipt = Reciept(
          id: 1,
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 999.99,
          amount_paid: 4999.95,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {
            "id": 1,
            "date": "2025-01-15T10:00:00.000",
            "subscriper": {"id": 1, "name": "Test Subscriber", "Ambers": 5, "circuit_number": "C001", "phone": "07712345678"},
            "image": null,
            "amber_price": 999.99,
            "amount_paid": 4999.95,
            "worker": null
          }
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdReceipt = await recieptRepository.createReciept(receipt);

        // Assert
        expect(createdReceipt.amber_price, equals(999.99));
        expect(createdReceipt.amount_paid, equals(4999.95));
      });

      test('should handle receipt with different date formats', () async {
        // Arrange
        final receipt = Reciept(
          id: 1,
          date: DateTime(2025, 12, 31, 23, 59, 59),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {
            "id": 1,
            "date": "2025-12-31T23:59:59.000",
            "subscriper": {"id": 1, "name": "Test Subscriber", "Ambers": 5, "circuit_number": "C001", "phone": "07712345678"},
            "image": null,
            "amber_price": 10.0,
            "amount_paid": 50.0,
            "worker": null
          }
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdReceipt = await recieptRepository.createReciept(receipt);

        // Assert
        expect(createdReceipt.date, equals(DateTime(2025, 12, 31, 23, 59, 59)));
      });

      test('should handle network timeout gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => throw Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => recieptRepository.fetchReciepts(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed URL gracefully', () async {
        // Arrange
        final receipt = Reciept(
          date: DateTime(2025, 1, 15),
          subscriper: testSubscriper,
          amber_price: 10.0,
          amount_paid: 50.0,
        );

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => throw Exception('Invalid URL'));

        // Act & Assert
        expect(
          () => recieptRepository.createReciept(receipt),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Mock classes for testing
class MockResponse extends Mock implements http.Response {}
