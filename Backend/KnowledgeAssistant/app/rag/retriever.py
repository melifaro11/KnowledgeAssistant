from typing import Tuple, List
from langchain.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain.docstore.document import Document
from langchain.vectorstores.base import VectorStoreRetriever
from langchain.chains.retrieval_qa.base import RetrievalQA
from app.schemas.chat import ChatSource
from app.rag.registry import get_llm, get_embeddings
import os

FAISS_ROOT = "storage/faiss_indexes"


def load_vectorstores(collection_id: str) -> List[VectorStoreRetriever]:
    collection_path = os.path.join(FAISS_ROOT, collection_id)
    if not os.path.exists(collection_path):
        return []

    retrievers = []
    for source_id in os.listdir(collection_path):
        source_path = os.path.join(collection_path, source_id)
        if os.path.isdir(source_path):
            try:
                db = FAISS.load_local(folder_path=source_path, embeddings=get_embeddings())
                retrievers.append(db.as_retriever(search_kwargs={"k": 3}))
            except Exception:
                continue
    return retrievers


def ask_with_rag(collection_id: str, question: str) -> Tuple[str, List[ChatSource]]:
    retrievers = load_vectorstores(collection_id)
    if not retrievers:
        return "В коллекции нет проиндексированных источников.", []

    llm = get_llm()

    # Наивное объединение документов из всех retrievers
    all_docs = []
    for retriever in retrievers:
        all_docs.extend(retriever.get_relevant_documents(question))

    if not all_docs:
        return "Не найдено релевантных документов.", []

    qa = RetrievalQA.from_chain_type(llm=llm, return_source_documents=True)
    result = qa.run(all_docs, return_only_outputs=False)

    answer = result["result"]
    docs: List[Document] = result["source_documents"]

    sources = []
    for doc in docs:
        title = doc.metadata.get("title") or doc.metadata.get("source") or "Источник"
        sources.append(ChatSource(title=title))

    return answer, sources
