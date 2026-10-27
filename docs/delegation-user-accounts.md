# Délégation de la gestion des comptes utilisateurs — Bordeaux

## 1. Objectif

Permettre à l’équipe IT de Bordeaux de gérer les comptes utilisateurs de son site sans lui accorder de droits de gestion équivalents sur Angoulême ni sur l’ensemble du domaine.

## 2. Périmètre

- **Domaine :** `novera.fr`
- **OU cible :** `Bordeaux\Users`
- **Groupe bénéficiaire :** `GG_Bordeaux_IT_Admins`
- **Portée :** l’OU `Bordeaux\Users` et ses sous-OU, notamment les services IT, Accounting, HR, Data, Cybersecurity et `Lab-Tests`.

Les droits sont configurés sur l’OU parente afin d’être hérités par les sous-OU concernées.

## 3. Délégations configurées

### Lecture et réinitialisation des mots de passe

Une première délégation accorde au groupe :
- la lecture de toutes les propriétés des utilisateurs descendants ;
- la réinitialisation des mots de passe et la possibilité de forcer le changement au prochain logon.

### Création et gestion des comptes

Une seconde délégation a été configurée à l’aide de l’assistant graphique **Délégation de contrôle** :

1. Ouvrir `dsa.msc` avec un compte administrateur du domaine.
2. Naviguer vers `novera.fr → Bordeaux → Users`.
3. Clic droit sur **Users → Délégation de contrôle**.
4. Ajouter `GG_Bordeaux_IT_Admins`.
5. Sélectionner la tâche prédéfinie **Créer, supprimer et gérer les comptes utilisateurs**.
6. Terminer l’assistant.

**Attention :** cette tâche prédéfinie inclut le droit de supprimer des comptes utilisateurs. Ce compromis a été accepté pour privilégier une configuration simple dans le laboratoire.

## 4. Contrôles des autorisations

- Les autorisations de lecture et de réinitialisation des mots de passe sont présentes dans les ACL de `Bordeaux\Users`.
- Leur héritage a été vérifié dans la sous-OU `Bordeaux\Users\IT`.
- Une entrée d’autorisation vide, définie directement sur `Bordeaux\Users`, a été supprimée après vérification qu’aucune permission n’y était cochée.
- Aucune entrée ACL correspondant à `GG_Bordeaux_IT_Admins` n’a été trouvée lors de l’inspection de `Angouleme\Users`.
- Le groupe contient uniquement des comptes utilisateurs, sans groupe imbriqué.
- Les membres du groupe ont été vérifiés et jugés légitimes pour cette fonction.

## 5. Tests fonctionnels réalisés

Les tests ont été effectués depuis `CL01-BDX`, avec le compte `NOVERA\smichel`, membre de `GG_Bordeaux_IT_Admins`.

| Test | Résultat |
|---|---|
| Réinitialiser le mot de passe d’un utilisateur de Bordeaux | Réussi |
| Créer le compte de test `lab.delegation` dans `Bordeaux\Users\Lab-Tests` | Réussi |
| Modifier la description de `lab.delegation` | Réussi |
| Réinitialiser le mot de passe de `lab.delegation` | Réussi |
| Réinitialiser le mot de passe du compte testé dans Angoulême | Refusé |
| Vérifier la disponibilité de l’option de création dans Angoulême | Option non disponible dans l’interface testée |
| Vérifier la disponibilité de l’option de création au-dessus de `Bordeaux\Users` | Option non disponible dans l’interface testée |

## 6. Résultat et limites

La délégation est fonctionnelle pour les opérations testées et son périmètre apparent correspond à l’objectif du laboratoire.

L’absence d’option dans l’interface et les tests effectués constituent des indices cohérents, mais ne remplacent pas un audit exhaustif des autorisations effectives. D’autres ACL ou appartenances à des groupes pourraient accorder des droits supplémentaires.

## 7. Nettoyage recommandé

Après validation de la procédure, supprimer le compte de test `lab.delegation` s’il n’est plus nécessaire, ainsi que tout autre compte de test temporaire devenu inutile.

**État :** délégation configurée et tests fonctionnels réalisés le 27 octobre 2026.