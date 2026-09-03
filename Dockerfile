FROM python:3.12-slim AS builder

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    POETRY_VERSION=2.1.3

WORKDIR /app

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root

FROM dhi.io/python:3.12

ENV PYTHONPATH=/app/.venv/lib/python3.12/site-packages
WORKDIR /app
COPY --from=builder /app/.venv/lib/python3.12/site-packages /app/.venv/lib/python3.12/site-packages
COPY . .

USER nonroot
CMD ["python3", "-m", "quotaclimat.monitoring.metrics_server"]
