import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../tabs/news_list_tab.dart';
import '../tabs/ai_summary_tab.dart';
import '../theme/app_theme.dart';
import 'source_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final api = context.read<ApiService>();
      api.fetchSources();
      api.fetchArticles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openSourceManager() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SourceManagerScreen()),
    ).then((_) {
      // 戻ってきたときに記事を再取得
      context.read<ApiService>().fetchArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.f1Red,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(right: 10),
            ),
            const Text('F1 ニュース'),
          ],
        ),
        actions: [
          // カスタムソース追加バッジ
          Consumer<ApiService>(
            builder: (_, api, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'ソース管理',
                  onPressed: _openSourceManager,
                ),
                if (api.customSources.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.f1Red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '更新',
            onPressed: () {
              final api = context.read<ApiService>();
              if (_tabController.index == 0) {
                api.fetchArticles();
              } else {
                api.fetchAiSummaries();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.feed_rounded, size: 20),
              text: '各社記事',
            ),
            Tab(
              icon: Icon(Icons.auto_awesome_rounded, size: 20),
              text: 'AIまとめ',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NewsListTab(),
          AiSummaryTab(),
        ],
      ),
    );
  }
}
