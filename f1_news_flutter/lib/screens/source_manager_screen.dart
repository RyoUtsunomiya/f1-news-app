import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_source.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SourceManagerScreen extends StatefulWidget {
  const SourceManagerScreen({super.key});

  @override
  State<SourceManagerScreen> createState() => _SourceManagerScreenState();
}

class _SourceManagerScreenState extends State<SourceManagerScreen> {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isValidating = false;
  String? _validateError;
  String? _detectedName;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _validateAndPreview() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isValidating = true;
      _validateError = null;
      _detectedName = null;
    });

    final api = context.read<ApiService>();
    final result = await api.validateRss(url);

    if (!mounted) return;
    setState(() {
      _isValidating = false;
      if (result['valid'] == true) {
        _detectedName = result['display_name'] as String?;
        _nameController.text = _detectedName ?? '';
      } else {
        _validateError = result['message'] as String? ?? '無効なRSSです';
      }
    });
  }

  Future<void> _addSource() async {
    final url = _urlController.text.trim();
    final name = _nameController.text.trim();
    if (url.isEmpty || name.isEmpty) return;

    final api = context.read<ApiService>();
    await api.addCustomSource(url, name);

    if (!mounted) return;
    _urlController.clear();
    _nameController.clear();
    setState(() {
      _detectedName = null;
      _validateError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('「$name」を追加しました'),
        backgroundColor: AppTheme.f1Red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _removeSource(UserSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('ソースを削除'),
        content: Text('「${source.displayName}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.f1Red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<ApiService>().removeCustomSource(source.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ニュースソース管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ApiService>(
        builder: (context, api, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // デフォルトソース
              _SectionHeader(title: 'デフォルトソース', icon: Icons.verified_rounded),
              const SizedBox(height: 8),
              ...api.sources
                  .where((s) => s['is_default'] == true)
                  .map((s) => _DefaultSourceTile(name: s['name'] ?? '')),

              const SizedBox(height: 24),

              // カスタムソース
              _SectionHeader(title: 'カスタムソース', icon: Icons.add_circle_rounded),
              const SizedBox(height: 8),

              if (api.customSources.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '追加したカスタムソースはありません',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                )
              else
                ...api.customSources.map(
                  (s) => _CustomSourceTile(
                    source: s,
                    onDelete: () => _removeSource(s),
                  ),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // RSSを追加フォーム
              Text(
                'RSSフィードを追加',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'RSSフィードのURLを入力してください',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // URL入力
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'RSS URL',
                  hintText: 'https://example.com/feed',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _validateError,
                  suffixIcon: _isValidating
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search_rounded),
                          tooltip: 'RSS確認',
                          onPressed: _validateAndPreview,
                        ),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _validateAndPreview(),
              ),

              if (_detectedName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'RSSを確認: $_detectedName',
                        style: const TextStyle(
                            color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // サイト名入力
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'サイト名（表示名）',
                  hintText: '例: F1速報',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _detectedName != null ? _addSource : null,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ソースを追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.f1Red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.f1Red),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.f1Red,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DefaultSourceTile extends StatelessWidget {
  final String name;

  const _DefaultSourceTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.rss_feed_rounded, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 14, color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('デフォルト',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class _CustomSourceTile extends StatelessWidget {
  final UserSource source;
  final VoidCallback onDelete;

  const _CustomSourceTile({required this.source, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.f1Red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.rss_feed_rounded, size: 16, color: AppTheme.f1Red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source.displayName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  source.url,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.grey, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
