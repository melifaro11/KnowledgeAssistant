import uuid

from sqlalchemy.orm import Session
from app.models.source import Source, SourceTypeEnum
from app.schemas.source import SourceCreate
from app.indexing.pipeline import index_source


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


def run_indexing_for_source(db: Session, source: Source, collection_id: str):
    index_source(collection_id, source.type.value, source.location)
    source.is_indexed = True
    db.commit()
