import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service.dart';
import 'package:moalidaty1/features/workers/repositories/repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([WorkerRepository])
import 'worker_service_test.mocks.dart';

void main() {
  group('WorkerService Tests', () {
    late WorkerService workerService;
    late MockWorkerRepository mockRepository;

    setUp(() {
      mockRepository = MockWorkerRepository();
      workerService = WorkerService();
      // Reset GetX state
      Get.reset();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize service successfully', () async {
      // Arrange
      final testWorkers = [
        Gen_Worker(id: 1, name: 'Test Worker 1'),
        Gen_Worker(id: 2, name: 'Test Worker 2'),
      ];
      
      when(mockRepository.fetchWorkers()).thenAnswer((_) async => testWorkers);

      // Act
      final result = await workerService.init();

      // Assert
      expect(result, isA<WorkerService>());
      expect(workerService.workers.length, equals(2));
    });

    test('should fetch workers successfully', () async {
      // Arrange
      final testWorkers = [
        Gen_Worker(id: 1, name: 'Worker 1', phone: '07711111111', salary: '500.0'),
        Gen_Worker(id: 2, name: 'Worker 2', phone: '07722222222', salary: '600.0'),
      ];
      
      when(mockRepository.fetchWorkers()).thenAnswer((_) async => testWorkers);

      // Act
      await workerService.fetchWorkers();

      // Assert
      expect(workerService.workers.length, equals(2));
      expect(workerService.workers[0].name, equals('Worker 1'));
      expect(workerService.workers[1].name, equals('Worker 2'));
      verify(mockRepository.fetchWorkers()).called(1);
    });

    test('should handle fetch workers error gracefully', () async {
      // Arrange
      when(mockRepository.fetchWorkers()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => workerService.fetchWorkers(), returnsNormally);
      expect(workerService.workers.length, equals(0));
    });

    test('should add worker successfully', () async {
      // Arrange
      final newWorker = Gen_Worker(
        id: 3,
        name: 'New Worker',
        phone: '07733333333',
        salary: '700.0',
      );
      
      when(mockRepository.createWorker(newWorker)).thenAnswer((_) async => newWorker);

      // Act
      workerService.addWorker(newWorker);

      // Assert
      expect(workerService.workers.length, equals(1));
      expect(workerService.workers[0].name, equals('New Worker'));
      verify(mockRepository.createWorker(newWorker)).called(1);
    });

    test('should update worker successfully', () async {
      // Arrange
      final existingWorker = Gen_Worker(id: 1, name: 'Old Name');
      final updatedWorker = Gen_Worker(id: 1, name: 'New Name');
      
      workerService.workers.add(existingWorker);
      
      when(mockRepository.updateWorker(1, existingWorker))
          .thenAnswer((_) async => updatedWorker);

      // Act
      workerService.updateWorker(existingWorker);

      // Assert
      verify(mockRepository.updateWorker(1, existingWorker)).called(1);
    });

    test('should handle update worker error gracefully', () async {
      // Arrange
      final worker = Gen_Worker(id: 1, name: 'Test Worker');
      workerService.workers.add(worker);
      
      when(mockRepository.updateWorker(1, worker))
          .thenThrow(Exception('Update failed'));

      // Act
      workerService.updateWorker(worker);

      // Assert
      expect(workerService.workers.length, equals(1));
      expect(workerService.workers[0].name, equals('Test Worker')); // Should remain unchanged
    });

    test('should remove worker successfully', () async {
      // Arrange
      final worker = Gen_Worker(id: 1, name: 'Worker to Remove');
      workerService.workers.add(worker);
      
      when(mockRepository.deleteWorker(1)).thenAnswer((_) async => null);

      // Act
      workerService.removeWorker(worker);

      // Assert
      expect(workerService.workers.length, equals(0));
      verify(mockRepository.deleteWorker(1)).called(1);
    });

    test('should handle multiple operations correctly', () async {
      // Arrange
      final worker1 = Gen_Worker(id: 1, name: 'Worker 1');
      final worker2 = Gen_Worker(id: 2, name: 'Worker 2');
      final worker3 = Gen_Worker(id: 3, name: 'Worker 3');
      
      when(mockRepository.createWorker(any)).thenAnswer((invocation) async {
        final worker = invocation.positionalArguments[0] as Gen_Worker;
        return worker;
      });
      
      when(mockRepository.deleteWorker(any)).thenAnswer((_) async => null);

      // Act
      workerService.addWorker(worker1);
      workerService.addWorker(worker2);
      workerService.addWorker(worker3);
      
      expect(workerService.workers.length, equals(3));
      
      workerService.removeWorker(worker2);
      
      // Assert
      expect(workerService.workers.length, equals(2));
      expect(workerService.workers[0].name, equals('Worker 1'));
      expect(workerService.workers[1].name, equals('Worker 3'));
    });

    test('should maintain worker list state correctly', () async {
      // Arrange
      final initialWorkers = [
        Gen_Worker(id: 1, name: 'Initial Worker 1'),
        Gen_Worker(id: 2, name: 'Initial Worker 2'),
      ];
      
      when(mockRepository.fetchWorkers()).thenAnswer((_) async => initialWorkers);

      // Act
      await workerService.fetchWorkers();
      
      // Assert
      expect(workerService.workers.length, equals(2));
      expect(workerService.workers[0].name, equals('Initial Worker 1'));
      expect(workerService.workers[1].name, equals('Initial Worker 2'));
    });

    test('should handle empty worker list', () async {
      // Arrange
      when(mockRepository.fetchWorkers()).thenAnswer((_) async => []);

      // Act
      await workerService.fetchWorkers();

      // Assert
      expect(workerService.workers.length, equals(0));
      expect(workerService.workers, isEmpty);
    });

    test('should handle worker with null values', () async {
      // Arrange
      final workerWithNulls = Gen_Worker(
        id: 1,
        name: 'Null Worker',
        phone: null,
        salary: null,
      );
      
      when(mockRepository.createWorker(workerWithNulls))
          .thenAnswer((_) async => workerWithNulls);

      // Act
      workerService.addWorker(workerWithNulls);

      // Assert
      expect(workerService.workers.length, equals(1));
      expect(workerService.workers[0].phone, isNull);
      expect(workerService.workers[0].salary, isNull);
    });
  });
}
