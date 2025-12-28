import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_data.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0F),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                project.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.3),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    project.title,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (project.demoUrl != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () => _launchUrl(project.demoUrl!),
                  tooltip: 'Live Demo',
                ),
              if (project.githubUrl != null)
                IconButton(
                  icon: const Icon(Icons.code),
                  onPressed: () => _launchUrl(project.githubUrl!),
                  tooltip: 'View Code',
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      project.tagline,
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    project.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // The Problem
                  _buildSection(
                    title: 'The Problem',
                    icon: Icons.warning_amber_outlined,
                    content: project.problem,
                  ),
                  const SizedBox(height: 20),

                  // The Solution
                  _buildSection(
                    title: 'The Solution',
                    icon: Icons.lightbulb_outline,
                    content: project.solution,
                  ),
                  const SizedBox(height: 20),

                  // Results
                  const Text(
                    'Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...project.results.map((result) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                result,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Tech Stack
                  const Text(
                    'Built With',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.tech.map((tech) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[800]!,
                            ),
                          ),
                          child: Text(
                            tech,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        )).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      if (project.demoUrl != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(project.demoUrl!),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Live Demo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (project.demoUrl != null && project.githubUrl != null)
                        const SizedBox(width: 12),
                      if (project.githubUrl != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(project.githubUrl!),
                            icon: const Icon(Icons.code),
                            label: const Text('View Code'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey[700]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Colors.grey[400],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback: try without mode specification
      try {
        await launchUrl(uri);
      } catch (_) {
        // URL launch failed silently
      }
    }
  }
}
