# Terraform appliqué à Microsoft Azure

## Comprendre, concevoir et déployer une infrastructure réelle

### Étude de cas : Architecture hybride AZ-700

---

**Version : 0.1**

**Projet : Azure AZ-700 Real World Lab**

**Auteur : Morad Djebli**

---

# Préambule

## Pourquoi ce document existe

Terraform est souvent présenté comme un simple outil permettant de créer des ressources dans un cloud public.

Cette vision est incomplète.

Terraform est avant tout une méthode de conception et de gestion d'infrastructure.

Ce document a pour objectif d'expliquer non seulement comment utiliser Terraform, mais surtout comment Terraform raisonne.

L'objectif est de comprendre :

- comment Terraform interprète un projet ;
- comment il construit son modèle interne ;
- comment il compare l'état désiré avec l'état réel ;
- comment il décide des actions à effectuer.

Ce livre est construit autour d'un cas réel :

la construction progressive d'une architecture Azure hybride dans le cadre d'un laboratoire AZ-700.

Cette architecture comprend notamment :

- une architecture Hub & Spoke ;
- des réseaux virtuels Azure ;
- des peerings VNet ;
- des tables de routage ;
- des groupes de sécurité réseau ;
- une VPN Gateway ;
- une connexion IPsec IKEv2 ;
- du routage dynamique BGP ;
- une interconnexion avec un environnement local simulé.

Chaque concept Terraform présenté sera illustré par son utilisation dans cette architecture.

---

# Table des matières

## Partie 1 - Comprendre Terraform

## Chapitre 1 - Pourquoi l'Infrastructure as Code ?

## Chapitre 2 - Comment pense Terraform ?

## Chapitre 3 - Anatomie d'un projet Terraform

## Chapitre 4 - Le langage HCL

## Chapitre 5 - Le cycle de vie Terraform

- terraform init
- terraform fmt
- terraform validate
- terraform plan
- terraform apply
- terraform destroy

## Chapitre 6 - Le Terraform State

## Chapitre 7 - Le graphe de dépendances

## Chapitre 8 - Variables, Locals et Outputs


---

# Partie 2 - Construction de notre architecture Azure

## Chapitre 9 - Organisation des fichiers Terraform du projet

## Chapitre 10 - Création de la couche réseau

## Chapitre 11 - Les VNets et Subnets

## Chapitre 12 - Les Peerings Hub & Spoke

## Chapitre 13 - Le routage Azure

## Chapitre 14 - La sécurité réseau

## Chapitre 15 - La connectivité hybride VPN

## Chapitre 16 - BGP et échange de routes


---

# Partie 3 - Terraform avancé

## Chapitre 17 - Les expressions Terraform

## Chapitre 18 - Les boucles for_each et count

## Chapitre 19 - Les blocs dynamiques

## Chapitre 20 - Les Data Sources

## Chapitre 21 - Les Modules

## Chapitre 22 - Les Backends distants

## Chapitre 23 - Terraform en environnement professionnel


---

# Chapitre 1

# Pourquoi l'Infrastructure as Code ?

## Introduction

Historiquement, les infrastructures informatiques étaient construites manuellement.

Un administrateur se connectait à une console d'administration, créait les ressources nécessaires puis répétait ces opérations pour chaque nouvel environnement.

Cette approche fonctionne pour quelques ressources.

Elle devient rapidement problématique lorsque l'infrastructure grandit.

---

## Les limites d'une approche manuelle

Une infrastructure créée uniquement via une interface graphique présente plusieurs difficultés :

- manque de reproductibilité ;
- risque d'erreur humaine ;
- difficulté d'audit ;
- absence d'historique précis ;
- difficulté à recréer un environnement identique.

Deux administrateurs expérimentés peuvent réaliser deux architectures légèrement différentes simplement parce qu'ils n'ont pas appliqué exactement les mêmes actions.

---

## Le principe de l'Infrastructure as Code

L'Infrastructure as Code consiste à décrire l'infrastructure sous forme de fichiers.

L'infrastructure devient alors :

- lisible ;
- versionnable ;
- partageable ;
- reproductible.

Le code devient la représentation de l'état attendu.

---

## Approche impérative et approche déclarative

Deux philosophies existent.

### Approche impérative

On décrit les actions à effectuer.

Exemple :

Créer un réseau.

Créer un sous-réseau.

Créer une machine virtuelle.

Configurer une règle réseau.

L'utilisateur décrit une séquence.

---

### Approche déclarative

Terraform utilise une approche déclarative.

On décrit le résultat attendu.

Exemple :

"Je souhaite disposer d'un réseau virtuel nommé vnet-aue-hub avec l'espace d'adressage 10.0.0.0/16."

Terraform détermine ensuite quelles opérations sont nécessaires.

---

## Comment pense Terraform

Terraform ne fonctionne pas comme un script.

Il n'exécute pas simplement les lignes du fichier dans l'ordre.

Il cherche à atteindre un état cible.

Il compare :
Configuration Terraform

    +

Terraform State

    +

Infrastructure réelle Azure

    ↓

Plan d'exécution

Son objectif est de réduire l'écart entre l'état actuel et l'état désiré.

---

# À retenir

- Terraform est un outil d'Infrastructure as Code.
- Terraform utilise une approche déclarative.
- Le code décrit un état attendu, pas une liste d'actions.
- Terraform calcule les changements nécessaires pour atteindre cet état.
- Le code Terraform devient une source de vérité versionnable.

---

# Dans notre projet

Notre architecture Azure est entièrement construite selon cette approche.

Exemple :

Le fichier :


01-network.tf


ne contient pas une suite d'actions.

Il décrit les réseaux virtuels qui doivent exister.

Terraform se charge ensuite de déterminer comment créer ces ressources dans Azure.
