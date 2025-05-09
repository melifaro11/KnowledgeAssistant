import uuid
from sqlalchemy import Column, String, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.db_base import Base


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    question = Column(String, nullable=False)
    answer = Column(String, nullable=False)
    sources = Column(JSON, nullable=False, default=[])
    timestamp = Column(DateTime, default=datetime.utcnow)

    collection_id = Column(String, ForeignKey("collections.id"))
    collection = relationship("Collection", back_populates="chat_messages")
