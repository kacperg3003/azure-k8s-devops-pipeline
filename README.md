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
- [ ] **Stage 3:** CI/CD Pipeline Automation (GitHub Actions) - *In Progress*
- [ ] **Stage 4:** Kubernetes Deployment & GitOps Integration
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

#### Hot to Run Locally (Stage 2):
1. Ensure you are authenticated with your Azure CLI and have access to the ACR instance.
2. Navigate to the project root directory and spin up the environment:
   ```bash
   docker compose up
3. The application will start listening on port `8000`. Verify it works by opening your browser and visiting: `http://localhost:8000/`.

---

### Stage 3: CI/CD Pipeline Automation
**Status:** `In Progress`

**Description:**
Active development of full build and push automation. The goal is to configure a **GitHub Actions** workflow that triggers on every `git push` to the `main` branch. It will authenticate securely without persistent passwords/secrets using **OIDC (OpenID Connect)**, build a fresh Docker image, tag it. and push it automatically to the Azure Container Registry.

---

### Stage 4: Kubernetes Deployment & GitOps Integration
**Status:** `Planned`

**Description:**
This stage focuses on deploying the containerized application into the Azure Kubernetes Service (AKS) cluster. We will define Kubernetes manifests (Deployments, Services, Ingress) and transition to a modern **GitOps** approach, ensuring the cluster state automatically syncs with our Git repository.

---

### Stage 5: Cloud Observability & Monitoring
**Status:** `Planned`

**Description:**
The final stage establishes complete visibility over our cloud infrastructure and application health. We will deploy industry-standard monitoring tools within Kubernetes to collect metrics, visualize performance, and configure real-time alerts.

**Planned Components:**
* **Prometheus:** For scraping and storing time-series metrics from both the AKS cluster and the FastAPI application.
* **Grafana:** For building professional, interactive dashboards to monitor CPU/Memony uusage, network traffic, and HTTP request rates.
* **Alertmanager:** To set up automated notifications (e.g., via Slack or Email) in case of high error rates of infrastructure downtime.
