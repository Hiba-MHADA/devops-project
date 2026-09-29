> Copie du projet de groupe hébergé sur GitLab : https://gitlab.com/cloud-group3773711/devops-project (le pipeline CI/CD d'origine s'exécute sur GitLab CI).
#  Devops-Project — Master DSBD & IA

Pipeline CI/CD complet avec Kubernetes, Terraform, Ansible et Monitoring sur Azure.

---

## 👥 Équipe

| Membre | Rôle |
|--------|------|
| P1 (WIJDANE BASSIRY)| Infrastructure & Terraform & Ansible |
| P2 (HIBA MHADA)| Application Flask & Docker |
| P3 (SOUKAINA GRANDI)| CI/CD GitLab |
| P4 (AYA MOUJOUD )| Kubernetes & Monitoring |

---

##  Architecture
```
Developer Machine
      |
   git push
      |
 GitLab CI/CD
   /        \
Test        Build Image
   \        /
  Docker Hub (hibamhada/prix-immo-ai)
      |
   Deploy
      |
================================
   CLUSTER KUBERNETES (Azure)
   Master Node : 51.11.241.154
   Worker Node : 51.11.241.115
================================
      |
Terraform + Ansible
```

---

##  Technologies utilisées

| Outil | Rôle |
|-------|------|
| Azure VM | Hébergement des serveurs |
| Terraform | Création de l'infrastructure Azure |
| Ansible | Configuration des serveurs |
| Docker | Conteneurisation de l'application |
| Kubernetes | Orchestration des containers |
| GitLab CI/CD | Pipeline automatique |
| Helm | Gestionnaire de paquets pour le monitoring |
| Prometheus + Grafana | Monitoring du cluster |

---

##  Application

Interface interactive de prédiction de prix immobilier.

- **Image Docker** : `hibamhada/prix-immo-ai:1.0.0`
- **Port** : `30080`
- **URL** : `http://51.11.241.115:30080`

### Routes disponibles
| Route | Description |
|-------|-------------|
| `/` | Interface principale |
| `/health` | Health check Kubernetes |
| `/info` | Informations sur l'app |

---

##  Pipeline CI/CD

Le pipeline se déclenche automatiquement à chaque `git push` sur la branche `main` :
```
Stage 1 — TEST    ✅  Lance les tests unitaires pytest
Stage 2 — BUILD   ✅  Construit et pousse l'image Docker
Stage 3 — DEPLOY  ✅  Met à jour Kubernetes automatiquement
```

---

##  Variables CI/CD configurées

| Variable | Description |
|----------|-------------|
| `DOCKER_USERNAME` | Username Docker Hub |
| `DOCKER_PASSWORD` | Password Docker Hub (masked) |
| `K8S_WORKER_IP` | IP publique du worker Azure |
| `KUBECONFIG_CONTENT` | Fichier kubeconfig du cluster |

---

##  Lancer le projet

### 1. Infrastructure (Terraform)
```bash
cd terraform/
terraform init
terraform apply
```

### 2. Configuration (Ansible)
```bash
cd ansible/
ansible-playbook -i inventory.ini playbook.yml
```

### 3. Déploiement (Kubernetes)
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 4. Monitoring ( via helm )
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install my-monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```
---

##  Monitoring

| Service | URL |
|---------|-----|
| Grafana | `http://51.11.241.115:30080` |
| Prometheus | `http://51.11.241.115:30080` |

Grafana login : `admin / admin123`

---

##  Commandes utiles
```bash
# Vérifier le cluster
kubectl get nodes
kubectl get pods
kubectl get services

# Logs de l'application
kubectl logs -l app=devops-api

# Statut du pipeline
# GitLab → CI/CD → Pipelines
```
