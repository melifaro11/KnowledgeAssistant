from pathlib import Path

from langchain.docstore.document import Document
from ..app.indexing.loaders.file_loader import FileLoader


def create_temp_file(tmp_path: Path, name: str, content: str) -> str:
    file_path = tmp_path / name
    file_path.write_text(content)
    return str(file_path)


def test_file_loader_single_txt(tmp_path):
    file_path = create_temp_file(tmp_path, "test.txt", "Hello world")
    loader = FileLoader(location=file_path, config={"recursive": False})
    docs = loader.load_documents()
    assert len(docs) == 1
    doc = docs[0]
    assert isinstance(doc, Document)
    assert doc.metadata["source"] == file_path
    assert doc.metadata["title"] == "test.txt"
    assert "Hello world" in doc.page_content


def test_file_loader_directory(tmp_path):
    dir_path = tmp_path / "docs"
    dir_path.mkdir()
    file1 = create_temp_file(dir_path, "a.md", "# Heading")
    file2 = create_temp_file(dir_path, "b.txt", "Content")
    loader = FileLoader(
        location=str(dir_path),
        config={"recursive": True, "extensions": [".md", ".txt"]},
    )
    docs = loader.load_documents()
    titles = {doc.metadata["title"] for doc in docs}
    assert titles == {"a.md", "b.txt"}


def test_file_loader_glob_pattern(tmp_path):
    dir_path = tmp_path / "data"
    dir_path.mkdir()
    create_temp_file(dir_path, "foo.txt", "foo")
    create_temp_file(dir_path, "bar.log", "log")
    loader = FileLoader(
        location=str(dir_path),
        config={"glob_pattern": "*.txt", "extensions": [".txt"]},
    )
    docs = loader.load_documents()
    assert len(docs) == 1
    assert docs[0].metadata["title"] == "foo.txt"
