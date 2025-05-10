import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collections_event.dart';
import 'package:knowledge_assistant/bloc/states/collections_state.dart';
import '../../repositories/collections_repository.dart';
import '../../models/collection.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final CollectionsRepository repository;

  CollectionsBloc({required this.repository}) : super(CollectionsInitial()) {
    on<LoadCollections>(_onLoadCollections);
    on<CreateCollection>(_onCreateCollection);
    on<DeleteCollection>(_onDeleteCollection);
    on<LoadCollectionById>(_onLoadCollectionById);
    on<AddSourceToCollection>(_onAddSourceToCollection);
    on<DeleteSourceFromCollection>(_onDeleteSourceFromCollection);
    on<UpdateSourceInCollection>(_onUpdateSourceInCollection);
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
      emit(CollectionsError('Collection loading error: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCollection(
    CreateCollection event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state is CollectionsLoaded) {
      try {
        final newCollection = await repository.createCollection(event.name);
        final updated = List<Collection>.from(
          (state as CollectionsLoaded).collections,
        )..add(newCollection);
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
        emit(CollectionsError('Error deleting collection: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadCollectionById(
    LoadCollectionById event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(CollectionsLoading());
    try {
      debugPrint('AAA');
      final collection = await repository.getCollectionById(event.id);
      debugPrint('BBB');
      emit(CollectionsLoaded([collection]));
      debugPrint('CCC');
    } catch (e) {
      emit(CollectionsError('Error adding source: ${e.toString()}'));
    }
  }

  Future<void> _onAddSourceToCollection(
    AddSourceToCollection event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state is CollectionsLoaded) {
      try {
        final updated = await repository.addSourceToCollection(
          event.collectionId,
          event.name,
          event.type,
          event.location,
        );

        emit(
          CollectionsLoaded(
            (state as CollectionsLoaded).collections
                .map((c) => c.id == updated.id ? updated : c)
                .toList(),
          ),
        );
      } catch (e) {
        emit(CollectionsError('Error adding source: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteSourceFromCollection(
    DeleteSourceFromCollection event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state is CollectionsLoaded) {
      try {
        final updated = await repository.deleteSourceFromCollection(
          event.collectionId,
          event.sourceId,
        );
        emit(
          CollectionsLoaded(
            (state as CollectionsLoaded).collections
                .map((c) => c.id == updated.id ? updated : c)
                .toList(),
          ),
        );
      } catch (e) {
        emit(CollectionsError('Source deleting error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateSourceInCollection(
    UpdateSourceInCollection event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state is CollectionsLoaded) {
      final current = (state as CollectionsLoaded).collections;
      final index = current.indexWhere((c) => c.id == event.collectionId);
      if (index == -1) return;

      final collection = current[index];
      final updatedSources =
          collection.sources.map((s) {
            return s.id == event.updatedSource.id ? event.updatedSource : s;
          }).toList();

      final updatedCollection = collection.copyWith(sources: updatedSources);

      final updated = [...current];
      updated[index] = updatedCollection;

      emit(CollectionsLoaded(updated));
    }
  }
}
