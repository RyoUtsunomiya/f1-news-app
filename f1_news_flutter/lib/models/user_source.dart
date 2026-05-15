class UserSource {
  final String url;
  final String displayName;
  final String sourceId;
  final bool isDefault;

  const UserSource({
    required this.url,
    required this.displayName,
    required this.sourceId,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'display_name': displayName,
        'source_id': sourceId,
      };

  factory UserSource.fromJson(Map<String, dynamic> json) => UserSource(
        url: json['url'] as String,
        displayName: json['display_name'] as String,
        sourceId: json['source_id'] as String,
      );

  UserSource copyWith({String? displayName}) => UserSource(
        url: url,
        displayName: displayName ?? this.displayName,
        sourceId: sourceId,
        isDefault: isDefault,
      );
}
