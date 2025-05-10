import uuid

import datetime

from sqlalchemy.orm import Session
from app.models.chat import ChatMessage


def get_chat_history(db: Session, collection_id: str):
    return db.query(ChatMessage) \
        .filter(ChatMessage.collection_id == collection_id) \
        .order_by(ChatMessage.timestamp.asc()).all()


def create_chat_message(db: Session, collection_id: str, question: str, answer: str, sources: list):
    sources_data = [source.dict() for source in sources]
    chat = ChatMessage(
        id=str(uuid.uuid4()),
        question=question,
        answer=answer,
        sources=sources_data,
        collection_id=collection_id,
        timestamp=datetime.datetime.now(datetime.UTC)
    )
    db.add(chat)
    db.commit()
    db.refresh(chat)
    return chat
