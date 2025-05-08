from pydantic import BaseModel
from typing import List, Optional
import uuid
from datetime import datetime


class ChatSource(BaseModel):
    title: str
    url: Optional[str] = None
    page: Optional[str] = None


class ChatMessageBase(BaseModel):
    question: str
    answer: str


class ChatMessageCreate(BaseModel):
    question: str


class ChatMessageRead(ChatMessageBase):
    id: uuid.UUID
    sources: List[ChatSource] = []
    timestamp: datetime

    class Config:
        orm_mode = True
