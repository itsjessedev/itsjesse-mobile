import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  final Dio _dio = Dio();

  static const String _pdfUrl = 'https://dl.itsjesse.dev/Jesse-Eldridge-Resume.pdf';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        setState(() => _isDownloading = false);
        _showSnackBar('Could not access storage', isError: true);
        return;
      }

      final pdfPath = '${directory.path}/Jesse-Eldridge-Resume.pdf';
      final file = File(pdfPath);

      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        _pdfUrl,
        pdfPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() => _isDownloading = false);

      if (!await file.exists()) {
        _showSnackBar('Download failed', isError: true);
        return;
      }

      final result = await OpenFilex.open(pdfPath);
      if (result.type != ResultType.done) {
        _showSnackBar('Downloaded to ${directory.path}', isError: false);
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      _showSnackBar('Download failed: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0F),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Jesse Eldridge',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3B82F6).withAlpha(30),
                      const Color(0xFF1A1A2E),
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
                  // Contact Info
                  _buildContactInfo(),
                  const SizedBox(height: 24),

                  // Summary
                  _buildSection(
                    'Summary',
                    child: Text(
                      'Software developer specializing in business automation and system integration. I build solutions that connect disparate systems, automate workflows, and provide real-time visibility into operations. Portfolio includes 15 production-ready projects demonstrating API integration, data pipelines, and full-stack development.',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Technical Skills
                  _buildSection(
                    'Technical Skills',
                    child: _buildSkillsGrid(),
                  ),
                  const SizedBox(height: 24),

                  // Featured Projects
                  _buildSection(
                    'Featured Projects',
                    child: Column(
                      children: [
                        _buildProject(
                          'OrderHub',
                          'E-commerce Aggregator',
                          'Unified dashboard aggregating orders from Shopify, Amazon, eBay, and Etsy with real-time inventory sync.',
                          [
                            'Reduced order processing time by 70% through unified interface',
                            'Eliminated overselling with cross-platform inventory synchronization',
                          ],
                          ['React', 'FastAPI', 'Shopify API', 'Amazon SP-API'],
                        ),
                        const SizedBox(height: 12),
                        _buildProject(
                          'DealScout',
                          'AI Deal Discovery',
                          'Mobile app that monitors marketplace alerts, uses AI to classify items, and calculates flip profit potential.',
                          [
                            'Gemini AI classifies items and extracts product details automatically',
                            'eBay API integration for real-time market value comparison',
                          ],
                          ['React Native', 'FastAPI', 'Gemini AI', 'eBay API'],
                        ),
                        const SizedBox(height: 12),
                        _buildProject(
                          'DocuMind',
                          'RAG Document Intelligence',
                          'Document Q&A system using retrieval-augmented generation for accurate answers from uploaded files.',
                          [
                            'Semantic search across document collections with source citations',
                            'Supports PDF, Word, and text file ingestion with vector embeddings',
                          ],
                          ['Python', 'OpenAI', 'ChromaDB', 'FastAPI'],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Education
                  _buildSection(
                    'Education',
                    child: _buildTimelineItem(
                      'Western Governors University',
                      'Expected 2026',
                      'Bachelor of Science, Computer Science',
                      null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Experience
                  _buildSection(
                    'Experience',
                    child: Column(
                      children: [
                        _buildTimelineItem(
                          'Independent Developer',
                          '2024 – Present',
                          'Automation & Integration Consulting',
                          'Building custom automation solutions for small businesses. 15 portfolio projects spanning e-commerce, AI/ML, mobile apps, and workflow automation.',
                        ),
                        const SizedBox(height: 16),
                        _buildTimelineItem(
                          'Amazon',
                          '2023 – 2024',
                          'Fulfillment Center Associate',
                          'High-volume operations experience with strict productivity metrics and quality standards.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A3E), width: 1),
          ),
        ),
        child: ElevatedButton.icon(
          onPressed: _isDownloading ? null : _downloadPdf,
          icon: _isDownloading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: _downloadProgress,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download),
          label: Text(_isDownloading
              ? 'Downloading ${(_downloadProgress * 100).toStringAsFixed(0)}%'
              : 'Download PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildContactItem(Icons.location_on_outlined, 'Cookeville, TN (Remote)'),
        GestureDetector(
          onTap: () => _launchUrl('mailto:jobs@itsjesse.dev'),
          child: _buildContactItem(Icons.email_outlined, 'jobs@itsjesse.dev', isLink: true),
        ),
        GestureDetector(
          onTap: () => _launchUrl('https://itsjesse.dev'),
          child: _buildContactItem(Icons.language, 'itsjesse.dev', isLink: true),
        ),
        GestureDetector(
          onTap: () => _launchUrl('https://github.com/itsjessedev'),
          child: _buildContactItem(Icons.code, 'github.com/itsjessedev', isLink: true),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, {bool isLink = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isLink ? const Color(0xFF3B82F6) : Colors.grey[400],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFF3B82F6).withAlpha(77),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildSkillsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkillCard('Languages & Frameworks', 'Python, TypeScript, SQL, FastAPI, React, Next.js, React Native')),
            const SizedBox(width: 12),
            Expanded(child: _buildSkillCard('Data & Infrastructure', 'PostgreSQL, SQLite, Docker, Git, Linux, CI/CD, Cloudflare')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkillCard('APIs & Integrations', 'Salesforce, Shopify, Amazon, eBay, HubSpot, QuickBooks, Slack, Twilio')),
            const SizedBox(width: 12),
            Expanded(child: _buildSkillCard('AI & Automation', 'OpenAI, Google Gemini, RAG, OCR, Sentiment Analysis, Workflow Automation')),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillCard(String title, String skills) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            skills,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProject(String title, String subtitle, String description, List<String> results, List<String> tech) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          ...results.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13)),
                    Expanded(
                      child: Text(
                        result,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tech.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, String subtitle, String? details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
            ),
            if (details != null)
              Container(
                width: 2,
                height: 50,
                color: const Color(0xFF3B82F6).withAlpha(77),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              if (details != null) ...[
                const SizedBox(height: 6),
                Text(
                  details,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
