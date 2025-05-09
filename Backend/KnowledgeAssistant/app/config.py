import os
from enum import Enum


class StorageType(str, Enum):
    local = "local"
    server = "server"


class ModelType(str, Enum):
    openai = "openai"
    local = "local"


MODEL_TYPE = os.getenv("MODEL_TYPE", "openai")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "openai")
VECTOR_STORE = os.getenv("VECTOR_STORE", "faiss")
