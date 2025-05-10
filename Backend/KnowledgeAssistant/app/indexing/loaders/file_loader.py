import os

from typing import List

from langchain_community.docstore.document import Document
from langchain_community.document_loaders import (
    TextLoader,
    UnstructuredPDFLoader,
    UnstructuredWordDocumentLoader,
    UnstructuredMarkdownLoader,
    UnstructuredHTMLLoader,
)


EXTENSION_LOADER_MAP = {
    ".txt": TextLoader,
    ".md": UnstructuredMarkdownLoader,
    ".pdf": UnstructuredPDFLoader,
    ".docx": UnstructuredWordDocumentLoader,
    ".html": UnstructuredHTMLLoader,
    ".htm": UnstructuredHTMLLoader,
    ".py": TextLoader,
    ".c": TextLoader,
    ".cpp": TextLoader,
    ".h": TextLoader,
    ".hpp": TextLoader,
    ".cs": TextLoader,
    ".java": TextLoader,
    ".js": TextLoader,
    ".ts": TextLoader,
    ".go": TextLoader,
    ".rs": TextLoader,
    ".swift": TextLoader,
    ".kt": TextLoader,
    ".sql": TextLoader,
}


def load_files(path: str) -> List[Document]:
    if not os.path.exists(path):
        raise ValueError("Path does not exist")

    documents = []

    if os.path.isdir(path):
        for root, _, files in os.walk(path):
            for f in files:
                if f.endswith(".txt") or f.endswith(".md"):
                    full_path = os.path.join(root, f)
                    loader = TextLoader(full_path)
                    docs = loader.load()
                    for doc in docs:
                        doc.metadata["source"] = full_path
                        doc.metadata["title"] = f
                    documents.extend(docs)
    elif os.path.isfile(path):
        loader = TextLoader(path)
        docs = loader.load()
        for doc in docs:
            doc.metadata["source"] = path
            doc.metadata["title"] = os.path.basename(path)
        documents.extend(docs)
    else:
        raise ValueError("Invalid path")

    return documents
