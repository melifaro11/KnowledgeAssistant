import os
import dramatiq
import traceback

from dramatiq import actor
from dramatiq.brokers.redis import RedisBroker

from app.db.session import get_db
from app.models.source import Source, SourceTypeEnum
from app.indexing.pipeline import index_source


REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

broker = RedisBroker(url=REDIS_URL)
dramatiq.set_broker(broker)


@actor(max_retries=0)
def index_source_task(collection_id: str, source_id: str):
    """
    Background task: indexing giving source into collection.
    Reporting status and progress in database.
    """
    db = next(get_db())
    try:
        src: Source = db.query(Source).get(source_id)
        src.status = "running"
        src.progress = 0
        src.progress_message = "Starting indexing"
        db.commit()

        index_source(
            collection_id=collection_id,
            source_id=source_id,
            source_type=src.type.value,
            location=src.location,
            config=src.config or {},
        )

        src.status = "indexed"
        src.progress = 100
        src.progress_message = "Done"
        src.last_error = None
        db.commit()
    except Exception as e:
        src.status = "failed"
        src.last_error = f"{e}\\n{traceback.format_exc()}"
        db.commit()
