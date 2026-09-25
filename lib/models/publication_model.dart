class Publication {
  final String id;
  final String title;
  final String category; // 'Actualité', 'Événement', 'Opportunité', 'Conseil', 'Success Story'
  final String summary;
  final String content;
  final String author;
  final String? imageUrl;
  final DateTime publishedDate;
  final bool isPublished; // true = Publié, false = Brouillon
  final List<String> tags;
  final int viewsCount;

  const Publication({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.author,
    this.imageUrl,
    required this.publishedDate,
    this.isPublished = true,
    this.tags = const [],
    this.viewsCount = 0,
  });

  Publication copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    String? content,
    String? author,
    String? imageUrl,
    DateTime? publishedDate,
    bool? isPublished,
    List<String>? tags,
    int? viewsCount,
  }) {
    return Publication(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      isPublished: isPublished ?? this.isPublished,
      tags: tags ?? this.tags,
      viewsCount: viewsCount ?? this.viewsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'content': content,
      'author': author,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'isPublished': isPublished,
      'tags': tags,
      'viewsCount': viewsCount,
    };
  }

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'Actualité',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String? ?? 'Direction GM GROUP',
      imageUrl: json['imageUrl'] as String?,
      publishedDate: json['publishedDate'] != null
          ? DateTime.tryParse(json['publishedDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      isPublished: json['isPublished'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      viewsCount: json['viewsCount'] as int? ?? 0,
    );
  }
}
