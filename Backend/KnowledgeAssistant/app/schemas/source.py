from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Dict, Any
from enum import Enum


class SourceType(str, Enum):
    file = "file"
    git = "git"
    url = "url"


class SourceCreate(BaseModel):
    """
    Schema for creating a new source.
    """
    name: str
    type: SourceType
    location: Optional[str] = None
    config: Optional[Dict[str, Any]] = Field(default_factory=dict)


class SourceResponse(BaseModel):
    """
    Schema for returning source details.
    """
    id: str
    name: str
    type: SourceType
    added_at: datetime
    location: Optional[str] = None
    config: Dict[str, Any] = Field(default_factory=dict)
    is_indexed: bool = False
    last_error: Optional[str] = None

    class Config:
        from_attributes = True
