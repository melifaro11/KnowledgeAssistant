import os

from fastapi import FastAPI
from app.db.session import init_db
from app.api import auth, collections, sources, chat

os.environ["USER_AGENT"] = "KnowledgeAssistantBot/1.0"

app = FastAPI()

init_db()

app.include_router(auth.router)
app.include_router(collections.router)
app.include_router(sources.router)
app.include_router(chat.router)
