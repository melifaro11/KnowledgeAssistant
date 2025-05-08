from pydantic import BaseModel, EmailStr
from typing import Optional
import uuid


class UserBase(BaseModel):
    email: EmailStr
    name: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserRead(UserBase):
    id: uuid.UUID


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserReadWithToken(UserRead):
    authToken: str
