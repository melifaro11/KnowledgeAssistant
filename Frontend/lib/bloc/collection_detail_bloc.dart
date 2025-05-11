import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/bloc/states/collection_detail_state.dart';
import 'package:knowledge_assistant/models/source.dart';
import 'package:knowledge_assistant/repositories/collections_repository.dart';

class CollectionDetailBloc
    extends Bloc<CollectionDetailEvent, CollectionDetailState> {
  final CollectionsRepository repository;

  CollectionDetailBloc({required this.repository})
    : super(CollectionDetailInitial()) {
    on<LoadCollectionDetail>(_onLoadDetail);
    on<AddFileSourceToCollection>(_onAddFileSource);
    on<AddGitSourceToCollection>(_onAddGitSource);
    on<AddUrlSourceToCollection>(_onAddUrlSource);
    on<DeleteSourceFromCollection>(_onDeleteSource);
    on<UpdateSourceInCollection>(_onUpdateSource);
  }

  Future<void> _onLoadDetail(
    LoadCollectionDetail event,
    Emitter<CollectionDetailState> emit,
  ) async {
    emit(CollectionDetailLoading());
    try {
      final collection = await repository.getCollectionById(event.id);
      emit(CollectionDetailLoaded(collection));
    } catch (e) {
      emit(CollectionDetailError('Error loading collection: ${e.toString()}'));
    }
  }

  Future<void> _onAddFileSource(
    AddFileSourceToCollection event,
    Emitter<CollectionDetailState> emit,
  ) async {
    if (state is CollectionDetailLoaded) {
      try {
        final updated = await repository.addFileSource(
          event.collectionId,
          event.name,
          event.file,
        );
        emit(CollectionDetailLoaded(updated));
      } catch (e) {
        emit(CollectionDetailError('Error adding file: $e'));
      }
    }
  }

  Future<void> _onAddGitSource(
    AddGitSourceToCollection event,
    Emitter<CollectionDetailState> emit,
  ) async {
    if (state is CollectionDetailLoaded) {
      try {
        final updated = await repository.addGitSource(
          event.collectionId,
          event.name,
          event.gitUrl,
          config: event.config,
        );
        emit(CollectionDetailLoaded(updated));
      } catch (e) {
        emit(CollectionDetailError('Error adding git: $e'));
      }
    }
  }

  Future<void> _onAddUrlSource(
    AddUrlSourceToCollection event,
    Emitter<CollectionDetailState> emit,
  ) async {
    if (state is CollectionDetailLoaded) {
      try {
        final updated = await repository.addUrlSource(
          event.collectionId,
          event.name,
          event.url,
          config: event.config,
        );
        emit(CollectionDetailLoaded(updated));
      } catch (e) {
        emit(CollectionDetailError('Error adding url: $e'));
      }
    }
  }

  Future<void> _onDeleteSource(
    DeleteSourceFromCollection event,
    Emitter<CollectionDetailState> emit,
  ) async {
    if (state is CollectionDetailLoaded) {
      try {
        final updated = await repository.deleteSourceFromCollection(
          event.collectionId,
          event.sourceId,
        );
        emit(CollectionDetailLoaded(updated));
      } catch (e) {
        emit(CollectionDetailError('Error deleting source: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateSource(
    UpdateSourceInCollection event,
    Emitter<CollectionDetailState> emit,
  ) async {
    if (state is CollectionDetailLoaded) {
      final current = (state as CollectionDetailLoaded).collection;
      final updatedSources =
          current.sources
                  .map(
                    (s) =>
                        s.id == event.updatedSource.id
                            ? event.updatedSource
                            : s,
                  )
                  .toList()
              as List<Source>;
      emit(CollectionDetailLoaded(current.copyWith(sources: updatedSources)));
    }
  }
}
