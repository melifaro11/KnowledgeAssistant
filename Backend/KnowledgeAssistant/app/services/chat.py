from sqlalchemy.orm import Session
from app.models.chat import ChatMessage
from app.schemas.chat import ChatMessageCreate
import uuid
from datetime import datetime


def get_chat_history(db: Session, collection_id: str):
    return db.query(ChatMessage) \
        .filter(ChatMessage.collection_id == collection_id) \
        .order_by(ChatMessage.timestamp.asc()).all()


def create_chat_message(db: Session, collection_id: str, question: str, answer: str, sources: list):
    chat = ChatMessage(
        id=str(uuid.uuid4()),
        question=question,
        answer=answer,
        sources=sources,
        collection_id=collection_id,
        timestamp=datetime.utcnow()
    )
    db.add(chat)
    db.commit()
    db.refresh(chat)
    return chat
