import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_data.dart';

class ContactScreen extends StatelessWidget {
  final Profile profile;

  const ContactScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Contact'),
          floating: true,
          backgroundColor: Color(0xFF0A0A0F),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.mail_outline,
                  size: 60,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Have a project in mind? Let\'s talk!',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // Contact Options
                _buildContactCard(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: profile.email,
                  onTap: () => _launchUrl('mailto:${profile.email}'),
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.work,
                  title: 'Job Inquiries',
                  subtitle: profile.jobsEmail,
                  onTap: () => _launchUrl('mailto:${profile.jobsEmail}'),
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.code,
                  title: 'GitHub',
                  subtitle: 'View my code',
                  onTap: () => _launchUrl(profile.github),
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.link,
                  title: 'LinkedIn',
                  subtitle: 'Connect with me',
                  onTap: () => _launchUrl(profile.linkedin),
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.language,
                  title: 'Website',
                  subtitle: profile.website,
                  onTap: () => _launchUrl(profile.website),
                ),
                const SizedBox(height: 32),

                // Location
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${profile.location}${profile.remote ? ' • Available for remote work' : ''}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
