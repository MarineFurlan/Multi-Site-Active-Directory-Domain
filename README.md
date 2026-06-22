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
 
| Virtual machine   | Role                             | RAM     | Storage    |   IP                    | 
|-------------------|----------------------------------|---------|------------|-------------------------|
| DC01              | Primary Domain Controller        | 2Go     | 20 Go      | 192.168.100.10          |
| DC02              | Secondary Domain Controller      | 2Go     | 20 Go      | 192.168.100.11          |
| WIN10             | Client                           | 1Go     | 10 Go      | Auto                    |

</details>
 
<br/>

<details>
<summary>Network Plan</summary>
 
<br/>

| Parameter         | Value                           | 
|-------------------|---------------------------------|
| Lab network       | 192.168.100.0 - 255.255.255.0   |
| Domain name       | ADlab.local                     |

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
 
- Physical host: XX GB RAM minimum
- Hypervisor installed (Here VMWare WorkStation)
- Windows Server Evaluation ISO (free, 180 days)
</details>

<br/>

<details>
<summary>Step 1 - Create local network </summary> 
</details>

<br/>

<details>
<summary>Step 2 - Create and configure primary domain controller DC01 </summary> 

 <br/>

1. Create VM
 
 <br/>
 
2. Give it a fixed IP
```bash
New-NetIPAddress -InterfaceAlias 'Ethernet0' -IPAddress 192.168.100.10 -PrefixLength 24
```

3. Restart VM
```bash
Restart-Computer
```

4. Use itself as dns server
```bash
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet0' -ServerAddresses 127.0.0.1
```

5. Rename VM
```bash
Rename-Computer -NewName 'DC01' -Restart
```
</details>

<br/>

<details>
<summary>Step 3  - Install Active Directory and configure local domain </summary> 

 ```bash
Install-WindowsFeature -Name AD-Domain-Services, Dns -IncludeManagementTools
```

</details>

<br/>

<details>
<summary>Step 4 - Create AD forest structure </summary> 

  ```bash
Install-ADDSForest `
-DomainName 'lab.local' `
-ForestMode 'WinThreshold' `
-DomainMode 'WinThreshold' `
-Force                                         
```

</details>

<br/>

<details>
<summary>Step 5 - Create and configure secondary domain controller DC02 </summary> 
</details>

<br/>

<details>
<summary>Step 6 - Create and configure client </summary> 
</details>

<br/>

<details>
<summary>Step 7 - Establish Group Policy Objects </summary> 
</details>

<br/>

<details>
<summary>Step 8 - Synchronize local Active Directory with Azure ADConnect cloud </summary> 
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
- NET-Bios is too old ??
- 
- 
 

<br/>
<br/>
<br/>

## 9. References
<a name="#9-references"></a>  
