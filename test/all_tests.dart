import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'features/workers/models/worker_model_test.dart' as worker_model_test;
import 'features/subscripers/models/subscriper_model_test.dart' as subscriper_model_test;
import 'features/reciepts/models/reciept_model_test.dart' as reciept_model_test;
import 'features/budgets/models/budget_model_test.dart' as budget_model_test;
import 'features/workers/services/worker_service_test.dart' as worker_service_test;
import 'features/subscripers/services/subscriper_service_test.dart' as subscriper_service_test;
import 'features/reciepts/services/reciept_service_test.dart' as reciept_service_test;
import 'features/workers/repositories/worker_repository_test.dart' as worker_repository_test;
import 'features/subscripers/repositories/subscriper_repository_test.dart' as subscriper_repository_test;
import 'features/reciepts/repositories/reciept_repository_test.dart' as reciept_repository_test;
import 'common_widgets/appbar_test.dart' as appbar_test;
import 'utils/dummy_functions_test.dart' as dummy_functions_test;

void main() {
  group('All Tests Suite', () {
    // Model Tests
    group('Model Tests', () {
      worker_model_test.main();
      subscriper_model_test.main();
      reciept_model_test.main();
      budget_model_test.main();
    });

    // Service Tests
    group('Service Tests', () {
      worker_service_test.main();
      subscriper_service_test.main();
      reciept_service_test.main();
    });

    // Repository Tests
    group('Repository Tests', () {
      worker_repository_test.main();
      subscriper_repository_test.main();
      reciept_repository_test.main();
    });

    // Widget Tests
    group('Widget Tests', () {
      appbar_test.main();
    });

    // Utility Tests
    group('Utility Tests', () {
      dummy_functions_test.main();
    });
  });
}
