import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/repositories/repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'worker_repository_test.mocks.dart';

void main() {
  group('WorkerRepository Tests', () {
    late WorkerRepository workerRepository;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      workerRepository = WorkerRepository();
    });

    group('fetchWorkers', () {
      test('should return list of workers when HTTP call completes successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          [
            {"id": 1, "name": "Worker 1", "phone": "07711111111", "salary": "500.0"},
            {"id": 2, "name": "Worker 2", "phone": "07722222222", "salary": "600.0"}
          ]
        ''');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final workers = await workerRepository.fetchWorkers();

        // Assert
        expect(workers, isA<List<Gen_Worker>>());
        expect(workers.length, equals(2));
        expect(workers[0].name, equals('Worker 1'));
        expect(workers[1].name, equals('Worker 2'));
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
          () => workerRepository.fetchWorkers(),
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
        final workers = await workerRepository.fetchWorkers();

        // Assert
        expect(workers, isEmpty);
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
          () => workerRepository.fetchWorkers(),
          throwsA(isA<FormatException>()),
        );
        verify(mockHttpClient.get(any)).called(1);
      });
    });

    group('fetchWorkerDetail', () {
      test('should return worker when HTTP call completes successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Worker Detail", "phone": "07711111111", "salary": "500.0"}
        ''');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final worker = await workerRepository.fetchWorkerDetail(1);

        // Assert
        expect(worker, isA<Gen_Worker>());
        expect(worker.id, equals(1));
        expect(worker.name, equals('Worker Detail'));
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should throw exception when worker not found', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(404);
        when(mockResponse.body).thenReturn('Worker not found');

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => workerRepository.fetchWorkerDetail(999),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.get(any)).called(1);
      });
    });

    group('createWorker', () {
      test('should create worker successfully', () async {
        // Arrange
        final worker = Gen_Worker(
          id: 3,
          name: 'New Worker',
          phone: '07733333333',
          salary: '700.0',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 3, "name": "New Worker", "phone": "07733333333", "salary": "700.0"}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdWorker = await workerRepository.createWorker(worker);

        // Assert
        expect(createdWorker, isA<Gen_Worker>());
        expect(createdWorker.name, equals('New Worker'));
        expect(createdWorker.phone, equals('07733333333'));
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should throw exception when creation fails', () async {
        // Arrange
        final worker = Gen_Worker(name: 'Failed Worker');

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(400);
        when(mockResponse.body).thenReturn('Bad Request');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => workerRepository.createWorker(worker),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });
    });

    group('updateWorker', () {
      test('should update worker successfully', () async {
        // Arrange
        final worker = Gen_Worker(
          id: 1,
          name: 'Updated Worker',
          phone: '07799999999',
          salary: '800.0',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Updated Worker", "phone": "07799999999", "salary": "800.0"}
        ''');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final updatedWorker = await workerRepository.updateWorker(1, worker);

        // Assert
        expect(updatedWorker, isA<Gen_Worker>());
        expect(updatedWorker.name, equals('Updated Worker'));
        expect(updatedWorker.phone, equals('07799999999'));
        verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        final worker = Gen_Worker(id: 1, name: 'Update Failed Worker');

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.body).thenReturn('Internal Server Error');

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => workerRepository.updateWorker(1, worker),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .called(1);
      });
    });

    group('deleteWorker', () {
      test('should delete worker successfully', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(204);
        when(mockResponse.body).thenReturn('');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act
        await workerRepository.deleteWorker(1);

        // Assert
        verify(mockHttpClient.delete(any)).called(1);
      });

      test('should throw exception when deletion fails', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(404);
        when(mockResponse.body).thenReturn('Worker not found');

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => workerRepository.deleteWorker(999),
          throwsA(isA<Exception>()),
        );
        verify(mockHttpClient.delete(any)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle worker with null values', () async {
        // Arrange
        final worker = Gen_Worker(
          id: 1,
          name: 'Null Worker',
          phone: null,
          salary: null,
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "Null Worker", "phone": null, "salary": null}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdWorker = await workerRepository.createWorker(worker);

        // Assert
        expect(createdWorker.phone, isNull);
        expect(createdWorker.salary, isNull);
      });

      test('should handle worker with empty strings', () async {
        // Arrange
        final worker = Gen_Worker(
          id: 1,
          name: '',
          phone: '',
          salary: '',
        );

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.body).thenReturn('''
          {"id": 1, "name": "", "phone": "", "salary": ""}
        ''');

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final createdWorker = await workerRepository.createWorker(worker);

        // Assert
        expect(createdWorker.name, equals(''));
        expect(createdWorker.phone, equals(''));
        expect(createdWorker.salary, equals(''));
      });

      test('should handle network timeout gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => throw Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => workerRepository.fetchWorkers(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Mock classes for testing
class MockResponse extends Mock implements http.Response {}
