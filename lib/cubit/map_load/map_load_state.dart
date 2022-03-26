part of 'map_load_cubit.dart';

abstract class MapLoadState extends Equatable {
  const MapLoadState();

  @override
  List<Object?> get props => [];
}

class MapLoadInitState extends MapLoadState {}

class MapLoadedState extends MapLoadState {
  MapLoadedState();
}

class MapLoadingState extends MapLoadState {}

class MapLoadingFailedState extends MapLoadState {}
