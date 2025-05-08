
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
