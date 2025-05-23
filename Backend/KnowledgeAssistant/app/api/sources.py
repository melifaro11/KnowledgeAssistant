import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Body
from sqlalchemy.orm import Session
from typing import List

from app.tasks import index_source_task
from app.schemas.source import SourceCreate, SourceResponse, SourceType
from app.services import source as source_service, collection as collection_service
from app.auth.jwt import get_current_user
from app.models.user import User
from app.db.session import get_db

router = APIRouter(prefix="/collections/{collection_id}/sources", tags=["Sources"])


def _verify_collection(db: Session, collection_id: str, user: User):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Collection not found")
    return collection


@router.get("/", response_model=List[SourceResponse])
def get_sources(
        collection_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    return source_service.get_sources(db, collection_id)


@router.get("/{source_id}", response_model=SourceResponse)
def get_source(
        collection_id: str,
        source_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    source = source_service.get_source(db, source_id)
    if not source or source.collection_id != collection_id:
        raise HTTPException(status_code=404, detail="Source not found")

    return source


@router.get("/{source_id}/status")
def get_source_status(
    collection_id: str,
    source_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)
    source = source_service.get_source(db, source_id)
    if not source:
        raise HTTPException(404, "Source not found")

    return {
        "status": source.status,
        "progress": source.progress,
        "message": source.progress_message,
    }


@router.post("/file", response_model=SourceResponse, status_code=201)
async def add_file_source(
        collection_id: str,
        name: str = Form(...),
        file: UploadFile = File(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    upload_dir = os.path.join("storage", "uploads", collection_id)
    os.makedirs(upload_dir, exist_ok=True)
    file_id = uuid.uuid4().hex
    _, ext = os.path.splitext(file.filename)
    filename = f"{file_id}{ext}"
    file_path = os.path.join(upload_dir, filename)
    content = await file.read()
    with open(file_path, "wb") as out_file:
        out_file.write(content)

    source_create = SourceCreate(name=name, type=SourceType.file, location=file_path)
    source = source_service.create_source(db, collection_id, source_create)

    return source


@router.post("/git", response_model=SourceResponse, status_code=201)
def add_git_source(
        collection_id: str,
        payload: dict = Body(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    name = payload.get("name")
    location = payload.get("location")
    if not name or not location:
        raise HTTPException(status_code=400, detail="Both 'name' and 'location' are required")

    source_create = SourceCreate(name=name, type=SourceType.git, location=location)
    source = source_service.create_source(db, collection_id, source_create)

    return source


@router.post("/url", response_model=SourceResponse, status_code=201)
def add_url_source(
        collection_id: str,
        payload: dict = Body(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    name = payload.get("name")
    location = payload.get("location")
    if not name or not location:
        raise HTTPException(status_code=400, detail="Both 'name' and 'location' are required")

    source_create = SourceCreate(name=name, type=SourceType.url, location=location)
    source = source_service.create_source(db, collection_id, source_create)

    return source


@router.post("/{source_id}/index", response_model=SourceResponse)
def index_source(
        collection_id: str,
        source_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    source = source_service.get_source(db, source_id)
    if not source or source.collection_id != collection_id:
        raise HTTPException(status_code=404, detail="Source not found")

    source.status = "pending"
    db.commit()

    index_source_task.send(collection_id, source_id)

    return source


@router.delete("/{source_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_source(
        collection_id: str,
        source_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    _verify_collection(db, collection_id, current_user)

    source = source_service.get_source(db, source_id)
    if not source or source.collection_id != collection_id:
        raise HTTPException(status_code=404, detail="Source not found")

    source_service.delete_source(db, source_id, collection_id)
