import os
import shutil
from typing import Any, Dict

from app.rag.registry import get_embeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS

from app.indexing.loaders.registry import LoaderRegistry
from app.models.source import SourceTypeEnum

FAISS_ROOT = "storage/faiss_indexes"


def index_source(
    collection_id: str,
    source_id: str,
    source_type: str,
    location: str,
    config: Dict[str, Any],
) -> None:
    """
    Index documents from a given source into FAISS.

    Args:
        collection_id: Identifier of the target collection.
        source_id: Identifier of the source to index.
        source_type: Type of the source (must match SourceTypeEnum).
        location: Path or URL for the loader to fetch data from.
        config: Loader-specific configuration parameters.

    Raises:
        KeyError: If no loader is registered for the given source type.
        ValueError: If no documents are returned by the loader.
    """
    output_path = os.path.join(FAISS_ROOT, collection_id, source_id)
    if os.path.exists(output_path):
        shutil.rmtree(output_path)

    loader_cls = LoaderRegistry.get_loader(SourceTypeEnum(source_type))
    loader = loader_cls(location, config)
    documents = loader.load_documents()
    if not documents:
        raise ValueError("No documents to index")

    ts_config = config.get("text_splitter", {})
    chunk_size = ts_config.get("chunk_size", 1000)
    chunk_overlap = ts_config.get("chunk_overlap", 100)
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
    )
    chunks = splitter.split_documents(documents)

    embeddings = get_embeddings()
    vectorstore = FAISS.from_documents(chunks, embeddings)

    os.makedirs(output_path, exist_ok=True)
    vectorstore.save_local(output_path)
