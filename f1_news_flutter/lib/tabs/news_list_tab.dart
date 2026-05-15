import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/source_chip.dart';

class NewsListTab extends StatefulWidget {
  const NewsListTab({super.key});

  @override
  State<NewsListTab> createState() => _NewsListTabState();
}

class _NewsListTabState extends State<NewsListTab>
    with AutomaticKeepAliveClientMixin {
  String? _selectedSource;

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() =>
      context.read<ApiService>().fetchArticles(source: _selectedSource);

  void _selectSource(String? source) {
    if (_selectedSource == source) return;
    setState(() => _selectedSource = source);
    context.read<ApiService>().fetchArticles(source: source);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ApiService>(
      builder: (context, api, _) {
        return Column(
          children: [
            if (api.sources.isNotEmpty) _SourceFilterBar(
              sources: api.sources,
              selected: _selectedSource,
              onSelect: _selectSource,
            ),
            const AdBannerWidget(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: Theme.of(context).primaryColor,
                child: _buildBody(api),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(ApiService api) {
    if (api.isLoadingArticles && api.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (api.articlesError != null && api.articles.isEmpty) {
      return _ErrorView(message: api.articlesError!, onRetry: _refresh);
    }
    if (api.articles.isEmpty) {
      return const Center(
        child: Text('記事がありません', style: TextStyle(color: Colors.grey)),
      );
    }

    // 5記事ごとに広告を挿入
    final articles = api.articles;
    final itemCount = articles.length + (articles.length ~/ 5);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final adIndex = index ~/ 6;
        final isAdSlot = index > 0 && index % 6 == 5;

        if (isAdSlot) return const AdBannerWidget(isMedium: true);

        final articleIndex = index - adIndex;
        if (articleIndex >= articles.length) return null;
        return ArticleCard(article: articles[articleIndex]);
      },
    );
  }
}

class _SourceFilterBar extends StatelessWidget {
  final List<Map<String, String>> sources;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _SourceFilterBar({
    required this.sources,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          SourceChip(
            label: 'すべて',
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...sources.map(
            (s) => SourceChip(
              label: s['name'] ?? '',
              isSelected: selected == s['id'],
              onTap: () => onSelect(s['id']),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('再試行'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
