import 'package:file_picker/file_picker.dart';

abstract class CollectionDetailEvent {}

class LoadCollectionDetail extends CollectionDetailEvent {
  final String id;

  LoadCollectionDetail(this.id);
}

class AddFileSourceToCollection extends CollectionDetailEvent {
  final String collectionId;
  final String name;
  final PlatformFile file;

  AddFileSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.file,
  });
}

class AddGitSourceToCollection extends CollectionDetailEvent {
  final String collectionId;
  final String name;
  final String gitUrl;

  AddGitSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.gitUrl,
  });
}

class AddUrlSourceToCollection extends CollectionDetailEvent {
  final String collectionId;
  final String name;
  final String url;

  AddUrlSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.url,
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
