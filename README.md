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


## 2. Design Decisions   
<br/>

| Components                                | Justification                                                                                                                                                   |
|-------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **PowerShell**                            | Automation of tasks and Windows compatibility                                                                                                                   | 
| **Azure AD Connect**                      | Testing hybrid replication for better availability                                                                                                              |
| **2 Domain Controllers**                  | High Availability principe                                                                                                                                      |

<br/>
<br/>
<br/>

## 3. Architecture Overview
<a name="#3-architecture-overview"></a> 

| Components        | AWS Service                                                                         | Role                                                                                                  | 
|-------------------|-------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| ** **             |                                                                                     |                                                                                                       |
| **Security**      |                                                                                     |                                                                                                       | 
| **Routing**       |                                                                                     |                                                                                                       |                       


<br/>
<br/>
<br/>

## 4. Deployment
<a name="#4-deployment"></a> 

<br/>

<details>
<summary>Prerequisites</summary>
 
-
-
-
-

</details>

<br/>

<details>
<summary>Step 1 -</summary> 

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
