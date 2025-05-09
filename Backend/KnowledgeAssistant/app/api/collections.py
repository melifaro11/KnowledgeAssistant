from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.schemas.collection import CollectionCreate, CollectionResponse
from app.services import collection as collection_service
from app.auth.jwt import get_current_user
from app.models.user import User
from app.db.session import get_db

router = APIRouter(prefix="/collections", tags=["Collections"])


@router.get("/", response_model=List[CollectionResponse])
def get_collections(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return collection_service.get_collections(db, current_user.id)


@router.post("/", response_model=CollectionResponse, status_code=201)
def create_collection(
    collection_in: CollectionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return collection_service.create_collection(db, current_user.id, collection_in)


@router.get("/{collection_id}", response_model=CollectionResponse)
def get_collection_by_id(
    collection_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")
    return collection


@router.delete("/{collection_id}", status_code=204)
def delete_collection(
    collection_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")
    collection_service.delete_collection(db, collection_id)
