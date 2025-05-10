import 'package:knowledge_assistant/models/collection.dart';

abstract class CollectionDetailState {}

class CollectionDetailInitial extends CollectionDetailState {}

class CollectionDetailLoading extends CollectionDetailState {}

class CollectionDetailLoaded extends CollectionDetailState {
  final Collection collection;

  CollectionDetailLoaded(this.collection);
}

class CollectionDetailError extends CollectionDetailState {
  final String message;

  CollectionDetailError(this.message);
}
