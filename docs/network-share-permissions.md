# Network Share and NTFS Permissions

## 1. Objective

Create a network share for the Bordeaux IT team, with access controlled at two levels:

- SMB share permissions.
- NTFS permissions on the file system.

This configuration restricts network access to authorized users and controls the operations they can perform on files and folders.

## 2. Location and Configuration

**File server:** `DC01-BDX`

**Local path:** `C:\Shares\IT-Bordeaux`

**Network path:** `\\DC01-BDX\IT-Bordeaux`

The share is temporarily hosted on the `DC01-BDX` domain controller for lab purposes. In a production environment, a dedicated file server would be preferable.

## 3. SMB Share Permissions

The following permissions were configured in the advanced sharing settings:

| Group | Permission |
|---|---|
| `Administrateurs` | Full Control |
| `GG_Bordeaux_IT` | Modify |

The generic **Everyone** permission was removed.

## 4. NTFS Permissions

NTFS permissions were configured through the **Security** tab and the advanced security settings for `C:\Shares\IT-Bordeaux`.

| Group or entry | Permission |
|---|---|
| `GG_Bordeaux_IT` | Modify |
| Inherited entries from the parent folder | Preserved |

The permission granted to `GG_Bordeaux_IT` applies to the folder, subfolders, and files.

Other inherited permissions were not removed. Effective access depends on all applicable permissions.

## 5. Tests Performed

### Test 1 — Access by an IT Team Member

**Account used:** `NOVERA\smichel`

Results:

- Network share access succeeded.
- Creation of `test-acces.txt` succeeded.
- Effective NTFS permissions were reviewed in the advanced security settings.

The effective permissions shown allowed operations including reading and creating files. Certain privileged operations, such as changing permissions and taking ownership, were not allowed.

### Test 2 — Access by a Non-IT User

A user who was not a member of `GG_Bordeaux_IT` attempted to open `\\DC01-BDX\IT-Bordeaux`.

**Result:** Access denied.

This confirms that network access to the share is restricted by the configured SMB permissions.

## 6. Security Principles

Access to a file over the network depends on both SMB share permissions and NTFS permissions. Effective access is determined by the permissions allowed by both layers.

SMB permissions control access to the network share, while NTFS permissions control the operations that can be performed on files and folders.

## 7. Validation Status

- [x] Shared folder created
- [x] SMB share permissions configured
- [x] NTFS permissions configured for `GG_Bordeaux_IT`
- [x] Positive access test performed with an IT team member
- [x] Negative access test performed with a non-IT user
- [x] Effective NTFS permissions reviewed

**Note:** The negative access test confirms that access to the share was denied, but it does not isolate the effect of NTFS permissions because SMB share permissions may already block access.