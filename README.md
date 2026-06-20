# Structure and deploy a High Availability multi-site Active Directory domain

**Status :** 🟡 In progress
<br/>
<br/>

## Table of content
- [Introduction](#1-introduction)
- [Design Decisions](#2-design-decisions)
- [Architecture Overview](#3-architecture-overview)
- [Deployment](#4-deployment)
- [Results](#5-results)
- [Infrastructure Cleaning](#6-infrastructure-cleaning)
- [Pricing](#7-pricing)
- [Improvements & Next Steps](#8-improvements--next-steps)
- [References](#9-references)
- [Repository Structure](#10-repo-structure)
<br/>
<br/>
<br/>

## 1. Introduction 
<a name="#1-introduction"></a>     
&emsp;&emsp;This lab walks through deploying a complete Active Directory domain on VMware, featuring two domain controllers for high availability, an organizational unit (OU) structure aligned with a multi-site environment, and Group Policies designed to secure workstations. 
All administration, including the creation of users, groups, OUs, and GPOs, is automated through PowerShell rather than performed manually through graphical management consoles.
<br/>
<br/>


## 2. Objectives 
<br/>

| Professional requirement                  | What this lab demonstrates                          |
|-------------------------------------------|-----------------------------------------------------|
| **Windows infrastructure administration** | Full AD DS domain deployment from scratch           | 
| **Active Directory proficiency**          | OU structure, user/group management, delegation     |
| **GPO and security management*            | Hardening GPOs tested and documented                |
| **Automation / process industrialization**| Reusable PowerShell scripts, zero manual action     |
| **Hybrid environment / Microsoft 365**    | Azure AD synchronization                            |

<br/>
<br/>
<br/>

## 3. Architecture Overview
<a name="#3-architecture-overview"></a> 


<details>
<summary>Virtual Machines Topology</summary>
 
<br/>
 
| Virtual machine   | Role                             | RAM     | Storage    | OS   |  IP                    | 
|-------------------|----------------------------------|---------|------------|------|------------------------|
| DC01              | Primary Domain Controller        |         |            |      |                        |
| DC02              | Secondary Domain Controller      |         |            |      |                        |

</details>
 
<br/>

<details>
<summary>Network Plan</summary>
 
<br/>

| Parameter         | Value             | 
|-------------------|-------------------|
| Lab network       | [Subnet]          |
| Domain name       | xxxx.local        |
| NetBIOS           |                   |

</details>

<br/>

<details>
<summary>Organizational unit structure</summary>
 
<br/>

```bash
domain.local
  ├── _ADMINISTRATION
  ├── SERVERS
  ├── USERS
  └── GROUPS
```

</details>
<br/>
<br/>
<br/>

## 4. Deployment
<a name="#4-deployment"></a> 

<br/>

<details>
<summary>Prerequisites</summary>
 
- Physical host with at least 16GO of RAM ( the 3 combined VMs require ~ 8 Go)
- VMWare Workstation installed
- Windows Server 2022 Evaluation ISO 
- Windows 10/11 ISO for the client machine

</details>

<br/>

<details>
<summary>Step 1 - Install and configure networking on DC01 </summary> 
</details>

<br/>

<details>
<summary>Step 2 - Promote to Domain Controller </summary>
</details>

<br/>

<details>
<summary>Step 3 - Post-installation validation </summary>
</details>

<br/>

<details>
<summary>Step 4 - Create the OU structure </summary>
</details>

<br/>

<details>
<summary>Step 5 - Create users and groups </summary>
</details>

<br/>

<details>
<summary>Step 6 - Deploy DC02 and verify replication </summary>
</details>

<br/>

<details>
<summary>Step 7 - Join the client workstation to the domain </summary>
</details>

<br/>

</details>


<br/>
<br/>
<br/>

## 5. Results
<a name="#5-results"></a>

Infrastructure overview :

<!-- Infrastructure screenshots -->

<br/>
<br/>
<br/>

## 7. Pricing
<a name="#7-pricing"></a>
The estimate below is based on the [AWS Pricing Calculator](https://calculator.aws).  

| Service                            | Selected Option                   | Estimated Monthly*  | Justification |
|------------------------------------|-----------------------------------|---------------------|---------------|
| **VMWare Workstation**             | Licence Evaluation (180 days)     | 0 USD               |               |
| **Windows Server 2022**            | Trial                             | 0 USD               |               |
| **Windows 10/11 Client**           |                                   | 0 USD               |               |
| **Microsoft 365 Business Premium** | Trial (30 days)                   | 0 USD               |               |
| **TOTAL**                          |                                   | **0 USD**           |

\* In production, real costs would lie in Windows Server licences, Microsoft 365 licences per user, hardware and/or cloud instances hosting DCs.  

<br/> 
<br/>
<br/>

## 8. Improvements & Next Steps
<a name="#8-improvements--next-steps"></a>

Potential enhancements to the infrastructure include:  
- 
- 
- 
 

<br/>
<br/>
<br/>

## 9. References
<a name="#9-references"></a>  
