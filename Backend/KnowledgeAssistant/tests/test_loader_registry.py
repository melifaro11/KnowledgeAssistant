import pytest
from typing import Dict, Any

from app.indexing.loaders.registry import LoaderRegistry
from app.models.source import SourceTypeEnum


class DummyLoader:
    def __init__(self, location: str, config: Dict[str, Any]):
        pass

    def load_documents(self):
        return []


def test_register_and_get_loader():
    # Register DummyLoader for file
    LoaderRegistry.register(SourceTypeEnum.file, DummyLoader)
    loader_cls = LoaderRegistry.get_loader(SourceTypeEnum.file)
    assert loader_cls is DummyLoader


def test_get_loader_not_found():
    # Unregister url loader if exists
    # Force KeyError for url if not overridden
    with pytest.raises(KeyError):
        LoaderRegistry.get_loader(SourceTypeEnum.url)
