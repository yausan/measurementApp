import 'package:flutter/foundation.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/measurement_item.dart';
import '../../../data/models/site_photo.dart';
import '../../../data/models/site_note.dart';
import '../../../data/services/sync_service.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;

  List<ProjectModel> _projects = [];
  bool _isOffline = false;
  bool _isSyncing = false;
  SyncResult? _lastSyncResult;
  String _searchQuery = '';
  ProjectStatus? _statusFilter;

  ProjectViewModel({required this._repository}) {
    _isOffline = _repository.isOffline();
    loadProjects();
  }

  List<ProjectModel> get projects => _projects;
  bool get isOffline => _isOffline;
  bool get isSyncing => _isSyncing;
  SyncResult? get lastSyncResult => _lastSyncResult;
  String get searchQuery => _searchQuery;
  ProjectStatus? get statusFilter => _statusFilter;

  int get totalProjectsCount => _projects.length;
  int get pendingSyncCount =>
      _projects.where((p) => p.syncStatus == SyncStatus.pendingSync || p.syncStatus == SyncStatus.offlineOnly).length;
  int get syncedCount => _projects.where((p) => p.syncStatus == SyncStatus.synced).length;
  int get totalMeasurementsCount =>
      _projects.fold(0, (sum, p) => sum + p.measurements.length);

  List<ProjectModel> get filteredProjects {
    return _projects.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.projectNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.siteAddress.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _statusFilter == null || p.status == _statusFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void loadProjects() {
    _projects = _repository.getAllProjects();
    _isOffline = _repository.isOffline();
    notifyListeners();
  }

  ProjectModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return _repository.getProject(id);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> toggleSimulatedOffline() async {
    _isOffline = !_isOffline;
    await _repository.setOffline(_isOffline);
    loadProjects();
  }

  Future<void> createProject(ProjectModel project) async {
    final toSave = project.copyWith(
      syncStatus: _isOffline ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
    );
    await _repository.saveProject(toSave);
    loadProjects();
  }

  Future<void> updateProject(ProjectModel project) async {
    final toSave = project.copyWith(
      syncStatus: _isOffline ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await _repository.saveProject(toSave);
    loadProjects();
  }

  Future<void> deleteProject(String id) async {
    await _repository.deleteProject(id);
    loadProjects();
  }

  Future<void> addMeasurement(String projectId, MeasurementItem item) async {
    await _repository.addMeasurement(projectId, item);
    loadProjects();
  }

  Future<void> deleteMeasurement(String projectId, String measurementId) async {
    await _repository.deleteMeasurement(projectId, measurementId);
    loadProjects();
  }

  Future<void> addNote(String projectId, SiteNote note) async {
    await _repository.addNote(projectId, note);
    loadProjects();
  }

  Future<void> deleteNote(String projectId, String noteId) async {
    await _repository.deleteNote(projectId, noteId);
    loadProjects();
  }

  Future<void> addPhoto(String projectId, SitePhoto photo) async {
    await _repository.addPhoto(projectId, photo);
    loadProjects();
  }

  Future<void> deletePhoto(String projectId, String photoId) async {
    await _repository.deletePhoto(projectId, photoId);
    loadProjects();
  }

  Future<SyncResult> syncAll() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final result = await _repository.syncAll();
      _lastSyncResult = result;
      loadProjects();
      return result;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<SyncResult> syncSingleProject(String projectId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final result = await _repository.syncProject(projectId);
      _lastSyncResult = result;
      loadProjects();
      return result;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Profile properties & updates
  String get deviceId => _repository.getDeviceId();
  String get technicianName => _repository.getTechnicianName();
  String get technicianRole => _repository.getTechnicianRole();
  String get technicianEmail => _repository.getTechnicianEmail();
  String get technicianPhone => _repository.getTechnicianPhone();
  String get companyName => _repository.getCompanyName();

  Future<void> updateProfile({
    required String name,
    required String role,
    required String email,
    required String phone,
    required String company,
  }) async {
    await _repository.setTechnicianName(name.trim());
    await _repository.setTechnicianRole(role.trim());
    await _repository.setTechnicianEmail(email.trim());
    await _repository.setTechnicianPhone(phone.trim());
    await _repository.setCompanyName(company.trim());
    notifyListeners();
  }
}
