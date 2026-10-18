import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';
import '../models/measurement_item.dart';
import '../models/site_photo.dart';
import '../models/site_note.dart';
import 'sample_data.dart';

class AppStorage {
  static const String _projectsKey = 'pooja_measurement_projects_v1';
  static const String _isOfflineModeKey = 'pooja_is_simulated_offline';
  static const String _deviceIdKey = 'pooja_device_unique_id';
  static const String _technicianNameKey = 'pooja_technician_name';
  static const String _technicianRoleKey = 'app_technician_role';
  static const String _technicianEmailKey = 'app_technician_email';
  static const String _technicianPhoneKey = 'app_technician_phone';
  static const String _companyNameKey = 'app_company_name';

  final SharedPreferences _prefs;

  AppStorage(this._prefs);

  static Future<AppStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = AppStorage(prefs);
    await storage._initDeviceId();
    await storage._seedIfEmpty();
    return storage;
  }

  Future<void> _initDeviceId() async {
    if (!_prefs.containsKey(_deviceIdKey)) {
      final randomSuffix = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
      await _prefs.setString(_deviceIdKey, 'PHONE-$randomSuffix');
    }
  }

  String getDeviceId() {
    return _prefs.getString(_deviceIdKey) ?? 'PHONE-FIELD-01';
  }

  String getTechnicianName() {
    return _prefs.getString(_technicianNameKey) ?? 'Field Technician';
  }

  Future<void> setTechnicianName(String name) async {
    await _prefs.setString(_technicianNameKey, name);
  }

  String getTechnicianRole() {
    return _prefs.getString(_technicianRoleKey) ?? 'Lead Field Estimator';
  }

  Future<void> setTechnicianRole(String role) async {
    await _prefs.setString(_technicianRoleKey, role);
  }

  String getTechnicianEmail() {
    return _prefs.getString(_technicianEmailKey) ?? '';
  }

  Future<void> setTechnicianEmail(String email) async {
    await _prefs.setString(_technicianEmailKey, email);
  }

  String getTechnicianPhone() {
    return _prefs.getString(_technicianPhoneKey) ?? '';
  }

  Future<void> setTechnicianPhone(String phone) async {
    await _prefs.setString(_technicianPhoneKey, phone);
  }

  String getCompanyName() {
    return _prefs.getString(_companyNameKey) ?? 'UniSC Partner Building Solutions';
  }

  Future<void> setCompanyName(String company) async {
    await _prefs.setString(_companyNameKey, company);
  }

  Future<void> _seedIfEmpty() async {
    final raw = _prefs.getString(_projectsKey);
    if (raw == null || raw.isEmpty) {
      final initialProjects = SampleData.getInitialProjects();
      await saveProjects(initialProjects);
    }
  }

  bool isSimulatedOffline() {
    return _prefs.getBool(_isOfflineModeKey) ?? false;
  }

  Future<void> setSimulatedOffline(bool offline) async {
    await _prefs.setBool(_isOfflineModeKey, offline);
  }

  List<ProjectModel> getProjects() {
    final raw = _prefs.getString(_projectsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return SampleData.getInitialProjects();
    }
  }

  Future<void> saveProjects(List<ProjectModel> projects) async {
    final jsonList = projects.map((p) => p.toJson()).toList();
    await _prefs.setString(_projectsKey, jsonEncode(jsonList));
  }

  Future<void> saveProject(ProjectModel project) async {
    final projectToSave = project.deviceId.isEmpty
        ? project.copyWith(
            deviceId: getDeviceId(),
            technicianName: project.technicianName.isEmpty ? getTechnicianName() : project.technicianName,
          )
        : project;
    final projects = getProjects();
    final index = projects.indexWhere((p) => p.id == projectToSave.id);
    if (index >= 0) {
      projects[index] = projectToSave;
    } else {
      projects.insert(0, projectToSave);
    }
    await saveProjects(projects);
  }

  Future<void> deleteProject(String id) async {
    final projects = getProjects();
    projects.removeWhere((p) => p.id == id);
    await saveProjects(projects);
  }

  ProjectModel? getProjectById(String id) {
    final projects = getProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addMeasurement(String projectId, MeasurementItem measurement) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final updatedMeasurements = List<MeasurementItem>.from(project.measurements)..add(measurement);
    final updated = project.copyWith(
      measurements: updatedMeasurements,
      syncStatus: isSimulatedOffline() ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  Future<void> deleteMeasurement(String projectId, String measurementId) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final updatedMeasurements = List<MeasurementItem>.from(project.measurements)
      ..removeWhere((m) => m.id == measurementId);
    final updated = project.copyWith(
      measurements: updatedMeasurements,
      syncStatus: isSimulatedOffline() ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  Future<void> addNote(String projectId, SiteNote note) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final updatedNotes = List<SiteNote>.from(project.notes)..insert(0, note);
    final updated = project.copyWith(
      notes: updatedNotes,
      syncStatus: isSimulatedOffline() ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  Future<void> deleteNote(String projectId, String noteId) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final updatedNotes = List<SiteNote>.from(project.notes)..removeWhere((n) => n.id == noteId);
    final updated = project.copyWith(
      notes: updatedNotes,
      syncStatus: isSimulatedOffline() ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  Future<void> addPhoto(String projectId, SitePhoto photo) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final updatedPhotos = List<SitePhoto>.from(project.photos)..insert(0, photo);
    final updated = project.copyWith(
      photos: updatedPhotos,
      syncStatus: isSimulatedOffline() ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  Future<void> deletePhoto(String projectId, String photoId) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final updatedPhotos = List<SitePhoto>.from(project.photos)..removeWhere((p) => p.id == photoId);
    final updated = project.copyWith(
      photos: updatedPhotos,
      syncStatus: isSimulatedOffline() ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }
}
