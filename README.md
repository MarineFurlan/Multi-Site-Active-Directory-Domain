# Multi-Site Active Directory Infrastructure Lab

**Status:** 🟢 Done

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

| Professional skill | What this lab demonstrates |
|---|---|
| Windows infrastructure administration | Deployment and configuration of Windows Server domain controllers |
| Active Directory administration | Domain, OU, user, and security group management |
| Multi-site infrastructure | Separate site subnets, AD Sites and Services, and inter-site replication |
| Group Policy management | Configuration and functional validation of workstation and account policies |
| Delegated administration | Scoped delegation of user-account management permissions |
| File access management | SMB share configuration and NTFS permission management |
| PowerShell automation | Scripted employee import and associated test files |
| Network administration | Inter-site routing using a Debian router |

Cloud identity synchronization and broader infrastructure automation are potential future improvements, not completed objectives.

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

### Active Directory Infrastructure

- Two Windows Server 2025 domain controllers deployed in the `novera.fr` forest.
- DNS installed on both domain controllers.
- Two AD sites configured: Bordeaux and Angoulême.
- Site subnets and the `BDX-ANG` site link configured.
- Inter-site replication validated after the initial synchronization period.

### Organizational Structure and Identity Management

- Site-based organizational unit hierarchy created.
- Departmental user OUs and security groups configured.
- Employee data imported using PowerShell automation.
- Employee import tests maintained in the `tests/` directory.

Relevant files:
- [`scripts/import-employees.ps1`](scripts/import-employees.ps1)
- [`tests/test-employees.ps1`](tests/test-employees.ps1)

### Group Policy

- Workstation inactivity lock policy configured and tested.
- Domain account lockout policy configured and tested.

### Delegated Administration

- Delegated user-account administration configured for the Bordeaux IT administration group.
- User creation, description modification, and password reset tested with a delegated account.

Documentation:
- [`docs/delegation-administration.md`](docs/delegation-administration.md)
- [`docs/delegation-user-accounts.md`](docs/delegation-user-accounts.md)

### Network Share and File Permissions

- SMB share created at `\\DC01-BDX\IT-Bordeaux`.
- `GG_Bordeaux_IT` granted Modify permissions at the SMB share and NTFS levels.
- `Administrateurs` granted Full Control at the SMB share level.
- Access tested with an authorized IT user and a non-IT user.

Documentation:
- [`docs/network-share-permissions.md`](docs/network-share-permissions.md)

**Lab limitation:** The file share is hosted on a domain controller for demonstration purposes. A dedicated file server would be preferable in a production environment.

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

The lab's core features have been validated through functional tests.

| Component | Validation performed | Result |
|---|---|---|
| Domain membership | Joined `CL01-BDX` to `novera.fr` | Successful |
| Inter-site networking | Tested connectivity between the Bordeaux and Angoulême subnets | Successful |
| AD replication | Checked replication using `repadmin`; the summary eventually returned no errors after allowing synchronization to complete | Successful |
| Workstation Group Policy | Tested the configured inactivity lock policy | Successful |
| Account lockout policy | Tested account lockout using a temporary test account | Successful |
| Delegated administration | Tested user creation, description modification, and password reset | Successful |
| SMB share access | Confirmed file creation by an authorized IT user and access denial for a non-IT user | Successful |
| Employee import | PowerShell import script and corresponding test file are present in the repository | Implementation present; test status to be documented separately |

These results reflect the tests performed during the lab. They do not constitute a complete production-readiness or disaster-recovery assessment.

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

### Current Limitations

- The file share is hosted on `DC01-BDX`, a domain controller. A dedicated file server would provide a clearer separation of roles.
- Inherited NTFS permissions remain in place on the shared folder. A more restrictive permissions review may be appropriate depending on the intended access policy.
- The lab validates core Active Directory functionality but does not constitute a full production-readiness assessment.
- Backup and disaster recovery procedures have not been implemented as part of the current scope.
- The deployment is only partially automated; not every infrastructure configuration step is performed by script.

### Potential Improvements

- Move file sharing to a dedicated member server.
- Review NTFS inheritance and document the intended effective permissions.
- Expand PowerShell automation for repeatable infrastructure deployment.
- Add automated validation for DNS, domain controller health, and replication.
- Implement and test backup and recovery procedures.
- Explore Microsoft Entra ID integration and directory synchronization as a separate project phase.
- Improve architecture diagrams and add selected deployment screenshots.

## 11. References

- [Microsoft Learn — Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/)
- [Microsoft Learn — Group Policy](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview)
- [Microsoft Learn — Active Directory replication](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/replication/active-directory-replication-concepts)
- [Debian Documentation](https://www.debian.org/doc/)
- [VMware Workstation Pro](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)