import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteResultsState extends Equatable {
  final int selectedRouteIndex;
  final bool isSaved;

  const RouteResultsState({this.selectedRouteIndex = 0, this.isSaved = false});

  RouteResultsState copyWith({int? selectedRouteIndex, bool? isSaved}) {
    return RouteResultsState(
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [selectedRouteIndex, isSaved];
}

class RouteResultsCubit extends Cubit<RouteResultsState> {
  RouteResultsCubit() : super(const RouteResultsState());

  void selectRoute(int index) => emit(state.copyWith(selectedRouteIndex: index));

  void toggleSaved() => emit(state.copyWith(isSaved: !state.isSaved));
}
