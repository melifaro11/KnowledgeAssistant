from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.schemas.source import SourceCreate, SourceResponse
from app.services import source as source_service, collection as collection_service
from app.auth.jwt import get_current_user
from app.models.user import User
from app.db.session import get_db

router = APIRouter(prefix="/collections/{collection_id}/sources", tags=["Sources"])


@router.get("/", response_model=List[SourceResponse])
def get_sources(
    collection_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")
    return source_service.get_sources(db, collection_id)


@router.post("/", response_model=SourceResponse, status_code=201)
def add_source(
    collection_id: str,
    source_in: SourceCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")
    return source_service.create_source(db, collection_id, source_in)


@router.get("/{source_id}", response_model=SourceResponse)
def get_source(
    collection_id: str,
    source_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    source = source_service.get_source(db, source_id)
    if not source or source.collection_id != collection_id:
        raise HTTPException(status_code=404, detail="Source not found")
    return source


@router.post("/{source_id}/index", response_model=SourceResponse)
def index_source_endpoint(
    collection_id: str,
    source_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    source = get_source(db, source_id)
    if not source or source.collection_id != collection_id:
        raise HTTPException(status_code=404, detail="Source not found")

    # Удаляем предыдущий индекс коллекции (можно хранить по source.id, если нужно более тонко)
    source_service.delete_faiss_index(collection_id)

    # Индексируем заново
    try:
        source_service.run_indexing_for_source(db, source, collection_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Indexing failed: {str(e)}")

    return source
