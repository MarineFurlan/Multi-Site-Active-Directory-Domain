# NOVERA — Multi-Site Active Directory
## Technical Guide: Site-Based Administrative Delegation

**Project:** LAB — Active Directory Multi-Site  
**Domain:** `novera.fr`  
**Scope:** Delegated user-account administration  
**Environment:** Windows Server 2025, Windows 11 Pro, RSAT  
**Status:** Functional tests completed successfully

---

## 1. Objective

Implement delegated administration in Active Directory so that the Bordeaux IT administration group can manage user accounts within its assigned organizational unit (OU) scope, without granting its members Domain Admin privileges.

The configuration follows the principle of least privilege: each group should receive only the permissions required for its administrative responsibilities.

The final configuration uses a predefined delegation task that grants broader user-account management permissions than password reset alone. This is a documented design trade-off for the lab.

## 2. Technical Environment

| Component | Configuration |
|---|---|
| Active Directory domain | `novera.fr` |
| Bordeaux domain controller | `DC01-BDX` |
| Angoulême domain controller | `DC02-ANG` |
| Administration workstation | `CL01-BDX` |
| Administration tool | RSAT — `dsa.msc` |
| Delegated test account | `smichel` |
| Delegation group | `GG_Bordeaux_IT_Admins` |
| Target Bordeaux OU | `OU=Users,OU=Bordeaux,DC=novera,DC=fr` |
| Test OU | `Lab-Tests` |

## 3. Delegation Design

The `GG_Bordeaux_IT_Admins` group receives delegated permissions to manage user accounts within the designated Bordeaux OU scope.

Delegation is configured through **Active Directory Users and Computers** (`dsa.msc`), using the **Delegate Control** wizard.

Two delegation stages were performed:

1. **Password reset delegation:** the group was granted the task to reset user passwords and require a password change at the next logon.
2. **User-account management delegation:** the predefined **Create, delete, and manage user accounts** task was subsequently applied to `OU=Users,OU=Bordeaux,DC=novera,DC=fr`.

The second task grants broader permissions, including the ability to delete user accounts. The final configuration must therefore not be described as password-reset-only delegation.

The effective scope depends on the permissions configured on the target OU, their inheritance, and any other permissions assigned to the group or its members.

## 4. Configuration Procedure

### 4.1 Prepare the Test Environment

1. Create the `Lab-Tests` OU under `Bordeaux\Users`.
2. Create a temporary test account named `lab.test` in that OU.
3. Use the `smichel` account to perform the tests from `CL01-BDX`.

### 4.2 Test Before Delegation

1. Open `dsa.msc` as `NOVERA\smichel`.
2. Locate the `lab.test` account.
3. Attempt to reset its password.
4. Record the result.

**Observed result:** Access denied.

### 4.3 Delegate Password Reset on the Test OU

1. On `DC01-BDX`, open `dsa.msc` using an authorized administrative account.
2. Right-click `Lab-Tests`.
3. Select **Delegate Control**.
4. Add `GG_Bordeaux_IT_Admins`.
5. Select the task to reset user passwords and force a password change at the next logon.
6. Complete the wizard.

### 4.4 Validate Delegation on the Test OU

From the `smichel` session on `CL01-BDX`:

1. Refresh the Active Directory Users and Computers console.
2. Locate the `lab.test` account.
3. Select **Reset Password**.
4. Enter and confirm a test password.
5. Complete the operation.

**Observed result:** Password reset succeeded.

### 4.5 Extend Delegation to the Bordeaux Users OU

On `DC01-BDX`, using an authorized administrative account:

1. Open `dsa.msc`.
2. Right-click `Bordeaux\Users`.
3. Select **Delegate Control**.
4. Add `GG_Bordeaux_IT_Admins`.
5. Select the predefined task **Create, delete, and manage user accounts**.
6. Complete the wizard.

**Important:** This predefined task grants broader user-account management rights, including account deletion. It should not be treated as equivalent to password-reset-only delegation.

### 4.6 Test the Bordeaux Scope

From the `NOVERA\smichel` session on `CL01-BDX`:

1. Access a user account within the Bordeaux OU scope.
2. Perform an account-management operation.
3. Record the result.

**Observed results:** User creation, description modification, and password reset succeeded within the tested Bordeaux scope.

### 4.7 Test Outside the Delegated Scope

From the same session:

1. Locate a test account in an Angoulême OU.
2. Attempt to reset its password.
3. Record the result.

**Observed result:** The operation was denied for the tested account outside the delegated Bordeaux scope.

## 5. Test Summary

| Test | Result | Conclusion |
|---|---|---|
| Reset `lab.test` before delegation | Access denied | The account lacked sufficient permissions under the test conditions |
| Reset `lab.test` after delegation on `Lab-Tests` | Successful | Password-reset delegation worked on the test OU |
| User creation within the Bordeaux scope | Successful | The delegated account could create a user in the tested location |
| Description modification within the Bordeaux scope | Successful | The delegated account could modify the tested user account |
| Password reset within the Bordeaux scope | Successful | Password reset worked within the tested scope |
| Password reset on a tested Angoulême account | Access denied | The operation was denied outside the intended Bordeaux scope |

## 6. Results and Lessons Learned

This implementation demonstrates delegated Active Directory administration without assigning the Domain Admin role to the delegated test account.

The lab covers:

- Organizational unit and security group management.
- Active Directory delegation through the Delegate Control wizard.
- Least-privilege principles and the implications of predefined delegation tasks.
- Positive and negative permission tests.
- Remote administration from a Windows 11 workstation using RSAT.

**Scope limitation:** The denied operation on an Angoulême account confirms the result of that specific test. It does not, by itself, prove that no inherited or indirect permissions exist elsewhere. A comprehensive review of effective permissions has not been completed.

## 7. Remaining Improvements

- [ ] Review effective permissions on the Bordeaux and Angoulême OUs.
- [ ] Verify that `GG_Bordeaux_IT_Admins` has no unintended administrative privileges elsewhere in the domain.
- [ ] Remove the temporary `lab.test` account and `Lab-Tests` OU, or retain them as a documented test environment.
- [ ] Preserve relevant test results in the project repository.
- [ ] Consider automating delegation and group-membership audits with PowerShell.

---

**NOVERA Project — Proof of concept: delegated Active Directory user-account administration by OU scope.**