import os
from abc import ABC

from typing import Tuple, List

from langchain_community.vectorstores import FAISS
from langchain.chains.retrieval_qa.base import RetrievalQA
from langchain.schema import Document, BaseRetriever
from langchain_core.vectorstores import VectorStore

from app.schemas.chat import ChatSource
from app.rag.registry import get_llm, get_embeddings

FAISS_ROOT = "storage/faiss_indexes"


def load_vectorstores(collection_id: str) -> List[FAISS]:
    """
    Load all FAISS indexes for a collection and wrap each as a retriever.
    """
    collection_path = os.path.join(FAISS_ROOT, collection_id)
    if not os.path.exists(collection_path):
        return []

    faiss_list = []
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

            faiss_list.append(db)
        except Exception:
            continue

    return faiss_list


class MultiRetriever(BaseRetriever):
    def __init__(self, vectorstores: List[VectorStore], score_threshold: float = 0.5, top_k: int = 5):
        super().__init__()
        self._vectorstores = vectorstores
        self._score_threshold = score_threshold
        self._top_k = top_k

    def get_relevant_documents(self, query: str) -> List[Document]:
        docs: List[Document] = []
        for store in self._vectorstores:
            try:
                results = store.similarity_search_with_score(query, k=self._top_k)
                filtered = [doc for doc, score in results if score <= self._score_threshold]
                docs.extend(filtered)
            except:
                continue
        return docs


def ask_with_rag(collection_id: str, question: str) -> Tuple[str, List[ChatSource]]:
    vectorstores = load_vectorstores(collection_id)
    if not vectorstores:
        return "No indexed sources in the collection", []

    llm = get_llm()

    multi_retriever = MultiRetriever(vectorstores)

    qa = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=multi_retriever,
        return_source_documents=True
    )

    result = qa.invoke({"query": question})
    answer = result.get("result") or result.get("answer")
    docs: List[Document] = result.get("source_documents", [])

    seen = set()
    sources: List[ChatSource] = []
    for doc in docs:
        title = doc.metadata.get("title") or doc.metadata.get("source") or "Unknown"
        url = doc.metadata.get("url")
        page = doc.metadata.get("page")

        key = (title, url, page)
        if key not in seen:
            seen.add(key)
            sources.append(ChatSource(title=title, url=url, page=page))

    return answer, sources
