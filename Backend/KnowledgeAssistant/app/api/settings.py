from fastapi import APIRouter
from app.schemas.settings import SettingsResponse, SettingsUpdate
from app.services import settings as settings_service

router = APIRouter(prefix="/settings", tags=["Settings"])


@router.get("/", response_model=SettingsResponse)
def get_settings():
    return settings_service.load_settings()


@router.post("/", response_model=SettingsResponse)
def update_settings(new_settings: SettingsUpdate):
    settings_service.save_settings(new_settings)
    return new_settings
