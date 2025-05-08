# Team Knowledge AI (RAG Assistant)

**AI-powered knowledge assistant for research teams.**  

Index your documents, git repositories, URLs, and ask natural language questions to get accurate answers with sources.

---

## 🔎 Project Description

Team Knowledge AI is a knowledge retrieval system designed for teams and researchers.  
It allows users to create **collections** of data sources, index them into a vector database, and interact with the information using a conversational AI (RAG - Retrieval Augmented Generation).

The project consists of:
- **Backend**: FastAPI, LangChain, ChromaDB, PostgreSQL
- **Frontend**: (Flutter client / Web client compatible)
- **Vector Search**: Local or server storage (ChromaDB / FAISS)

---

## ✅ MVP Features

- User authentication (registration, login, logout)
- Collection management (create, list, delete)
- Source management (file, git, URL):
  - Add, view, delete
  - Indexing via LangChain
- Chat interface:
  - Ask questions within a collection
  - Retrieve answers with citations
  - Chat history per collection

---

## 🚀 Planned Features

- Scheduled source reindexing (e.g., daily git pulls)
- Multiple vector storage options (Weaviate, Pinecone)
- Team accounts & permissions
- Custom source pipeline integration (via Python scripts)
- Advanced search filters (by date, source type, relevance)
- Notifications (Slack/Telegram integrations)
- Local LLM support (Ollama, LLaMA 3 models)
- API for external integrations
- Frontend dark/light theme, Markdown viewer

---

## 🛠️ Installation

### 1 Clone the repository

```bash
git clone https://github.com/yourorg/team-knowledge-ai.git
cd team-knowledge-ai
```

### 2 Create virtual environment and install dependencies
```bash
python -m venv .venv
source .venv/bin/activate   # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 3 Configure environment variables

Create a .env file in the root folder:

```env
SECRET_KEY=your_super_secret_key
DATABASE_URL=postgresql+asyncpg://user:password@localhost/dbname
CHROMA_DB_PATH=./chromadb
OPENAI_API_KEY=your_openai_api_key
```

For local testing, you can use SQLite instead of PostgreSQL.

### 4 Start the application

```bash
uvicorn app.main:app --reload
```

API will be available at: http://127.0.0.1:8000

## 📖 API Overview

POST /auth/register — User registration

POST /auth/login — User login

POST /auth/logout — User logout

GET /collections — List collections

POST /collections — Create collection

GET /collections/{id} — Get collection details

DELETE /collections/{id} — Delete collection

POST /collections/{id}/sources — Add source

GET /collections/{id}/sources — List sources

POST /collections/{id}/sources/{source_id}/index — Index source

POST /collections/{id}/chat — Ask question

GET /collections/{id}/chat/history — Get chat history

## 👥 Contributing

We welcome contributions!
If you'd like to report bugs, suggest features, or contribute code, please open an issue or submit a pull request.