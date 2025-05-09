from typing import List

from langchain_community.document_loaders import WebBaseLoader
from langchain.docstore.document import Document


def load_urls(url: str) -> List[Document]:
    loader = WebBaseLoader(url)
    return loader.load()
