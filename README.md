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

![Network_diagramm.png](images/Network_diagramm.png)

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

### Site Topology

The lab uses a single Active Directory forest and domain across two geographical sites:

- `Bordeaux`, associated with subnet `10.10.10.0/24`.
- `Angouleme`, associated with subnet `10.10.20.0/24`.

The sites are connected through the `BDX-ANG` site link. Active Directory Sites and Services represents the physical network topology and supports site-aware domain controller discovery and replication.

### Organizational Unit Design

The OU hierarchy follows a **site-first approach**, with resources separated by object type and user accounts further organized by department.

The structure is designed around the following principles:

- **Location-based administration:** separating Bordeaux and Angouleme provides clear administrative boundaries between the two locations.
- **Delegation scope:** site-specific OU branches make it easier to delegate administrative tasks to local IT teams without intentionally granting them the same scope across the entire domain.
- **Object separation:** dedicated OUs for users, computers, servers, and groups provide a clearer structure for administration and targeted Group Policy application.
- **Departmental organization:** user OUs are subdivided by department to make user management and the application of department-specific policies easier when required.
- **Separation of administration and access control:** OUs organize objects and define potential delegation and Group Policy scopes, while security groups are used to assign permissions to resources.

### Rationale and Trade-offs

A site-first hierarchy was chosen because the lab focuses on a multi-site organization in which administrative responsibilities may differ by location. It also provides a practical structure for testing delegated administration within a defined OU boundary.

An alternative would be to organize all users and computers primarily by department, regardless of location. That approach can be appropriate when departments are the main administrative boundary. For this lab, however, location was selected as the first organizational dimension because site-based administration and delegation are key objectives.

This OU hierarchy is a logical administrative design; it does not itself control network routing or Active Directory replication. Those functions are handled by the network configuration and Active Directory Sites and Services, respectively.

## 6. Implemented Features

### Active Directory Infrastructure

- Two Windows Server 2025 domain controllers deployed in the `novera.fr` forest.
- DNS installed on both domain controllers.
- Two AD sites configured: Bordeaux and Angoulême.
- Site subnets and the `BDX-ANG` site link configured.
- Inter-site replication validated after the initial synchronization period.

![Sites_structure.png](images/Sites_structure.png)

### Organizational Structure and Identity Management

- Site-based organizational unit hierarchy created.
- Departmental user OUs and security groups configured.
- Employee data imported using PowerShell automation.
- Employee import tests maintained in the `tests/` directory.

![OU_structure.png](images/OU_structure.png)

Relevant files:
- [`scripts/import-employees.ps1`](scripts/import-employees.ps1)
- [`tests/test-employees.ps1`](tests/test-employees.ps1)

### Group Policy

- Workstation inactivity lock policy configured and tested.
- Domain account lockout policy configured and tested.

![GPO_strategies.png](images/GPO_strategies.png)

### Delegated Administration

- Delegated user-account administration configured for the Bordeaux IT administration group.
- User creation, description modification, and password reset tested with a delegated account.


### Network Share and File Permissions

- SMB share created at `\\DC01-BDX\IT-Bordeaux`.
- `GG_Bordeaux_IT` granted Modify permissions at the SMB share and NTFS levels.
- `Administrateurs` granted Full Control at the SMB share level.
- Access tested with an authorized IT user and a non-IT user.


## 7. Deployment and Configuration

The lab was deployed manually in VMware Workstation Pro, with PowerShell used for employee data import and validation.

<details>
<summary><strong>Infrastructure deployment</strong></summary>

1. Create the VMware networks for Bordeaux (`10.10.10.0/24`), Angoulême (`10.10.20.0/24`), and NAT connectivity.
2. Deploy the Debian 12 router and configure its three network interfaces and IPv4 forwarding.
3. Install Windows Server 2025 on both domain controllers and assign static IP addresses.
4. Promote `DC01-BDX` to create the `novera.fr` forest, then join `DC02-ANG` as an additional domain controller.
5. Configure DNS, Active Directory sites, subnets, and the `BDX-ANG` site link.
6. Create the site-based OU structure, security groups, and employee accounts.
7. Join `CL01-BDX` to the domain and configure Group Policies.

</details>

<details>
<summary><strong>Delegated administration</strong></summary>

- Create the `GG_Bordeaux_IT_Admins` security group.
- Delegate user-account management within `Bordeaux\Users`.
- Validate user creation, description modification, and password reset with a delegated account.
- Verify that the delegated account cannot reset passwords outside its intended administrative scope.

**Note:** The predefined *Create, delete, and manage user accounts* delegation includes account deletion rights. Review the scope carefully before using this configuration outside the lab.

</details>

<details>
<summary><strong>Network share configuration</strong></summary>

- Create `C:\Shares\IT-Bordeaux` on `DC01-BDX` and publish it as `\\DC01-BDX\IT-Bordeaux`.
- Grant `GG_Bordeaux_IT` Modify permissions at the SMB share and NTFS levels.
- Grant `Administrateurs` Full Control at the SMB share level.
- Test file creation with an authorized IT account and verify access denial for a non-IT account.

**Note:** Inherited NTFS permissions were retained. The share is hosted on a domain controller for lab purposes; a dedicated file server is preferable in production.

</details>

<details>
<summary><strong>Validation and testing</strong></summary>

- Check domain membership and inter-site connectivity.
- Verify AD replication using `repadmin /replsummary`.
- Test the workstation inactivity lock and domain account lockout policies.
- Validate delegated administration and SMB share access.
- Run the employee import validation script when its test status needs to be confirmed.

</details>



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

![Server_replication_results.png](images/Server_replication_results.png)

These results reflect the tests performed during the lab. They do not constitute a complete production-readiness or disaster-recovery assessment.

## 9. Repository Structure
<details>
<summary>View repository structure</summary>

```text
.
├── data/
│   ├── employees.json
│   ├── references.json
│   └── roles.json
├── docs/
│   ├── images/
│   │   └── DNS_manager.png
│   │   └── GPO_strategies.png
│   │   └── Group_delegation_ITAdmins.png
│   │   └── ITFolder_permissions.png
│   │   └── Network_access_validation.png
│   │   └── Network_diagramm.png
│   │   └── OU_structure.png
│   │   └── Server_replication_results.png
│   │   └── Sites_structure.png
├── scripts/
│   └── import-employees.ps1
├── tests/
│   └── test-employees.ps1
└── README.md
```
</details>

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

## 11. References

- [Microsoft Learn — Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/)
- [Microsoft Learn — Group Policy](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview)
- [Microsoft Learn — Active Directory replication](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/replication/active-directory-replication-concepts)
- [Debian Documentation](https://www.debian.org/doc/)
- [VMware Workstation Pro](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)