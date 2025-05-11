import os
import uuid
import shutil

from sqlalchemy.orm import Session
from app.models.source import Source, SourceTypeEnum
from app.schemas.source import SourceCreate
from app.indexing.pipeline import index_source


def get_sources(db: Session, collection_id: str):
    """
    Retrieve all sources for a given collection.

    Args:
        db: Database session.
        collection_id: Identifier of the collection.

    Returns:
        List of Source instances.
    """
    return db.query(Source).filter(Source.collection_id == collection_id).all()


def get_source(db: Session, source_id: str):
    """
    Retrieve a source by its ID.

    Args:
        db: Database session.
        source_id: Identifier of the source.

    Returns:
        Source instance or None if not found.
    """
    return db.query(Source).filter(Source.id == source_id).first()


def create_source(db: Session, collection_id: str, source_in: SourceCreate):
    """
    Create a new source record.

    Args:
        db: Database session.
        collection_id: Identifier of the collection to attach.
        source_in: Data for creating the source, including config.

    Returns:
        Newly created Source instance.
    """
    source = Source(
        id=str(uuid.uuid4()),
        name=source_in.name,
        type=SourceTypeEnum(source_in.type),
        location=source_in.location,
        config=source_in.config or {},
        collection_id=collection_id,
    )
    db.add(source)
    db.commit()
    db.refresh(source)

    return source


def reindex_source(db: Session, source: Source, collection_id: str):
    """
    (Re)index a source into the FAISS vector store.

    Args:
        db: Database session.
        source: Source instance to index.
        collection_id: Identifier of the collection.

    Returns:
        Updated Source instance with indexing status.
    """
    try:
        index_source(
            collection_id,
            source.id,
            source.type.value,
            source.location,
            source.config or {},
        )
        source.is_indexed = True
        source.last_error = None
    except Exception as e:
        source.is_indexed = False
        source.last_error = str(e)
    db.commit()
    db.refresh(source)

    return source


def delete_source(db: Session, source_id: str, collection_id: str):
    """
    Delete a source and its FAISS index data.

    Args:
        db: Database session.
        source_id: Identifier of the source to delete.
        collection_id: Identifier of the associated collection.
    """
    index_path = os.path.join("storage", "faiss_indexes", collection_id, source_id)
    if os.path.exists(index_path):
        shutil.rmtree(index_path)

    source = get_source(db, source_id)
    if source:
        db.delete(source)
        db.commit()
