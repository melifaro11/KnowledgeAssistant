import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/bloc/states/collection_detail_state.dart';
import 'package:knowledge_assistant/models/source.dart';
import 'package:knowledge_assistant/repositories/collections_repository.dart';

class CollectionDetailBloc
    extends Bloc<CollectionDetailEvent, CollectionDetailState> {
  final CollectionsRepository repository;
  Timer? _pollingTimer;

  CollectionDetailBloc({required this.repository})
    : super(CollectionDetailInitial()) {
    on<LoadCollectionDetail>(_onLoadDetail);
    on<AddFileSourceToCollection>(_onAddFileSource);
    on<AddGitSourceToCollection>(_onAddGitSource);
    on<AddUrlSourceToCollection>(_onAddUrlSource);
    on<DeleteSourceFromCollection>(_onDeleteSource);
    on<UpdateSourceInCollection>(_onUpdateSource);
    on<FetchSourceStatus>(_onFetchSourceStatus);
  }

  Future<void> _onLoadDetail(
    LoadCollectionDetail event,
    Emitter<CollectionDetailState> emit,
  ) async {
    emit(CollectionDetailLoading());
    try {
      final collection = await repository.getCollectionById(event.id);
      emit(CollectionDetailLoaded(collection));
      debugPrint('Start pooling');
      debugPrint('Collection: $collection');
      for (final s in collection.sources) {
        debugPrint('${s.id} ${s.name} ${s.status} ${s.progress} ${s.isIndexed} ${s.lastError}');
      }
      _startPolling(CollectionDetailLoaded(collection));
    } catch (e) {
      emit(CollectionDetailError('Error loading collection: \${e.toString()}'));
    }
  }

  void _startPolling(CollectionDetailLoaded state) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      debugPrint('UPDATE STATUS');
      for (final s in state.collection.sources) {
        debugPrint('SOURCE: ${s.name} ${s.status} ${s.progress}');
        if (s.status == 'pending' || s.status == 'running') {
          add(FetchSourceStatus(state.collection.id, s.id));
        }
      }
    });
  }

  Future<void> _onFetchSourceStatus(
    FetchSourceStatus event,
    Emitter<CollectionDetailState> emit,
  ) async {
    if (state is CollectionDetailLoaded) {
      try {
        final status = await repository.fetchSourceStatus(
          event.collectionId,
          event.sourceId,
        );
        final currentState = state as CollectionDetailLoaded;
        final updatedSources =
            currentState.collection.sources.map((s) {
              if (s.id == status.sourceId) {
                return s.copyWith(
                  status: status.status,
                  progress: status.progress,
                  lastError: status.status == 'failed' ? s.lastError : null,
                );
              }
              return s;
            }).toList();
        final updatedCollection = currentState.collection.copyWith(
          sources: updatedSources,
        );
        emit(CollectionDetailLoaded(updatedCollection));

        if (updatedSources.every((s) => s.status == 'indexed')) {
          _pollingTimer?.cancel();
        }
      } catch (_) {
        // ignore
      }
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
        emit(CollectionDetailError('Error adding file: \$e'));
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
        emit(CollectionDetailError('Error adding git: \$e'));
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
        emit(CollectionDetailError('Error adding url: \$e'));
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
        emit(CollectionDetailError('Error deleting source: \${e.toString()}'));
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

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
