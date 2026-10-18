import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/database/app_storage.dart';
import 'data/services/sync_service.dart';
import 'domain/repositories/project_repository.dart';
import 'ui/core/theme.dart';
import 'ui/features/projects/project_view_model.dart';
import 'ui/features/dashboard/dashboard_screen.dart';
import 'ui/features/projects/project_list_screen.dart';
import 'ui/features/tools/inclinometer_screen.dart';
import 'ui/features/projects/new_project_screen.dart';
import 'ui/features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  final storage = await AppStorage.init();
  final syncService = SyncService(storage);
  final repository = ProjectRepository(storage: storage, syncService: syncService);
  final viewModel = ProjectViewModel(repository: repository);

  runApp(OnsiteMeasurementApp(viewModel: viewModel));
}

class OnsiteMeasurementApp extends StatelessWidget {
  final ProjectViewModel viewModel;

  const OnsiteMeasurementApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'On-site Measurements & Details',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainNavigationShell(viewModel: viewModel),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final ProjectViewModel viewModel;

  const MainNavigationShell({super.key, required this.viewModel});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        viewModel: widget.viewModel,
        onNavigateToTools: () => setState(() => _currentIndex = 2),
      ),
      ProjectListScreen(viewModel: widget.viewModel),
      InclinometerScreen(viewModel: widget.viewModel),
      ProfileScreen(viewModel: widget.viewModel),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_main_shell',
        backgroundColor: AppTheme.accentCyan,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, fontWeight: FontWeight.bold),
        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewProjectScreen(viewModel: widget.viewModel),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: AppTheme.primaryNavy,
        indicatorColor: AppTheme.accentCyan.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.accentCyan),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded, color: AppTheme.accentCyan),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.crop_free_outlined),
            selectedIcon: Icon(Icons.crop_free_rounded, color: AppTheme.accentCyan),
            label: 'Level & Pitch',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.accentCyan),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
