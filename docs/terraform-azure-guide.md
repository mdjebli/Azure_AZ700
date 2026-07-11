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

---

# Chapitre 2

# Comment pense Terraform ?

## Introduction

Comprendre Terraform nécessite de changer de modèle mental.

L'erreur la plus fréquente consiste à imaginer Terraform comme un langage de script exécutant des commandes dans un ordre précis.

Terraform n'est pas un script classique.

Il ne reçoit pas une liste d'actions à exécuter ligne par ligne.

Terraform fonctionne selon une approche déclarative : l'utilisateur décrit un état attendu, puis Terraform calcule les opérations nécessaires pour atteindre cet état.

Autrement dit :

* L'utilisateur décrit ce qui doit exister.
* Terraform détermine comment parvenir à cet état.

---

# 2.1 Terraform n'est pas un script impératif

Dans une approche impérative traditionnelle, l'administrateur décrit une succession d'actions.

Exemple :

* Créer un réseau virtuel.
* Créer un sous-réseau.
* Créer une machine virtuelle.
* Configurer une règle réseau.

Dans cette approche, l'ordre des commandes est essentiel.

Si une étape échoue, les étapes suivantes peuvent ne pas être exécutées.

Terraform adopte une approche différente.

Il ne raisonne pas en termes d'actions successives mais en termes de ressources et de relations entre ces ressources.

Une déclaration Terraform décrit une ressource souhaitée.

Exemple :

resource "azurerm_virtual_network" "hub" {

name = "vnet-hub"

address_space = [
"10.0.0.0/16"
]

}

Cette déclaration signifie :

"Un réseau virtuel Azure correspondant à cette définition doit exister."

Elle ne signifie pas :

"Terraform doit immédiatement exécuter une commande de création."

Terraform va analyser l'ensemble du projet avant de déterminer les opérations nécessaires.

# 2.2 Terraform construit une configuration logique unique

Notre projet contient plusieurs fichiers Terraform :

* 01-network.tf
* 02-network-peering.tf
* 03-route-tables.tf
* 04-network-security-groups.tf
* 05-public-ip.tf
* 06-vpn-gateway.tf
* 07-local-network-gateway.tf
* 08-vpn-connection.tf
* locals.tf
* providers.tf
* outputs.tf

Une erreur fréquente consiste à penser que Terraform lit ces fichiers dans l'ordre numérique :

01-network.tf

puis :

02-network-peering.tf

puis :

03-route-tables.tf

Ce n'est pas le fonctionnement réel.

Terraform charge tous les fichiers portant l'extension `.tf` présents dans le répertoire courant.

Ensuite, il fusionne leur contenu afin de construire une configuration logique unique.

Le moteur Terraform ne voit donc pas une succession de fichiers séparés.

Il voit un ensemble cohérent de déclarations d'infrastructure.

---

# 2.3 Le rôle du nom des fichiers Terraform

Le nom des fichiers Terraform n'a aucune influence sur l'ordre d'exécution.

Par exemple, renommer :

02-network-peering.tf

en :

99-network-peering.tf

ne changera pas le comportement de Terraform.

Les préfixes numériques utilisés dans notre projet :

* 01-
* 02-
* 03-
* etc.

sont uniquement une convention humaine.

Ils permettent :

* de comprendre la progression logique de construction ;
* de faciliter la lecture du dépôt Git ;
* de retrouver rapidement une fonctionnalité ;
* de présenter une architecture pédagogique cohérente.

Dans un projet professionnel, cette organisation améliore fortement la maintenabilité.

---

# 2.4 Pourquoi découper Terraform en plusieurs fichiers ?

Terraform pourrait fonctionner avec un seul fichier contenant toute l'infrastructure.

Un fichier unique pourrait contenir :

* les providers ;
* les réseaux virtuels ;
* les subnets ;
* les règles de sécurité ;
* les VPN ;
* les connexions hybrides ;
* les outputs.

Cependant, cette approche devient rapidement difficile à maintenir.

Le découpage en plusieurs fichiers apporte plusieurs avantages.

## Lisibilité

Chaque fichier possède une responsabilité fonctionnelle.

Exemple :

01-network.tf

Responsabilité :

Création de la fondation réseau :

* Resource Group ;
* Virtual Networks ;
* Subnets.

Exemple :

06-vpn-gateway.tf

Responsabilité :

Création de la connectivité hybride :

* VPN Gateway ;
* IP publique associée ;
* activation BGP ;
* paramètres de passerelle.

---

## Maintenance

Une modification concernant la connectivité VPN ne nécessite pas de parcourir plusieurs centaines de lignes mélangées avec la configuration réseau générale.

Chaque composant peut évoluer indépendamment.

---

## Collaboration

Dans un environnement professionnel, plusieurs ingénieurs peuvent intervenir plus facilement sur différentes parties de l'infrastructure.

Un ingénieur réseau pourra travailler sur :

* les VNets ;
* les subnets ;
* le routage.

Un autre pourra travailler sur :

* les VPN ;
* les firewalls ;
* les mécanismes de sécurité.

La séparation logique facilite également les revues de code.

# 2.5 Le rôle du provider AzureRM

Terraform est un moteur d'orchestration d'infrastructure.

Cependant, Terraform ne connaît pas nativement Azure.

Il ne sait pas créer directement :

* un Virtual Network ;
* une VPN Gateway ;
* une Network Security Group ;
* une Public IP ;
* ou toute autre ressource Azure.

Pour communiquer avec Azure, Terraform utilise un composant appelé **provider**.

Dans notre projet, nous utilisons le provider :

AzureRM

fourni par Microsoft.

Le fonctionnement général est le suivant :

Terraform

↓

Provider AzureRM

↓

Azure Resource Manager (ARM)

↓

Ressources Azure

Le provider joue donc le rôle d'intermédiaire entre Terraform et les API Azure.

---

# 2.6 Le fichier providers.tf

Le fichier :

providers.tf

a pour rôle de déclarer les informations nécessaires au fonctionnement de Terraform avec Azure.

Il définit notamment :

* le provider utilisé ;
* la version du provider ;
* les paramètres de connexion ;
* les contraintes éventuelles.

Exemple de logique :

Terraform doit utiliser Azure.

Pour cela :

Terraform charge le provider AzureRM.

Le provider AzureRM utilise ensuite les API Azure Resource Manager.

---

# 2.7 Le rôle du fichier versions.tf

Le fichier :

versions.tf

définit les contraintes de versions utilisées par le projet.

Il permet de figer l'environnement Terraform.

Cela concerne notamment :

* la version minimale de Terraform ;
* les versions autorisées des providers.

Exemple :

Un projet validé avec :

* Terraform 1.x ;
* AzureRM provider 4.x ;

doit pouvoir être reconstruit plusieurs mois plus tard dans un environnement identique.

Sans contrainte de version, une nouvelle exécution pourrait utiliser automatiquement une version différente d'un provider et produire un comportement inattendu.

---

# 2.8 Le rôle du fichier .terraform.lock.hcl

Lors de l'initialisation du projet avec :

terraform init

Terraform télécharge les providers nécessaires.

Il crée alors un fichier :

.terraform.lock.hcl

Ce fichier contient les versions exactes des providers utilisés ainsi que leurs empreintes de sécurité.

Son objectif est de garantir la reproductibilité.

Exemple :

Un ingénieur valide aujourd'hui une infrastructure avec :

AzureRM provider version X.

Un autre ingénieur récupère demain le dépôt Git.

Grâce au fichier :

.terraform.lock.hcl

Terraform utilisera la même version validée.

Ce fichier doit généralement être versionné dans Git.

Il fait partie intégrante du projet Terraform.

---

# 2.9 Le cycle de travail Terraform

Un projet Terraform suit généralement ce cycle :

## 1. Initialisation

Commande :

terraform init

Objectif :

* télécharger les providers ;
* initialiser le répertoire Terraform ;
* préparer l'environnement.

---

## 2. Validation

Commande :

terraform validate

Objectif :

* vérifier la syntaxe ;
* détecter les erreurs de structure ;
* vérifier la cohérence générale de la configuration.

Cette commande ne contacte pas Azure.

Elle analyse uniquement le code Terraform.

---

## 3. Planification

Commande :

terraform plan

Objectif :

calculer les différences entre :

* la configuration Terraform ;
* le state Terraform ;
* l'infrastructure Azure réelle.

Terraform produit alors un plan d'exécution.

---

## 4. Application

Commande :

terraform apply

Objectif :

appliquer les changements nécessaires dans Azure.

Terraform exécute alors les opérations déterminées précédemment.

---

# 2.10 Pourquoi utiliser terraform plan -out ?

Dans un environnement professionnel, on évite généralement de faire directement :

terraform apply

Après validation du plan.

La pratique recommandée est :

terraform plan -out=plan.tfplan

Cette commande génère un fichier contenant le plan exact calculé par Terraform.

Ensuite :

terraform apply plan.tfplan

applique exactement ce plan.

Cela garantit que :

* le plan validé est celui qui sera exécuté ;
* une modification accidentelle du code entre plan et apply ne change pas le résultat ;
* une validation humaine peut intervenir avant l'exécution.

Cette méthode est particulièrement importante dans les environnements critiques.

# 2.11 Que se passe-t-il si l'on exécute terraform apply sans plan figé ?

La commande :

terraform apply

est parfaitement valide.

Dans ce cas, Terraform réalise automatiquement plusieurs étapes :

1. Lecture de la configuration Terraform.
2. Lecture du fichier state.
3. Interrogation d'Azure pour connaître l'état réel.
4. Calcul d'un nouveau plan.
5. Présentation du plan à l'utilisateur.
6. Application après confirmation.

Le point important est que le plan n'est pas conservé.

Terraform calcule donc un plan temporaire uniquement destiné à cette exécution.

---

Dans un environnement de laboratoire, cette méthode est souvent suffisante.

Exemple :

* création d'un VNet de test ;
* modification d'une règle NSG ;
* ajout d'un subnet expérimental.

Dans un environnement professionnel, on préfère généralement séparer les phases :

* génération du plan ;
* revue du plan ;
* validation ;
* application.

---

# 2.12 Le risque d'appliquer une configuration non figée

Considérons le scénario suivant :

Étape 1 :

L'administrateur exécute :

terraform plan

Terraform affiche :

2 ressources vont être créées.

L'administrateur analyse le résultat.

---

Étape 2 :

Une modification est effectuée dans un fichier Terraform.

Exemple :

* modification d'une adresse IP ;
* changement d'une référence ;
* modification d'un paramètre de sécurité.

---

Étape 3 :

L'administrateur exécute :

terraform apply

Terraform ne connaît pas le plan précédent.

Il recalcule un nouveau plan basé sur la nouvelle configuration.

Le résultat appliqué peut donc être différent du résultat initialement analysé.

---

C'est précisément le rôle du plan figé :

terraform plan -out=plan.tfplan

puis :

terraform apply plan.tfplan

Le fichier plan devient une photographie précise des changements approuvés.

---

# 2.13 Le rôle des outputs Terraform

Le fichier :

outputs.tf

permet d'exposer certaines informations produites par Terraform.

Un output est une valeur que Terraform conserve et affiche après un déploiement.

Exemples :

* une adresse IP publique ;
* l'identifiant d'un Virtual Network ;
* l'identifiant d'une VPN Gateway ;
* une information nécessaire à une autre équipe.

---

Exemple dans notre projet :

Après création de la VPN Gateway, il peut être utile d'obtenir :

* son Resource ID ;
* son adresse IP publique ;
* son état.

Un output permet d'éviter de rechercher manuellement ces informations dans le portail Azure.

---

# 2.14 Utilisation de terraform output

Après un déploiement réussi :

terraform output

affiche tous les outputs disponibles.

Exemple :

terraform output

peut retourner :

* l'adresse IP publique de la passerelle VPN ;
* l'identifiant du réseau Hub ;
* les informations nécessaires à une configuration externe.

---

Pour obtenir une valeur précise :

terraform output nom_de_l_output

Exemple :

terraform output vpn_public_ip

permet d'obtenir uniquement l'adresse IP publique de la VPN Gateway.

---

Avec l'option :

terraform output -raw nom_de_l_output

Terraform retourne uniquement la valeur brute.

Cette option est pratique pour automatiser des scripts.

Exemple :

Récupérer automatiquement une IP publique afin de générer une configuration pfSense.

---

# 2.15 Les outputs dans une démarche professionnelle

Les outputs jouent un rôle important dans les architectures complexes.

Ils permettent de créer des points d'intégration entre composants.

Exemple dans notre architecture AZ-700 :

Terraform crée :

* le Hub ;
* la VPN Gateway ;
* le réseau Spoke.

Les outputs peuvent ensuite fournir :

* l'ID du Hub ;
* l'ID des VNets ;
* les adresses IP ;
* les informations nécessaires aux autres modules Terraform.

Cela évite les valeurs codées en dur.

---

# 2.16 Résumé du fonctionnement global de Terraform

Le fonctionnement complet peut être résumé ainsi :

Configuration Terraform

↓

Lecture des fichiers `.tf`

↓

Chargement des providers

↓

Evaluation des variables et locals

↓

Construction du graphe de dépendances

↓

Lecture du Terraform State

↓

Comparaison avec Azure

↓

Création d'un plan

↓

Application éventuelle des changements

---

# À retenir

* Terraform charge tous les fichiers `.tf` d'un dossier.
* Les fichiers Terraform forment une configuration logique unique.
* Les noms des fichiers servent uniquement à l'organisation humaine.
* Le provider AzureRM permet la communication avec Azure.
* `versions.tf` et `.terraform.lock.hcl` permettent de garantir la reproductibilité.
* `terraform plan -out` permet de figer un plan validé.
* `terraform apply plan.tfplan` applique exactement ce plan.
* Sans plan figé, Terraform recalcule toujours un nouveau plan.
* Les outputs permettent d'extraire facilement des informations après déploiement.

