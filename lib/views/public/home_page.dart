import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../models/activity_model.dart';
import '../../services/app_data_service.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard_view.dart';
import '../admin/admin_login_view.dart';
import '../../models/offer_model.dart';
import '../../services/pwa_install_service.dart';
import 'widgets/offer_detail_dialog.dart';
import 'widgets/offers_section.dart';
import 'widgets/publications_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _universKey = GlobalKey();
  final GlobalKey _offersKey = GlobalKey();
  final GlobalKey _newsKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _methodKey = GlobalKey();

  Future<void> _openWhatsApp([String? message]) async {
    final whatsAppNumber = AppDataService().whatsAppNumber;
    final whatsAppUri = Uri.https('wa.me', '/$whatsAppNumber', <String, String>{
      'text': message ??
          'Bonjour GREAT MINDS GROUP, je souhaite obtenir plus d’informations.',
    });

    if (!await launchUrl(whatsAppUri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      _showMessage(
        'Impossible d’ouvrir WhatsApp. Contactez-nous au +$whatsAppNumber.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openAdminPortal() {
    if (AuthService().isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const AdminDashboardView(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const AdminLoginView(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PwaInstallService.promptInstall(context),
        backgroundColor: const Color(0xFFE5A93C),
        foregroundColor: Colors.black,
        elevation: 6,
        icon: const Icon(Icons.install_mobile_rounded, size: 20),
        label: const Text(
          'Installer l\'App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 1. Hero & Navigation
            _HeroSection(
              onExplore: () => _scrollToKey(_servicesKey),
              onContact: _openWhatsApp,
              onNavigate: (section) {
                switch (section) {
                  case 'services':
                    _scrollToKey(_servicesKey);
                    break;
                  case 'univers':
                    _scrollToKey(_universKey);
                    break;
                  case 'offers':
                    _scrollToKey(_offersKey);
                    break;
                  case 'news':
                    _scrollToKey(_newsKey);
                    break;
                  case 'about':
                    _scrollToKey(_aboutKey);
                    break;
                  case 'method':
                    _scrollToKey(_methodKey);
                    break;
                }
              },
              onAdminPortal: _openAdminPortal,
            ),

            // 2. Stats
            const _StatsSection(),

            // 3. Services
            Container(key: _servicesKey, child: const _ServicesSection()),

            // 4. Univers / Activities
            Container(
              key: _universKey,
              child: _BusinessActivitiesSection(
                onOrder: (activity) => _openWhatsApp(
                  'Bonjour GREAT MINDS GROUP, je souhaite ${activity.requestMessage}.',
                ),
                onVisit: (activity) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => _DepartmentPage(
                      activity: activity,
                      onContact: () => _openWhatsApp(
                        'Bonjour GREAT MINDS GROUP, je souhaite ${activity.requestMessage}.',
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. Dynamic Offers Section
            Container(key: _offersKey, child: const OffersSection()),

            // 6. Dynamic Publications & News Section
            Container(key: _newsKey, child: const PublicationsSection()),

            // 7. About
            Container(key: _aboutKey, child: const _AboutSection()),

            // 8. Process / Method
            Container(key: _methodKey, child: const _ProcessSection()),

            // 9. CTA
            _CTASection(onContact: _openWhatsApp),

            // 10. Footer
            _Footer(
              onContact: _openWhatsApp,
              onAdminPortal: _openAdminPortal,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HERO & NAVIGATION
// ==========================================
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onExplore,
    required this.onContact,
    required this.onNavigate,
    required this.onAdminPortal,
  });

  final VoidCallback onExplore;
  final VoidCallback onContact;
  final ValueChanged<String> onNavigate;
  final VoidCallback onAdminPortal;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 720),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF061A2E), Color(0xFF0B2F4F), Color(0xFF113C62)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _Navigation(
                  onContact: onContact,
                  onNavigate: onNavigate,
                  onAdminPortal: onAdminPortal,
                ),
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 760;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                      child: compact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _heroContent(onExplore, onContact, onAdminPortal, compact: true),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _heroContent(onExplore, onContact, onAdminPortal),
                                  ),
                                ),
                                const SizedBox(width: 28),
                                const _BusinessVisual(),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _heroContent(
    VoidCallback onExplore,
    VoidCallback onContact,
    VoidCallback onAdminPortal, {
    bool compact = false,
  }) => [
    const _HeroLogo(),
    const SizedBox(height: 26),
    const Text(
      'GREAT MINDS\nGROUP',
      style: TextStyle(
        fontSize: 58,
        fontWeight: FontWeight.w800,
        color: Color(0xFFF5FAFF),
        height: 0.95,
        letterSpacing: -2,
      ),
    ),
    const SizedBox(height: 18),
    const Text(
      'GM GROUP',
      style: TextStyle(
        color: Color(0xFF8FD6FF),
        fontSize: 18,
        letterSpacing: 4,
        fontWeight: FontWeight.w800,
      ),
    ),
    const SizedBox(height: 22),
    SizedBox(
      width: compact ? double.infinity : 480,
      child: const Text(
        'Des solutions concrètes pour la formation, l’insertion professionnelle, l’accompagnement et la création d’opportunités durables pour les jeunes et les organisations.',
        style: TextStyle(color: Color(0xFFD7E7F7), fontSize: 17, height: 1.6),
      ),
    ),
    const SizedBox(height: 28),
    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _Pill(label: 'Formation & Emploi'),
        _Pill(label: 'GM Parfum'),
        _Pill(label: 'GM Texa (Visa)'),
        _Pill(label: 'GM Autosolution'),
        _Pill(label: 'GM Fondation'),
      ],
    ),
    const SizedBox(height: 34),
    Wrap(
      spacing: 14,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onContact,
          icon: const Icon(Icons.chat_rounded, size: 18),
          label: const Text('Écrire sur WhatsApp'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF59D6B6),
            foregroundColor: const Color(0xFF061A2E),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onExplore,
          icon: const Icon(Icons.arrow_downward_rounded, size: 18),
          label: const Text('Découvrir les offres'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFB7D9F1)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          ),
        ),
      ],
    ),
  ];
}

class _Navigation extends StatelessWidget {
  const _Navigation({
    required this.onContact,
    required this.onNavigate,
    required this.onAdminPortal,
  });

  final VoidCallback onContact;
  final ValueChanged<String> onNavigate;
  final VoidCallback onAdminPortal;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const _Brand(),
          const Spacer(),
          if (width > 860) ...[
            TextButton(onPressed: () => onNavigate('services'), child: const Text('Services', style: TextStyle(color: Colors.white70))),
            TextButton(onPressed: () => onNavigate('univers'), child: const Text('Univers GM', style: TextStyle(color: Colors.white70))),
            TextButton(onPressed: () => onNavigate('offers'), child: const Text('Offres & Emploi', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w700))),
            TextButton(onPressed: () => onNavigate('news'), child: const Text('Actualités', style: TextStyle(color: Colors.white70))),
            TextButton(onPressed: () => onNavigate('about'), child: const Text('À propos', style: TextStyle(color: Colors.white70))),
          ],
          const SizedBox(width: 8),
          // Install App Button
          ElevatedButton.icon(
            onPressed: () => PwaInstallService.promptInstall(context),
            icon: const Icon(Icons.install_mobile_rounded, size: 16),
            label: const Text('Installer l\'App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5A93C),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          // Admin Access Button
          IconButton(
            onPressed: onAdminPortal,
            tooltip: 'Espace Administrateur',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: AppTheme.accentCyan,
            ),
            icon: const Icon(Icons.admin_panel_settings_rounded, size: 20),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onContact,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF59D6B6)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            child: const Text('Contact WhatsApp'),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF59D6B6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.business_center_rounded,
              color: Color(0xFF061A2E),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GREAT MINDS',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Colors.white,
              ),
            ),
            Text(
              'GROUP',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.2,
                color: Color(0xFF8FD6FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroLogo extends StatelessWidget {
  const _HeroLogo();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo GREAT MINDS GROUP',
      child: Container(
        width: 122,
        height: 122,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF6FE8CB), Color(0xFF3A9BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFC9F6EA), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/Image.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const _HeroLogoFallback(),
          ),
        ),
      ),
    );
  }
}

class _HeroLogoFallback extends StatelessWidget {
  const _HeroLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.auto_awesome_rounded, color: Color(0xCC061A2E), size: 84),
        Container(
          width: 82,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF061A2E).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'GM',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF123B58),
        border: Border.all(color: const Color(0xFF87B9DE)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF2F9FF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BusinessVisual extends StatelessWidget {
  const _BusinessVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFF153D61),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF96CAEA), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 28,
            left: 24,
            right: 24,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF59D6B6), Color(0xFF3A9BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Center(
                child: Icon(
                  Icons.insights_rounded,
                  size: 82,
                  color: Color(0xFF061A2E),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 28,
            right: 28,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vision & résultats',
                    style: TextStyle(color: Color(0xFFF3F9FF), fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Un modèle qui transforme des ambitions en trajectoires concrètes.',
                    style: TextStyle(color: Color(0xFFD5EAF7), height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// STATS SECTION
// ==========================================
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    const stats = [
      _Stat(number: '2000+', label: 'personnes accompagnées'),
      _Stat(number: '15+', label: 'partenaires actifs'),
      _Stat(number: '85%', label: 'taux de satisfaction'),
    ];

    return Container(
      color: const Color(0xFFF4F8FC),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 18,
            children: stats.map((s) => SizedBox(width: 300, child: s)).toList(),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBF4)),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFF061A2E),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5A6E82),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SERVICES SECTION
// ==========================================
class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    const items = [
      _ServiceCard(
        icon: Icons.work_history_rounded,
        title: 'Insertion professionnelle',
        description: 'Accompagnement des jeunes vers des opportunités réelles, des missions et des emplois durables.',
      ),
      _ServiceCard(
        icon: Icons.auto_stories_rounded,
        title: 'Formation & montée en compétences',
        description: 'Programmes orientés métier pour développer les compétences utiles au marché du travail.',
      ),
      _ServiceCard(
        icon: Icons.support_agent_rounded,
        title: 'Conseil & accompagnement',
        description: 'Un suivi personnalisé, de la préparation au placement, avec un regard stratégique.',
      ),
    ];

    return Container(
      color: const Color(0xFFF9FBFF),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NOS SERVICES',
                style: TextStyle(
                  color: Color(0xFF1B7AE6),
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Les services de la réussite.',
                style: TextStyle(
                  color: Color(0xFF061A2E),
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 820;
                  final cards = items
                      .map(
                        (item) => compact
                            ? Container(margin: const EdgeInsets.only(bottom: 18), child: item)
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 18),
                                  child: item,
                                ),
                              ),
                      )
                      .toList();
                  return compact ? Column(children: cards) : Row(children: cards);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1ECF7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF1B7AE6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF0D335B), size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF061A2E),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF536D84), height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// BUSINESS ACTIVITIES (UNIVERS GM)
// ==========================================
class _BusinessActivitiesSection extends StatelessWidget {
  const _BusinessActivitiesSection({
    required this.onOrder,
    required this.onVisit,
  });

  final ValueChanged<BusinessActivity> onOrder;
  final ValueChanged<BusinessActivity> onVisit;

  @override
  Widget build(BuildContext context) {
    final activities = AppDataService.activities;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NOS UNIVERS',
                style: TextStyle(
                  color: Color(0xFF1B7AE6),
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Des activités pensées pour vos projets.',
                style: TextStyle(
                  color: Color(0xFF061A2E),
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'GREAT MINDS GROUP réunit des services spécialisés pour répondre à des besoins concrets.',
                style: TextStyle(
                  color: Color(0xFF536D84),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 820;
                  if (compact) {
                    return Column(
                      children: activities
                          .map(
                            (activity) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _BusinessActivityCard(
                                activity: activity,
                                onOrder: () => onOrder(activity),
                                onVisit: () => onVisit(activity),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: activities
                        .map(
                          (activity) => SizedBox(
                            width: (constraints.maxWidth - 18) / 2,
                            child: _BusinessActivityCard(
                              activity: activity,
                              onOrder: () => onOrder(activity),
                              onVisit: () => onVisit(activity),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessActivityCard extends StatelessWidget {
  const _BusinessActivityCard({
    required this.activity,
    required this.onOrder,
    required this.onVisit,
  });

  final BusinessActivity activity;
  final VoidCallback onOrder;
  final VoidCallback onVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1ECF7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            image: true,
            label: activity.title,
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: activity.imageAsset == null
                  ? _ActivityImageFallback(icon: activity.fallbackIcon)
                  : Image.asset(
                      activity.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _ActivityImageFallback(icon: activity.fallbackIcon),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Color(0xFF061A2E),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  activity.description,
                  style: const TextStyle(color: Color(0xFF536D84), height: 1.6),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: onOrder,
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: Text(activity.actionLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3153),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onVisit,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Visiter le département'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF073454),
                        backgroundColor: const Color(0xFF59D6B6),
                        side: const BorderSide(color: Color(0xFF073454), width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
}

class _ActivityImageFallback extends StatelessWidget {
  const _ActivityImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C3153),
      alignment: Alignment.center,
      child: Icon(icon, color: const Color(0xFF59D6B6), size: 64),
    );
  }
}

// ==========================================
// DEPARTMENT PAGE
// ==========================================
class _DepartmentPage extends StatelessWidget {
  const _DepartmentPage({required this.activity, required this.onContact});

  final BusinessActivity activity;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFF061A2E),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 68),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Retour à GREAT MINDS GROUP'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFB9DDF5)),
                        ),
                        const SizedBox(height: 42),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 700;
                            final identity = _DepartmentIdentity(activity: activity);
                            final details = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DÉPARTEMENT GREAT MINDS GROUP',
                                  style: TextStyle(
                                    color: Color(0xFF59D6B6),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.8,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'L’univers ${activity.title}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 42,
                                    height: 1.08,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  activity.description,
                                  style: const TextStyle(color: Color(0xFFD7E7F7), height: 1.6, fontSize: 17),
                                ),
                                const SizedBox(height: 26),
                                FilledButton.icon(
                                  onPressed: onContact,
                                  icon: const Icon(Icons.chat_rounded),
                                  label: Text(activity.actionLabel),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF59D6B6),
                                    foregroundColor: const Color(0xFF061A2E),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                                  ),
                                ),
                              ],
                            );
                            return compact
                                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [identity, const SizedBox(height: 30), details])
                                : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [identity, const SizedBox(width: 44), Expanded(child: details)]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Dynamic Products & Opportunities Section for this department
              ListenableBuilder(
                listenable: AppDataService(),
                builder: (context, _) {
                  final offers = AppDataService().activeOffers.where((offer) {
                    final dept = offer.department.toLowerCase();
                    final actId = activity.id.toLowerCase();
                    if (actId == 'parfum') return dept.contains('parfum');
                    if (actId == 'texa') return dept.contains('texa') || dept.contains('visa') || dept.contains('passeport');
                    if (actId == 'autosolution') return dept.contains('auto');
                    if (actId == 'fondation') return dept.contains('fondation');
                    if (actId == 'emploi') return dept.contains('emploi') || dept.contains('formation');
                    return dept.contains(actId) || activity.title.toLowerCase().contains(dept);
                  }).toList();

                  if (offers.isEmpty) return const SizedBox.shrink();

                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PRODUITS & OPPORTUNITÉS DISPONIBLES',
                                      style: TextStyle(
                                        color: Color(0xFF1B7AE6),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.8,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Catalogue & offres de ${activity.title}',
                                      style: const TextStyle(
                                        color: Color(0xFF061A2E),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B7AE6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${offers.length} active(s)',
                                    style: const TextStyle(
                                      color: Color(0xFF1B7AE6),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final compact = constraints.maxWidth < 760;
                                return Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: offers.map((offer) {
                                    return SizedBox(
                                      width: compact ? double.infinity : (constraints.maxWidth - 20) / 2,
                                      child: _DepartmentProductCard(
                                        offer: offer,
                                        activity: activity,
                                      ),
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
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 78),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CE QUE VOUS TROUVEREZ',
                          style: TextStyle(color: Color(0xFF1B7AE6), fontWeight: FontWeight.w800, letterSpacing: 1.8, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Des exemples d’offres pour votre projet.',
                          style: TextStyle(color: Color(0xFF061A2E), fontSize: 34, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        const SizedBox(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 760;
                            final cards = activity.offerings.map((offering) => _DepartmentOfferingCard(offering: offering)).toList();
                            return compact
                                ? Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 16), child: card)).toList())
                                : Row(children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: card))).toList());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentProductCard extends StatelessWidget {
  const _DepartmentProductCard({
    required this.offer,
    required this.activity,
  });

  final Offer offer;
  final BusinessActivity activity;

  Future<void> _orderViaWhatsApp(BuildContext context) async {
    final whatsAppNumber = offer.customContactWhatsApp ?? AppDataService().whatsAppNumber;
    final message = 'Bonjour GREAT MINDS GROUP, je souhaite commander / souscrire à "${offer.title}" (${offer.department} - Réf: ${offer.id}).';
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
    Color typeBg = const Color(0xFFE8F1FF);
    Color typeColor = const Color(0xFF1B7AE6);

    switch (offer.type) {
      case 'Promotion':
        typeBg = const Color(0xFFFFF0F5);
        typeColor = const Color(0xFFD63384);
        break;
      case 'Emploi':
        typeBg = const Color(0xFFE6F8F2);
        typeColor = const Color(0xFF0D9488);
        break;
      case 'Stage':
        typeBg = const Color(0xFFFFF8E6);
        typeColor = const Color(0xFFD97706);
        break;
      case 'Formation':
        typeBg = const Color(0xFFF3E8FF);
        typeColor = const Color(0xFF7C3AED);
        break;
      case 'Partenariat':
        typeBg = const Color(0xFFECFDF5);
        typeColor = const Color(0xFF059669);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E7F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offer.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (offer.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 13, color: Colors.red),
                      SizedBox(width: 3),
                      Text(
                        'VEDETTE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offer.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          if (offer.salaryOrPrice != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF59D6B6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                offer.salaryOrPrice!,
                style: const TextStyle(
                  color: Color(0xFF095A48),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            offer.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          if (offer.requirements.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: offer.requirements.take(2).map((req) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF1B7AE6)),
                      const SizedBox(width: 4),
                      Text(
                        req.length > 35 ? '${req.substring(0, 32)}...' : req,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4A657E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(height: 1, color: Color(0xFFE8EFF6)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => OfferDetailDialog(offer: offer),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF061A2E),
                    side: const BorderSide(color: Color(0xFFB5CDE4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Fiche détaillée', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _orderViaWhatsApp(context),
                  icon: const Icon(Icons.shopping_bag_rounded, size: 15),
                  label: const Text('Commander', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1B7AE6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DepartmentIdentity extends StatelessWidget {
  const _DepartmentIdentity({required this.activity});

  final BusinessActivity activity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo ${activity.title}',
      child: Container(
        width: 190,
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF0C3153),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF59D6B6), width: 2),
        ),
        child: activity.imageAsset == null
            ? _ActivityImageFallback(icon: activity.fallbackIcon)
            : Image.asset(
                activity.imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _ActivityImageFallback(icon: activity.fallbackIcon),
              ),
      ),
    );
  }
}

class _DepartmentOfferingCard extends StatelessWidget {
  const _DepartmentOfferingCard({required this.offering});

  final DepartmentOffering offering;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1ECF7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(offering.icon, color: const Color(0xFF1B7AE6), size: 32),
          const Spacer(),
          Text(offering.title, style: const TextStyle(color: Color(0xFF061A2E), fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(offering.description, style: const TextStyle(color: Color(0xFF536D84), height: 1.5)),
        ],
      ),
    );
  }
}

// ==========================================
// ABOUT SECTION
// ==========================================
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C1F35),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final textBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À PROPOS',
                    style: TextStyle(color: Color(0xFF59D6B6), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Une plateforme pour créer des opportunités de vie.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 36 : 46,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'GREAT MINDS GROUP accompagne les jeunes et les organisations dans l’accès à l’emploi, la formation, l’autonomie professionnelle et la construction d’un avenir solide.',
                    style: TextStyle(color: Color(0xFFCBDCEB), height: 1.7, fontSize: 17),
                  ),
                  const SizedBox(height: 24),
                  const _AboutList(),
                ],
              );

              if (compact) {
                return textBlock;
              }

              return Row(
                children: [
                  Expanded(child: textBlock),
                  const SizedBox(width: 28),
                  Container(
                    width: 320,
                    height: 360,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF59D6B6), Color(0xFF1B7AE6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: Icon(Icons.groups_2_rounded, size: 100, color: Color(0xFF061A2E)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AboutList extends StatelessWidget {
  const _AboutList();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Consulting stratégique et accompagnement humain',
      'Création de parcours professionnels adaptés',
      'Valorisation des talents et des potentialités',
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF59D6B6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(color: Color(0xFFEAF7FF), height: 1.6)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ==========================================
// PROCESS SECTION
// ==========================================
class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('01', 'Écoute', 'Nous identifions les besoins, la situation et les objectifs visés.'),
      ('02', 'Plan d’action', 'Nous construisons un parcours clair, pratique et réaliste.'),
      ('03', 'Suivi & impact', 'Nous accompagnons jusqu’à l’insertion, la stabilisation et la réussite.'),
    ];

    return Container(
      color: const Color(0xFFF4F8FC),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NOTRE MÉTHODE',
                style: TextStyle(color: Color(0xFF1B7AE6), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              const Text(
                'Un accompagnement pensé pour aller loin.',
                style: TextStyle(color: Color(0xFF061A2E), fontSize: 42, fontWeight: FontWeight.w800, height: 1.05),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 820;
                  return compact
                      ? Column(
                          children: steps
                              .map((step) => Padding(padding: const EdgeInsets.only(bottom: 18), child: _StepCard(step: step)))
                              .toList(),
                        )
                      : Row(
                          children: steps
                              .map((step) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 18), child: _StepCard(step: step))))
                              .toList(),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final (String, String, String) step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1ECF7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.$1, style: const TextStyle(color: Color(0xFF1B7AE6), fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Text(step.$2, style: const TextStyle(color: Color(0xFF061A2E), fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(step.$3, style: const TextStyle(color: Color(0xFF536D84), height: 1.6)),
        ],
      ),
    );
  }
}

// ==========================================
// CTA SECTION
// ==========================================
class _CTASection extends StatelessWidget {
  const _CTASection({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF59D6B6),
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              const text = Text(
                'Votre avenir mérite une vraie opportunité.',
                style: TextStyle(color: Color(0xFF061A2E), fontSize: 42, fontWeight: FontWeight.w800, height: 1.1),
              );
              final button = FilledButton(
                onPressed: onContact,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF061A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                ),
                child: const Text('Discutons sur WhatsApp'),
              );
              return compact
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 24), button])
                  : Row(children: [const Expanded(child: text), button]);
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================
// FOOTER
// ==========================================
class _Footer extends StatelessWidget {
  const _Footer({required this.onContact, required this.onAdminPortal});

  final VoidCallback onContact;
  final VoidCallback onAdminPortal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061A2E),
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _Brand(),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => PwaInstallService.promptInstall(context),
                    icon: const Icon(Icons.install_mobile_rounded, size: 16, color: Color(0xFFE5A93C)),
                    label: const Text(
                      'Installer l\'App',
                      style: TextStyle(color: Color(0xFFE5A93C), fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  TextButton.icon(
                    onPressed: onAdminPortal,
                    icon: const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF8FBCE4)),
                    label: const Text(
                      'Accès Espace Admin',
                      style: TextStyle(color: Color(0xFF8FBCE4), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 14),
                  TextButton(
                    onPressed: onContact,
                    child: const Text(
                      'Contact Direct',
                      style: TextStyle(color: Color(0xFF59D6B6), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Divider(color: Color(0xFF1B3A5E)),
              const SizedBox(height: 18),
              Text(
                'WhatsApp : +${AppDataService().whatsAppNumber}',
                style: const TextStyle(color: Color(0xFF59D6B6), fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                '© 2026 GREAT MINDS GROUP — Accompagnement, insertion, formation et impact social.',
                style: TextStyle(color: Color(0xFFD9E8F8), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
