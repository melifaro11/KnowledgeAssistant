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
    added_at: datetime
    location: Optional[str] = None
    is_indexed: bool = False
    last_error: Optional[str] = None

    class Config:
        from_attributes = True
