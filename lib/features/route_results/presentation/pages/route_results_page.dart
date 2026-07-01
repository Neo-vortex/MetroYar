import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../shared/extensions/build_context_extensions.dart';
import '../../../../shared/models/route_result.dart';
import '../cubit/route_results_cubit.dart';
import '../widgets/route_steps_timeline.dart';
import '../widgets/route_summary_card.dart';
import '../widgets/route_tabs.dart';

class RouteResultsPage extends StatelessWidget {
  final RouteResult routeResult;

  const RouteResultsPage({super.key, required this.routeResult});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteResultsCubit(),
      child: _RouteResultsView(routeResult: routeResult),
    );
  }
}

class _RouteResultsView extends StatelessWidget {
  final RouteResult routeResult;

  const _RouteResultsView({required this.routeResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${routeResult.start.displayName} ← ${routeResult.end.displayName}',
          style: const TextStyle(fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          BlocBuilder<RouteResultsCubit, RouteResultsState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'ذخیره مسیر',
                onPressed: () {
                  context.read<RouteResultsCubit>().toggleSaved();
                  context.showSnack(
                    state.isSaved ? 'از مسیرهای ذخیره‌شده حذف شد' : 'مسیر ذخیره شد',
                    icon: Icons.bookmark_rounded,
                  );
                },
                icon: Icon(
                  state.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RouteResultsCubit, RouteResultsState>(
        builder: (context, state) {
          final routes = routeResult.routes;
          final selectedIndex = state.selectedRouteIndex.clamp(0, routes.length - 1);
          final steps = routes[selectedIndex];

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              RouteSummaryCard(result: routeResult),
              const SizedBox(height: AppSpacing.md),
              RouteTabs(
                routeCount: routes.length,
                selectedIndex: selectedIndex,
                onChanged: (index) =>
                    context.read<RouteResultsCubit>().selectRoute(index),
              ),
              if (routes.length > 1) const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                  child: RouteStepsTimeline(
                    steps: steps,
                    filters: routeResult.filters,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
