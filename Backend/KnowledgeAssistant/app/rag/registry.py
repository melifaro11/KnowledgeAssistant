from app.config import MODEL_TYPE, EMBEDDING_MODEL

from langchain_openai.chat_models import ChatOpenAI
from langchain_community.llms import LlamaCpp
from langchain_openai.embeddings import OpenAIEmbeddings
from langchain_community.embeddings import HuggingFaceEmbeddings


def get_llm():
    if MODEL_TYPE == "openai":
        return ChatOpenAI(temperature=0.3)
    elif MODEL_TYPE == "local":
        return LlamaCpp(model_path="./models/llama.gguf", temperature=0.3)
    else:
        raise ValueError("Unsupported model type")


def get_embeddings():
    if EMBEDDING_MODEL == "openai":
        return OpenAIEmbeddings()
    elif EMBEDDING_MODEL == "local":
        return HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
    else:
        raise ValueError("Unsupported embedding model")
