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
    print('index_source_task_started')
    db = next(get_db())
    src: Source = db.query(Source).get(source_id)

    print(f'Loaded source: {src}')
    if src in None:
        return

    try:
        src.status = "running"
        src.progress = 0
        src.progress_message = "Starting indexing"
        db.commit()

        print('EEEEEEEE')

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
        print(f'INDEX EXCEPTION: {e}')
        src.status = "failed"
        src.last_error = f"{e}\\n{traceback.format_exc()}"
        db.commit()
