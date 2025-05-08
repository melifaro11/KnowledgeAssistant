import '../../models/collection.dart';

abstract class CollectionsState {
  const CollectionsState();
}

class CollectionsInitial extends CollectionsState {}

class CollectionsLoading extends CollectionsState {}

class CollectionsLoaded extends CollectionsState {
  final List<Collection> collections;

  const CollectionsLoaded(this.collections);
}

class CollectionsError extends CollectionsState {
  final String message;

  const CollectionsError(this.message);
}
