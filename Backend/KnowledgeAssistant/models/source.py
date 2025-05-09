import uuid
from sqlalchemy import Column, String, DateTime, Boolean, Enum, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from KnowledgeAssistant.models.db import Base


class SourceTypeEnum(str, enum.Enum):
    file = "file"
    git = "git"
    url = "url"

class Source(Base):
    __tablename__ = "sources"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    type = Column(Enum(SourceTypeEnum), nullable=False)
    added_at = Column(DateTime, default=datetime.utcnow)
    location = Column(String, nullable=True)
    is_indexed = Column(Boolean, default=False)

    collection_id = Column(String, ForeignKey("collections.id"))
    collection = relationship("Collection", back_populates="sources")
