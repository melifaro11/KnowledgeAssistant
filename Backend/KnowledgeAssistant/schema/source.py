from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from enum import Enum


class SourceType(str, Enum):
    file = "file"
    git = "git"
    url = "url"


class SourceCreate(BaseModel):
    name: str
    type: SourceType
    location: Optional[str] = None


class SourceResponse(BaseModel):
    id: str
    name: str
    type: SourceType
    addedAt: datetime
    location: Optional[str] = None
    isIndexed: bool = False

    class Config:
        orm_mode = True
