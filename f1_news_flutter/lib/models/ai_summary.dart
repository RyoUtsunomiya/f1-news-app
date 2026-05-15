class AiSummary {
  final String id;
  final String title;
  final String content;
  final List<String> relatedArticles;
  final DateTime generatedAt;
  final String topic;

  const AiSummary({
    required this.id,
    required this.title,
    required this.content,
    required this.relatedArticles,
    required this.generatedAt,
    required this.topic,
  });

  factory AiSummary.fromJson(Map<String, dynamic> json) {
    return AiSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      relatedArticles: List<String>.from(json['related_articles'] as List),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      topic: json['topic'] as String,
    );
  }
}
