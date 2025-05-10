abstract class CollectionDetailEvent {}

class LoadCollectionDetail extends CollectionDetailEvent {
  final String id;

  LoadCollectionDetail(this.id);
}

class AddSourceToCollection extends CollectionDetailEvent {
  final String collectionId, name, type;
  final String? location;

  AddSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.type,
    this.location,
  });
}

class DeleteSourceFromCollection extends CollectionDetailEvent {
  final String collectionId, sourceId;

  DeleteSourceFromCollection(this.collectionId, this.sourceId);
}

class UpdateSourceInCollection extends CollectionDetailEvent {
  final String collectionId;
  final dynamic updatedSource;

  UpdateSourceInCollection(this.collectionId, this.updatedSource);
}
