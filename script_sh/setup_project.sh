#!/bin/bash
# setup_project.sh — Crea la estructura base del proyecto
set -e  # detiene el script si cualquier comando falla

echo "Creando estructura de directorios..."
mkdir -p .github/workflows \
         data/landing \
         data/samples \
         data/processed \
         ingestion \
         dags \
         transforms/models/staging \
         transforms/models/marts \
         tests/unit \
         tests/integration \
         docker \
         docs \
         credentials \
         script_sh

echo "Creando archivos base..."
touch ingestion/__init__.py \
      ingestion/readers.py \
      ingestion/validators.py \
      ingestion/loaders.py \
      dags/pipeline_dag.py \
      docker/docker-compose.yml \
      .env.example \
      pipeline_config.yaml \
      pyproject.toml \
      docs/architecture.md

echo "Creando .gitkeep en directorios vacíos..."
touch data/landing/.gitkeep \
      data/samples/.gitkeep \
      data/processed/.gitkeep \
      credentials/.gitkeep

echo "Actualizando .gitignore..."
cat >> .gitignore << 'GITIGNORE'
*.env
data/landing/*
data/processed/*
credentials/*.json
GITIGNORE

echo "Estructura creada correctamente."
