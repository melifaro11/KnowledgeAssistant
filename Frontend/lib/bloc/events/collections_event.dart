import 'package:knowledge_assistant/models/source.dart';

abstract class CollectionsEvent {
  const CollectionsEvent();
}

class LoadCollections extends CollectionsEvent {}

class CreateCollection extends CollectionsEvent {
  final String name;

  const CreateCollection(this.name);
}

class DeleteCollection extends CollectionsEvent {
  final String id;

  const DeleteCollection(this.id);
}

class LoadCollectionById extends CollectionsEvent {
  final String id;
  LoadCollectionById(this.id);
}

class AddSourceToCollection extends CollectionsEvent {
  final String collectionId;
  final String name;
  final String type;
  final String? location;

  AddSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.type,
    this.location,
  });
}

class DeleteSourceFromCollection extends CollectionsEvent {
  final String collectionId;
  final String sourceId;

  DeleteSourceFromCollection(this.collectionId, this.sourceId);
}

class UpdateSourceInCollection extends CollectionsEvent {
  final String collectionId;
  final Source updatedSource;

  UpdateSourceInCollection(this.collectionId, this.updatedSource);
}
