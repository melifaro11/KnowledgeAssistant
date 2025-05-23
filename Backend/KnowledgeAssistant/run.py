import subprocess
import signal
import sys
import os

COMMANDS = [
    ["dramatiq", "app.tasks"],
    ["fastapi", "run"],
]

processes = []


def shutdown(signum, frame):
    for p in processes:
        p.terminate()
    sys.exit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)

    os.environ.setdefault("REDIS_URL", "redis://localhost:6379/0")

    for cmd in COMMANDS:
        p = subprocess.Popen(cmd)
        processes.append(p)
        print(f"Started: {' '.join(cmd)} (pid {p.pid})")

    try:
        for p in processes:
            p.wait()
    except KeyboardInterrupt:
        shutdown(None, None)
