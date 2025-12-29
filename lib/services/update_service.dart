import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateInfo {
  final String version;
  final int versionCode;
  final String downloadUrl;
  final String changelog;

  UpdateInfo({
    required this.version,
    required this.versionCode,
    required this.downloadUrl,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] ?? '1.0.0',
      versionCode: json['versionCode'] ?? 1,
      downloadUrl: json['downloadUrl'] ?? '',
      changelog: json['changelog'] ?? '',
    );
  }
}

class UpdateService {
  static const String _apiUrl = 'https://itsjesse.dev/api/portfolio.json';
  final Dio _dio = Dio();

  // Check if an update is available
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Fetch remote version info
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final mobileApp = data['mobileApp'];
      if (mobileApp == null) return null;

      final updateInfo = UpdateInfo.fromJson(mobileApp);

      // Compare version codes
      if (updateInfo.versionCode > currentVersionCode) {
        return updateInfo;
      }

      return null;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  // Download and install update
  Future<bool> downloadAndInstall(
    UpdateInfo updateInfo, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Request storage permission on older Android versions
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      // Get the downloads directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint('Could not get external storage directory');
        return false;
      }

      final apkPath = '${directory.path}/itsjesse-update.apk';
      final file = File(apkPath);

      // Delete old APK if exists
      if (await file.exists()) {
        await file.delete();
      }

      // Download the APK
      await _dio.download(
        updateInfo.downloadUrl,
        apkPath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received, total);
          }
        },
      );

      // Verify file exists
      if (!await file.exists()) {
        debugPrint('APK file was not downloaded');
        return false;
      }

      // Open the APK for installation
      final result = await OpenFilex.open(apkPath);
      debugPrint('OpenFilex result: ${result.type} - ${result.message}');

      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Error downloading or installing update: $e');
      return false;
    }
  }

  // Show update dialog
  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo updateInfo,
    UpdateService updateService,
  ) async {
    bool isDownloading = false;
    double progress = 0;
    String statusText = 'A new version is available!';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.system_update,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Update Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Version',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'v${updateInfo.version}',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (updateInfo.changelog.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            updateInfo.changelog,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isDownloading) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFF0A0A0F),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              actions: [
                if (!isDownloading)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Later',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                if (!isDownloading)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        isDownloading = true;
                        statusText = 'Downloading update...';
                      });

                      final success = await updateService.downloadAndInstall(
                        updateInfo,
                        onProgress: (received, total) {
                          setState(() {
                            progress = received / total;
                            if (progress >= 1.0) {
                              statusText = 'Installing...';
                            }
                          });
                        },
                      );

                      if (!success && context.mounted) {
                        setState(() {
                          isDownloading = false;
                          statusText = 'Download failed. Please try again.';
                        });
                      } else if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Update Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
