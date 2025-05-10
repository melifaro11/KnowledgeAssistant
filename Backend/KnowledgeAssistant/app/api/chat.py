from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.schemas.chat import ChatMessageCreate, ChatMessageResponse, ChatMessageUpdate
from app.auth.jwt import get_current_user
from app.models.user import User
from app.services import collection as collection_service, chat as chat_service
from app.db.session import get_db
from app.rag.retriever import ask_with_rag

router = APIRouter(prefix="/collections/{collection_id}/chat", tags=["Chat"])


@router.post("/", response_model=ChatMessageResponse)
def ask_question(
        collection_id: str,
        chat_in: ChatMessageCreate,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    answer, sources = ask_with_rag(collection_id, chat_in.question)

    message = chat_service.create_chat_message(
        db=db,
        collection_id=collection_id,
        question=chat_in.question,
        answer=answer,
        sources=sources,
    )

    return message


@router.get("/history", response_model=List[ChatMessageResponse])
def get_history(
        collection_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    return chat_service.get_chat_history(db, collection_id)


@router.delete("/{message_id}", status_code=204)
def delete_message(
        collection_id: str,
        message_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    message = chat_service.delete_chat_message(db, collection_id, message_id)
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")


@router.delete("/history", status_code=204)
def delete_history(
        collection_id: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    chat_service.delete_chat_history(db, collection_id)


@router.patch("/{message_id}", response_model=ChatMessageResponse)
def update_message(
        collection_id: str,
        message_id: str,
        update: ChatMessageUpdate,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    collection = collection_service.get_collection(db, collection_id)
    if not collection or collection.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Collection not found")

    message = chat_service.update_chat_message(
        db, collection_id, message_id, update.question, update.answer
    )

    if not message:
        raise HTTPException(status_code=404, detail="Message not found")

    return message
