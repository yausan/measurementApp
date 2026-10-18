import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:measurement_app/data/models/measurement_item.dart';
import 'package:measurement_app/data/models/project_model.dart';
import 'package:measurement_app/data/database/app_storage.dart';
import 'package:measurement_app/data/services/sync_service.dart';
import 'package:measurement_app/domain/repositories/project_repository.dart';
import 'package:measurement_app/ui/features/projects/project_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Measurement Item Validation & Formatting', () {
    test('Formatted values display correctly with units', () {
      final itemMm = MeasurementItem(
        projectId: 'test-p1',
        label: 'Window Opening',
        type: MeasurementType.length,
        value: 1200.0,
        unit: MeasurementUnit.mm,
      );
      expect(itemMm.formattedValue, '1200 mm');

      final itemAngle = MeasurementItem(
        projectId: 'test-p1',
        label: 'Roof Glazing Pitch',
        type: MeasurementType.angle,
        value: 22.5,
        unit: MeasurementUnit.deg,
      );
      expect(itemAngle.formattedValue, '22.50 °');
    });

    test('Serialization to/from JSON preserves values', () {
      final original = MeasurementItem(
        projectId: 'test-p1',
        label: 'Balcony Sill',
        type: MeasurementType.width,
        value: 1540.5,
        unit: MeasurementUnit.mm,
        locationTag: 'Balcony',
        notes: 'Check squareness',
      );

      final json = original.toJson();
      final restored = MeasurementItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.label, original.label);
      expect(restored.value, original.value);
      expect(restored.unit, original.unit);
      expect(restored.locationTag, original.locationTag);
    });
  });

  group('Offline-first Data Storage & Synchronization Workflow', () {
    test('Records are persisted locally and seeded on startup', () async {
      final storage = await AppStorage.init();
      final syncService = SyncService(storage);
      final repo = ProjectRepository(storage: storage, syncService: syncService);
      final vm = ProjectViewModel(repository: repo);

      expect(vm.projects.isNotEmpty, isTrue);
      expect(vm.totalProjectsCount, greaterThanOrEqualTo(3));
      expect(vm.projects.first.clientName, 'Isuru');
    });

    test('Adding new measurement updates project and flags sync status', () async {
      final storage = await AppStorage.init();
      final syncService = SyncService(storage);
      final repo = ProjectRepository(storage: storage, syncService: syncService);
      final vm = ProjectViewModel(repository: repo);

      final projectId = vm.projects.first.id;
      final initialCount = vm.projects.first.measurements.length;

      final newItem = MeasurementItem(
        projectId: projectId,
        label: 'New Jamb Rebate',
        type: MeasurementType.depth,
        value: 75.0,
        unit: MeasurementUnit.mm,
      );

      await vm.addMeasurement(projectId, newItem);

      final updated = vm.getProjectById(projectId);
      expect(updated?.measurements.length, initialCount + 1);
      expect(updated?.syncStatus, SyncStatus.pendingSync);
    });

    test('Sync operation transitions pending items to synced', () async {
      final storage = await AppStorage.init();
      final syncService = SyncService(storage);
      final repo = ProjectRepository(storage: storage, syncService: syncService);
      final vm = ProjectViewModel(repository: repo);

      final result = await vm.syncAll();
      expect(result.success, isTrue);
      expect(vm.pendingSyncCount, 0);
    });
  });
}
