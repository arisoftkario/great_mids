import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/offer_model.dart';
import 'package:intl/intl.dart';

class OfferFormDialog extends StatefulWidget {
  final Offer? offer;

  const OfferFormDialog({super.key, this.offer});

  @override
  State<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _salaryOrPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _requirementsController;
  late TextEditingController _whatsAppController;

  String _selectedDepartment = 'GM Formation & Emploi';
  String _selectedType = 'Emploi';
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isUrgent = false;

  final List<String> _departments = [
    'GM Formation & Emploi',
    'GM Parfum',
    'GM Texa',
    'GM Autosolution',
    'GM Fondation',
  ];

  final List<String> _types = [
    'Emploi',
    'Stage',
    'Formation',
    'Promotion',
    'Partenariat',
    'Service',
  ];

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _titleController = TextEditingController(text: o?.title ?? '');
    _locationController = TextEditingController(text: o?.location ?? 'Kinshasa (Gombe)');
    _salaryOrPriceController = TextEditingController(text: o?.salaryOrPrice ?? '');
    _descriptionController = TextEditingController(text: o?.description ?? '');
    _requirementsController = TextEditingController(text: o?.requirements.join('\n') ?? '');
    _whatsAppController = TextEditingController(text: o?.customContactWhatsApp ?? '');
    _selectedDepartment = o?.department ?? 'GM Formation & Emploi';
    _selectedType = o?.type ?? 'Emploi';
    _deadline = o?.deadline ?? DateTime.now().add(const Duration(days: 30));
    _isActive = o?.isActive ?? true;
    _isUrgent = o?.isUrgent ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _salaryOrPriceController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _whatsAppController.dispose();
    super.dispose();
  }

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final reqs = _requirementsController.text
          .split('\n')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();

      final newOffer = Offer(
        id: widget.offer?.id ?? 'off_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        department: _selectedDepartment,
        type: _selectedType,
        location: _locationController.text.trim(),
        salaryOrPrice: _salaryOrPriceController.text.trim().isEmpty ? null : _salaryOrPriceController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: reqs,
        deadline: _deadline,
        publishedDate: widget.offer?.publishedDate ?? DateTime.now(),
        isActive: _isActive,
        isUrgent: _isUrgent,
        customContactWhatsApp: _whatsAppController.text.trim().isEmpty ? null : _whatsAppController.text.trim(),
      );

      Navigator.of(context).pop(newOffer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.offer != null;
    final dateStr = DateFormat('dd/MM/yyyy').format(_deadline);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 820),
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
                    child: const Icon(Icons.work_outline_rounded, color: AppTheme.accentCyan, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isEdit ? 'Modifier l’Offre' : 'Créer une Nouvelle Offre',
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
                      const Text('Intitulé de l’offre *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Conseiller Commercial B2B, Coffret Parfum Luxe...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir un titre' : null,
                      ),
                      const SizedBox(height: 18),

                      // Département & Type
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Département / Univers *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedDepartment,
                                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedDepartment = val);
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
                                const Text('Type d’offre *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedType,
                                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedType = val);
                                  },
                                  decoration: const InputDecoration(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Localisation & Rémunération / Prix
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Localisation *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ex: Kinshasa, En ligne, À distance...',
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez indiquer le lieu' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Salaire / Tarif / Avantages', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _salaryOrPriceController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ex: À négocier, 50 \$, Gratuit...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Date limite & Statut Actif & Urgent
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date limite de candidature / validité', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickDeadline,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.borderSubtle),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accentBlue),
                                        const SizedBox(width: 10),
                                        Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                      ],
                                    ),
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
                                const Text('Options d’affichage', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    FilterChip(
                                      selected: _isActive,
                                      label: Text(_isActive ? 'Actif' : 'Désactivé'),
                                      selectedColor: AppTheme.accentCyan.withValues(alpha: 0.3),
                                      onSelected: (val) => setState(() => _isActive = val),
                                    ),
                                    const SizedBox(width: 8),
                                    FilterChip(
                                      selected: _isUrgent,
                                      label: const Text('Urgent / En vedette'),
                                      selectedColor: AppTheme.warningOrange.withValues(alpha: 0.3),
                                      onSelected: (val) => setState(() => _isUrgent = val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Description
                      const Text('Description détaillée de l’opportunité *', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Décrivez les missions, objectifs, avantages ou spécifications de l’offre...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir une description' : null,
                      ),
                      const SizedBox(height: 18),

                      // Exigences / Critères
                      const Text('Critères / Prérequis (un par ligne)', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _requirementsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Niveau d’études\nExpérience souhaitée\nCompétences requises',
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Contact WhatsApp Spécifique
                      const Text('Numéro WhatsApp dédié (laisser vide pour le numéro général GM)', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _whatsAppController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 243994673769',
                          prefixIcon: Icon(Icons.phone_iphone_rounded, color: AppTheme.accentCyan),
                        ),
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
                    label: Text(isEdit ? 'Mettre à jour' : 'Créer l’offre'),
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
