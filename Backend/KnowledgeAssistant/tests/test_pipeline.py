import os
import pytest
from pathlib import Path
from typing import Dict, Any

from langchain.docstore.document import Document

import app.indexing.pipeline as pipeline
from app.models.source import SourceTypeEnum


class DummyLoaderSuccess:
    def __init__(self, location: str, config: Dict[str, Any]):
        pass

    def load_documents(self):
        return [Document(page_content="test", metadata={"source": "dummy", "title": "dummy"})]


class DummyLoaderEmpty:
    def __init__(self, location: str, config: Dict[str, Any]):
        pass

    def load_documents(self):
        return []


class DummyVectorStore:
    def __init__(self, docs, emb):
        pass

    def save_local(self, path: str):
        os.makedirs(path, exist_ok=True)
        # write a dummy file to signal save
        with open(os.path.join(path, "index.faiss"), "w") as f:
            f.write("dummy")


@pytest.fixture(autouse=True)
def setup_faiss_root(tmp_path, monkeypatch):
    fake_root = tmp_path / "faiss_indexes"
    # Patch FAISS_ROOT in pipeline
    monkeypatch.setattr(pipeline, "FAISS_ROOT", str(fake_root))
    # Patch embeddings
    monkeypatch.setattr(pipeline, "get_embeddings", lambda: None)
    return fake_root


def test_index_source_success(monkeypatch, tmp_path):
    # Patch loader to success
    monkeypatch.setattr(pipeline.LoaderRegistry, "get_loader", classmethod(lambda cls, st: DummyLoaderSuccess))
    # Patch FAISS.from_documents
    monkeypatch.setattr(pipeline.FAISS, "from_documents",
                        classmethod(lambda cls, docs, emb: DummyVectorStore(docs, emb)))

    collection_id = "col1"
    source_id = "src1"
    pipeline.index_source(collection_id, source_id, SourceTypeEnum.file.value, "loc", {})
    index_path = Path(pipeline.FAISS_ROOT) / collection_id / source_id
    assert (index_path / "index.faiss").exists()


def test_index_source_no_documents(monkeypatch):
    # Patch loader to empty
    monkeypatch.setattr(pipeline.LoaderRegistry, "get_loader", classmethod(lambda cls, st: DummyLoaderEmpty))
    with pytest.raises(ValueError):
        pipeline.index_source("c", "s", SourceTypeEnum.file.value, "loc", {})
