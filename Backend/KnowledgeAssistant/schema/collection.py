from pydantic import BaseModel
from typing import List
import uuid
from datetime import datetime

from schema.source import SourceRead


class CollectionBase(BaseModel):
    name: str


class CollectionCreate(CollectionBase):
    pass


class CollectionRead(CollectionBase):
    id: uuid.UUID
    createdAt: datetime
    sources: List[SourceRead] = []

    class Config:
        orm_mode = True
