import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:measurement_app/data/database/app_storage.dart';
import 'package:measurement_app/data/services/sync_service.dart';
import 'package:measurement_app/domain/repositories/project_repository.dart';
import 'package:measurement_app/ui/features/projects/project_view_model.dart';
import 'package:measurement_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders Dashboard with Pooja Basoula and Isuru partner', (WidgetTester tester) async {
    final storage = await AppStorage.init();
    final syncService = SyncService(storage);
    final repo = ProjectRepository(storage: storage, syncService: syncService);
    final vm = ProjectViewModel(repository: repo);

    await tester.pumpWidget(OnsiteMeasurementApp(viewModel: vm));
    await tester.pumpAndSettle();

    // Verify operator profile & partner header
    expect(find.textContaining('Pooja Basoula'), findsOneWidget);
    expect(find.textContaining('ISURU PARTNER'), findsOneWidget);

    // Verify key metrics
    expect(find.text('Total Projects'), findsOneWidget);
    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Pending Sync'), findsOneWidget);

    // Verify navigation tabs
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Level & Pitch'), findsOneWidget);
  });
}
