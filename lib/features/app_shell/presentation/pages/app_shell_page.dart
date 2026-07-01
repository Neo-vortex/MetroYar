import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../metro_map/presentation/pages/metro_map_page.dart';
import '../../../route_finder/presentation/pages/route_finder_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/nav_cubit.dart';

/// The app's root shell: a bottom [NavigationBar] switching between the
/// three main destinations with an [IndexedStack] so each tab keeps its
/// own scroll position and bloc state alive while hidden.
class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: const _AppShellView(),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView();

  static const _pages = [
    RouteFinderPage(),
    MetroMapPage(),
    SettingsPage(),
  ];

  // The map tab (index 1) is temporarily hidden from navigation without
  // deleting any of its code/page — only these indices are reachable from
  // the bottom bar.
  static const _visiblePageIndices = [0, 2];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, int>(
      builder: (context, index) {
        final selectedVisibleIndex = _visiblePageIndices.indexOf(index);
        return Scaffold(
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedVisibleIndex < 0 ? 0 : selectedVisibleIndex,
            onDestinationSelected: (i) => context
                .read<NavCubit>()
                .selectTab(_visiblePageIndices[i]),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route_rounded),
                label: 'مسیریاب',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'تنظیمات',
              ),
            ],
          ),
        );
      },
    );
  }
}
