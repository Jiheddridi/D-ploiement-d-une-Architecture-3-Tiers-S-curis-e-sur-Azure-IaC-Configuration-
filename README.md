# ☁️ Azure Secure 3-Tier Platform — Terraform & Ansible

![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoft-azure)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-Configuration-red?logo=ansible)
![DevOps](https://img.shields.io/badge/DevOps-CI%2FCD-green)

## 📖 À propos du projet

Ce projet démontre la création et la configuration d'une **infrastructure 3-tiers sécurisée (Zero Trust)** sur Microsoft Azure. 
L'objectif est de prouver une maîtrise complète de la chaîne DevOps : du provisionnement réseau sécurisé (sans IP publique) à la configuration des serveurs via des tunnels chiffrés, le tout 100% automatisé et idempotent.

---

## 🏗️ 1. Architecture de l'Infrastructure (Azure)

### A. Schéma théorique
```mermaid
graph TD
    Internet((🌍 Internet)) -->|HTTPS/SSH| Bastion[🛡️ Azure Bastion Standard]
    
    subgraph RG [Resource Group : lergprod]
        subgraph VNet [VNet : vnet-prod 10.0.0.0/16]
            Bastion -.->|Tunnels SSH| SubnetApp
            Internet -->|HTTP| LB[⚖️ Load Balancer]
            
            LB --> SubnetWeb[Subnet Web 10.0.1.0/24]
            LB --> SubnetApp[Subnet App 10.0.2.0/24]
            
            subgraph SubnetApp [Subnet App 10.0.2.0/24]
                VM1[💻 vm-app-0 - Nginx]
                VM2[💻 vm-app-1 - Nginx]
            end
            
            subgraph SubnetData [Subnet Data 10.0.3.0/24]
                SQL[🗄️ Azure SQL - Private Endpoint]
            end
            
            VM1 & VM2 -->|Managed Identity| KV[🔐 Azure Key Vault]
            VM1 & VM2 -.->|Connexion privée| SQL
        end
    end
    
    classDef azure fill:#0078D4,stroke:#fff,stroke-width:2px,color:#fff;
    classDef net fill:#E6F2FF,stroke:#0078D4,stroke-width:2px;
    class Bastion,LB,SQL,KV,VM1,VM2 azure;
    class RG,VNet net;
