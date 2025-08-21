# Test Suite for Moalidaty Flutter App

This directory contains comprehensive tests for all features of the Moalidaty Flutter application.

## Test Coverage

### 🏗️ Model Tests
- **Worker Model** (`features/workers/models/worker_model_test.dart`)
  - Constructor tests with required and optional parameters
  - JSON serialization/deserialization
  - Default values handling
  - Edge cases and null values

- **Subscriber Model** (`features/subscripers/models/subscriper_model_test.dart`)
  - Constructor tests with required and optional parameters
  - JSON serialization/deserialization
  - Amber field handling
  - Circuit number and phone validation

- **Receipt Model** (`features/reciepts/models/reciept_model_test.dart`)
  - Constructor tests with required and optional parameters
  - JSON serialization/deserialization
  - Date handling and validation
  - Amount calculations and validation
  - Worker and subscriber relationships

- **Budget Model** (`features/budgets/models/budget_model_test.dart`)
  - Constructor tests with required and optional parameters
  - JSON serialization/deserialization
  - Year/month handling
  - Subscriber list management

### 🔧 Service Tests
- **Worker Service** (`features/workers/services/worker_service_test.dart`)
  - CRUD operations (Create, Read, Update, Delete)
  - Error handling and edge cases
  - State management with GetX
  - Repository integration

- **Subscriber Service** (`features/subscripers/services/subscriper_service_test.dart`)
  - CRUD operations
  - Error handling and edge cases
  - State management with GetX
  - Repository integration

- **Receipt Service** (`features/reciepts/services/reciept_service_test.dart`)
  - CRUD operations
  - Error handling and edge cases
  - State management with GetX
  - Repository integration

### 🗄️ Repository Tests
- **Worker Repository** (`features/workers/repositories/worker_repository_test.dart`)
  - HTTP API integration tests
  - CRUD operations
  - Error handling for different HTTP status codes
  - JSON parsing and validation

- **Subscriber Repository** (`features/subscripers/repositories/subscriper_repository_test.dart`)
  - HTTP API integration tests
  - CRUD operations
  - Error handling for different HTTP status codes
  - JSON parsing and validation

- **Receipt Repository** (`features/reciepts/repositories/reciept_repository_test.dart`)
  - HTTP API integration tests
  - CRUD operations
  - Error handling for different HTTP status codes
  - JSON parsing and validation

### 🎨 Widget Tests
- **AppBar Widget** (`common_widgets/appbar_test.dart`)
  - Widget rendering tests
  - Title handling
  - Styling validation
  - Edge cases (long text, special characters, Arabic text)

### 🛠️ Utility Tests
- **Dummy Functions** (`utils/dummy_functions_test.dart`)
  - Array subtraction functionality
  - Different data type handling
  - Edge cases and performance tests
  - Null value handling

## Running Tests

### Prerequisites
Make sure you have the following dependencies in your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### Install Dependencies
```bash
flutter pub get
```

### Generate Mock Files
Before running tests, generate the mock files:

```bash
flutter packages pub run build_runner build
```

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
# Run only model tests
flutter test test/features/workers/models/worker_model_test.dart

# Run only service tests
flutter test test/features/workers/services/worker_service_test.dart

# Run only repository tests
flutter test test/features/workers/repositories/worker_repository_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests with Verbose Output
```bash
flutter test --verbose
```

## Test Structure

Each test file follows the **Arrange-Act-Assert** pattern:

```dart
test('should do something', () {
  // Arrange - Set up test data and conditions
  final testData = TestData();
  
  // Act - Execute the code being tested
  final result = functionUnderTest(testData);
  
  // Assert - Verify the expected outcome
  expect(result, equals(expectedValue));
});
```

## Mocking

The tests use **Mockito** for mocking dependencies:

```dart
@GenerateMocks([WorkerRepository])
import 'worker_service_test.mocks.dart';

// In tests
final mockRepository = MockWorkerRepository();
when(mockRepository.fetchWorkers()).thenAnswer((_) async => testWorkers);
```

## Best Practices

1. **Test Isolation**: Each test is independent and doesn't affect others
2. **Descriptive Names**: Test names clearly describe what is being tested
3. **Edge Cases**: Tests cover normal operation, error conditions, and edge cases
4. **Mocking**: External dependencies are mocked to ensure test reliability
5. **Coverage**: Tests cover all public methods and important logic paths

## Troubleshooting

### Common Issues

1. **Mock Generation Fails**
   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build
   ```

2. **Tests Fail Due to Missing Dependencies**
   ```bash
   flutter pub get
   flutter clean
   flutter pub get
   ```

3. **Platform-Specific Test Issues**
   - Ensure you're running tests on the correct platform
   - Some tests may require specific platform configurations

### Debugging Tests

1. **Run Single Test**
   ```bash
   flutter test test/features/workers/models/worker_model_test.dart --name "should create a Gen_Worker with required parameters"
   ```

2. **Add Debug Prints**
   ```dart
   test('debug test', () {
     print('Debug information');
     // Your test code here
   });
   ```

3. **Use Flutter Inspector**
   - Run tests in debug mode
   - Use breakpoints to step through code

## Contributing

When adding new features or modifying existing code:

1. **Write Tests First**: Follow TDD principles
2. **Maintain Coverage**: Ensure new code has adequate test coverage
3. **Update This README**: Document new test files and functionality
4. **Follow Patterns**: Use existing test patterns and naming conventions

## Test Results

After running tests, you'll see output like:

```
00:00 +0: All Tests Suite / Model Tests / Gen_Worker Model Tests / should create a Gen_Worker with required parameters
00:00 +1: All Tests Suite / Model Tests / Gen_Worker Model Tests / should create a Gen_Worker with default values
...
00:01 +50: All tests passed!
```

This indicates all tests passed successfully.
