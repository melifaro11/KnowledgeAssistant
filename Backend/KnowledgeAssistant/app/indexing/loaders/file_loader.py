from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain.docstore.document import Document
import os
from typing import List


def load_files(path: str) -> List[Document]:
    if os.path.isdir(path):
        loader = DirectoryLoader(path, glob="**/*.txt", loader_cls=TextLoader, use_multithreading=True)
    elif os.path.isfile(path):
        loader = TextLoader(path)
    else:
        raise ValueError("File path does not exist")
    return loader.load()
