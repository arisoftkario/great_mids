class Offer {
  final String id;
  final String title;
  final String department; // 'GM Formation & Emploi', 'GM Parfum', 'GM Texa', 'GM Autosolution', 'GM Fondation'
  final String type; // 'Emploi', 'Stage', 'Formation', 'Promotion', 'Partenariat'
  final String location;
  final String? salaryOrPrice;
  final String description;
  final List<String> requirements;
  final DateTime deadline;
  final DateTime publishedDate;
  final bool isActive;
  final bool isUrgent;
  final String? customContactWhatsApp;

  const Offer({
    required this.id,
    required this.title,
    required this.department,
    required this.type,
    required this.location,
    this.salaryOrPrice,
    required this.description,
    this.requirements = const [],
    required this.deadline,
    required this.publishedDate,
    this.isActive = true,
    this.isUrgent = false,
    this.customContactWhatsApp,
  });

  Offer copyWith({
    String? id,
    String? title,
    String? department,
    String? type,
    String? location,
    String? salaryOrPrice,
    String? description,
    List<String>? requirements,
    DateTime? deadline,
    DateTime? publishedDate,
    bool? isActive,
    bool? isUrgent,
    String? customContactWhatsApp,
  }) {
    return Offer(
      id: id ?? this.id,
      title: title ?? this.title,
      department: department ?? this.department,
      type: type ?? this.type,
      location: location ?? this.location,
      salaryOrPrice: salaryOrPrice ?? this.salaryOrPrice,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      deadline: deadline ?? this.deadline,
      publishedDate: publishedDate ?? this.publishedDate,
      isActive: isActive ?? this.isActive,
      isUrgent: isUrgent ?? this.isUrgent,
      customContactWhatsApp: customContactWhatsApp ?? this.customContactWhatsApp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'type': type,
      'location': location,
      'salaryOrPrice': salaryOrPrice,
      'description': description,
      'requirements': requirements,
      'deadline': deadline.toIso8601String(),
      'publishedDate': publishedDate.toIso8601String(),
      'isActive': isActive,
      'isUrgent': isUrgent,
      'customContactWhatsApp': customContactWhatsApp,
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      title: json['title'] as String,
      department: json['department'] as String? ?? 'GM Formation & Emploi',
      type: json['type'] as String? ?? 'Emploi',
      location: json['location'] as String? ?? 'Kinshasa / À distance',
      salaryOrPrice: json['salaryOrPrice'] as String?,
      description: json['description'] as String? ?? '',
      requirements: (json['requirements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String) ?? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      publishedDate: json['publishedDate'] != null
          ? DateTime.tryParse(json['publishedDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      isUrgent: json['isUrgent'] as bool? ?? false,
      customContactWhatsApp: json['customContactWhatsApp'] as String?,
    );
  }
}
