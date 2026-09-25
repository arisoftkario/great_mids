import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/publication_model.dart';
import '../../../services/app_data_service.dart';
import 'publication_detail_dialog.dart';

class PublicationsSection extends StatefulWidget {
  const PublicationsSection({super.key});

  @override
  State<PublicationsSection> createState() => _PublicationsSectionState();
}

class _PublicationsSectionState extends State<PublicationsSection> {
  String _selectedCategory = 'Tous';

  void _openPublicationDetail(Publication pub) {
    AppDataService().incrementPublicationViews(pub.id);
    showDialog<void>(
      context: context,
      builder: (context) => PublicationDetailDialog(publication: pub),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = AppDataService();

    return AnimatedBuilder(
      animation: dataService,
      builder: (context, _) {
        final allPubs = dataService.publishedPublications;
        final filteredPubs = _selectedCategory == 'Tous'
            ? allPubs
            : allPubs.where((p) => p.category == _selectedCategory).toList();

        final categories = ['Tous', ...allPubs.map((p) => p.category).toSet()];

        return Container(
          color: const Color(0xFFF9FBFF),
          padding: const EdgeInsets.fromLTRB(24, 90, 24, 90),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  const Text(
                    'ACTUALITÉS & PUBLICATIONS',
                    style: TextStyle(
                      color: AppTheme.accentBlue,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Les nouvelles de l’écosystème GM GROUP.',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Découvrez nos derniers articles, annonces de programmes, conseils stratégiques et initiatives pour l’avenir.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category Filter Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryNavy,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryNavy
                                  : AppTheme.borderSubtle,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Publications Grid
                  if (filteredPubs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.newspaper_rounded,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Aucune publication dans cette catégorie',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 780;
                        final isMedium = constraints.maxWidth < 1100;
                        final columns = isCompact ? 1 : (isMedium ? 2 : 3);
                        final itemWidth =
                            (constraints.maxWidth - (18 * (columns - 1))) /
                            columns;

                        return Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: filteredPubs.map((pub) {
                            return SizedBox(
                              width: itemWidth,
                              child: _buildPublicationCard(pub),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPublicationCard(Publication pub) {
    final dateStr = DateFormat(
      'dd MMM yyyy',
      'fr_FR',
    ).format(pub.publishedDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image or Placeholder
          if (pub.imageUrl != null && pub.imageUrl!.isNotEmpty)
            SizedBox(
              height: 170,
              width: double.infinity,
              child:
                  pub.imageUrl!.startsWith('http://') ||
                      pub.imageUrl!.startsWith('https://')
                  ? Image.network(
                      pub.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildCardImagePlaceholder(pub),
                    )
                  : Image.asset(
                      pub.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildCardImagePlaceholder(pub),
                    ),
            )
          else
            _buildCardImagePlaceholder(pub),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pub.category,
                        style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  pub.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  pub.summary,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pub.author,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openPublicationDetail(pub),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Lire l’article'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentBlue,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardImagePlaceholder(Publication pub) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C2C4D), Color(0xFF1E5285)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 48,
          color: AppTheme.accentCyan.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
