# Tetris Infrastructure

A complete CI/CD infrastructure setup for deploying a Tetris game application on AWS EKS using Jenkins, ArgoCD, and Terraform.

## 🏗️ Architecture Overview

This project provides Infrastructure as Code (IaC) for:
- **Jenkins Server**: CI/CD automation with security scanning
- **AWS EKS Cluster**: Kubernetes cluster for application deployment
- **Automated Pipelines**: Build, test, scan, and deploy workflows
- **GitOps with ArgoCD**: Continuous deployment to Kubernetes

## 📋 Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform >= 1.0
- Git
- S3 bucket named `argo-cd-deployment` for Terraform state (or modify backend.tf files)

## 🚀 Project Structure

```
.
├── Eks-terraform/          # EKS cluster infrastructure
│   ├── main.tf            # EKS cluster and node group resources
│   ├── provider.tf        # AWS provider configuration
│   └── backend.tf         # S3 backend for state management
├── Jenkins-terraform/      # Jenkins server infrastructure
│   ├── Main.tf            # EC2 instance with Jenkins
│   ├── install_jenkins.sh # Bootstrap script
│   ├── provider.tf        # AWS provider configuration
│   └── backend.tf         # S3 backend for state management
├── manifest/              # Kubernetes manifests
│   └── deployment.yml     # Tetris app deployment and service
├── eks-pipline.txt        # Jenkins pipeline for EKS provisioning
├── game-pipline.txt       # Jenkins pipeline for app deployment
└── shell-script.sh        # Manual installation script
```

## 🛠️ Infrastructure Components

### Jenkins Server
- **Instance Type**: t3.large
- **Region**: eu-central-1
- **AMI**: Ubuntu (ami-023adaba598e661ac)
- **Installed Tools**:
  - Jenkins
  - Docker
  - SonarQube (containerized)
  - Trivy (security scanner)
  - Terraform
  - kubectl
  - AWS CLI
  - Java 17 (Temurin)
  - Node.js

### EKS Cluster
- **Cluster Name**: EKS_CLOUD
- **Node Group**: Node-cloud
- **Instance Type**: t3.medium
- **Scaling**: 1-2 nodes (desired: 1)
- **Network**: Default VPC with public subnets

## 📦 Deployment Steps

### 1. Deploy Jenkins Server

```bash
cd Jenkins-terraform
terraform init
terraform plan
terraform apply -auto-approve
```

After deployment:
1. Access Jenkins at `http://<jenkins-public-ip>:8080`
2. Retrieve initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
3. Complete Jenkins setup wizard
4. Install required plugins:
   - Docker Pipeline
   - SonarQube Scanner
   - OWASP Dependency-Check
   - Kubernetes CLI
   - Git

### 2. Configure Jenkins

**Tools Configuration** (Manage Jenkins → Tools):
- JDK 17 (name: `jdk17`)
- NodeJS 16 (name: `node16`)
- SonarQube Scanner (name: `sonar-scanner`)
- Docker (name: `docker`)
- OWASP Dependency-Check (name: `DP-Check`)

**Credentials** (Manage Jenkins → Credentials):
- `docker`: Docker Hub credentials
- `github`: GitHub personal access token
- `Sonar-token`: SonarQube authentication token

**SonarQube Configuration**:
1. Access SonarQube at `http://<jenkins-public-ip>:9000`
2. Default credentials: admin/admin
3. Generate token and configure in Jenkins (Manage Jenkins → System → SonarQube servers)
4. Name: `sonar-server`

### 3. Deploy EKS Cluster

Create a Jenkins pipeline with `eks-pipline.txt`:
1. New Item → Pipeline
2. Add parameter: `action` (choice: apply/destroy)
3. Copy pipeline code from `eks-pipline.txt`
4. Run with `action=apply`

Or deploy manually:
```bash
cd Eks-terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Configure kubectl:
```bash
aws eks update-kubeconfig --name EKS_CLOUD --region eu-central-1
```

### 4. Install ArgoCD on EKS

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD server
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 5. Configure Application Pipeline

Create a Jenkins pipeline with `game-pipline.txt`:
1. New Item → Pipeline
2. Copy pipeline code from `game-pipline.txt`
3. Update GitHub repository URLs if needed
4. Run the pipeline

**Pipeline Stages**:
- Code checkout
- SonarQube analysis
- Dependency check (OWASP)
- Trivy filesystem scan
- Docker build and push
- Trivy image scan
- Update Kubernetes manifest
- GitOps commit

### 6. Configure ArgoCD Application

1. Access ArgoCD UI using LoadBalancer endpoint
2. Login with admin credentials
3. Create new application:
   - **Application Name**: tetris
   - **Project**: default
   - **Repository URL**: https://github.com/virajt71/tetris-infra.git
   - **Path**: manifest
   - **Cluster**: https://kubernetes.default.svc
   - **Namespace**: default
4. Enable auto-sync

## 🔒 Security Features

- **SonarQube**: Code quality and security analysis
- **Trivy**: Container vulnerability scanning
- **OWASP Dependency-Check**: Dependency vulnerability detection
- **IAM Roles**: Least privilege access for AWS resources
- **Security Groups**: Restricted network access

## 🌐 Accessing the Application

After successful deployment:
```bash
kubectl get svc tetris-service
```

Access the Tetris game at the LoadBalancer endpoint on port 80.

## 🧹 Cleanup

```bash
# Destroy EKS cluster
cd Eks-terraform
terraform destroy -auto-approve

# Destroy Jenkins server
cd ../Jenkins-terraform
terraform destroy -auto-approve
```

## 📝 Customization

### Change AWS Region
Update `region` in provider.tf files and backend.tf

### Change Instance Types
- Jenkins: Modify `instance_type` in Jenkins-terraform/Main.tf
- EKS nodes: Modify `instance_types` in Eks-terraform/main.tf

### Modify Security Groups
Update ingress rules in Jenkins-terraform/Main.tf

### Change Docker Image Repository
Update Docker Hub username in game-pipline.txt (replace `soulr27`)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is open source and available under the MIT License.

## 🐛 Troubleshooting

**Jenkins won't start**:
```bash
sudo systemctl status jenkins
sudo journalctl -u jenkins -f
```

**EKS connection issues**:
```bash
aws eks update-kubeconfig --name EKS_CLOUD --region eu-central-1
kubectl get nodes
```

**Docker permission denied**:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 📚 Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## 👥 Authors

- GitHub: [@virajt71](https://github.com/virajt71)

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!
