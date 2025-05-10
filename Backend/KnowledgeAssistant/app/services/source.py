import os
import uuid
import shutil

from sqlalchemy.orm import Session
from app.models.source import Source, SourceTypeEnum
from app.schemas.source import SourceCreate
from app.indexing.pipeline import index_source

FAISS_ROOT = "storage/faiss_indexes"


def get_sources(db: Session, collection_id: str):
    return db.query(Source).filter(Source.collection_id == collection_id).all()


def get_source(db: Session, source_id: str):
    return db.query(Source).filter(Source.id == source_id).first()


def create_source(db: Session, collection_id: str, source_in: SourceCreate):
    source = Source(
        id=str(uuid.uuid4()),
        name=source_in.name,
        type=SourceTypeEnum(source_in.type),
        location=source_in.location,
        collection_id=collection_id
    )
    db.add(source)
    db.commit()
    db.refresh(source)

    return source


def reindex_source(db: Session, source: Source, collection_id: str):
    try:
        index_source(collection_id, source.id, source.type.value, source.location)
        source.is_indexed = True
        source.last_error = None
    except Exception as e:
        source.is_indexed = False
        source.last_error = str(e)
    db.commit()
    db.refresh(source)

    return source


def delete_source(db: Session, source_id: str, collection_id: str):
    index_path = os.path.join("storage/faiss_indexes", collection_id, source_id)
    if os.path.exists(index_path):
        shutil.rmtree(index_path)

    source = get_source(db, source_id)
    if source:
        db.delete(source)
        db.commit()
