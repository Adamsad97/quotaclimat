# ============================================================
# Stage 1 : Builder
# Image classique avec shell pour installer Poetry + dépendances
# ============================================================
FROM python:3.12-slim AS builder

ENV POETRY_VERSION=2.1.3 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_NO_INTERACTION=1

WORKDIR /app

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root --without dev

# ============================================================
# Stage 2 : Production – Docker Hardened Image (DHI)
# Image minimale sans shell, sans pip, sans outils système :
# surface d'attaque réduite au minimum (0 CVE connue).
# https://dhi.io → python:3.12
# ============================================================
FROM dhi.io/python:3.12

LABEL org.opencontainers.image.source="https://github.com/Adamsad97/quotaclimat"
LABEL org.opencontainers.image.description="QuotaClimat – metrics server (DHI hardened)"
LABEL org.opencontainers.image.licenses="MIT"

# PYTHONPATH pointe vers les packages du venv copié depuis le builder
# L'image DHI a Python à /usr/bin/python3 ; le venv fournit tous les packages
ENV PYTHONPATH=/app/.venv/lib/python3.12/site-packages \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# On copie UNIQUEMENT les librairies compilées (pas les binaires du venv
# qui sont des symlinks cassés dans l'image DHI) + le code source
COPY --from=builder /app/.venv/lib/python3.12/site-packages /app/.venv/lib/python3.12/site-packages
COPY . .

# Utilisateur non-root (bonne pratique sécurité)
USER nonroot

CMD ["python3", "-c", "import quotaclimat; print('QuotaClimat DHI image ready')"]
