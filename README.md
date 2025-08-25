# Student Web App 2

## Overview
**Std-web-app2** is a containerized full-stack application deployed on AWS.  
Infrastructure is provisioned with **Terraform**, configured with **Ansible**, and orchestrated using **K3s (lightweight Kubernetes)**. The application demonstrates a modern DevOps workflow: Docker images pushed to Docker Hub, Kubernetes manifests for deployments, and Ingress routing with NGINX.  

## Features
- **Backend**: Python Flask API (backend/app.py)  
- **Frontend**: Static HTML served by Nginx (frontend/index.html)  
- **Database**: MySQL initialized with SQL scripts (db/init.sql)  
- **Containerization**: Docker images for backend, frontend, and database  
- **Orchestration**: K3s Kubernetes cluster with Deployments, Services, PVCs  
- **Ingress**: NGINX Ingress Controller routes `/` → frontend, `/api` → backend  
- **Automation**: Ansible for cluster setup, Terraform for infra provisioning  
- **Backup**: CronJob in backend Pod for automated database dumps  

## Project Structure
```
std-web-app2/
│── backend/               # Flask backend service
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── cron-backup.sh
│
│── frontend/              # Nginx frontend
│   ├── index.html
│   ├── nginx.conf
│   └── Dockerfile
│
│── db/                    # Database initialization
│   └── init.sql
│
│── k8s/                   # Kubernetes manifests
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── db-deploy.yaml
│   ├── backend-deploy.yaml
│   ├── frontend-deploy.yaml
│   ├── services.yaml
│   └── ingress.yaml
│
│── ansible/               # Ansible playbooks
│   ├── site.yml
│   └── db-backup.yaml
│
│── terraform/             # Terraform IaC
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
```

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/std-web-app2.git
cd std-web-app2
```

### 2. Provision Infrastructure (Terraform)
```bash
cd terraform
terraform init
terraform apply -auto-approve
```
This creates:  
- 1× EC2 (Ubuntu 22.04, t3.small, 30GB disk)  
- Security Group (22 restricted to your IP, 80/443 open)  

### 3. Configure Cluster (Ansible)
```bash
cd ../ansible
ansible-playbook -i hosts site.yml
```
This installs **K3s** and sets up kubectl.  

### 4. Deploy Application (Kubernetes)
```bash
cd ../k8s
kubectl apply -f .
```
- Backend available at `/api`  
- Frontend available at `/`  
- Database runs as stateful Deployment with PVC  

### 5. Database Backup
A CronJob inside the backend Pod runs `cron-backup.sh` to dump MySQL data into `/app/backups`.  

### 6. Access Application
Find your EC2 Public IP:  
```bash
echo $(terraform output -raw ec2_public_ip)
```
Open in browser:  
- `http://<EC2_IP>/` → Frontend  
- `http://<EC2_IP>/api/list` → Backend API  

## Technologies Used
- **Infrastructure**: AWS EC2, Terraform  
- **Configuration**: Ansible  
- **Containerization**: Docker  
- **Orchestration**: K3s Kubernetes  
- **Routing**: NGINX Ingress Controller  
- **Database**: MySQL with PVC storage  
- **Automation**: Kubernetes CronJob for DB backups  

## Contribution
1. Fork the repo  
2. Create a new feature branch:  
   ```bash
   git checkout -b feature-name
   ```  
3. Commit changes:  
   ```bash
   git commit -m "Add feature"
   ```  
4. Push and open a Pull Request  

## License
This project is licensed under the MIT License – see the LICENSE file for details.
