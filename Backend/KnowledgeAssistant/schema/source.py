from pydantic import BaseModel
from typing import Optional
from enum import Enum
import uuid
from datetime import datetime


class SourceType(str, Enum):
    file = "file"
    git = "git"
    url = "url"


class SourceBase(BaseModel):
    name: str
    type: SourceType
    location: Optional[str] = None


class SourceCreate(SourceBase):
    pass


class SourceRead(SourceBase):
    id: uuid.UUID
    added_at: datetime
    isIndexed: bool

    class Config:
        orm_mode = True
