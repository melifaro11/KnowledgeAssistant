from pydantic import BaseModel
from datetime import datetime
from typing import List
from app.schemas.source import SourceResponse


class CollectionCreate(BaseModel):
    name: str


class CollectionResponse(BaseModel):
    id: str
    name: str
    created_at: datetime
    sources: List[SourceResponse] = []

    class Config:
        from_attributes = True
