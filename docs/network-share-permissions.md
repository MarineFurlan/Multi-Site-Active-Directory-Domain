# Partage réseau et permissions NTFS

## 1. Objectif

Mettre en place un partage réseau destiné à l’équipe IT de Bordeaux, avec des autorisations contrôlées à deux niveaux :
- les permissions de partage SMB ;
- les permissions NTFS sur le système de fichiers.

Cette configuration permet de limiter l’accès au partage aux utilisateurs autorisés et de contrôler leurs droits sur les fichiers et dossiers.

## 2. Emplacement et configuration

**Serveur hébergeant le partage :** `DC01-BDX`

**Chemin local :** `C:\Shares\IT-Bordeaux`

**Chemin réseau :** `\\DC01-BDX\IT-Bordeaux`

Le partage est hébergé temporairement sur le contrôleur de domaine `DC01-BDX` dans le cadre du laboratoire. Dans un environnement de production, il serait préférable d’utiliser un serveur de fichiers dédié.

## 3. Permissions du partage SMB

Les permissions suivantes ont été configurées dans les paramètres de partage avancé :

| Groupe | Autorisation |
|---|---|
| `Administrateurs` | Contrôle total |
| `GG_Bordeaux_IT` | Modification |

L’autorisation générique « Tout le monde » a été retirée.

## 4. Permissions NTFS

Les permissions NTFS ont été configurées dans l’onglet **Sécurité**, via les paramètres de sécurité avancés du dossier `C:\Shares\IT-Bordeaux`.

| Groupe | Autorisation |
|---|---|
| `GG_Bordeaux_IT` | Modification |
| Entrées héritées du dossier parent | Conservées |

L’autorisation accordée à `GG_Bordeaux_IT` s’applique au dossier, aux sous-dossiers et aux fichiers.

Les autres autorisations héritées n’ont pas été supprimées. Les droits effectifs résultent de l’ensemble des autorisations applicables.

## 5. Tests réalisés

### Test 1 — Accès avec un membre de l’équipe IT

**Compte utilisé :** `NOVERA\smichel`

Résultats :
- accès au partage réseau réussi ;
- création du fichier `test-acces.txt` réussie ;
- droits NTFS effectifs examinés dans les paramètres de sécurité avancés.

Les droits effectifs affichés autorisent notamment les opérations de lecture et de création. Certaines opérations privilégiées, telles que la modification des autorisations et l’appropriation, ne sont pas autorisées.

### Test 2 — Accès avec un utilisateur non-IT

Un compte n’appartenant pas à `GG_Bordeaux_IT` a tenté d’ouvrir `\\DC01-BDX\IT-Bordeaux`.

**Résultat :** accès refusé.

Ce résultat confirme que l’accès réseau au partage est limité par les autorisations SMB configurées.

## 6. Principe de sécurité

L’accès à un fichier via le réseau dépend à la fois des permissions SMB et des permissions NTFS. Les droits effectifs correspondent aux autorisations compatibles accordées par les deux couches.

Les permissions SMB contrôlent l’accès au partage réseau ; les permissions NTFS contrôlent les opérations possibles sur les fichiers et dossiers.

## 7. État de validation

- [x] Création du dossier partagé
- [x] Configuration des permissions SMB
- [x] Configuration des permissions NTFS pour `GG_Bordeaux_IT`
- [x] Test d’accès positif avec un membre de l’équipe IT
- [x] Test d’accès négatif avec un utilisateur non-IT
- [x] Vérification des droits NTFS effectifs

**Remarque :** le test négatif confirme le refus d’accès au partage, mais ne permet pas à lui seul d’isoler l’effet des permissions NTFS, puisque les permissions SMB peuvent déjà bloquer l’accès.