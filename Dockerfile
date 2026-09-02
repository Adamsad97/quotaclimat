# Stage 1: Builder
FROM python:3.12-slim AS builder

ENV POETRY_VERSION=2.1.3 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_NO_INTERACTION=1

WORKDIR /app

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

# Copy only requirements to cache them in docker layer
COPY pyproject.toml poetry.lock ./
# Install dependencies in /app/.venv
RUN poetry install --no-root --without dev

# Stage 2: Final Hardened Image
# Docker Hardened Image (consigne Partie 3) : recherché sur dhi.io
FROM dhi.io/python:3.12

ENV PYTHONPATH=/app \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Copy the virtual environment from the builder
COPY --from=builder /app/.venv /app/.venv

# Copy the application code
COPY . .

CMD ["python", "--version"]
