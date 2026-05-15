class Article {
  final String id;
  final String title;
  final String url;
  final String source;
  final String sourceDisplayName;
  final DateTime publishedAt;
  final String? summary;
  final String? imageUrl;

  const Article({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.sourceDisplayName,
    required this.publishedAt,
    this.summary,
    this.imageUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      source: json['source'] as String,
      sourceDisplayName: json['source_display_name'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
