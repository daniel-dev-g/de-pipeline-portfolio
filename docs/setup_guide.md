# Setup Guide — de-pipeline-portfolio

Registro de pasos ejecutados para configurar el entorno desde cero.
Útil como referencia personal y para entrevistas técnicas.

---

## 1. Prerequisitos locales

| Herramienta | Verificar | Instalar |
|---|---|---|
| Git | `git --version` | https://git-scm.com |
| Docker Desktop | `docker --version` | https://docker.com |
| Google Cloud CLI | `gcloud --version` | https://cloud.google.com/sdk |
| Python (uv) | `uv --version` | https://github.com/astral-sh/uv |

---

## 2. Repositorio GitHub

```bash
# Crear en GitHub:
# - Nombre: de-pipeline-portfolio
# - Visibilidad: public
# - Inicializar con README
# - .gitignore: Python
# - Licencia: MIT

# Clonar local
git clone https://github.com/<usuario>/de-pipeline-portfolio.git
cd de-pipeline-portfolio
```

---

## 3. Estructura de directorios

```bash
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
         scripts

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

touch data/landing/.gitkeep \
      data/samples/.gitkeep \
      data/processed/.gitkeep \
      credentials/.gitkeep

echo "*.env" >> .gitignore
echo "data/landing/*" >> .gitignore
echo "data/processed/*" >> .gitignore
echo "credentials/*.json" >> .gitignore
echo "credentials/" >> .gitignore
```

### Script reutilizable

```bash
# Guardar como scripts/setup_project.sh
chmod +x scripts/setup_project.sh
./scripts/setup_project.sh
```

---

## 4. Primer commit

```bash
git add .
git commit -m "chore: initial project structure"
git push origin main
```

### Convención de commits (Conventional Commits)

| Prefijo | Cuándo usarlo |
|---|---|
| `feat` | Agrega funcionalidad nueva |
| `fix` | Corrige un error |
| `docs` | Solo documentación |
| `refactor` | Reorganiza sin cambiar comportamiento |
| `test` | Agrega o modifica tests |
| `chore` | Configuración, dependencias, scripts |
| `ci` | Cambios en GitHub Actions |

---

## 5. Google Cloud CLI

### Instalación en Linux/Ubuntu

```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud --version
```

### Autenticación con Application Default Credentials (ADC)

```bash
# Login con cuenta personal — abre browser
gcloud auth application-default login

# Asignar proyecto de cuota (evita warning de quota)
gcloud auth application-default set-quota-project <PROJECT_ID>

# Configurar proyecto por defecto
gcloud config set project <PROJECT_ID>

# Verificar configuración
gcloud config list
```

> **Nota:** ADC es la alternativa segura al JSON de Service Account.
> En entornos con la política `iam.disableServiceAccountKeyCreation` activa
> (common en empresas), ADC es el método requerido para desarrollo local.
> En producción se usa Workload Identity Federation o Service Account
> attached a la instancia (sin credenciales en disco).

---

## 6. BigQuery — configuración inicial

```bash
# Crear dataset "raw" (landing zone de datos crudos)
bq mk --dataset \
  --location=US \
  <PROJECT_ID>:raw

# Crear dataset "pipeline_meta" (audit log)
bq mk --dataset \
  --location=US \
  <PROJECT_ID>:pipeline_meta

# Verificar datasets creados
bq ls
```

### Datasets del proyecto

| Dataset | Propósito |
|---|---|
| `raw` | Datos crudos tal como llegan de la fuente |
| `pipeline_meta` | Audit log de ejecuciones del pipeline |

---

## 7. Conceptos clave para entrevistas

### ¿Por qué ADC en vez de JSON?
- El JSON de Service Account es un archivo con credenciales permanentes
- Si se sube a GitHub por accidente → compromiso de seguridad total
- ADC usa las credenciales del usuario autenticado — no hay archivo que perder
- En producción: Workload Identity Federation (sin credenciales en disco)

### ¿Por qué location=US en BigQuery?
- US es multi-región — mayor disponibilidad y menor latencia en general
- Alternativas: `EU` (Europa), `us-central1` (región específica)
- Los datos no pueden moverse entre locations sin recrear el dataset
- Elegir location según dónde viven los datos origen y los usuarios

### ¿Qué es un dataset en BigQuery?
- Equivalente a un schema/database en PostgreSQL
- Agrupa tablas relacionadas
- Tiene su propia location, permisos y configuración de expiración
- Convención: separar `raw`, `staging`, `marts` en datasets distintos

### ¿Qué es Application Default Credentials?
- Mecanismo de autenticación de Google que busca credenciales en orden:
  1. Variable de entorno `GOOGLE_APPLICATION_CREDENTIALS`
  2. Credenciales de `gcloud auth application-default login`
  3. Service Account attached (en VMs de GCP)
- Las librerías de Python (google-cloud-bigquery) las usan automáticamente

---

## 8. Variables de entorno (.env.example)

```bash
# GCP
GCP_PROJECT_ID=de-portfolio-499511
GCP_LOCATION=US
GCP_BUCKET_NAME=de-portfolio-raw

# BigQuery
BQ_DATASET_RAW=raw
BQ_DATASET_META=pipeline_meta

# Pipeline
PIPELINE_ENV=development
ALERT_EMAIL=daniel@empresa.cl
```

> Copiar a `.env` local y completar valores reales.
> El archivo `.env` está en `.gitignore` — nunca se sube al repo.

---

## Estado actual del proyecto

- [x] Repositorio GitHub creado
- [x] Estructura de directorios
- [x] Google Cloud CLI instalado
- [x] Autenticación ADC configurada
- [x] pipeline_config.yaml con data contracts
- [ ] Dataset BigQuery creado
- [ ] Datos sintéticos generados
- [ ] Script de ingestión (readers, validators, loaders)
- [ ] Airflow en Docker
- [ ] dbt models
- [ ] CI/CD GitHub Actions
