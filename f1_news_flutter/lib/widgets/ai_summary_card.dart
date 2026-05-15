import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ai_summary.dart';
import '../theme/app_theme.dart';

class AiSummaryCard extends StatefulWidget {
  final AiSummary summary;

  const AiSummaryCard({super.key, required this.summary});

  @override
  State<AiSummaryCard> createState() => _AiSummaryCardState();
}

class _AiSummaryCardState extends State<AiSummaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopicBadge(topic: widget.summary.topic),
            const SizedBox(height: 10),
            Text(
              widget.summary.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedCrossFade(
              firstChild: Text(
                widget.summary.content,
                style: const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 14,
                  height: 1.7,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.summary.content,
                style: const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? '閉じる' : '続きを読む',
                      style: const TextStyle(
                        color: AppTheme.f1Red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.f1Red,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'AI生成 ${DateFormat('M/d HH:mm').format(widget.summary.generatedAt.toLocal())}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicBadge extends StatelessWidget {
  final String topic;

  const _TopicBadge({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.f1Red, Color(0xFFFF3333)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 11),
          const SizedBox(width: 5),
          Text(
            topic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
