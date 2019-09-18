# Cloner un environnement

## 1. Récupération des sources

Dans un premier temps, on récupère les sources depuis le dépôt Git.

```bash
git clone ssh://git@git.octree.ch:6118/decidim/ocsin.git decidim
cd decidim
```

## 2. Configuration

La configuration de l’application est faite uniquement par l’intermédiaire de variables d’environnement passées au container Docker Decidim avec un fichier `.env`.

On récupère le `.env` de l’environnement que l’on souhaite cloner et on le place dans le dossier où se situe le fichier `docker-compose.yml`.

## 3. Lancement de l’application

Une fois la configuration prête, on peut lancer le container Decidim avec Docker Compose.

```bash
docker-compose -f docker-compose-prod.yml up -d
```

Après quelques secondes, le container se met en écoute sur le port 80 de l’hôte mais retourne une erreur 500 en attendant que la base de données soit initialisée.

## 4. Récupération de la base de données

À partir d’un dump de la base de données effectué sur l’environnement à cloner, on recrée un base de donnée cible avec ses données.

Si l’environnement à cloner est à jour au niveau des sources, il n’est pas nécessaire de faire une migration des données sur le nouvel environnement.
Dans le cas inverse, il faut lancer la commande suivante pour mettre à jour les schemas de la base de données:

```bash
docker-compose -f docker-compose-prod.yml exec app rails db:migrate
```

## 5. Récupération des fichiers d’uploads

Pour récupéer les fichiers uploadés par les utilisateurs sur l’environnement à cloner, on copie l’ensemble du contenu du volume `storage` (*/code/storage* dans le container Decidim) de l’environnement d’origine au nouvel environnement. 

> Attention au maintient des droits sur les fichiers copiés.

## 6. Configuration des organisations présentes

Les organisations Decidim présentes en base de données doivent avoir une variable `host` correspondant à l’URL sur laquelle elles sont accessibles. Après récupération des données de la base, il est nécessaire de modifier ces champs pour chaque organisation pour qu’ils correspondent à la nouvelle configuration du serveur.

Par exemple, si une organisation était accessible sur “decidim.ch” et qu’on souhaite cloner l’environnement avec une adresse “decidim-geneve.ch”, il faut changer le champ `host` de cette organisation pour “decidim-geneve.ch” dans la base de données répliquée.

Cela se faire directement avec la console Ruby on Rails dans Docker:

```bash
docker-compose -f docker-compose-prod.yml exec app rails c
Decidim::Organization.find(1).update(host: "decidim-geneve.ch")
# 
```

Dans l’exemple précédent, on modifie l'organisation correspondant à l'ID 1. Pour voir toutes les organisations et notamment récupérer un ID, on peut utiliser la commande Rails suivante:

```ruby
Decidim::Organization.all
```



L’environnement cloné devrait maintenant fonctionner sur l’URL configuré.