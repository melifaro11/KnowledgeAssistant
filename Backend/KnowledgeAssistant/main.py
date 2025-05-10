import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db.session import init_db
from app.api import auth, collections, sources, chat, settings

os.environ["USER_AGENT"] = "KnowledgeAssistantBot/1.0"

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

init_db()

app.include_router(auth.router)
app.include_router(collections.router)
app.include_router(sources.router)
app.include_router(chat.router)
app.include_router(settings.router)
