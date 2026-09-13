import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/onboarding_slide.dart';

/// Loads CMS slides from `onboarding_slides`, with bundled QLYP copy as fallback.
class OnboardingService {
  const OnboardingService._();

  static const collection = 'onboarding_slides';

  static List<OnboardingSlide> bundledCustomer() => const [
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_client_01.webp',
          order: 1,
          block1TitleFr: 'Bienvenue sur Qlyp',
          block1TitleEn: 'Welcome to Qlyp',
          block1TextFr:
              'Votre super plateforme de mobilité locale pour le transport : course, livraison et logistique.',
          block1TextEn:
              'Your all-in-one local mobility platform for rides, delivery, and logistics.',
          block2TitleFr: 'Réservation simple, multicanal',
          block2TitleEn: 'Simple, multi-channel booking',
          block2TextFr:
              'Réservez ou planifiez vos trajets, livraisons et déménagements en un instant, depuis l\'app Qlyp, par appel direct ou sur WhatsApp.',
          block2TextEn:
              'Book or schedule your rides, deliveries, and moves instantly — from the Qlyp app, by phone call, or on WhatsApp.',
        ),
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_client_02.webp',
          order: 2,
          block1TitleFr: 'Prenez le contrôle avec les enchères',
          block1TitleEn: 'Take control with bidding',
          block1TextFr:
              'Reprenez la main sur votre budget : proposez votre prix ou confirmez le meilleur tarif pour vous.',
          block1TextEn:
              'Take charge of your budget: offer your own price or accept the best fare for you.',
          block2TitleFr: 'Trajets et colis partagés',
          block2TitleEn: 'Shared rides and packages',
          block2TextFr:
              'Partagez votre course avec d\'autres passagers ou colis qui vont dans la même direction, et économisez à chaque trajet.',
          block2TextEn:
              'Share your ride with other passengers or packages heading the same way, and save on every trip.',
        ),
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_client_03.webp',
          order: 3,
          block1TitleFr: 'Suivi en temps réel',
          block1TitleEn: 'Real-time tracking',
          block1TextFr:
              'Suivez vos trajets et livraisons en direct, de la prise en charge jusqu\'à l\'arrivée, et partagez votre position avec vos proches.',
          block1TextEn:
              'Track your rides and deliveries live, from pickup to arrival, and share your location with loved ones.',
          block2TitleFr: 'Réservez pour vos proches',
          block2TitleEn: 'Book for someone else',
          block2TextFr:
              'Demandez une course pour un membre de votre famille, un client, un patient ou toute autre personne, même sans l\'app.',
          block2TextEn:
              'Request a ride for a family member, client, patient, or anyone else — even without the app.',
        ),
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_client_04.webp',
          order: 4,
          block1TitleFr: 'Entreprises et visiteurs',
          block1TitleEn: 'Businesses and visitors',
          block1TextFr:
              'Simplifiez la gestion des frais de déplacement et de livraison de votre organisation, et offrez à vos visiteurs des trajets sans effort depuis une borne ou un ordinateur.',
          block1TextEn:
              'Simplify travel and delivery expense management for your organization, and offer visitors effortless rides from a kiosk or computer.',
          block2TitleFr: 'Arrêts multiples et visites de ville',
          block2TitleEn: 'Multiple stops and city tours',
          block2TextFr:
              'Ajoutez plusieurs arrêts à votre trajet et faites vos courses en chemin.',
          block2TextEn:
              'Add multiple stops to your trip and run your errands along the way.',
          ctaTextFr: 'Commencer',
          ctaTextEn: 'Get Started',
        ),
      ];

  static List<OnboardingSlide> bundledDriver() => const [
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_pilote_01.webp',
          order: 1,
          block1TitleFr: 'Bienvenue sur Qlyp',
          block1TitleEn: 'Welcome to Qlyp',
          block1TextFr:
              'Votre super plateforme de mobilité locale pour le transport : course, livraison et logistique.',
          block1TextEn:
              'Your all-in-one local mobility platform for rides, delivery, and logistics.',
          block2TitleFr: 'Devenez chauffeur pro',
          block2TitleEn: 'Become a pro driver',
          block2TextFr:
              'Prêt à gagner votre vie ? Inscrivez-vous et faites-vous vérifier pour démarrer votre parcours de chauffeur professionnel.',
          block2TextEn:
              'Ready to earn a living? Sign up and get verified to start your journey as a professional driver.',
        ),
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_pilote_02.webp',
          order: 2,
          block1TitleFr: 'Travaillez à votre rythme',
          block1TitleEn: 'Work at your own pace',
          block1TextFr:
              'Acceptez des courses quand et où vous le souhaitez. Flexibilité totale, sans engagement.',
          block1TextEn:
              'Accept rides whenever and wherever you want. Total flexibility, no commitment.',
          block2TitleFr: 'Des demandes en temps réel',
          block2TitleEn: 'Real-time ride requests',
          block2TextFr:
              'Recevez une notification instantanée à chaque demande de course dans votre secteur. Définissez vos zones d\'activité.',
          block2TextEn:
              'Get an instant notification for every ride request in your area. Set your own activity zones.',
        ),
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_pilote_03.webp',
          order: 3,
          block1TitleFr: 'Maximisez vos revenus',
          block1TitleEn: 'Maximize your earnings',
          block1TextFr:
              'Suivez vos gains au quotidien en toute simplicité et planifiez votre stratégie en conséquence.',
          block1TextEn:
              'Track your daily earnings with ease and plan your strategy accordingly.',
          block2TitleFr: 'Une réputation qui parle pour vous',
          block2TitleEn: 'A reputation that speaks for itself',
          block2TextFr:
              'Des évaluations détaillées pour progresser et maintenir un service haut de gamme.',
          block2TextEn:
              'Detailed ratings to help you improve and keep delivering a premium service.',
        ),
        OnboardingSlide(
          fallbackAsset: 'assets/images/onboarding/slide_pilote_04.webp',
          order: 4,
          block1TitleFr: 'La livraison de colis',
          block1TitleEn: 'Package delivery',
          block1TextFr:
              'Augmentez vos revenus en livrant colis et documents sur vos trajets.',
          block1TextEn:
              'Boost your income by delivering packages and documents along your routes.',
          block2TitleFr: 'Courses et livraisons',
          block2TitleEn: 'Rides and deliveries',
          block2TextFr:
              'Alternez entre passagers et colis pour maximiser vos gains chaque jour.',
          block2TextEn:
              'Switch between passengers and packages to maximize your earnings every day.',
          ctaTextFr: 'Rejoindre Qlyp',
          ctaTextEn: 'Join Qlyp',
        ),
      ];

  static List<OnboardingSlide> bundled(String appType) =>
      appType == 'driver' ? bundledDriver() : bundledCustomer();

  static Future<List<OnboardingSlide>> load(String appType) async {
    final fallback = bundled(appType);
    try {
      final snap = await FirebaseFirestore.instance
          .collection(collection)
          .where('app_type', isEqualTo: appType)
          .get();
      final remote = <OnboardingSlide>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['active'] == false) continue;
        final order = (data['order'] is num) ? (data['order'] as num).toInt() : 0;
        final asset = fallback.firstWhere(
          (s) => s.order == order,
          orElse: () => fallback.first,
        ).fallbackAsset;
        remote.add(
          OnboardingSlide.fromFirestore(data, fallbackAsset: asset)
              .withBundledFallback(fallback.firstWhere(
            (s) => s.order == order,
            orElse: () => fallback.first,
          )),
        );
      }
      if (remote.isEmpty) return fallback;
      remote.sort((a, b) => a.order.compareTo(b.order));
      return remote;
    } catch (e) {
      debugPrint('OnboardingService.load: $e');
      return fallback;
    }
  }
}
