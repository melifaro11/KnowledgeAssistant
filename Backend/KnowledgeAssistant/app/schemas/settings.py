from pydantic import BaseModel
from enum import Enum


class StorageType(str, Enum):
    local = "local"
    server = "server"


class ModelType(str, Enum):
    openai = "openai"
    localLLM = "localLLM"


class SettingsResponse(BaseModel):
    storageType: StorageType
    modelType: ModelType


class SettingsUpdate(BaseModel):
    storageType: StorageType
    modelType: ModelType
