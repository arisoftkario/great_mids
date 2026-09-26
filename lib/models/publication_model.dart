class Publication {
  final String id;
  final String title;
  final String category; // 'Actualité', 'Événement', 'Opportunité', 'Conseil', 'Success Story'
  final String summary;
  final String content;
  final String author;
  final String? imageUrl;
  final List<String> images;
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
    this.images = const [],
    required this.publishedDate,
    this.isPublished = true,
    this.tags = const [],
    this.viewsCount = 0,
  });

  /// Retourne la liste complète des images (inclut imageUrl si non vide)
  List<String> get allImages {
    final list = <String>[];
    if (images.isNotEmpty) {
      list.addAll(images);
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      list.add(imageUrl!.trim());
    }
    return list;
  }

  /// Image principale
  String? get primaryImage => allImages.isNotEmpty ? allImages.first : imageUrl;

  Publication copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    String? content,
    String? author,
    String? imageUrl,
    List<String>? images,
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
      images: images ?? this.images,
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
      'imageUrl': primaryImage,
      'images': images,
      'publishedDate': publishedDate.toIso8601String(),
      'isPublished': isPublished,
      'tags': tags,
      'viewsCount': viewsCount,
    };
  }

  factory Publication.fromJson(Map<String, dynamic> json) {
    final parsedImages = (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    final mainImage = json['imageUrl'] as String?;
    if (parsedImages.isEmpty && mainImage != null && mainImage.isNotEmpty) {
      parsedImages.add(mainImage);
    }

    return Publication(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'Actualité',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String? ?? 'Direction GM GROUP',
      imageUrl: mainImage ?? (parsedImages.isNotEmpty ? parsedImages.first : null),
      images: parsedImages,
      publishedDate: json['publishedDate'] != null
          ? DateTime.tryParse(json['publishedDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      isPublished: json['isPublished'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      viewsCount: json['viewsCount'] as int? ?? 0,
    );
  }
}
