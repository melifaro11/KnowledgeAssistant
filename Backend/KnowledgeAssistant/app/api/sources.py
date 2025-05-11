import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List

from app.schemas.source import SourceCreate, SourceResponse, SourceType
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
async def add_source(
        collection_id: str,
        name: str = Form(...),
        type: SourceType = Form(...),
        file: UploadFile = File(None),
        location: str = Form(None),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    if type == SourceType.file:
        if not file:
            raise HTTPException(status_code=400, detail="File is required for file source")
        upload_dir = os.path.join("storage", "uploads", collection_id)
        os.makedirs(upload_dir, exist_ok=True)

        file_id = uuid.uuid4().hex
        _, ext = os.path.splitext(file.filename)
        filename = f"{file_id}{ext}"
        file_path = os.path.join(upload_dir, filename)

        content = await file.read()
        with open(file_path, "wb") as out_file:
            out_file.write(content)
        location_to_use = file_path
    else:
        if not location:
            raise HTTPException(status_code=400, detail="Location is required for non-file sources")
        location_to_use = location

    source_create = SourceCreate(name=name, type=type, location=location_to_use)
    source = source_service.create_source(db, collection_id, source_create)

    return source_service.reindex_source(db, source, collection_id)


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
def index_source(
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
    return source_service.reindex_source(db, source, collection_id)


@router.delete("/{source_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_source(
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
    source_service.delete_source(db, source_id, collection_id)
