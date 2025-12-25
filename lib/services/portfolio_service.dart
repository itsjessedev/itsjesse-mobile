import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_data.dart';

class PortfolioService {
  static const String _apiUrl = 'https://itsjesse.dev/api/portfolio.json';
  static const String _cacheKey = 'portfolio_data_cache';
  static const String _cacheTimestampKey = 'portfolio_data_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 1);

  // Fetch portfolio data with caching
  Future<PortfolioData> getPortfolioData({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Check cache first (unless forcing refresh)
    if (!forceRefresh) {
      final cachedData = prefs.getString(_cacheKey);
      final cachedTimestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData != null && cachedTimestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          // Return cached data
          return PortfolioData.fromJson(jsonDecode(cachedData));
        }
      }
    }

    // Fetch fresh data
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Cache the data
        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);

        return PortfolioData.fromJson(jsonData);
      } else {
        throw Exception('Failed to load portfolio data: ${response.statusCode}');
      }
    } catch (e) {
      // If network fails, try to return cached data even if expired
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        return PortfolioData.fromJson(jsonDecode(cachedData));
      }
      rethrow;
    }
  }

  // Check for updates without full refresh
  Future<bool> hasUpdates() async {
    try {
      final response = await http.head(Uri.parse(_apiUrl));
      final prefs = await SharedPreferences.getInstance();
      final lastModified = response.headers['last-modified'];
      final cachedLastModified = prefs.getString('portfolio_last_modified');

      if (lastModified != null && lastModified != cachedLastModified) {
        await prefs.setString('portfolio_last_modified', lastModified);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }
}
