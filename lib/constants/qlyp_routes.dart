class QlypRoutes {
  const QlypRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String services = '/services';
  static const String bookings = '/bookings';
  static const String cast = '/cast';
  static const String compte = '/compte';
  static const String piloteHome = '/pilote/home';
  static const String piloteActivite = '/pilote/activite';
  static const String piloteGains = '/pilote/gains';
  static const String piloteHub = '/pilote/hub';
  static const String piloteCompte = '/pilote/compte';
  static const String initial = splash;

  static const List<String> clientTabs = [
    home,
    services,
    bookings,
    cast,
    compte,
  ];

  static const List<String> piloteTabs = [
    piloteHome,
    piloteActivite,
    piloteGains,
    piloteHub,
    piloteCompte,
  ];
}

typedef AppRoutes = QlypRoutes;
