import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../database/app_storage.dart';
import '../models/project_model.dart';

class SyncResult {
  final bool success;
  final int syncedCount;
  final String message;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SyncService {
  final AppStorage _storage;
  final FirebaseFirestore _firestore;

  SyncService(this._storage, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<SyncResult> syncAllProjects() async {
    if (_storage.isSimulatedOffline()) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Device is currently in OFFLINE mode. Changes are saved locally on device and will sync automatically once online.',
      );
    }

    try {
      final localProjects = _storage.getProjects();
      int syncedCount = 0;

      // 1. Upload local changes to Cloud Firestore
      for (final project in localProjects) {
        if (project.syncStatus != SyncStatus.synced) {
          final docRef = _firestore.collection('projects').doc(project.id);
          await docRef.set(project.toJson(), SetOptions(merge: true));
          syncedCount++;
        }
      }

      // 2. Fetch remote projects from Cloud Firestore
      final remoteSnapshot = await _firestore.collection('projects').get();
      final Map<String, ProjectModel> merged = {
        for (var p in localProjects) p.id: p,
      };

      for (final doc in remoteSnapshot.docs) {
        try {
          final remoteData = doc.data();
          final remoteProject = ProjectModel.fromJson(remoteData);
          final localProject = merged[remoteProject.id];

          if (localProject == null) {
            merged[remoteProject.id] = remoteProject.copyWith(
              syncStatus: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            );
          } else {
            if (localProject.syncStatus == SyncStatus.synced &&
                remoteProject.updatedAt.isAfter(localProject.updatedAt)) {
              merged[remoteProject.id] = remoteProject.copyWith(
                syncStatus: SyncStatus.synced,
                lastSyncedAt: DateTime.now(),
              );
            }
          }
        } catch (e) {
          debugPrint('Error parsing remote project ${doc.id}: $e');
        }
      }

      final updatedProjects = merged.values.map((project) {
        if (project.syncStatus != SyncStatus.synced) {
          return project.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
          );
        }
        return project;
      }).toList();

      await _storage.saveProjects(updatedProjects);

      return SyncResult(
        success: true,
        syncedCount: syncedCount,
        message: syncedCount > 0
            ? 'Successfully synced $syncedCount project(s) to Cloud Firestore.'
            : 'All projects and site data are up to date with Cloud Firestore.',
      );
    } catch (e) {
      debugPrint('Cloud Firestore sync error: $e');
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Sync note: $e. All data is saved safely on your device.',
      );
    }
  }

  Future<SyncResult> syncSingleProject(String projectId) async {
    if (_storage.isSimulatedOffline()) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Device is OFFLINE. Project saved locally and will sync when network is restored.',
      );
    }

    final project = _storage.getProjectById(projectId);
    if (project == null) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Project not found.',
      );
    }

    try {
      final docRef = _firestore.collection('projects').doc(project.id);
      await docRef.set(project.toJson(), SetOptions(merge: true));

      final updated = project.copyWith(
        syncStatus: SyncStatus.synced,
        lastSyncedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _storage.saveProject(updated);

      return SyncResult(
        success: true,
        syncedCount: 1,
        message: 'Project ${project.projectNumber} successfully synced to Cloud Firestore.',
      );
    } catch (e) {
      debugPrint('Error syncing single project to Firestore: $e');
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Saved locally. Sync error: $e',
      );
    }
  }
}
