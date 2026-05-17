# End-to-End Azure DevOps & Kubernetes Pipeline

## Overview
This project demonstrates a production-ready, cloud-native deployment process according to DevOps and DevSecOps best practices. The primary obejective is to achieve full automation - spanning from application development and containerization to automated infrastructure provisioning on **Microsoft Azure** and container orchestration within **Azure Kubernetes Service (AKS)** utilizing CI/CD pipelines.

### Tech Stack
* **Cloud Platform:** Microsoft Azure
* **Infrastructure as Code (IaC):** Terraform
* **Containerization & Local Dev:** Docker, Docker Compose
* **Backend Framework:** Python (FastiAPI, Uvicorn)
* **Orchestration:** Azure Kubernetes Service (AKS)
* **CI/CD Automation:** GitHub Actions
* **Security:** OIDC, Azure Workload Identity

---

## Project Roadmap
- [x] **Stage 1:** Cloud Infrastructure as Code (Terraform)
- [x] **Stage 2:** Backend Application & Containerization (FastAPI + Docker)
- [x] **Stage 3:** CI Pipeline Automation (GitHub Actions)
- [ ] **Stage 4:** Kubernetes Deployment, GitOps Integration & CD Pipeline - *In progress*
- [ ] **Stage 5:** Cloud Observability, Monitoring & Alerting (Prometheus & Grafana)

---

## Stages Breakdown & Usage

### Stage 1: Cloud Infrastructure (Terraform)
**Status:** `Completed`

**Description:**
In this stage, a secure cloud architecture was designed and deployed in the `polandcentral` region. The state file management was secured by migrating it to a remote backend (Azure Blob Storage) located within a dedicated management Resource Group.

**Provisioned Resources:**
* Networking: **VNet** along with dedicated **Subnet**.
* Registry: **Azure COntainer Registry (ACR)** for storing secure Docker images.
* Compute: **Azure Kubernetes Service (AKS)** with OIDC issuer and Workload Identity enabled.
* Security: Integrated AKS with ACR via a role assignment (`AcrPull`) to allow secure image pulling.

---

### Stage 2: Backend App & Containerization
**Status:** `Completed`

**Description:**
A lightweight Python backend application was created, followed by setting up the environment for containerization and local verification of the cloud registry integration.

**Implemented Components:**
* **FastAPI Application:** Features a root endpoint `/` returning the container's hostname (essential for testing load balancing in K8s) and a `/health` endpoint dedicated to Kubernetes Liveness/Readiness probes.
* **Dockerfile:** A highly optimized, multi-stage build utilizing a `python:3.11-slim` base image leveraging build layer caching.
* **Docker Compose:** A local development environment configured to pull and run images directly from the remote Azure Container Registry to test integration.

#### How to Run Locally (Stage 2):
1. Ensure you are authenticated with your Azure CLI and have access to the ACR instance.
2. Navigate to the project root directory and spin up the environment:
   ```bash
   docker compose up
3. The application will start listening on port `8000`. Verify it works by opening your browser and visiting: `http://localhost:8000/`.

---

### Stage 3: CI/CD Pipeline Automation
**Status:** `Completed`

**Description:**
This stage introduces a production-ready, highly optimized **decoupled dual-pipeline architecture** built from scratch. Instead of a single monolithic pipeline, the workflow is split into two specialized pipelines untlizing GitHub Actions **Path Filtering**. This ensures that cloud compute resources are saved by only running workflows relevant to the domain of the modified files.

**Implemented Components & Workflow:**
* **Pre-commit Hooks & Local Checkov (Shift-Left Security):** Configured local verification mechanisms to format and validate code (`terraform fmt`) automatically before a commit is made, preventing syntax errors and exposed secrets from reaching the remote repository. Checkov can also be run locally for instant feedback.
* **Infrastructure CI Pipeline (`terraform-ci.yml`):** Automatically triggers **exclusively** on pushes to `main` affecting the `terraform/**` directory. It runs an automated security audit of the IaC code via Checkov. It operates with `soft_fail: true` to log vulnerabilities as GitHub inline annotations without breaking the development flow at this stage.
* **Application CI Pipeline (`app-ci.yml`):** Automatically triggers **exclusively** on pushes to `main` affecting the application directory (`app/**`). It enforces a strict, multi-stage **"Fail-Fast" quality gate** before any Docker build takes place.
* **Code Linting (Ruff):** Instantly analyzes Python code quality, enforcing clean standards and catching syntax errors or unused imports in milliseconds.
* **Automated Unit Testing (Pytest & TestClient):** Executes automated test suites using FastAPI's `TestClient` to verify application logic and routing (e.g., checking that the critical `/health` endpoint returns `200 OK`), ensuring broken logic never gets containerized.
* **Software Composition Analysis (pip-audit):** Implements DevSecOps supply chain security by scanning the application dependencies (including transitive ones) against known vulnerability databases (CVEs) before the build stage.
* **Docker Build Context & Dual-Tagging:** Optimized to respect the subfolder project layout, passing `./app` as the build context. Every image is dual-tagged with the unique Git commit SHA (`${{ github.sha }}`) for absolute traceability, along with the `latest` tag, and pushed to **Azure Container Registry (ACR)**.
* **Secure Cloud Authentication:** Authenticates securely with Microsoft Azure using a dedicated *Service Principal* via GitHub Actions Secrets (`AZURE_CREDENTIALS` and `ACR_NAME`), eliminating hardcoded passwords.
* **Manual UI Triggers (`workflow_dispatch`):** Enabled manual execution capability for both pipelines directly from the GitHub Actions web interface for on-demand testing and debugging.

---

### Stage 4: Kubernetes Deployment & GitOps Integration
**Status:** `In progress`

**Description:**
This stage focuses on deploying the containerized application into the Azure Kubernetes Service (AKS) cluster. We will define Kubernetes manifests (Deployments, Services, Ingress) and transition to a modern **GitOps** approach, ensuring the cluster state automatically syncs with our Git repository.

**Planned Components & Workflow:**
* **Kubernetes Manifests:** Defining declarative YAML configurations for `Deployments` (managing pods), `Services` (internal networking), and `Ingress` (routing external HTTP traffic).
* **Automated CD Pipeline:** Extending the GitHub Actions workflow to securely connect to the AKS cluster using OIDC after a successful image push to ACR.
* **Zero-Downtime Rollout:** Integrating automation commands (such as `kubectl rollout restart`) within the pipeline. This triggers Kubernetes to perform a rolling update, replacing old containers with the newly built version seamlessly, without a sigle second of appication downtime.

---

### Stage 5: Cloud Observability & Monitoring
**Status:** `Planned`

**Description:**
The final stage establishes complete visibility over our cloud infrastructure and application health. We will deploy industry-standard monitoring tools within Kubernetes to collect metrics, visualize performance, and configure real-time alerts.

**Planned Components:**
* **Prometheus:** For scraping and storing time-series metrics from both the AKS cluster and the FastAPI application.
* **Grafana:** For building professional, interactive dashboards to monitor CPU/Memony uusage, network traffic, and HTTP request rates.
* **Alert manager:** To set up automated notifications (e.g., via Slack or Email) in case of high error rates of infrastructure downtime.
