import 'package:flutter/material.dart';

import '../../features/about/presentation/pages/about_page.dart';
import '../../features/app_shell/presentation/pages/app_shell_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/route_results/presentation/pages/route_results_page.dart';
import '../../shared/models/route_result.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _page(const OnboardingPage(), settings);

      case AppRoutes.shell:
        return _page(const AppShellPage(), settings);

      case AppRoutes.about:
        return _page(const AboutPage(), settings);

      case AppRoutes.routeResults:
        final result = settings.arguments as RouteResult;
        return _page(RouteResultsPage(routeResult: result), settings);

      default:
        return _page(
          Scaffold(
            body: Center(child: Text('مسیر یافت نشد: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
