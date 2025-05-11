from typing import Dict, Type

from .base_class import BaseLoader
from app.models.source import SourceTypeEnum


class LoaderRegistry:
    """
    Registry for mapping source types to loader classes.
    """
    _registry: Dict[SourceTypeEnum, Type[BaseLoader]] = {}

    @classmethod
    def register(cls, source_type: SourceTypeEnum, loader_cls: Type[BaseLoader]) -> None:
        """
        Register a loader class for a given source type.

        Args:
            source_type: Enum value representing the source type.
            loader_cls: Loader class implementing BaseLoader.
        """
        cls._registry[source_type] = loader_cls

    @classmethod
    def get_loader(cls, source_type: SourceTypeEnum) -> Type[BaseLoader]:
        """
        Retrieve the loader class registered for the given source type.

        Args:
            source_type: Enum value representing the source type.

        Returns:
            Loader class implementing BaseLoader.

        Raises:
            KeyError: If no loader is registered for source_type.
        """
        try:
            return cls._registry[source_type]
        except KeyError:
            raise KeyError(f"No loader registered for source type {source_type}")


# Register built-in loaders
from .file_loader import FileLoader
from .git_loader import GitLoader
from .url_loader import UrlLoader

LoaderRegistry.register(SourceTypeEnum.file, FileLoader)
LoaderRegistry.register(SourceTypeEnum.git, GitLoader)
LoaderRegistry.register(SourceTypeEnum.url, UrlLoader)
