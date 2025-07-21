FROM python:3.12-slim AS builder

WORKDIR /app

# Installer poetry
RUN pip install --no-cache-dir poetry

# Copier les fichiers de dépendances
COPY pyproject.toml poetry.lock ./

# Installer les dépendances sans installer le projet lui-même
# J'ai des erreurs, je n'arrive pas a lancer poetry :(
RUN poetry config virtualenvs.create false \
  && poetry install --only main --no-root --no-interaction --no-ansi

# Copier le code source
COPY app app/

# Étape finale
FROM python:3.12-slim

WORKDIR /app

# Copier l’environnement Python
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /app /app

EXPOSE 5000

CMD ["python", "app/main.py"]
