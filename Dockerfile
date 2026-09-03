# Stage 1 : Builder - image classique pour installer les dépendances
FROM python:3.12-slim AS builder

ENV POETRY_VERSION=2.1.3 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_NO_INTERACTION=1

WORKDIR /app

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root --without dev

# Stage 2 : Image de production (slim = minimale, sécurisée)
# Note DHI: la construction avec dhi.io/python:3.12 est validée en CI/CD
# (voir .github/workflows/ci.yml étape "Build Docker image"). En local,
# on utilise python:3.12-slim pour la compatibilité du docker-compose.
FROM python:3.12-slim

ENV PYTHONPATH=/app \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Copier uniquement le venv compilé depuis le builder
COPY --from=builder /app/.venv /app/.venv

# Copier le code applicatif
COPY . .

CMD ["python", "--version"]
