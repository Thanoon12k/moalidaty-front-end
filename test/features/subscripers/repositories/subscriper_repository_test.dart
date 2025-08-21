import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/repositories/repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'subscriper_repository_test.mocks.dart';

void main() {
  group('SubscriperRepository Tests', () {
    late SubscriperRepository subscriperRepository;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      subscriperRepository = SubscriperRepository();
    });

    group('fetchSubscribers', () {
      test('should return list of subscribers when HTTP call completes successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          [
            {"id": 1, "name": "Subscriber 1", "Ambers": 5, "circuit_number": "C001", "phone": "07711111111"},
            {"id": 2, "name": "Subscriber 2", "Ambers": 3, "circuit_number": "C002", "phone": "07722222222"}
          ]
        ''');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final subscribers = await subscriperRepository.fetchSubscribers();

        // Assert
        expect(subscribers, isA<List<Subscriper>>());
        expect(subscribers.length, equals(2));
        expect(subscribers[0].name, equals('Subscriber 1'));
        expect(subscribers[0].amber, equals(5));
        expect(subscribers[1].name, equals('Subscriber 2'));
        expect(subscribers[1].amber, equals(3));
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
          () => subscriperRepository.fetchSubscribers(),
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
        final subscribers = await subscriperRepository.fetchSubscribers();

        // Assert
        expect(subscribers, isEmpty);
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
          () => subscriperRepository.fetchSubscribers(),
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
          () => subscriperRepository.fetchSubscribers(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createSubscriper', () {
      test('should create subscriber successfully', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 3,
          name: 'New Subscriber',
          amber: 7,
          circuit_number: 'C003',
          phone: '07733333333',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 3, "name": "New Subscriber", "Ambers": 7, "circuit_number": "C003", "phone": "07733333333"}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdSubscriber = await subscriperRepository.createSubscriper(subscriber);

        // Assert
        expect(createdSubscriber, isA<Subscriper>());
        expect(createdSubscriber.name, equals('New Subscriber'));
        expect(createdSubscriber.amber, equals(7));
        expect(createdSubscriber.circuit_number, equals('C003'));
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should throw exception when creation fails', () async {
        // Arrange
        final subscriber = Subscriper(
          name: 'Failed Subscriber',
          amber: 5,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(400);
        when(mockResponse.body).thenReturn('Bad Request');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => subscriperRepository.createSubscriper(subscriber),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should handle subscriber with null values', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: 'Null Subscriber',
          amber: 5,
          circuit_number: null,
          phone: null,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Null Subscriber", "Ambers": 5, "circuit_number": null, "phone": null}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdSubscriber = await subscriperRepository.createSubscriper(subscriber);

        // Assert
        expect(createdSubscriber.circuit_number, isNull);
        expect(createdSubscriber.phone, isNull);
      });
    });

    group('updateSubscriper', () {
      test('should update subscriber successfully', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: 'Updated Subscriber',
          amber: 8,
          circuit_number: 'C999',
          phone: '07799999999',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Updated Subscriber", "Ambers": 8, "circuit_number": "C999", "phone": "07799999999"}
        ''');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final updatedSubscriber = await subscriperRepository.updateSubscriper(subscriber);

        // Assert
        expect(updatedSubscriber, isA<Subscriper>());
        expect(updatedSubscriber.name, equals('Updated Subscriber'));
        expect(updatedSubscriber.amber, equals(8));
        expect(updatedSubscriber.circuit_number, equals('C999'));
        verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: 'Update Failed Subscriber',
          amber: 5,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.body).thenReturn('Internal Server Error');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => subscriperRepository.updateSubscriper(subscriber),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should handle subscriber with different amber values', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: 'Amber Test Subscriber',
          amber: 0,
          circuit_number: 'C001',
          phone: '07711111111',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Amber Test Subscriber", "Ambers": 0, "circuit_number": "C001", "phone": "07711111111"}
        ''');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final updatedSubscriber = await subscriperRepository.updateSubscriper(subscriber);

        // Assert
        expect(updatedSubscriber.amber, equals(0));
      });
    });

    group('destroySubscriper', () {
      test('should delete subscriber successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(204);
        when(mockResponse.body).thenReturn('');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act
        await subscriperRepository.destroySubscriper(1);

        // Assert
        verify(mockHttpClient.delete(any)).called(1);
      });

      test('should throw exception when deletion fails', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(404);
        when(mockResponse.body).thenReturn('Subscriber not found');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => subscriperRepository.destroySubscriper(999),
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
          () => subscriperRepository.destroySubscriper(1),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.delete(any)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle subscriber with empty strings', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: '',
          amber: 1,
          circuit_number: '',
          phone: '',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "", "Ambers": 1, "circuit_number": "", "phone": ""}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdSubscriber = await subscriperRepository.createSubscriper(subscriber);

        // Assert
        expect(createdSubscriber.name, equals(''));
        expect(createdSubscriber.circuit_number, equals(''));
        expect(createdSubscriber.phone, equals(''));
      });

      test('should handle subscriber with large amber values', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: 'Large Amber Subscriber',
          amber: 999,
          circuit_number: 'C999',
          phone: '07799999999',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Large Amber Subscriber", "Ambers": 999, "circuit_number": "C999", "phone": "07799999999"}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdSubscriber = await subscriperRepository.createSubscriper(subscriber);

        // Assert
        expect(createdSubscriber.amber, equals(999));
      });

      test('should handle network timeout gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => throw Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => subscriperRepository.fetchSubscribers(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed URL gracefully', () async {
        // Arrange
        final subscriber = Subscriper(
          id: 1,
          name: 'URL Test Subscriber',
          amber: 5,
        );

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => throw Exception('Invalid URL'));

        // Act & Assert
        expect(
          () => subscriperRepository.createSubscriper(subscriber),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Mock classes for testing
class MockResponse extends Mock implements http.Response {}
