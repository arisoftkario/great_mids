import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/publication_model.dart';

class PublicationFormDialog extends StatefulWidget {
  final Publication? publication;

  const PublicationFormDialog({super.key, this.publication});

  @override
  State<PublicationFormDialog> createState() => _PublicationFormDialogState();
}

class _PublicationFormDialogState extends State<PublicationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _authorController;
  late TextEditingController _tagsController;
  late TextEditingController _imageUrlController;

  String _selectedCategory = 'Actualité';
  bool _isPublished = true;

  final List<String> _categories = [
    'Actualité',
    'Événement',
    'Opportunité',
    'Conseil',
    'Success Story',
    'Communiqué',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.publication;
    _titleController = TextEditingController(text: p?.title ?? '');
    _summaryController = TextEditingController(text: p?.summary ?? '');
    _contentController = TextEditingController(text: p?.content ?? '');
    _authorController = TextEditingController(text: p?.author ?? 'Direction GM GROUP');
    _tagsController = TextEditingController(text: p?.tags.join(', ') ?? 'Formation, Emploi');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategory = p?.category ?? 'Actualité';
    _isPublished = p?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final newPub = Publication(
        id: widget.publication?.id ?? 'pub_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        author: _authorController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        publishedDate: widget.publication?.publishedDate ?? DateTime.now(),
        isPublished: _isPublished,
        tags: tags,
        viewsCount: widget.publication?.viewsCount ?? 0,
      );

      Navigator.of(context).pop(newPub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.publication != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.article_rounded, color: AppTheme.accentCyan, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isEdit ? 'Modifier la Publication' : 'Nouvelle Publication',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      const Text('Titre de la publication *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Lancement des nouvelles sessions de mentorat...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir un titre' : null,
                      ),
                      const SizedBox(height: 18),

                      // Catégorie & Statut
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Catégorie *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedCategory,
                                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                                  decoration: const InputDecoration(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Statut de publication', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.borderSubtle),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _isPublished ? 'En ligne' : 'Brouillon',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _isPublished ? AppTheme.successGreen : AppTheme.warningOrange,
                                        ),
                                      ),
                                      const Spacer(),
                                      Switch(
                                        value: _isPublished,
                                        activeThumbColor: AppTheme.accentCyan,
                                        onChanged: (val) => setState(() => _isPublished = val),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Auteur
                      const Text('Auteur / Département émetteur', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Direction GM GROUP, Équipe GM Texa...',
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Résumé
                      const Text('Court résumé / Extrait *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _summaryController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Une à deux phrases pour donner envie de lire...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir un résumé' : null,
                      ),
                      const SizedBox(height: 18),

                      // Contenu
                      const Text('Contenu complet de l’article *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Rédigez ici les détails, les étapes, les contacts et les modalités...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir le contenu' : null,
                      ),
                      const SizedBox(height: 18),

                      // Tags & Image URL
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mots-clés / Tags (séparés par des virgules)', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _tagsController,
                                  decoration: const InputDecoration(
                                    hintText: 'Emploi, Jeunesse, Innovation',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Image Asset / URL (optionnel)', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _imageUrlController,
                                  decoration: const InputDecoration(
                                    hintText: 'assets/Imag.jpeg ou https://...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(isEdit ? 'Mettre à jour' : 'Publier l’article'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
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
