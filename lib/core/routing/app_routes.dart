/// Named routes that are pushed on top of the bottom-nav shell.
/// (The shell's own tabs — route finder / metro map / settings — are
/// switched with an `IndexedStack`, not the navigator, so they aren't
/// listed here.)
abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String shell = '/';
  static const String routeResults = '/route-results';
  static const String about = '/about';
}
