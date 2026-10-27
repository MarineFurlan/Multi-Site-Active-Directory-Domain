# Multi-Site Active Directory Infrastructure Lab

**Status:** 🟡 Core deployment completed — documentation and final review in progress

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Objectives](#2-objectives)
- [3. Architecture Overview](#3-architecture-overview)
- [4. Network Design](#4-network-design)
- [5. Active Directory Design](#5-active-directory-design)
- [6. Implemented Features](#6-implemented-features)
- [7. Deployment Guide](#7-deployment-guide)
- [8. Validation Results](#8-validation-results)
- [9. Repository Structure](#9-repository-structure)
- [10. Limitations and Future Improvements](#10-limitations-and-future-improvements)
- [11. References](#11-references)

## 1. Introduction

This project documents the deployment and configuration of a multi-site Active Directory Domain Services (AD DS) infrastructure in a virtualized environment.

The lab simulates a company operating across two French locations: Bordeaux and Angoulême. Each site has its own subnet and domain controller, while both locations belong to the same Active Directory forest.

The infrastructure is built with VMware Workstation Pro, Windows Server 2025, Windows 11 Pro, and a Debian 12 router.

The project focuses on Active Directory administration, multi-site replication, organizational unit design, Group Policy management, delegated administration, network connectivity, and file access permissions.

## 2. Objectives

| Professional skill | Implementation in this lab |
|---|---|
| Windows infrastructure administration | Deploy and configure AD DS domain controllers |
| Active Directory administration | Manage OUs, users, groups, DNS, and domain membership |
| Multi-site infrastructure | Configure separate subnets, AD sites, and site replication |
| Group Policy management | Configure and validate workstation and account policies |
| Delegated administration | Delegate user-account management to a designated IT group |
| File access management | Configure SMB share permissions and NTFS permissions |
| PowerShell automation | Use scripts to automate selected administrative tasks |
| Network administration | Route traffic between the two sites using Debian |

## 3. Architecture Overview

The lab consists of two Active Directory sites connected through a Debian router.

- **Bordeaux:** primary lab site, including the first domain controller and a Windows client.
- **Angoulême:** second site, including the second domain controller.
- **Routing:** Debian 12 router connecting both site subnets and providing external connectivity for the lab.

The two domain controllers belong to the same forest and domain: `novera.fr`.

<!-- Replace this placeholder with the current architecture diagram. -->

### Virtual Machines

| Virtual machine | Role | Operating system | IP address |
|---|---|---|---|
| `DC01-BDX` | Domain controller and DNS | Windows Server 2025 | `10.10.10.10` |
| `DC02-ANG` | Domain controller and DNS | Windows Server 2025 | `10.10.20.10` |
| `RTR01` | Inter-site router | Debian 12 | See Network Design |
| `CL01-BDX` | Domain-joined workstation | Windows 11 Pro | `10.10.10.20` |

## 4. Network Design

### Site subnets

| Site | Subnet | Default gateway | Domain controller |
|---|---|---|---|
| Bordeaux | `10.10.10.0/24` | `10.10.10.1` | `DC01-BDX` |
| Angoulême | `10.10.20.0/24` | `10.10.20.1` | `DC02-ANG` |

### Router interfaces

| Interface | Network | IP address |
|---|---|---|
| `ens33` | Bordeaux | `10.10.10.1/24` |
| `ens34` | Angoulême | `10.10.20.1/24` |
| `ens38` | VMware NAT | `192.168.31.131/24` |

The router enables IPv4 forwarding between the two site networks. Its NAT-facing interface provides external connectivity for the lab.

## 5. Active Directory Design

**Forest and domain:** `novera.fr`  
**NetBIOS domain name:** `NOVERA`

Active Directory Sites and Services contains two sites:

- `Bordeaux`, associated with subnet `10.10.10.0/24`.
- `Angouleme`, associated with subnet `10.10.20.0/24`.

The sites are connected through the `BDX-ANG` site link.

The organizational unit structure separates resources by location. Each site contains OUs for users, computers, servers, and groups. User OUs are further organized by department.

This design supports location-based administration and delegation while keeping security groups responsible for access control.

## 6. Implemented Features

### Active Directory deployment

- Two domain controllers deployed in the same domain.
- DNS installed on both domain controllers.
- Two AD sites and their associated subnets configured.
- Inter-site replication configured and validated during the lab.

### Organizational structure and identity management

- Site-based OU hierarchy created.
- Departmental user OUs created.
- Users and security groups provisioned using PowerShell scripts.

### Group Policy

- Workstation inactivity policy configured and tested.
- Domain account lockout policy configured and tested.

### Delegated administration

- User-account administration delegated to `GG_Bordeaux_IT_Admins` within the Bordeaux user OU scope.
- Account creation, description modification, and password reset tested with the delegated account.

The predefined delegation used includes broader permissions than password reset alone, including account deletion. This is a documented lab design trade-off.

### File sharing and permissions

- SMB share created on `DC01-BDX` at `\\DC01-BDX\IT-Bordeaux`.
- `GG_Bordeaux_IT` granted Modify permissions at the share and NTFS levels.
- `Administrateurs` granted Full Control at the share level.
- Access tested with an authorized IT user and a non-IT user.

The file share is hosted on a domain controller for lab purposes. A dedicated file server would be preferable in a production environment.

## 7. Deployment Guide

The detailed deployment procedures will be maintained as separate documentation files where appropriate.

The deployment covers:

1. Creating the VMware virtual networks and virtual machines.
2. Configuring static IP addresses and routing.
3. Installing and promoting the domain controllers.
4. Configuring AD sites, subnets, and replication.
5. Creating the OU structure, users, and security groups.
6. Joining the Windows client to the domain.
7. Configuring and validating Group Policies.
8. Delegating user-account administration.
9. Configuring and testing the SMB share and NTFS permissions.

<!-- Add links to detailed deployment guides as they are finalized. -->

## 8. Validation Results

The following features have been tested during the lab:

| Component | Validation |
|---|---|
| Domain membership | `CL01-BDX` joined to `novera.fr` |
| Inter-site connectivity | Communication between the two site subnets tested |
| AD replication | Replication summary returned without errors after the lab was allowed to stabilize |
| Workstation policy | Inactivity lock tested |
| Account lockout policy | Lockout behavior tested with a temporary test account |
| Delegated administration | User creation, description modification, and password reset tested |
| SMB share | Authorized access and file creation succeeded; non-IT access was denied |

## 9. Repository Structure

```text
.
├── data/
│   ├── employees.json
│   ├── references.json
│   └── roles.json
├── docs/
│   ├── delegation-administration.md
│   ├── delegation-user-accounts.md
│   └── network-share-permissions.md
├── scripts/
│   └── import-employees.ps1
├── tests/
│   └── test-employees.ps1
└── README.md
```

### Directory Overview

| Path | Purpose |
|---|---|
| `data/` | Employee data and reference data used by the import process |
| `docs/` | Documentation covering delegated administration, user-account management, and network share permissions |
| `scripts/` | PowerShell scripts used to automate administrative tasks |
| `tests/` | Tests for employee import functionality |
| `README.md` | Project overview, architecture, deployment scope, and validation results |
## 10. Limitations and Future Improvements

Potential improvements include:

- Deploying a dedicated file server instead of hosting the share on a domain controller.
- Reviewing and refining inherited NTFS permissions for more restrictive file access.
- Expanding automated validation and deployment scripts.
- Implementing and documenting a backup and recovery strategy.
- Exploring Microsoft Entra ID integration and synchronization in a separate phase.
- Improving infrastructure diagrams and deployment documentation.

## 11. References

- [Microsoft Learn — Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/)
- [Microsoft Learn — Group Policy](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview)
- [Microsoft Learn — Active Directory replication](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/replication/active-directory-replication-concepts)
- [Debian Documentation](https://www.debian.org/doc/)
- [VMware Workstation Pro](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)