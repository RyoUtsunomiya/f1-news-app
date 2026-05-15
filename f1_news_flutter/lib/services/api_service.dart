import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/ai_summary.dart';
import '../models/user_source.dart';
import 'source_storage_service.dart';

class ApiService extends ChangeNotifier {
  // 開発時は 10.0.2.2 (Androidエミュレータ→ホスト)、本番では実サーバーURLに変更
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  final _storage = SourceStorageService();

  List<Article> _articles = [];
  List<AiSummary> _aiSummaries = [];
  List<Map<String, dynamic>> _sources = [];
  List<UserSource> _customSources = [];

  bool _isLoadingArticles = false;
  bool _isLoadingSummaries = false;
  String? _articlesError;
  String? _summariesError;

  List<Article> get articles => _articles;
  List<AiSummary> get aiSummaries => _aiSummaries;
  List<Map<String, String>> get sources =>
      _sources.map((s) => s.map((k, v) => MapEntry(k, v.toString()))).toList();
  List<UserSource> get customSources => _customSources;
  bool get isLoadingArticles => _isLoadingArticles;
  bool get isLoadingSummaries => _isLoadingSummaries;
  String? get articlesError => _articlesError;
  String? get summariesError => _summariesError;

  Future<void> init() async {
    _customSources = await _storage.loadCustomSources();
    notifyListeners();
  }

  // ---------- Articles ----------

  Future<void> fetchArticles({String? source}) async {
    _isLoadingArticles = true;
    _articlesError = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{
        'limit': '60',
        if (source != null) 'source': source,
      };
      // カスタムソースURLを追加（repeated query param）
      final customUrlParams =
          _customSources.map((s) => 'custom_urls=${Uri.encodeComponent(s.url)}').join('&');

      final baseUri = Uri.parse('$_baseUrl/articles').replace(queryParameters: params);
      final fullUrl = customUrlParams.isNotEmpty
          ? '${baseUri.toString()}&$customUrlParams'
          : baseUri.toString();

      final response = await http.get(Uri.parse(fullUrl)).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as List;
        _articles =
            data.map((j) => Article.fromJson(j as Map<String, dynamic>)).toList();
      } else {
        _articlesError = 'ニュースの取得に失敗しました (${response.statusCode})';
      }
    } catch (_) {
      _articlesError = 'ネットワークエラー。サーバー接続を確認してください。';
    }

    _isLoadingArticles = false;
    notifyListeners();
  }

  // ---------- AI Summaries ----------

  Future<void> fetchAiSummaries() async {
    _isLoadingSummaries = true;
    _summariesError = null;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/ai-summaries'))
          .timeout(const Duration(seconds: 45));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as List;
        _aiSummaries =
            data.map((j) => AiSummary.fromJson(j as Map<String, dynamic>)).toList();
      } else {
        _summariesError = 'AIまとめの取得に失敗しました';
      }
    } catch (_) {
      _summariesError = 'ネットワークエラーが発生しました';
    }

    _isLoadingSummaries = false;
    notifyListeners();
  }

  // ---------- Sources ----------

  Future<void> fetchSources() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/sources'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as List;
        _sources = data.map((j) => Map<String, dynamic>.from(j as Map)).toList();
        notifyListeners();
      }
    } catch (_) {
      // ソース取得失敗はサイレントに無視
    }
  }

  // ---------- Custom Sources ----------

  Future<Map<String, dynamic>> validateRss(String url) async {
    try {
      final uri = Uri.parse('$_baseUrl/validate-rss')
          .replace(queryParameters: {'url': url});
      final response =
          await http.post(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'valid': false, 'message': 'サーバーに接続できません'};
  }

  Future<void> addCustomSource(String url, String displayName) async {
    final source = UserSource(
      url: url,
      displayName: displayName,
      sourceId: 'custom_${url.hashCode.abs()}',
    );
    await _storage.addSource(source);
    _customSources = await _storage.loadCustomSources();
    notifyListeners();
    await fetchArticles();
  }

  Future<void> removeCustomSource(String url) async {
    await _storage.removeSource(url);
    _customSources = await _storage.loadCustomSources();
    notifyListeners();
    await fetchArticles();
  }
}
