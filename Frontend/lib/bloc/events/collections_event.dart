abstract class CollectionsEvent {}

class LoadCollections extends CollectionsEvent {}

class CreateCollection extends CollectionsEvent {
  final String name;

  CreateCollection(this.name);
}

class DeleteCollection extends CollectionsEvent {
  final String id;

  DeleteCollection(this.id);
}
