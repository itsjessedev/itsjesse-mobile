import 'package:flutter/material.dart';
import '../models/portfolio_data.dart';
import '../services/portfolio_service.dart';
import '../widgets/project_card.dart';
import 'project_detail_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PortfolioService _portfolioService = PortfolioService();
  PortfolioData? _data;
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _portfolioService.getPortfolioData(forceRefresh: forceRefresh);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading data', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _loadData(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildProjectsTab();
      case 2:
        return AboutScreen(data: _data!);
      case 3:
        return ContactScreen(profile: _data!.profile);
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final featuredProjects = _data!.projects.where((p) => p.featured).toList();

    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0F),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                _data!.profile.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF0A0A0F),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: _data!.profile.photoUrl != null
                              ? Image.network(
                                  _data!.profile.photoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const CircleAvatar(
                                      backgroundColor: Color(0xFF1A1A2E),
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Color(0xFF6366F1),
                                      ),
                                    );
                                  },
                                )
                              : const CircleAvatar(
                                  backgroundColor: Color(0xFF1A1A2E),
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _data!.profile.title,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _data!.profile.summary,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Projects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _currentIndex = 1),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final project = featuredProjects[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ProjectCard(
                    project: project,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailScreen(project: project),
                      ),
                    ),
                  ),
                );
              },
              childCount: featuredProjects.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('All Projects'),
            floating: true,
            backgroundColor: Color(0xFF0A0A0F),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final project = _data!.projects[index];
                  return ProjectCard(
                    project: project,
                    compact: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailScreen(project: project),
                      ),
                    ),
                  );
                },
                childCount: _data!.projects.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
