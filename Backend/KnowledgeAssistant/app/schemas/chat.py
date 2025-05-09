from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional


class ChatSource(BaseModel):
    title: str
    url: Optional[str] = None
    page: Optional[str] = None


class ChatMessageCreate(BaseModel):
    question: str


class ChatMessageResponse(BaseModel):
    id: str
    question: str
    answer: str
    sources: List[ChatSource]
    timestamp: datetime

    class Config:
        from_attributes = True
