from typing import List

from langchain_community.document_loaders import WebBaseLoader
from langchain.docstore.document import Document


def load_urls(url: str) -> List[Document]:
    loader = WebBaseLoader(url)
    docs = loader.load()
    for doc in docs:
        doc.metadata["url"] = url
        doc.metadata["title"] = doc.metadata.get("title") or "Web page"
    return docs
