import os

from dotenv import load_dotenv
from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from app.db.session import init_db
from app.api import auth, collections, sources, chat, settings


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

load_dotenv()
os.environ["USER_AGENT"] = "KnowledgeAssistantBot/1.0"

init_db()

app.include_router(auth.router)
app.include_router(collections.router)
app.include_router(sources.router)
app.include_router(chat.router)
app.include_router(settings.router)
