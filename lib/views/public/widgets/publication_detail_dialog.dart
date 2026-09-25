import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/publication_model.dart';
import '../../../services/app_data_service.dart';

class PublicationDetailDialog extends StatelessWidget {
  final Publication publication;

  const PublicationDetailDialog({super.key, required this.publication});

  Future<void> _shareWhatsApp(BuildContext context) async {
    final whatsAppNumber = AppDataService().whatsAppNumber;
    final message = 'Bonjour GREAT MINDS GROUP, j’ai lu votre article "${publication.title}" et j’aimerais en savoir plus.';
    final uri = Uri.https('wa.me', '/$whatsAppNumber', {'text': message});
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d’ouvrir WhatsApp. Contactez-nous au +$whatsAppNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy', 'fr_FR').format(publication.publishedDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 850),
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      publication.category,
                      style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (publication.imageUrl != null && publication.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: publication.imageUrl!.startsWith('http://') || publication.imageUrl!.startsWith('https://')
                              ? Image.network(
                                  publication.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                )
                              : Image.asset(
                                  publication.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      publication.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(publication.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(dateStr, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        const SizedBox(width: 16),
                        const Icon(Icons.remove_red_eye_outlined, size: 15, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text('${publication.viewsCount} lectures', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.borderSubtle),
                    const SizedBox(height: 20),

                    // Highlight summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: BorderSide(color: AppTheme.accentBlue, width: 4)),
                      ),
                      child: Text(
                        publication.summary,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Content Text
                    Text(
                      publication.content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2C435A),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tags
                    if (publication.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: publication.tags
                            .map(
                              (tag) => Chip(
                                label: Text('#$tag', style: const TextStyle(fontSize: 12, color: AppTheme.accentBlue, fontWeight: FontWeight.w600)),
                                backgroundColor: const Color(0xFFEAF3FB),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ],
                ),
              ),
            ),

            // Footer CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Une question sur cette publication ?',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _shareWhatsApp(context),
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('Échanger sur WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
