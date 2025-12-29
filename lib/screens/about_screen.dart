import 'package:flutter/material.dart';
import '../models/portfolio_data.dart';

class AboutScreen extends StatelessWidget {
  final PortfolioData data;

  const AboutScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('About'),
          floating: true,
          backgroundColor: Color(0xFF0A0A0F),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: data.profile.photoUrl != null
                              ? Image.network(
                                  data.profile.photoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const CircleAvatar(
                                      backgroundColor: Color(0xFF1A1A2E),
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF6366F1),
                                      ),
                                    );
                                  },
                                )
                              : const CircleAvatar(
                                  backgroundColor: Color(0xFF1A1A2E),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.profile.title,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${data.profile.location}${data.profile.remote ? ' (Remote)' : ''}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data.profile.summary,
                    style: TextStyle(
                      color: Colors.grey[300],
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Skills Sections
                _buildSkillSection('Languages', data.skills.languages),
                _buildSkillSection('Frameworks', data.skills.frameworks),
                _buildSkillSection('Databases', data.skills.databases),
                _buildSkillSection('Integrations', data.skills.integrations),
                _buildSkillSection('Concepts', data.skills.concepts),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillSection(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              )).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
