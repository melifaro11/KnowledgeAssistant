from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserLogin, UserResponse
from app.services import user as user_service
from app.db.session import get_db
from app.auth.jwt import create_access_token
from fastapi.security import OAuth2PasswordBearer

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=UserResponse, status_code=201)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    existing_user = user_service.get_user_by_email(db, user_in.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    user = user_service.create_user(db, user_in)
    token = create_access_token({"sub": user.id})

    return UserResponse(
        id=user.id,
        email=user.email,
        name=user.name,
        authToken=token
    )


@router.post("/login", response_model=UserResponse)
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    user = user_service.get_user_by_email(db, user_in.email)
    if not user or not user_service.verify_password(user_in.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token({"sub": user.id})
    return UserResponse(
        id=user.id,
        email=user.email,
        name=user.name,
        authToken=token
    )


@router.post("/logout", status_code=204)
def logout(token: str = Depends(OAuth2PasswordBearer(tokenUrl="/auth/login"))):
    # Для MVP можно не реализовывать logout полностью — просто вернуть 204
    return
