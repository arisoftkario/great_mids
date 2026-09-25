import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/publication_model.dart';
import '../models/offer_model.dart';
import '../models/activity_model.dart';

class AppDataService extends ChangeNotifier {
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;
  AppDataService._internal();

  List<Publication> _publications = [];
  List<Offer> _offers = [];
  String _whatsAppNumber = AppConstants.whatsAppNumber;
  bool _isInitialized = false;

  List<Publication> get publications => List.unmodifiable(_publications);
  List<Offer> get offers => List.unmodifiable(_offers);
  String get whatsAppNumber => _whatsAppNumber;
  bool get isInitialized => _isInitialized;

  List<Publication> get publishedPublications =>
      _publications.where((p) => p.isPublished).toList()
        ..sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

  List<Offer> get activeOffers =>
      _offers.where((o) => o.isActive).toList()
        ..sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

  static const String _publicationsKey = 'gm_publications_data_v1';
  static const String _offersKey = 'gm_offers_data_v1';
  static const String _whatsAppKey = 'gm_whatsapp_number_v1';

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // WhatsApp Number
      _whatsAppNumber = prefs.getString(_whatsAppKey) ?? AppConstants.whatsAppNumber;

      // Publications
      final pubJson = prefs.getString(_publicationsKey);
      if (pubJson != null && pubJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(pubJson);
        _publications = decoded.map((item) => Publication.fromJson(item)).toList();
      } else {
        _publications = _getDefaultPublications();
        await _savePublications();
      }

      // Offers
      final offerJson = prefs.getString(_offersKey);
      if (offerJson != null && offerJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(offerJson);
        _offers = decoded.map((item) => Offer.fromJson(item)).toList();
      } else {
        _offers = _getDefaultOffers();
        await _saveOffers();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading AppDataService: $e');
      _publications = _getDefaultPublications();
      _offers = _getDefaultOffers();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // --- Publications CRUD ---
  Future<void> addPublication(Publication publication) async {
    _publications.insert(0, publication);
    await _savePublications();
    notifyListeners();
  }

  Future<void> updatePublication(Publication updated) async {
    final index = _publications.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _publications[index] = updated;
      await _savePublications();
      notifyListeners();
    }
  }

  Future<void> deletePublication(String id) async {
    _publications.removeWhere((p) => p.id == id);
    await _savePublications();
    notifyListeners();
  }

  Future<void> incrementPublicationViews(String id) async {
    final index = _publications.indexWhere((p) => p.id == id);
    if (index != -1) {
      final pub = _publications[index];
      _publications[index] = pub.copyWith(viewsCount: pub.viewsCount + 1);
      await _savePublications();
      notifyListeners();
    }
  }

  // --- Offers CRUD ---
  Future<void> addOffer(Offer offer) async {
    _offers.insert(0, offer);
    await _saveOffers();
    notifyListeners();
  }

  Future<void> updateOffer(Offer updated) async {
    final index = _offers.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      _offers[index] = updated;
      await _saveOffers();
      notifyListeners();
    }
  }

  Future<void> toggleOfferStatus(String id) async {
    final index = _offers.indexWhere((o) => o.id == id);
    if (index != -1) {
      final offer = _offers[index];
      _offers[index] = offer.copyWith(isActive: !offer.isActive);
      await _saveOffers();
      notifyListeners();
    }
  }

  Future<void> deleteOffer(String id) async {
    _offers.removeWhere((o) => o.id == id);
    await _saveOffers();
    notifyListeners();
  }

  // --- WhatsApp & Config ---
  Future<void> setWhatsAppNumber(String number) async {
    _whatsAppNumber = number.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_whatsKey, _whatsAppNumber);
    } catch (e) {
      debugPrint('Error saving whatsapp: $e');
    }
    notifyListeners();
  }

  static const String _whatsKey = 'gm_whatsapp_number_v1';

  Future<void> resetToDemoData() async {
    _publications = _getDefaultPublications();
    _offers = _getDefaultOffers();
    _whatsAppNumber = AppConstants.whatsAppNumber;
    await _savePublications();
    await _saveOffers();
    notifyListeners();
  }

  // --- Persistence helpers ---
  Future<void> _savePublications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_publications.map((p) => p.toJson()).toList());
      await prefs.setString(_publicationsKey, encoded);
    } catch (e) {
      debugPrint('Error saving publications: $e');
    }
  }

  Future<void> _saveOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_offers.map((o) => o.toJson()).toList());
      await prefs.setString(_offersKey, encoded);
    } catch (e) {
      debugPrint('Error saving offers: $e');
    }
  }

  // --- Preloaded Initial Professional Data ---
  List<Publication> _getDefaultPublications() {
    return [
      Publication(
        id: 'pub_1',
        title: 'Lancement du Programme d’Accélération Professionnelle 2026',
        category: 'Actualité',
        summary: 'GREAT MINDS GROUP ouvre les candidatures pour son nouveau cycle intensif de formation et de placement pour 150 jeunes.',
        content: '''GREAT MINDS GROUP franchit une nouvelle étape dans son engagement pour l'employabilité des jeunes talents.\n\nCe programme intensif de 3 mois combine :\n• Des modules pratiques en compétences clés et leadership professionnel\n• Du coaching individuel avec des mentors issus du monde de l'entreprise\n• Un accompagnement sur-mesure pour l'accès à des stages et opportunités d'emploi.\n\nLes inscriptions sont ouvertes dès aujourd'hui. Contactez nos conseillers pour réserver votre place.''',
        author: 'Direction des Programmes GM',
        imageUrl: 'assets/Wh.jpeg',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        isPublished: true,
        tags: ['Formation', 'Emploi', 'Jeunesse', 'Insertion'],
        viewsCount: 342,
      ),
      Publication(
        id: 'pub_2',
        title: 'GM Texa : Simplification des démarches Visa et Titres de Voyage',
        category: 'Conseil',
        summary: 'Découvrez notre guide exclusif et notre service d’audit personnalisé pour optimiser vos dossiers de visa.',
        content: '''Préparer un voyage d'affaires, d'études ou de vacances nécessite une rigueur documentaire exemplaire.\n\nLe département GM Texa met à votre disposition un service d'accompagnement complet :\n1. Analyse préalable de l'éligibilité et audit des pièces justificatives\n2. Prise de rendez-vous et suivi des dossiers consulaires\n3. Conseils personnalisés pour maximiser les chances d'acceptation.\n\nPrenez contact avec nos experts pour un entretien préalable.''',
        author: 'Équipe GM Texa',
        publishedDate: DateTime.now().subtract(const Duration(days: 6)),
        isPublished: true,
        tags: ['Voyage', 'Visa', 'Passeport', 'Accompagnement'],
        viewsCount: 215,
      ),
      Publication(
        id: 'pub_3',
        title: 'Arrivée de la Nouvelle Collection GM Parfum Prestige',
        category: 'Opportunité',
        summary: 'Une gamme de fragrances haut de gamme sélectionnées pour l’élégance quotidienne et les grandes occasions.',
        content: '''GM Parfum a le plaisir de dévoiler sa nouvelle sélection exclusive de fragrances raffinées.\n\nDisponibles dès maintenant en coffrets cadeaux et formats personnalisés avec livraison rapide.\nCommandez directement via notre service WhatsApp dédié pour bénéficier des tarifs préférentiels de lancement.''',
        author: 'Département GM Parfum',
        imageUrl: 'assets/Imag.jpeg',
        publishedDate: DateTime.now().subtract(const Duration(days: 10)),
        isPublished: true,
        tags: ['Parfum', 'Prestige', 'Luxe', 'Catalogue'],
        viewsCount: 489,
      ),
      Publication(
        id: 'pub_4',
        title: 'Partenariat Stratégique avec les Acteurs Économiques Locaux',
        category: 'Communiqué',
        summary: 'Signature de conventions pour faciliter l’intégration directe de nos diplômés au sein des entreprises partenaires.',
        content: '''Dans le cadre de son plan de développement, GREAT MINDS GROUP a officialisé 5 nouveaux partenariats avec des leaders industriels et commerciaux.\n\nCes accords prévoient l'accueil régulier de nos stagiaires et l'ouverture de postes dédiés pour les profils qualifiés formés par GM GROUP.''',
        author: 'Direction Générale',
        publishedDate: DateTime.now().subtract(const Duration(days: 15)),
        isPublished: true,
        tags: ['Partenariats', 'Entreprises', 'Économie'],
        viewsCount: 178,
      ),
    ];
  }

  List<Offer> _getDefaultOffers() {
    return [
      Offer(
        id: 'off_1',
        title: 'Chargé(e) de Relations Clients & Vente',
        department: 'GM Formation & Emploi',
        type: 'Emploi',
        location: 'Kinshasa (Gombe)',
        salaryOrPrice: 'Selon profil + Primes',
        description: 'Nous recrutons pour le compte d’une entreprise partenaire un(e) chargé(e) de clientèle dynamique pour le suivi des comptes clés.',
        requirements: [
          'Diplôme Bac+2 minimum en Gestion, Marketing ou équivalent',
          'Excellente expression orale et écrite en Français',
          'Sens du service client et aisance relationnelle',
          'Maîtrise des outils bureautiques',
        ],
        deadline: DateTime.now().add(const Duration(days: 20)),
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        isUrgent: true,
      ),
      Offer(
        id: 'off_2',
        title: 'Formation Certifiante en Bureautique & Outils Numériques',
        department: 'GM Fondation',
        type: 'Formation',
        location: 'Centre GM Kinshasa / En présentiel',
        salaryOrPrice: 'Bourse de 50% disponible',
        description: 'Session intensive de 4 semaines pour maîtriser Excel avancé, gestion de projets digitaux et communication professionnelle.',
        requirements: [
          'Jeunes diplômés ou chercheurs d’emploi',
          'Motivation et assiduité requises',
          'Certificat délivré en fin de parcours',
        ],
        deadline: DateTime.now().add(const Duration(days: 14)),
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
        isUrgent: false,
      ),
      Offer(
        id: 'off_3',
        title: 'Offre Spéciale Coffrets Parfums Découverte',
        department: 'GM Parfum',
        type: 'Promotion',
        location: 'Livraison disponible à Kinshasa',
        salaryOrPrice: 'À partir de 45 \$',
        description: 'Profitez d’une réduction exclusive de 20% sur nos coffrets de 3 fragrances de luxe sélectionnées par GM Parfum.',
        requirements: [
          'Offre valable dans la limite des stocks disponibles',
          'Commande directe via WhatsApp avec livraison express',
        ],
        deadline: DateTime.now().add(const Duration(days: 30)),
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
        isUrgent: false,
      ),
      Offer(
        id: 'off_4',
        title: 'Diagnostic Automobile & Devis Pièces Détachées',
        department: 'GM Autosolution',
        type: 'Promotion',
        location: 'Kinshasa / Sur rendez-vous',
        salaryOrPrice: 'Devis gratuit sous 24h',
        description: 'Fourniture certifiée de pièces mécaniques et électroniques d’origine pour véhicules toutes marques.',
        requirements: [
          'Envoyez la référence de votre véhicule ou carte grise sur WhatsApp',
          'Livraison rapide et garantie de conformité',
        ],
        deadline: DateTime.now().add(const Duration(days: 45)),
        publishedDate: DateTime.now().subtract(const Duration(days: 8)),
        isActive: true,
        isUrgent: false,
      ),
      Offer(
        id: 'off_5',
        title: 'Stage Professionnel en Administration & Logistique',
        department: 'GM Texa',
        type: 'Stage',
        location: 'Kinshasa',
        salaryOrPrice: 'Indemnité de stage incluse',
        description: 'Opportunité de stage pratique de 3 à 6 mois au sein du pôle administratif et assistance voyage de GM Texa.',
        requirements: [
          'Étudiant en fin de cycle ou jeune diplômé',
          'Rigueur administrative, organisation et ponctualité',
          'Possibilité d’embauche post-stage',
        ],
        deadline: DateTime.now().add(const Duration(days: 12)),
        publishedDate: DateTime.now().subtract(const Duration(days: 4)),
        isActive: true,
        isUrgent: true,
      ),
    ];
  }

  // --- Static Activities list (univers) ---
  static List<BusinessActivity> get activities => [
    const BusinessActivity(
      id: 'parfum',
      title: 'GM Parfum',
      description: 'Une sélection raffinée de parfums disponibles sur commande en ligne.',
      imageAsset: 'assets/Imag.jpeg',
      fallbackIcon: Icons.local_florist_rounded,
      actionLabel: 'Passer commande',
      requestMessage: 'passer une commande de parfum',
      offerings: [
        DepartmentOffering(
          icon: Icons.spa_rounded,
          title: 'Parfums signature',
          description: 'Des fragrances sélectionnées pour offrir ou se démarquer.',
        ),
        DepartmentOffering(
          icon: Icons.card_giftcard_rounded,
          title: 'Coffrets cadeaux',
          description: 'Des compositions élégantes pour chaque occasion.',
        ),
        DepartmentOffering(
          icon: Icons.local_shipping_rounded,
          title: 'Commande accompagnée',
          description: 'Une prise de commande simple via WhatsApp.',
        ),
      ],
    ),
    const BusinessActivity(
      id: 'texa',
      title: 'GM Texa — Visa & passeport',
      description: 'Un accompagnement rigoureux pour préparer vos démarches de voyage.',
      fallbackIcon: Icons.flight_takeoff_rounded,
      actionLabel: 'Faire une demande',
      requestMessage: 'obtenir un accompagnement pour visa et passeport',
      offerings: [
        DepartmentOffering(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Préparation du dossier',
          description: 'Liste personnalisée des pièces nécessaires à votre projet.',
        ),
        DepartmentOffering(
          icon: Icons.badge_rounded,
          title: 'Visa & passeport',
          description: 'Orientation pratique pour les démarches de voyage.',
        ),
        DepartmentOffering(
          icon: Icons.event_available_rounded,
          title: 'Suivi du projet',
          description: 'Un accompagnement clair, étape par étape.',
        ),
      ],
    ),
    const BusinessActivity(
      id: 'autosolution',
      title: 'GM Autosolution',
      description: 'Des solutions adaptées pour les véhicules, pièces et besoins automobiles.',
      imageAsset: 'assets/Image (2).jpeg',
      fallbackIcon: Icons.directions_car_filled_rounded,
      actionLabel: 'Demander un devis',
      requestMessage: 'obtenir un devis pour des pièces automobiles',
      offerings: [
        DepartmentOffering(
          icon: Icons.settings_rounded,
          title: 'Pièces automobiles',
          description: 'Recherche de pièces adaptées à votre véhicule.',
        ),
        DepartmentOffering(
          icon: Icons.car_repair_rounded,
          title: 'Conseil technique',
          description: 'Orientation vers une solution fiable selon votre besoin.',
        ),
        DepartmentOffering(
          icon: Icons.request_quote_rounded,
          title: 'Devis personnalisé',
          description: 'Une proposition claire avant toute commande.',
        ),
      ],
    ),
    const BusinessActivity(
      id: 'fondation',
      title: 'GM Fondation',
      description: 'Des opérations d’accompagnement, de formation et d’insertion pour les jeunes.',
      imageAsset: 'assets/Wh.jpeg',
      fallbackIcon: Icons.volunteer_activism_rounded,
      actionLabel: 'Nous rejoindre',
      requestMessage: 'en savoir plus sur les opérations de GM Fondation',
      offerings: [
        DepartmentOffering(
          icon: Icons.work_outline_rounded,
          title: 'Orientation emploi',
          description: 'Des repères pratiques pour avancer vers l’emploi.',
        ),
        DepartmentOffering(
          icon: Icons.school_rounded,
          title: 'Formation',
          description: 'Des parcours pour développer des compétences utiles.',
        ),
        DepartmentOffering(
          icon: Icons.groups_rounded,
          title: 'Programmes jeunesse',
          description: 'Des actions favorisant l’autonomie et l’insertion.',
        ),
      ],
    ),
  ];
}
