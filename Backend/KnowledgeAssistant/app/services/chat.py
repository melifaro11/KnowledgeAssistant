import uuid

import datetime

from sqlalchemy.orm import Session
from app.models.chat import ChatMessage
from app.rag.retriever import ask_with_rag


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


def delete_chat_message(db: Session, collection_id: str, message_id: str):
    message = db.query(ChatMessage).filter(
        ChatMessage.id == message_id,
        ChatMessage.collection_id == collection_id
    ).first()

    if message:
        db.delete(message)
        db.commit()

    return message


def delete_chat_history(db: Session, collection_id: str):
    db.query(ChatMessage).filter(ChatMessage.collection_id == collection_id).delete()
    db.commit()


def update_chat_message(
        db: Session,
        collection_id: str,
        message_id: str,
        question: str,
):
    message = db.query(ChatMessage).filter(
        ChatMessage.id == message_id,
        ChatMessage.collection_id == collection_id
    ).first()

    if message:
        answer, sources = ask_with_rag(collection_id, question)
        message.question = question
        message.answer = answer
        message.sources = [s.dict() for s in sources]
        db.commit()
        db.refresh(message)

    return message
