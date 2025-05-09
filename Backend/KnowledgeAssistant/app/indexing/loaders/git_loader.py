import tempfile

from typing import List
from git import Repo

from langchain_community.document_loaders import TextLoader, DirectoryLoader


def load_git_repo(repo_url: str) -> List:
    with tempfile.TemporaryDirectory() as tmpdir:
        Repo.clone_from(repo_url, tmpdir)
        loader = DirectoryLoader(tmpdir, glob="**/*.py", loader_cls=TextLoader)
        return loader.load()
