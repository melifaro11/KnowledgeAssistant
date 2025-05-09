import os
from typing import Tuple, List
from app.schemas.chat import ChatSource

from app.rag.registry import get_embeddings, get_llm

from langchain.chains import RetrievalQA

from langchain_community.vectorstores import FAISS
from langchain_community.docstore.document import Document

FAISS_ROOT = "storage/faiss_indexes"


def load_vector_store(collection_id: str) -> FAISS:
    index_path = os.path.join(FAISS_ROOT, collection_id)
    if not os.path.exists(index_path):
        raise ValueError(f"FAISS index for collection {collection_id} not found")

    return FAISS.load_local(
        folder_path=index_path,
        embeddings=get_embeddings(),
    )


def ask_with_rag(collection_id: str, question: str) -> Tuple[str, List[ChatSource]]:
    # Загрузка индекса
    vectorstore = load_vector_store(collection_id)

    # Настройка модели
    retriever = vectorstore.as_retriever(search_kwargs={"k": 4})
    llm = get_llm()

    # RAG цепочка
    qa = RetrievalQA.from_chain_type(
        llm=llm,
        retriever=retriever,
        return_source_documents=True,
    )

    result = qa(question)
    answer = result["result"]
    docs: List[Document] = result["source_documents"]

    # Собираем список источников
    sources = []
    for doc in docs:
        metadata = doc.metadata
        title = metadata.get("title") or metadata.get("source") or "Unknown"
        sources.append(ChatSource(title=title, url=metadata.get("url"), page=None))

    return answer, sources
