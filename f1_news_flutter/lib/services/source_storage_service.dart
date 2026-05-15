import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_source.dart';

class SourceStorageService {
  static const String _key = 'custom_rss_sources';

  Future<List<UserSource>> loadCustomSources() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => UserSource.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomSources(List<UserSource> sources) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      sources.map((s) => json.encode(s.toJson())).toList(),
    );
  }

  Future<void> addSource(UserSource source) async {
    final sources = await loadCustomSources();
    if (sources.any((s) => s.url == source.url)) return;
    sources.add(source);
    await saveCustomSources(sources);
  }

  Future<void> removeSource(String url) async {
    final sources = await loadCustomSources();
    sources.removeWhere((s) => s.url == url);
    await saveCustomSources(sources);
  }
}
