import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs every bloc/cubit transition & error to the console in debug
/// builds only — a senior-friendly substitute for sprinkling `print`
/// statements through every bloc.
class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('[${bloc.runtimeType}] ${transition.event} → '
          '${transition.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[${bloc.runtimeType}] ERROR: $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}
