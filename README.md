<div align="center">

# 🛡️ Azure Secure 3-Tier Platform

### Infrastructure as Code (Terraform) & Configuration Management (Ansible)

*Déploiement 100 % automatisé d'une architecture 3-tiers sécurisée sur Microsoft Azure, sans aucune IP publique sur les serveurs.*

<br/>

![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu_22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Zero Trust](https://img.shields.io/badge/Security-Zero_Trust-success?style=for-the-badge)

![Status](https://img.shields.io/badge/status-completed-brightgreen?style=flat-square)
![IaC](https://img.shields.io/badge/IaC-idempotent-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)

<br/>

<a href="https://skillicons.dev">
  <img src="https://skillicons.dev/icons?i=azure,terraform,ansible,linux,nginx,bash,git,github&perline=8" alt="Technologies utilisées"/>
</a>

</div>

---

## 📑 Sommaire

- [Aperçu du projet](#-aperçu-du-projet)
- [Objectifs & valeur ajoutée](#-objectifs--valeur-ajoutée)
- [Architecture](#️-architecture)
- [Stack technique](#️-stack-technique)
- [Structure du projet](#-structure-du-projet)
- [Prérequis](#-prérequis)
- [Guide de déploiement](#-guide-de-déploiement)
- [Captures d'écran](#-captures-décran)
- [Validation](#-checklist-de-validation)
- [Bonnes pratiques de sécurité](#-bonnes-pratiques-de-sécurité)
- [Compétences démontrées](#-compétences-démontrées)
- [Auteur](#-auteur)

---

## 🚀 Aperçu du projet

Ce projet illustre une approche **DevOps complète** : du provisionnement réseau (aucune IP publique sur les VMs) à la configuration applicative via des **tunnels SSH chiffrés** par Azure Bastion.

| Principe | Outil | Garantie |
|---|---|---|
| **Reproductibilité** | Terraform | Même infrastructure à chaque `terraform apply` |
| **Idempotence** | Ansible | Une exécution répétée ne casse aucun service (`changed=0`) |
| **Zero Trust** | Bastion + NSG + Key Vault | Aucun port exposé, aucun secret dans le code |

<!--
  Pour afficher la capture du portail Azure :
  1. Éditez ce README sur GitHub, glissez-déposez l'image dans l'éditeur
  2. Copiez le lien généré (https://github.com/user-attachments/...) ici :
  <div align="center"><img src="LIEN_IMAGE" alt="Portail Azure" width="800"/></div>
-->

---

## 🎯 Objectifs & valeur ajoutée

- 🔐 **Sécurité (Zero Trust)** : aucune VM n'a d'IP publique, l'accès administrateur passe uniquement par **Azure Bastion**.
- 🗝️ **Gestion des secrets** : mots de passe stockés dans **Azure Key Vault**, lus par les VMs grâce aux **Managed Identities**.
- 🌐 **Réseau isolé** : segmentation via VNet, subnets et **NSG** (Deny All par défaut). Base SQL isolée via **Private Endpoint**.
- ⚙️ **Automatisation** : déploiement avec `terraform apply`, puis configuration avec `ansible-playbook`.
- 📊 **Supervision** : ressources de monitoring définies dans `monitoring.tf`.

---

## 🏗️ Architecture

### A. Vue d'ensemble

```text
                         INTERNET
                            |
                   (Azure CLI / Ansible)
                            |
                            v
 +---------------------------------------------------------------+
 |  VNet : vnet-prod  (10.0.0.0/16)                              |
 |                                                               |
 |  +---------------------------------------------------------+  |
 |  |  Subnet Bastion (10.0.4.0/26)                           |  |
 |  |  [ Azure Bastion - SKU Standard ]                       |  |
 |  +---------------------------+-----------------------------+  |
 |                              | SSH via tunnel chiffre         |
 |                              v                                |
 |  +---------------------------------------------------------+  |
 |  |  Subnet App (10.0.2.0/24)          [NSG : Deny All]     |  |
 |  |  [ vm-app-0 : Nginx ]     [ vm-app-1 : Nginx ]          |  |
 |  +------+-----------------------------------+--------------+  |
 |         |                                   |                 |
 |         | SQL 1433                          | Managed Identity|
 |         v                                   v                 |
 |  +--------------------------+      +--------------------+     |
 |  | Subnet Data (10.0.3.0/24)|      |   Azure Key Vault  |     |
 |  | [ Azure SQL ]            |      |   (secrets)        |     |
 |  | Private Endpoint         |      +--------------------+     |
 |  +--------------------------+                                 |
 +---------------------------------------------------------------+

 Aucune IP publique sur les VMs : acces admin uniquement via Bastion.
```

### B. Workflow DevOps

```text
 [Etape 1]  Terraform init & apply
     |        -> Creation reseau, VMs, SQL, Key Vault, Bastion
     v
 [Etape 2]  Azure CLI : az network bastion tunnel
     |        -> Port local 127.0.0.1:2222 --> VM privee (port 22)
     v
 [Etape 3]  Ansible playbook (SSH via le tunnel)
     |        -> Installation et configuration de Nginx
     v
 [Etape 4]  Test d'idempotence
              -> 2e execution : changed=0
```

---

## 🛠️ Stack technique

| Composant | Technologie | Rôle dans le projet |
|---|---|---|
| ☁️ **Cloud** | Microsoft Azure | Hébergement de l'infrastructure |
| 🧱 **IaC** | Terraform (`azurerm`) | Création des ressources, state distant sécurisé |
| 🔧 **Config. Mgmt** | Ansible | Installation de Nginx, templates Jinja2, handlers |
| 🔐 **Sécurité** | Azure AD / RBAC | Key Vault, Managed Identities, Zero Trust |
| 🌐 **Réseau** | Azure Bastion | Accès administratif sans IP publique |
| 🌐 **Réseau** | VNet / NSG | Segmentation et pare-feu (Deny All par défaut) |
| 🖥️ **Système** | Ubuntu 22.04 | OS des machines virtuelles |

---

## 📂 Structure du projet

```text
.
├── ansible/
│   ├── ansible.cfg        # Configuration globale d'Ansible
│   ├── inventory.ini      # Inventaire pointant vers les tunnels (127.0.0.1)
│   └── playbook.yml       # Playbook idempotent (installation Nginx)
│
├── app.tf                 # VMs applicatives (tier App)
├── data.tf                # Data sources & base SQL (tier Data)
├── main.tf                # Resource Group et ressources principales
├── monitoring.tf          # Supervision
├── network.tf             # VNet, Subnets, NSG, Bastion
├── providers.tf           # Backend distant et provider AzureRM
├── random.tf              # Suffixes / mots de passe aléatoires
├── variable.tf            # Variables d'environnement
├── web.tf                 # Ressources du tier Web
│
├── .terraform.lock.hcl    # Verrouillage des versions des providers
├── .gitignore             # Exclusions Git (tfstate, clés SSH, secrets)
└── README.md
```

---

## ✅ Prérequis

| Outil | Version conseillée | Vérification |
|---|---|---|
| Azure CLI | ≥ 2.50 + extension `bastion` | `az version` |
| Terraform | ≥ 1.5 | `terraform -version` |
| Ansible | ≥ 2.14 | `ansible --version` |
| Abonnement Azure | Droits *Contributor* + *User Access Administrator* | `az account show` |

```bash
az login
az extension add --name bastion
```

---

## ⚡ Guide de déploiement

### 1️⃣ Provisionner l'infrastructure

```bash
terraform init       # Télécharge les providers et configure le backend
terraform validate   # Vérifie la syntaxe
terraform plan       # Prévisualise les changements
terraform apply      # Déploie sur Azure (≈ 5-10 min)
```

### 2️⃣ Ouvrir le tunnel sécurisé (Bastion)

> ⚠️ Nécessite le **SKU Standard** avec `--enable-tunneling true`.

```bash
# Récupérer l'ID de la VM cible
VM_ID=$(az vm show -g lergprod -n vm-app-0 --query id -o tsv)

# Ouvrir le tunnel (garder ce terminal ouvert)
az network bastion tunnel \
  --name bastion-prod \
  --resource-group lergprod \
  --target-resource-id "$VM_ID" \
  --resource-port 22 \
  --port 2222
```

### 3️⃣ Configurer et valider avec Ansible

```bash
cd ansible/

# Tester la connexion via le tunnel
ansible -i inventory.ini app -m ping

# Déployer la configuration (Nginx)
ansible-playbook -i inventory.ini playbook.yml

# Relancer pour vérifier l'IDEMPOTENCE (doit afficher changed=0)
ansible-playbook -i inventory.ini playbook.yml
```

### 4️⃣ Nettoyage

```bash
terraform destroy
```

---

## 📸 Captures d'écran

| Étape | Commande | Résultat attendu |
|---|---|---|
| **Déploiement** | `terraform apply` | `Apply complete! Resources: N added` |
| **Tunnel Bastion** | `az network bastion tunnel ...` | Tunnel ouvert sur `127.0.0.1:2222` |
| **Connexion** | `ansible -i inventory.ini app -m ping` | `"ping": "pong"` |
| **Idempotence** | 2ᵉ `ansible-playbook` | `changed=0` |

<!--
  Pour ajouter vos captures (affichage garanti) :
  glissez-déposez chaque image dans l'éditeur du README sur GitHub,
  puis collez le lien généré, par exemple :
  ![terraform apply](https://github.com/user-attachments/assets/xxxx)
-->

---

## 🧪 Checklist de validation

- [x] `terraform validate` s'exécute sans aucune erreur
- [x] Les ressources sont déployées dans le groupe `lergprod`
- [x] Le Bastion est en **SKU Standard** (requis pour le tunnel)
- [x] Les VMs privées n'ont **aucune IP publique** (`publicIps` est vide)
- [x] Ansible atteint les VMs via les tunnels (`ping` = `pong`)
- [x] Nginx est installé et le service tourne (`state: started`)
- [x] Le second `ansible-playbook` retourne `changed=0` (**idempotence validée**)

---

## 🔒 Bonnes pratiques de sécurité

<details>
<summary><b>1. Le fichier <code>.gitignore</code></b></summary>

Ne jamais versionner les fichiers d'état Terraform ni les clés privées :

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log

# Secrets
*.tfvars
.env
*.pem
id_rsa
```
</details>

<details>
<summary><b>2. Pourquoi ne pas exposer les VMs ?</b></summary>

Ouvrir le port 22 (SSH) sur Internet est une faille majeure (attaques par force brute). Avec **Azure Bastion**, le port SSH n'est jamais exposé publiquement : le trafic transite par le réseau privé Azure et l'accès est authentifié via **Azure AD**.
</details>

<details>
<summary><b>3. Pourquoi ne pas mettre les mots de passe dans le code ?</b></summary>

Les identifiants sont stockés dans **Azure Key Vault**. Les VMs utilisent une **Managed Identity** pour s'authentifier auprès du coffre-fort et récupérer les secrets, sans qu'aucun mot de passe n'apparaisse dans le code Terraform ou Ansible.
</details>

---

## 🧠 Compétences démontrées

| Domaine | Détail |
|---|---|
| 🧱 **Infrastructure as Code** | Configurations Terraform structurées par fichier (réseau, app, data, monitoring) |
| 🔧 **Configuration Management** | Playbooks Ansible avec templates Jinja2 et handlers |
| 🔐 **Cloud Security (Zero Trust)** | Segmentation réseau, RBAC, Key Vault, Managed Identities |
| 🌐 **Réseau Azure** | VNets, NSG, Private Endpoints, tunnels Bastion |
| 🛠️ **Troubleshooting** | Lock Terraform, accès RBAC, SKU Bastion, routage (tunnels locaux vs IP privées) |
| 🔄 **DevOps** | Idempotence et cycle de vie complet d'une infrastructure |

---

## 👤 Auteur

**Jiheddridi**

[![GitHub](https://img.shields.io/badge/GitHub-Jiheddridi-181717?style=flat-square&logo=github)](https://github.com/Jiheddridi)

---

<div align="center">
  <sub>⭐ Si ce projet vous est utile, n'hésitez pas à lui laisser une étoile !</sub>
</div>
