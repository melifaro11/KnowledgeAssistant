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
  final Map<String, dynamic> config;

  AddGitSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.gitUrl,
    this.config = const {},
  });
}

class AddUrlSourceToCollection extends CollectionDetailEvent {
  final String collectionId;
  final String name;
  final String url;
  final Map<String, dynamic> config;

  AddUrlSourceToCollection({
    required this.collectionId,
    required this.name,
    required this.url,
    this.config = const {},
  });
}

class DeleteSourceFromCollection extends CollectionDetailEvent {
  final String collectionId;
  final String sourceId;

  DeleteSourceFromCollection(this.collectionId, this.sourceId);
}

class UpdateSourceInCollection extends CollectionDetailEvent {
  final String collectionId;
  final dynamic updatedSource;

  UpdateSourceInCollection(this.collectionId, this.updatedSource);
}

class FetchSourceStatus extends CollectionDetailEvent {
  final String collectionId;
  final String sourceId;

  FetchSourceStatus(this.collectionId, this.sourceId);
}
