from pydantic import BaseModel
from datetime import datetime
from typing import List
from app.schemas.source import SourceResponse


class CollectionCreate(BaseModel):
    name: str


class CollectionResponse(BaseModel):
    id: str
    name: str
    createdAt: datetime
    sources: List[SourceResponse] = []

    class Config:
        from_attributes = True
