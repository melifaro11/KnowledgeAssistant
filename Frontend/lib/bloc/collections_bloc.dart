import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collections_event.dart';
import 'package:knowledge_assistant/bloc/states/collections_state.dart';
import 'package:knowledge_assistant/repositories/collections_repository.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final CollectionsRepository repository;

  CollectionsBloc({required this.repository}) : super(CollectionsInitial()) {
    on<LoadCollections>(_onLoadCollections);
    on<CreateCollection>(_onCreateCollection);
    on<DeleteCollection>(_onDeleteCollection);
  }

  Future<void> _onLoadCollections(
    LoadCollections event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(CollectionsLoading());
    try {
      final collections = await repository.fetchCollections();
      emit(CollectionsLoaded(collections));
    } catch (e) {
      emit(CollectionsError('Collections loading error: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCollection(
    CreateCollection event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state is CollectionsLoaded) {
      try {
        final newCollection = await repository.createCollection(event.name);
        final updated = List.of((state as CollectionsLoaded).collections)
          ..add(newCollection);
        emit(CollectionsLoaded(updated));
      } catch (e) {
        emit(CollectionsError('Collection creating error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteCollection(
    DeleteCollection event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state is CollectionsLoaded) {
      try {
        await repository.deleteCollection(event.id);
        final updated =
            (state as CollectionsLoaded).collections
                .where((c) => c.id != event.id)
                .toList();
        emit(CollectionsLoaded(updated));
      } catch (e) {
        emit(CollectionsError('Collection deleting error: ${e.toString()}'));
      }
    }
  }
}
