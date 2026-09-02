# Docker Hardened Image (consigne Partie 3) : recherché sur dhi.io
FROM dhi.io/python:3.12

ENV PYTHONPATH=/app \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VERSION=2.1.3

WORKDIR /app

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root

COPY . .

CMD ["python", "--version"]
