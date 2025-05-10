import json
from pathlib import Path
from app.schemas.settings import SettingsUpdate, SettingsResponse

SETTINGS_FILE = Path("storage/settings.json")
DEFAULT_SETTINGS = {
    "modelType": "openai",
    "storageType": "local"
}


def load_settings() -> SettingsResponse:
    if SETTINGS_FILE.exists():
        with open(SETTINGS_FILE, "r") as f:
            data = json.load(f)
    else:
        data = DEFAULT_SETTINGS
        save_settings(SettingsUpdate(**data))

    return SettingsResponse(**data)


def save_settings(new_settings: SettingsUpdate):
    with open(SETTINGS_FILE, "w") as f:
        json.dump(new_settings.dict(), f)
