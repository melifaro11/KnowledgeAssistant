import os
import shutil

from app.rag.registry import get_embeddings
from app.indexing.loaders.file_loader import load_files
from app.indexing.loaders.url_loader import load_urls
from app.indexing.loaders.git_loader import load_git_repo

from langchain_community.vectorstores import FAISS
from langchain.text_splitter import RecursiveCharacterTextSplitter

FAISS_ROOT = "storage/faiss_indexes"


def index_source(collection_id: str, source_id: str, source_type: str, location: str):
    output_path = os.path.join(FAISS_ROOT, collection_id, source_id)
    if os.path.exists(output_path):
        shutil.rmtree(output_path)

    if source_type == "file":
        documents = load_files(location)
    elif source_type == "url":
        documents = load_urls(location)
    elif source_type == "git":
        documents = load_git_repo(location)
    else:
        raise ValueError("Unsupported source type")

    if not documents:
        raise ValueError("No documents to index")

    splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)
    chunks = splitter.split_documents(documents)

    embeddings = get_embeddings()
    vectorstore = FAISS.from_documents(chunks, embeddings)

    os.makedirs(output_path, exist_ok=True)
    vectorstore.save_local(output_path)
