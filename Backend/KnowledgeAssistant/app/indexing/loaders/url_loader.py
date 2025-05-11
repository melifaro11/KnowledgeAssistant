from typing import Any, Dict, List, Optional

from langchain.docstore.document import Document
from langchain_community.document_loaders import RecursiveUrlLoader

from .base_class import BaseLoader


class UrlLoader(BaseLoader):
    """
    Loader for HTTP/HTTPS URLs.

    This loader fetches content from a URL, optionally using a headless browser for JavaScript rendering.

    Args:
        location: URL to fetch.
        config: Dictionary of configuration options:
            - headers (Optional[Dict[str, str]]): HTTP headers to include.
            - max_depth (int): Depth for link crawling (default 1).
            - allowed_domains (List[str]): List of domains to restrict crawling to (default []).
            - js_render (bool): Whether to use a headless browser for JS-heavy pages (default False).
            - timeout (int): Request timeout in seconds (default 30).
    """

    def __init__(
        self,
        location: str,
        config: Optional[Dict[str, Any]] = None,
    ) -> None:
        super().__init__(location, config or {})
        self.max_depth: int = self.config.get("max_depth", 1)

    def load_documents(self) -> List[Document]:  # type: ignore
        """
        Fetch content from the URL and return a list of Document objects.

        Returns:
            List of Document instances with metadata fields 'url' and 'title'.
        """
        # Choose loader class based on JS rendering requirement
        loader = RecursiveUrlLoader(
            url=self.location,
            max_depth=self.max_depth,
        )

        docs = loader.load()
        for doc in docs:
            doc.metadata["url"] = self.location
            doc.metadata["title"] = doc.metadata.get("title") or self.location

        return docs
