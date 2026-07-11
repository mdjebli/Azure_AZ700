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

# Chapitre 3

# Le Terraform State

## Introduction

Le Terraform State est l'un des concepts les plus importants de Terraform.

Pour un débutant, il peut sembler étrange qu'un simple fichier soit nécessaire alors que l'infrastructure existe déjà dans Azure.

Après tout, Terraform pourrait-il simplement interroger Azure et comparer le résultat avec les fichiers `.tf` ?

La réponse est non.

Terraform a besoin de conserver une représentation de l'infrastructure qu'il gère.

Cette représentation est appelée :

Terraform State.

---

# 3.1 Le rôle du Terraform State

Le Terraform State est une base de données locale ou distante contenant la correspondance entre :

* les ressources déclarées dans Terraform ;
* les ressources réellement créées dans le fournisseur cloud.

Dans notre cas :

Terraform

déclare :

azurerm_virtual_network.hub

Le State conserve alors l'association :

azurerm_virtual_network.hub

correspond à :

Virtual Network Azure réellement créé.

---

Sans State, Terraform ne saurait pas faire la différence entre :

* une ressource qu'il a créée ;
* une ressource existante créée manuellement ;
* une ressource créée par un autre outil ;
* une ressource supprimée ou modifiée.

Le State est donc la mémoire de Terraform.

---

# 3.2 Configuration Terraform, State et infrastructure réelle

Terraform fonctionne avec trois sources d'information.

## 1. La configuration Terraform

Elle représente l'état souhaité.

Exemple :

Un fichier Terraform indique :

"Je souhaite un Virtual Network nommé vnet-hub avec l'adresse 10.0.0.0/16."

---

## 2. Le Terraform State

Il représente ce que Terraform pense gérer actuellement.

Exemple :

Terraform sait que :

azurerm_virtual_network.hub

correspond à :

/subscriptions/.../resourceGroups/.../virtualNetworks/vnet-hub

---

## 3. L'infrastructure réelle Azure

Elle représente ce qui existe réellement dans Azure.

Terraform compare donc :

Configuration désirée

*

State Terraform

*

Etat réel Azure

afin de déterminer les différences.

---

# 3.3 Pourquoi Terraform ne travaille pas uniquement avec Azure ?

On pourrait imaginer le fonctionnement suivant :

Terraform lit les fichiers `.tf`.

Terraform interroge Azure.

Terraform compare les deux.

Cependant, cette approche poserait plusieurs problèmes.

---

## Identifier les ressources

Une ressource Terraform possède un nom logique :

azurerm_virtual_network.hub

Azure possède un identifiant unique :

/subscriptions/<id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/vnet-hub

Terraform doit conserver cette correspondance.

C'est le rôle du State.

---

## Connaître l'historique

Terraform doit savoir :

* quelles ressources il gère ;
* quelles valeurs ont été utilisées ;
* quelles propriétés doivent être surveillées.

Le State conserve ces informations.

---

## Calculer les changements

Terraform ne cherche pas seulement à savoir :

"Est-ce que cette ressource existe ?"

Il cherche à savoir :

"Quelle est la différence entre l'état souhaité, l'état connu et l'état réel ?"

---

# 3.4 Le fichier terraform.tfstate

Dans un projet Terraform local, le State est généralement stocké dans un fichier :

terraform.tfstate

Exemple :

```
terraform.tfstate
```

Ce fichier contient notamment :

* les ressources suivies ;
* leurs identifiants Azure ;
* leurs propriétés ;
* les métadonnées nécessaires au fonctionnement de Terraform.

Ce fichier est généré automatiquement.

Il ne doit normalement jamais être modifié manuellement.

---

# 3.5 Pourquoi ne faut-il jamais supprimer terraform.tfstate ?

Supprimer le State ne supprime pas automatiquement les ressources Azure.

Cependant, Terraform perdrait sa mémoire.

Exemple :

Avant suppression du State :

Terraform sait :

azurerm_virtual_network.hub

=

VNet Azure vnet-hub

Après suppression :

Terraform ne sait plus qu'il gère ce VNet.

Lors du prochain plan, Terraform pourrait considérer que la ressource n'existe pas et tenter de la recréer.

Cela peut provoquer :

* des erreurs de duplication ;
* des destructions/recréations inutiles ;
* une perte de contrôle sur l'infrastructure.

---

# 3.6 Le State dans notre projet AZ-700

Depuis le début du laboratoire, Terraform a maintenu une correspondance entre notre code et Azure.

Par exemple :

La déclaration :

azurerm_virtual_network.hub

correspond au réseau :

Hub VNet Australia East

La déclaration :

azurerm_virtual_network_gateway.vpn

correspond à :

Azure VPN Gateway réellement déployée.

La commande :

terraform state list

nous permet d'observer cette liste de ressources suivies.

# 3.7 Explorer le State avec terraform state list

La commande :

terraform state list

permet d'afficher toutes les ressources actuellement suivies par Terraform.

Dans notre laboratoire AZ-700, cette commande nous a permis d'obtenir une vision directe de ce que Terraform connaît.

Exemple :

azurerm_virtual_network.hub

azurerm_virtual_network.workload

azurerm_virtual_network.dr

azurerm_virtual_network_gateway.vpn

azurerm_virtual_network_gateway_connection.onprem

---

Cette liste ne correspond pas simplement aux fichiers Terraform.

Elle correspond aux ressources que Terraform considère comme étant sous sa gestion.

Une ressource peut donc :

* exister dans un fichier `.tf` mais ne pas apparaître dans le State si elle n'a jamais été créée ;
* apparaître dans le State alors que sa déclaration a été supprimée du code.

Cette distinction est fondamentale.

---

# 3.8 Examiner une ressource avec terraform state show

La commande :

terraform state show

permet d'afficher le contenu détaillé d'une ressource suivie.

Exemple :

terraform state show azurerm_virtual_network.hub

Terraform affiche alors les informations connues concernant cette ressource.

On peut retrouver notamment :

* son identifiant Azure ;
* son groupe de ressources ;
* son adresse réseau ;
* ses propriétés configurées ;
* ses métadonnées.

---

Cette commande est très utile pour le diagnostic.

Exemple :

On pense avoir configuré :

10.10.0.0/16

dans un Virtual Network.

La commande :

terraform state show

permet de vérifier ce que Terraform connaît réellement.

---

# 3.9 Différence entre Terraform State et portail Azure

Une erreur fréquente consiste à croire que le portail Azure représente toujours la vérité utilisée par Terraform.

Ce n'est pas exactement le cas.

Terraform fonctionne avec une combinaison :

* configuration déclarée ;
* State ;
* état réel Azure.

Le portail Azure montre uniquement l'état actuel d'Azure.

Il ne connaît pas :

* les fichiers Terraform ;
* les noms logiques Terraform ;
* les dépendances déclarées ;
* l'intention de l'administrateur.

---

Exemple :

Un administrateur modifie manuellement une propriété dans Azure.

Avant modification :

Terraform :

adresse réseau = 10.0.0.0/16

Azure :

adresse réseau = 10.0.0.0/16

Tout est cohérent.

---

Après modification manuelle :

Terraform :

adresse réseau = 10.0.0.0/16

Azure :

adresse réseau = 10.1.0.0/16

Une divergence apparaît.

Terraform détectera cette différence lors du prochain plan.

---

# 3.10 Pourquoi éviter les modifications manuelles dans Azure ?

Terraform repose sur le principe d'Infrastructure as Code.

Cela signifie que l'état désiré doit être décrit dans le code.

Modifier directement Azure depuis le portail crée une dérive appelée :

Configuration Drift

ou :

Dérive de configuration.

---

Exemples de dérive :

* ajout manuel d'un subnet ;
* modification d'une règle NSG ;
* changement d'une route ;
* modification d'une adresse IP publique ;
* suppression d'une ressource.

---

La bonne pratique consiste à :

1. Modifier le code Terraform.
2. Effectuer un terraform plan.
3. Vérifier le résultat.
4. Appliquer avec terraform apply.

Ainsi, le code reste la source de vérité.

---

# 3.11 Le cas particulier d'une ressource supprimée manuellement dans Azure

Imaginons :

Terraform gère :

azurerm_public_ip.vpn_gateway

La ressource existe dans :

* le code Terraform ;
* le State ;
* Azure.

Puis un administrateur supprime l'adresse IP depuis le portail Azure.

La situation devient :

Code Terraform :

La ressource doit exister.

State :

La ressource est supposée exister.

Azure :

La ressource n'existe plus.

---

Lors d'un :

terraform plan

Terraform détecte une incohérence.

Il peut alors proposer :

* de recréer la ressource ;
* de restaurer l'état attendu.

C'est un exemple classique montrant l'importance du State.

---

# 3.12 Le rôle de terraform refresh

La commande :

terraform refresh

permettait historiquement de mettre à jour le State à partir de l'infrastructure réelle.

Son objectif était :

Azure réel

↓

Mise à jour du State

---

Cependant, dans les versions modernes de Terraform, cette commande est progressivement remplacée par le comportement intégré de :

terraform plan

et :

terraform apply

avec le rafraîchissement automatique du State.

La commande moderne recommandée pour analyser les différences reste :

terraform plan

---

# 3.13 Consulter le State avec terraform show

La commande :

terraform show

permet d'afficher une représentation lisible du State actuel.

Elle est différente de :

terraform state show

La différence est :

terraform show

affiche une vue globale du State.

terraform state show

affiche une ressource précise.

---

Exemple :

terraform show

permet d'avoir une vision générale du projet.

terraform state show azurerm_virtual_network.hub

permet d'analyser uniquement le Virtual Network Hub.

---

# À retenir

* Le State est la mémoire de Terraform.
* Le State associe les ressources Terraform aux ressources Azure réelles.
* terraform state list affiche les ressources suivies.
* terraform state show affiche le détail d'une ressource.
* Le portail Azure n'est pas la source de vérité Terraform.
* Les modifications manuelles dans Azure créent des dérives.
* Le code Terraform doit rester la source de vérité.
* terraform plan permet de détecter les divergences.

# 3.14 Le State local et ses limites

Par défaut, lorsqu'un projet Terraform est initialisé sans configuration particulière, le State est stocké localement.

Cela signifie qu'un fichier :

terraform.tfstate

est présent dans le répertoire du projet.

Cette approche est adaptée :

* aux laboratoires ;
* aux environnements personnels ;
* aux phases d'apprentissage ;
* aux tests rapides.

C'est d'ailleurs le fonctionnement que nous avons utilisé au début de notre laboratoire AZ-700.

---

Cependant, un State local présente rapidement des limites dans un contexte professionnel.

---

# 3.15 Les problèmes du State local en équipe

Imaginons une équipe composée de plusieurs ingénieurs Azure.

Chaque personne possède une copie du dépôt Git.

Si le State est local :

Ingénieur A :

terraform.tfstate local sur son poste.

Ingénieur B :

terraform.tfstate local sur son poste.

Ingénieur C :

terraform.tfstate local sur son poste.

Chaque personne possède alors une vision différente de l'infrastructure.

---

Cela provoque plusieurs problèmes.

## Divergence du State

Deux ingénieurs peuvent appliquer des changements différents avec des fichiers State différents.

---

## Absence de synchronisation

Une modification effectuée par un ingénieur n'est pas automatiquement connue des autres.

---

## Risque d'écrasement

Deux personnes peuvent modifier la même infrastructure simultanément.

Le dernier changement appliqué peut écraser le précédent.

---

Pour résoudre ces problèmes, Terraform utilise les backends distants.

---

# 3.16 Le rôle du backend Terraform

Un backend définit l'endroit où Terraform stocke son State.

Au lieu de :

Poste local

↓

terraform.tfstate

on utilise :

Terraform

↓

Backend distant

↓

State partagé

---

Les backends permettent :

* le stockage centralisé ;
* le partage entre équipes ;
* la sécurisation ;
* le verrouillage ;
* la sauvegarde.

---

Dans un environnement Azure professionnel, le backend le plus courant est :

Azure Storage Account.

---

# 3.17 Le backend Azure Storage

Terraform peut stocker son State dans un compte de stockage Azure.

L'architecture devient :

Poste administrateur

```
    |

    v
```

Terraform

```
    |

    v
```

Azure Storage Account

```
    |

    v
```

terraform.tfstate

---

Le fichier State n'est plus conservé localement.

Il devient une ressource Azure protégée.

---

Les avantages :

## Centralisation

Toute l'équipe utilise le même State.

---

## Sécurité

Le State peut bénéficier :

* du contrôle d'accès Azure RBAC ;
* du chiffrement ;
* des journaux d'audit ;
* des politiques de sécurité Azure.

---

## Collaboration

Plusieurs ingénieurs peuvent travailler sur la même infrastructure.

---

# 3.18 Le verrouillage du State

Un problème important reste possible :

Deux personnes lancent simultanément :

terraform apply

sur la même infrastructure.

Exemple :

Ingénieur A prépare une modification.

Ingénieur B prépare également une modification.

Les deux appliquent en même temps.

Le résultat peut devenir incohérent.

---

Pour éviter cela, Terraform utilise un mécanisme appelé :

State Locking

ou :

verrouillage du State.

---

Lorsqu'un utilisateur lance :

terraform apply

Terraform demande un verrou sur le State.

Pendant l'application :

* le State est verrouillé ;
* les autres utilisateurs ne peuvent pas appliquer de changement concurrent.

Une fois terminé :

* le verrou est libéré ;
* les autres opérations peuvent reprendre.

---

# 3.19 Le State dans une chaîne CI/CD

Dans une organisation mature, Terraform n'est généralement pas exécuté directement depuis un poste administrateur.

Le workflow devient :

Développeur

↓

Modification du code Terraform

↓

Git Repository

↓

Pipeline CI/CD

↓

terraform plan

↓

Validation humaine éventuelle

↓

terraform apply

↓

Azure

---

Le State distant devient alors indispensable.

La plateforme d'automatisation doit pouvoir accéder au même State que les ingénieurs.

---

# 3.20 Le State et la sécurité

Le State contient des informations sensibles.

Il peut contenir :

* des identifiants de ressources ;
* des paramètres réseau ;
* des informations de configuration ;
* parfois des secrets selon les ressources utilisées.

Il ne doit donc pas être :

* publié dans GitHub ;
* envoyé par email ;
* partagé sans contrôle.

---

C'est pourquoi un fichier :

.gitignore

Terraform contient généralement :

terraform.tfstate

terraform.tfstate.*

.terraform/

---

Dans notre projet AZ-700, le fichier :

.gitignore

joue donc un rôle important.

Il empêche de versionner accidentellement :

* le State ;
* les fichiers temporaires Terraform ;
* les fichiers téléchargés automatiquement.

---

# 3.21 Le State dans notre démarche AZ-700

Notre laboratoire a volontairement commencé avec un State local.

Cette approche était adaptée car :

* nous étions seuls sur le projet ;
* l'objectif était pédagogique ;
* nous construisions progressivement l'architecture.

Cependant, si ce laboratoire devenait :

* un environnement partagé ;
* un projet d'entreprise ;
* une plateforme de démonstration publique ;

la prochaine évolution logique serait :

Migration vers un backend Azure Storage.

---

# À retenir

* Un State local convient aux laboratoires et tests personnels.
* Un projet professionnel nécessite généralement un backend distant.
* Azure Storage Account est le backend Terraform courant sur Azure.
* Le verrouillage du State évite les modifications concurrentes.
* Le State contient des informations sensibles.
* Le fichier State ne doit jamais être versionné dans Git.
* Le backend distant est une évolution naturelle d'un projet Terraform mature.

# 3.14 Le State local et ses limites

Par défaut, lorsqu'un projet Terraform est initialisé sans configuration particulière, le State est stocké localement.

Cela signifie qu'un fichier :

terraform.tfstate

est présent dans le répertoire du projet.

Cette approche est adaptée :

* aux laboratoires ;
* aux environnements personnels ;
* aux phases d'apprentissage ;
* aux tests rapides.

C'est d'ailleurs le fonctionnement que nous avons utilisé au début de notre laboratoire AZ-700.

---

Cependant, un State local présente rapidement des limites dans un contexte professionnel.

---

# 3.15 Les problèmes du State local en équipe

Imaginons une équipe composée de plusieurs ingénieurs Azure.

Chaque personne possède une copie du dépôt Git.

Si le State est local :

Ingénieur A :

terraform.tfstate local sur son poste.

Ingénieur B :

terraform.tfstate local sur son poste.

Ingénieur C :

terraform.tfstate local sur son poste.

Chaque personne possède alors une vision différente de l'infrastructure.

---

Cela provoque plusieurs problèmes.

## Divergence du State

Deux ingénieurs peuvent appliquer des changements différents avec des fichiers State différents.

---

## Absence de synchronisation

Une modification effectuée par un ingénieur n'est pas automatiquement connue des autres.

---

## Risque d'écrasement

Deux personnes peuvent modifier la même infrastructure simultanément.

Le dernier changement appliqué peut écraser le précédent.

---

Pour résoudre ces problèmes, Terraform utilise les backends distants.

---

# 3.16 Le rôle du backend Terraform

Un backend définit l'endroit où Terraform stocke son State.

Au lieu de :

Poste local

↓

terraform.tfstate

on utilise :

Terraform

↓

Backend distant

↓

State partagé

---

Les backends permettent :

* le stockage centralisé ;
* le partage entre équipes ;
* la sécurisation ;
* le verrouillage ;
* la sauvegarde.

---

Dans un environnement Azure professionnel, le backend le plus courant est :

Azure Storage Account.

---

# 3.17 Le backend Azure Storage

Terraform peut stocker son State dans un compte de stockage Azure.

L'architecture devient :

Poste administrateur

```
    |

    v
```

Terraform

```
    |

    v
```

Azure Storage Account

```
    |

    v
```

terraform.tfstate

---

Le fichier State n'est plus conservé localement.

Il devient une ressource Azure protégée.

---

Les avantages :

## Centralisation

Toute l'équipe utilise le même State.

---

## Sécurité

Le State peut bénéficier :

* du contrôle d'accès Azure RBAC ;
* du chiffrement ;
* des journaux d'audit ;
* des politiques de sécurité Azure.

---

## Collaboration

Plusieurs ingénieurs peuvent travailler sur la même infrastructure.

---

# 3.18 Le verrouillage du State

Un problème important reste possible :

Deux personnes lancent simultanément :

terraform apply

sur la même infrastructure.

Exemple :

Ingénieur A prépare une modification.

Ingénieur B prépare également une modification.

Les deux appliquent en même temps.

Le résultat peut devenir incohérent.

---

Pour éviter cela, Terraform utilise un mécanisme appelé :

State Locking

ou :

verrouillage du State.

---

Lorsqu'un utilisateur lance :

terraform apply

Terraform demande un verrou sur le State.

Pendant l'application :

* le State est verrouillé ;
* les autres utilisateurs ne peuvent pas appliquer de changement concurrent.

Une fois terminé :

* le verrou est libéré ;
* les autres opérations peuvent reprendre.

---

# 3.19 Le State dans une chaîne CI/CD

Dans une organisation mature, Terraform n'est généralement pas exécuté directement depuis un poste administrateur.

Le workflow devient :

Développeur

↓

Modification du code Terraform

↓

Git Repository

↓

Pipeline CI/CD

↓

terraform plan

↓

Validation humaine éventuelle

↓

terraform apply

↓

Azure

---

Le State distant devient alors indispensable.

La plateforme d'automatisation doit pouvoir accéder au même State que les ingénieurs.

---

# 3.20 Le State et la sécurité

Le State contient des informations sensibles.

Il peut contenir :

* des identifiants de ressources ;
* des paramètres réseau ;
* des informations de configuration ;
* parfois des secrets selon les ressources utilisées.

Il ne doit donc pas être :

* publié dans GitHub ;
* envoyé par email ;
* partagé sans contrôle.

---

C'est pourquoi un fichier :

.gitignore

Terraform contient généralement :

terraform.tfstate

terraform.tfstate.*

.terraform/

---

Dans notre projet AZ-700, le fichier :

.gitignore

joue donc un rôle important.

Il empêche de versionner accidentellement :

* le State ;
* les fichiers temporaires Terraform ;
* les fichiers téléchargés automatiquement.

---

# 3.21 Le State dans notre démarche AZ-700

Notre laboratoire a volontairement commencé avec un State local.

Cette approche était adaptée car :

* nous étions seuls sur le projet ;
* l'objectif était pédagogique ;
* nous construisions progressivement l'architecture.

Cependant, si ce laboratoire devenait :

* un environnement partagé ;
* un projet d'entreprise ;
* une plateforme de démonstration publique ;

la prochaine évolution logique serait :

Migration vers un backend Azure Storage.

---

# À retenir

* Un State local convient aux laboratoires et tests personnels.
* Un projet professionnel nécessite généralement un backend distant.
* Azure Storage Account est le backend Terraform courant sur Azure.
* Le verrouillage du State évite les modifications concurrentes.
* Le State contient des informations sensibles.
* Le fichier State ne doit jamais être versionné dans Git.
* Le backend distant est une évolution naturelle d'un projet Terraform mature.
