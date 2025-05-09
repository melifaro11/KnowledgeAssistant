import uuid
from sqlalchemy import Column, String
from sqlalchemy.orm import relationship

from KnowledgeAssistant.models.db import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=True)
    password_hash = Column(String, nullable=False)

    collections = relationship("Collection", back_populates="owner")
