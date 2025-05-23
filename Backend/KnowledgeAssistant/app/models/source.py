import uuid
from sqlalchemy import Column, String, DateTime, Boolean, Enum, ForeignKey, JSON, Integer
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from app.db.db_base import Base


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
    config = Column(JSON, nullable=True, default={})
    is_indexed = Column(Boolean, default=False)
    last_error = Column(String, nullable=True)
    status = Column(Enum("pending", "running", "indexed", "failed", name="status_enum"),
                    nullable=False, default="pending")
    progress = Column(Integer, default=0, nullable=False)
    progress_message = Column(String, nullable=True)

    collection_id = Column(String, ForeignKey("collections.id"))
    collection = relationship("Collection", back_populates="sources")
