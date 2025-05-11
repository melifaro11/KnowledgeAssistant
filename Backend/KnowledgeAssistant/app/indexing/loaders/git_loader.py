import os
import tempfile

from typing import Any, Dict, List, Optional
from git import Repo

from langchain_community.docstore.document import Document
from langchain_community.document_loaders import TextLoader, DirectoryLoader

from .base_class import BaseLoader


class GitLoader(BaseLoader):
    """
    Loader for Git repositories.

    This loader clones a Git repository into a temporary directory and loads files
    based on specified glob patterns.

    Args:
        location: URL of the Git repository.
        config: Dictionary of configuration options:
            - branch (str): Git branch to clone (default 'main').
            - depth (int): Clone depth for shallow clone (default 1).
            - include_glob (str): Glob pattern for files to include (default '**/*.py').
            - exclude_glob (Optional[str]): Glob pattern for files to exclude (default None).
    """

    def __init__(
        self,
        location: str,
        config: Optional[Dict[str, Any]] = None,
    ) -> None:
        super().__init__(location, config or {})
        self.branch: str = self.config.get("branch", "main")
        self.depth: int = self.config.get("depth", 1)
        self.include_glob: str = self.config.get("include_glob", "**/*.py")
        self.exclude_glob: Optional[str] = self.config.get("exclude_glob")

    def load_documents(self) -> List[Document]:  # type: ignore
        """
        Clone the repository and load documents matching the glob patterns.

        Returns:
            List of Document instances with metadata fields 'repo_url', 'source', and 'title'.
        """
        documents: List[Document] = []

        with tempfile.TemporaryDirectory() as tmpdir:
            Repo.clone_from(
                self.location,
                tmpdir,
                branch=self.branch,
                depth=self.depth,
            )

            loader = DirectoryLoader(
                tmpdir,
                glob=self.include_glob,
                loader_cls=TextLoader,
            )
            loaded_docs = loader.load()

            for doc in loaded_docs:
                file_path = doc.metadata.get("source") or getattr(doc, "path", None)
                if file_path:
                    doc.metadata["source"] = file_path
                    doc.metadata["title"] = os.path.basename(file_path)

                doc.metadata["repo_url"] = self.location
                documents.append(doc)

        return documents
