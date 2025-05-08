from sqlalchemy import Column, String, DateTime, Enum, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
import uuid
import enum
from datetime import datetime

from models.base_class import Base


class SourceType(enum.Enum):
    file = "file"
    git = "git"
    url = "url"


class Source(Base):
    __tablename__ = "sources"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    name = Column(String, nullable=False)
    type = Column(Enum(SourceType), nullable=False)
    location = Column(String, nullable=True)
    added_at = Column(DateTime, default=datetime.utcnow)
    is_indexed = Column(Boolean, default=False)

    collection_id = Column(UUID(as_uuid=True), ForeignKey('collections.id'), nullable=False)
    collection = relationship("Collection", back_populates="sources")
