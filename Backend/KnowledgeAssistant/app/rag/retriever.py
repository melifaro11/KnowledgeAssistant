import os

from typing import Tuple, List

from langchain_community.vectorstores import FAISS
from langchain.chains.retrieval_qa.base import RetrievalQA
from langchain.schema import Document, BaseRetriever

from app.schemas.chat import ChatSource
from app.rag.registry import get_llm, get_embeddings

FAISS_ROOT = "storage/faiss_indexes"


def load_vectorstores(collection_id: str) -> List[BaseRetriever]:
    """
    Load all FAISS indexes for a collection and wrap each as a retriever.
    """
    collection_path = os.path.join(FAISS_ROOT, collection_id)
    if not os.path.exists(collection_path):
        return []

    retrievers: List[BaseRetriever] = []
    for source_id in os.listdir(collection_path):
        source_path = os.path.join(collection_path, source_id)
        if not os.path.isdir(source_path):
            continue
        try:
            db = FAISS.load_local(
                folder_path=source_path,
                embeddings=get_embeddings(),
                allow_dangerous_deserialization=True
            )
            retrievers.append(db.as_retriever(search_kwargs={"k": 5}))
        except Exception:
            continue
    return retrievers


class MultiRetriever(BaseRetriever):
    """
    A simple retriever that merges results from multiple underlying retrievers.
    """
    retrievers: List[BaseRetriever]

    def __init__(self, retrievers: List[BaseRetriever]):
        super().__init__(retrievers=retrievers)

    def get_relevant_documents(self, query: str) -> List[Document]:
        docs: List[Document] = []
        for retriever in self.retrievers:
            docs.extend(retriever.invoke(query))
        return docs


def ask_with_rag(collection_id: str, question: str) -> Tuple[str, List[ChatSource]]:
    retrievers = load_vectorstores(collection_id)
    if not retrievers:
        return "No indexed sources in the collection", []

    llm = get_llm()

    multi_retriever = MultiRetriever(retrievers)

    qa = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=multi_retriever,
        return_source_documents=True
    )

    result = qa.invoke({"query": question})

    answer = result.get("result") or result.get("answer")
    docs: List[Document] = result.get("source_documents", [])

    sources: List[ChatSource] = []
    for doc in docs:
        title = doc.metadata.get("title") or doc.metadata.get("source") or "Unknown"
        sources.append(ChatSource(title=title))

    return answer, sources
