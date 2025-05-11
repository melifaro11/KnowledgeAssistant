from abc import ABC, abstractmethod
from typing import Any, Dict, List
from langchain_community.docstore.document import Document


class BaseLoader(ABC):
    """
    Abstract base class for all document loaders.
    """

    def __init__(self, location: str, config: Dict[str, Any]) -> None:
        """
        Initialize the loader with a source location and configuration.

        Args:
            location: Path or URI of the data source.
            config: Loader-specific configuration parameters.
        """
        self.location = location
        self.config = config or {}

    @abstractmethod
    def load_documents(self) -> List[Document]:
        """
        Load documents from the configured source.

        Returns:
            A list of Document instances extracted from the source.
        """
        pass
