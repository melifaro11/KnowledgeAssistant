from sqlalchemy.orm import Session
from app.models.collection import Collection
from app.schemas.collection import CollectionCreate
import uuid


def get_collections(db: Session, user_id: str):
    return db.query(Collection).filter(Collection.owner_id == user_id).all()


def get_collection(db: Session, collection_id: str):
    return db.query(Collection).filter(Collection.id == collection_id).first()


def create_collection(db: Session, user_id: str, collection_in: CollectionCreate):
    collection = Collection(
        id=str(uuid.uuid4()),
        name=collection_in.name,
        owner_id=user_id
    )
    db.add(collection)
    db.commit()
    db.refresh(collection)
    return collection


def delete_collection(db: Session, collection_id: str):
    collection = get_collection(db, collection_id)
    if collection:
        db.delete(collection)
        db.commit()
    return collection
