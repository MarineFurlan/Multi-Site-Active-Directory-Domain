# Delegated User Account Management — Bordeaux

## 1. Objective

Allow the Bordeaux IT team to manage user accounts within its site without granting equivalent administrative rights over Angoulême or the entire domain.

## 2. Scope

- **Domain:** `novera.fr`
- **Target OU:** `Bordeaux\Users`
- **Delegated group:** `GG_Bordeaux_IT_Admins`
- **Scope:** The `Bordeaux\Users` OU and its child OUs, including IT, Accounting, HR, Data, Cybersecurity, and `Lab-Tests`.

Permissions are configured on the parent OU so that they can be inherited by the relevant child OUs.

## 3. Configured Delegations

### Read Access and Password Reset

An initial delegation grants the group:

- Read access to all properties of descendant user objects.
- Permission to reset user passwords and require a password change at the next logon.

### User Account Creation and Management

A second delegation was configured using the graphical **Delegate Control** wizard:

1. Open `dsa.msc` using a domain administrator account.
2. Navigate to `novera.fr → Bordeaux → Users`.
3. Right-click **Users** and select **Delegate Control**.
4. Add `GG_Bordeaux_IT_Admins`.
5. Select the predefined task **Create, delete, and manage user accounts**.
6. Complete the wizard.

**Important:** This predefined task includes permission to delete user accounts. This trade-off was accepted to keep the lab configuration straightforward.

## 4. Permission Checks

- Read and password-reset permissions were found in the ACLs of `Bordeaux\Users`.
- Inheritance of these permissions was verified in the `Bordeaux\Users\IT` child OU.
- An empty permission entry defined directly on `Bordeaux\Users` was removed after confirming that no permission was selected.
- No ACL entry corresponding to `GG_Bordeaux_IT_Admins` was found during the inspection of `Angouleme\Users`.
- The group contains user accounts only, with no nested groups.
- The group members were reviewed and considered appropriate for this responsibility.

## 5. Functional Tests

Tests were performed from `CL01-BDX` using the `NOVERA\smichel` account, which is a member of `GG_Bordeaux_IT_Admins`.

| Test | Result |
|---|---|
| Reset the password of a Bordeaux user | Successful |
| Create the test account `lab.delegation` under `Bordeaux\Users\Lab-Tests` | Successful |
| Modify the description of `lab.delegation` | Successful |
| Reset the password of `lab.delegation` | Successful |
| Reset the password of the tested account in Angoulême | Denied |
| Check whether the account-creation option was available in Angoulême | Option unavailable in the tested interface |
| Check whether the account-creation option was available above `Bordeaux\Users` | Option unavailable in the tested interface |

## 6. Results and Limitations

The delegation worked for the operations tested, and its observed scope is consistent with the lab's objectives.

The unavailable interface options and the functional tests provide supporting evidence, but they do not replace a comprehensive audit of effective permissions. Other ACL entries or group memberships could grant additional rights.

## 7. Recommended Cleanup

After validating the procedure, remove the `lab.delegation` test account if it is no longer needed, along with any other temporary test accounts that are no longer required.

**Status:** Delegation configured and functional tests performed on October 27, 2026.