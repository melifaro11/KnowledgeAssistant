import uuid
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.db_base import Base


class Collection(Base):
    __tablename__ = "collections"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    owner_id = Column(String, ForeignKey("users.id"))
    owner = relationship("User", back_populates="collections")

    sources = relationship("Source", back_populates="collection", cascade="all, delete-orphan")
    chat_messages = relationship("ChatMessage", back_populates="collection", cascade="all, delete-orphan")
