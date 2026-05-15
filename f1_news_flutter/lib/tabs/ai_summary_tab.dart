import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/ai_summary_card.dart';
import '../widgets/ad_banner_widget.dart';
import '../theme/app_theme.dart';

class AiSummaryTab extends StatefulWidget {
  const AiSummaryTab({super.key});

  @override
  State<AiSummaryTab> createState() => _AiSummaryTabState();
}

class _AiSummaryTabState extends State<AiSummaryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ApiService>().aiSummaries.isEmpty) {
        context.read<ApiService>().fetchAiSummaries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ApiService>(
      builder: (context, api, _) {
        return RefreshIndicator(
          onRefresh: api.fetchAiSummaries,
          color: AppTheme.f1Red,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              const SliverToBoxAdapter(child: AdBannerWidget()),
              _buildContent(api),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ApiService api) {
    if (api.isLoadingSummaries && api.aiSummaries.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.f1Red),
              SizedBox(height: 16),
              Text('AIが各社記事を分析中...', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 6),
              Text('しばらくお待ちください',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (api.summariesError != null && api.aiSummaries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 52, color: Colors.grey),
              const SizedBox(height: 16),
              Text(api.summariesError!,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: api.fetchAiSummaries,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.f1Red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (api.aiSummaries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.summarize_outlined, size: 52, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('まとめ記事を準備中です',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: api.fetchAiSummaries,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.f1Red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('生成する'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AiSummaryCard(summary: api.aiSummaries[index]),
          childCount: api.aiSummaries.length,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.f1Red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: AppTheme.f1Red, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Powered by Claude AI',
                      style: TextStyle(
                          color: AppTheme.f1Red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '本日のF1ニュースまとめ',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 4),
          const Text(
            '各社の記事をAIが分析・統合しました',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
