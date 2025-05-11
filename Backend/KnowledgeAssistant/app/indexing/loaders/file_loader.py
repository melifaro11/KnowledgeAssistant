import os
import glob

from typing import Any, Dict, List, Optional
from langchain_community.docstore.document import Document

from app.indexing.loaders.base_class import BaseLoader

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
}


def default_file_extensions() -> List[str]:
    """
    Get the list of default file extensions supported by the loader.
    """
    return list(EXTENSION_LOADER_MAP.keys())


class FileLoader(BaseLoader):
    """
    Loader for filesystem-based sources: single files, directories, and glob patterns.
    """

    def __init__(
        self,
        location: str,
        config: Optional[Dict[str, Any]] = None,
    ) -> None:
        """
        Initialize FileLoader.

        Args:
            location: Path to file, directory, or glob pattern.
            config: Optional config keys:
                - recursive (bool): whether to recurse into directories (default True)
                - extensions (List[str]): list of allowed extensions (default all)
                - glob_pattern (str): glob pattern for file names (default '*')
        """
        super().__init__(location, config or {})
        self.recursive: bool = self.config.get("recursive", True)
        self.extensions: List[str] = self.config.get(
            "extensions", default_file_extensions()
        )
        self.glob_pattern: str = self.config.get("glob_pattern", "*")

    def _gather_paths(self) -> List[str]:
        """
        Gather file paths based on location and config.
        """
        paths: List[str] = []
        loc = self.location
        # If it's a directory
        if os.path.isdir(loc):
            pattern = os.path.join(
                loc,
                "**" if self.recursive else "",
                self.glob_pattern,
            )
            all_paths = glob.glob(pattern, recursive=self.recursive)
            for p in all_paths:
                if os.path.isfile(p) and os.path.splitext(p)[1].lower() in self.extensions:
                    paths.append(p)
        # If it's a file or glob
        else:
            # Use glob to match both files and patterns
            for p in glob.glob(loc, recursive=self.recursive):
                if os.path.isfile(p) and os.path.splitext(p)[1].lower() in self.extensions:
                    paths.append(p)
        return paths

    def load_documents(self) -> List[Document]:
        """
        Load documents from filesystem based on gathered paths.

        Returns:
            List of langchain Document objects with metadata.
        """
        documents: List[Document] = []
        paths = self._gather_paths()
        for path in paths:
            _, ext = os.path.splitext(path)
            loader_cls = EXTENSION_LOADER_MAP.get(ext.lower())
            if not loader_cls:
                continue
            loader = loader_cls(path)
            try:
                docs = loader.load()
            except Exception as e:
                # Optionally log error
                continue
            for doc in docs:
                doc.metadata["source"] = path
                doc.metadata["title"] = os.path.basename(path)
                documents.append(doc)
        return documents
