# NOVERA — Active Directory multi-site
## Fiche technique : délégation d'administration par site

**Projet :** LAB — Active Directory Multi-site  
**Domaine :** `novera.fr`  
**Périmètre :** délégation de réinitialisation des mots de passe  
**Environnement :** Windows Server 2025, Windows 11 Pro, RSAT  
**Statut :** Tests fonctionnels réussis

---

## 1. Objectif

Mettre en place une administration déléguée dans Active Directory afin qu'un groupe informatique puisse réinitialiser les mots de passe des utilisateurs de Bordeaux, sans lui accorder les privilèges d'administrateur du domaine.

La configuration doit respecter le principe du moindre privilège : chaque groupe reçoit uniquement les autorisations nécessaires à ses tâches.

## 2. Environnement technique

| Élément | Configuration |
|---|---|
| Domaine Active Directory | `novera.fr` |
| Contrôleur de domaine Bordeaux | `DC01-BDX` |
| Contrôleur de domaine Angoulême | `DC02-ANG` |
| Poste d'administration | `CL01-BDX` |
| Outil d'administration | RSAT — `dsa.msc` |
| Compte de test administrateur délégué | `smichel` |
| Groupe de délégation | `GG_Bordeaux_IT_Admins` |
| OU Bordeaux ciblée | `OU=Users,OU=Bordeaux,DC=novera,DC=fr` |
| OU de test | `Lab-Tests` |

## 3. Principe de la délégation

Le groupe `GG_Bordeaux_IT_Admins` reçoit le droit de réinitialiser les mots de passe des comptes utilisateurs situés dans le périmètre délégué.

La délégation est configurée depuis la console **Utilisateurs et ordinateurs Active Directory** (`dsa.msc`), via l'assistant **Déléguer le contrôle**.

Tâche déléguée :

- Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session.

La délégation initiale sur `OU=Users,OU=Bordeaux` autorise également l'application du droit aux sous-OU concernées, selon les autorisations et l'héritage effectifs.

## 4. Procédure de configuration

### 4.1 Préparer un environnement de test

1. Créer l'OU `Lab-Tests` sous `Bordeaux\Users`.
2. Créer un compte utilisateur temporaire `lab.test` dans cette OU.
3. Utiliser le compte `smichel` pour effectuer les tests depuis `CL01-BDX`.

### 4.2 Tester avant délégation

1. Ouvrir `dsa.msc` avec `NOVERA\smichel`.
2. Localiser le compte `lab.test`.
3. Tenter une réinitialisation de son mot de passe.
4. Constater le résultat.

**Résultat observé :** accès refusé.

### 4.3 Déléguer sur l'OU de test

1. Sur `DC01-BDX`, ouvrir `dsa.msc` avec un compte administrateur autorisé.
2. Faire un clic droit sur `Lab-Tests`.
3. Sélectionner **Déléguer le contrôle**.
4. Ajouter `GG_Bordeaux_IT_Admins`.
5. Sélectionner uniquement la tâche de réinitialisation des mots de passe.
6. Terminer l'assistant.

### 4.4 Valider la délégation sur l'OU de test

Depuis la session de `smichel` sur `CL01-BDX` :

1. Actualiser la console Active Directory.
2. Ouvrir le compte `lab.test`.
3. Lancer **Réinitialiser le mot de passe**.
4. Saisir et confirmer un nouveau mot de passe de test.
5. Valider l'opération.

**Résultat observé :** réinitialisation réussie.

### 4.5 Étendre la délégation à Bordeaux

Sur `DC01-BDX`, avec un compte administrateur autorisé :

1. Ouvrir `dsa.msc`.
2. Faire un clic droit sur `Bordeaux\Users`.
3. Lancer **Déléguer le contrôle**.
4. Ajouter `GG_Bordeaux_IT_Admins`.
5. Sélectionner uniquement la tâche de réinitialisation des mots de passe.
6. Terminer l'assistant.

### 4.6 Tester le périmètre Bordeaux

Depuis la session `NOVERA\smichel` sur `CL01-BDX` :

1. Accéder à un compte utilisateur situé dans le périmètre Bordeaux.
2. Tenter la réinitialisation de son mot de passe.
3. Vérifier le résultat.

**Résultat observé :** réinitialisation réussie.

### 4.7 Tester hors périmètre

Depuis la même session :

1. Accéder à un compte de test situé dans une OU d'Angoulême.
2. Tenter la réinitialisation du mot de passe.
3. Vérifier le résultat.

**Résultat observé :** opération refusée.

## 5. Synthèse des tests

| Test | Résultat | Conclusion |
|---|---|---|
| Réinitialisation de `lab.test` avant délégation | Accès refusé | Aucun droit suffisant dans les conditions du test |
| Réinitialisation après délégation sur `Lab-Tests` | Réussite | Le droit délégué fonctionne sur l'OU de test |
| Réinitialisation dans le périmètre Bordeaux | Réussite | Le droit fonctionne dans le périmètre étendu |
| Réinitialisation d'un compte d'Angoulême | Accès refusé | L'opération a été refusée sur le compte testé hors périmètre |

## 6. Résultat et enseignements

Cette mise en œuvre démontre le fonctionnement d'une délégation ciblée dans Active Directory, sans attribuer à `smichel` le rôle d'administrateur du domaine.

Elle permet de mettre en pratique :

- La gestion des OU et des groupes de sécurité.
- La délégation de contrôle Active Directory.
- Le principe du moindre privilège.
- Les tests positifs et négatifs des autorisations.
- L'administration à distance depuis un poste Windows 11 équipé de RSAT.

**Limite des résultats :** le refus observé sur un compte d'Angoulême confirme le résultat de ce test, mais ne prouve pas à lui seul l'absence de toutes les autorisations héritées ou indirectes. Une vérification complémentaire des ACL effectives reste à effectuer.

## 7. Actions restantes

- [ ] Vérifier les autorisations effectives sur les OU Bordeaux et Angoulême.
- [ ] Vérifier que `GG_Bordeaux_IT_Admins` ne possède aucun droit d'administration excessif sur le domaine.
- [ ] Nettoyer le compte temporaire `lab.test` et l'OU `Lab-Tests`, ou les conserver comme environnement de test documenté.
- [ ] Conserver les résultats des tests dans le dépôt du projet.
- [ ] Automatiser ultérieurement l'audit des groupes, des comptes et des délégations avec PowerShell.

---

**Projet NOVERA — Preuve de concept validée : délégation de réinitialisation des mots de passe par périmètre Active Directory.**