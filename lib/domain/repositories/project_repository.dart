import '../../data/database/app_storage.dart';
import '../../data/models/project_model.dart';
import '../../data/models/measurement_item.dart';
import '../../data/models/site_photo.dart';
import '../../data/models/site_note.dart';
import '../../data/services/sync_service.dart';

class ProjectRepository {
  final AppStorage _storage;
  final SyncService _syncService;

  ProjectRepository({
    required this._storage,
    required this._syncService,
  });

  List<ProjectModel> getAllProjects() => _storage.getProjects();

  ProjectModel? getProject(String id) => _storage.getProjectById(id);

  Future<void> saveProject(ProjectModel project) => _storage.saveProject(project);

  Future<void> deleteProject(String id) => _storage.deleteProject(id);

  Future<void> addMeasurement(String projectId, MeasurementItem measurement) =>
      _storage.addMeasurement(projectId, measurement);

  Future<void> deleteMeasurement(String projectId, String measurementId) =>
      _storage.deleteMeasurement(projectId, measurementId);

  Future<void> addNote(String projectId, SiteNote note) => _storage.addNote(projectId, note);

  Future<void> deleteNote(String projectId, String noteId) => _storage.deleteNote(projectId, noteId);

  Future<void> addPhoto(String projectId, SitePhoto photo) => _storage.addPhoto(projectId, photo);

  Future<void> deletePhoto(String projectId, String photoId) => _storage.deletePhoto(projectId, photoId);

  bool isOffline() => _storage.isSimulatedOffline();

  Future<void> setOffline(bool offline) => _storage.setSimulatedOffline(offline);

  Future<SyncResult> syncAll() => _syncService.syncAllProjects();

  Future<SyncResult> syncProject(String projectId) => _syncService.syncSingleProject(projectId);
}
