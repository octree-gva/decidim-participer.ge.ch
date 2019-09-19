# Installation d'un environnement local

Dans un premier temps, on clone le dépôt localement:

```bash
git clone <url>
```

Pour pouvoir suivre les modifications effectuées sur la base Decidim d'Octree, on ajoute une branche `base`.
On pourra ainsi gérer les mises à jour de la base en mergeant cette branche dans notre branche `master`.

```bash
git remote add upstream ssh://git@git.octree.ch:6118/decidim/base.git # On ajoute le dépôt de base comme upstream
git pull upstream base # On récupère les infos de l'upstream
git checkout -b base # On crée une branche base localement
git branch -u upstream/base # On suit le dépôt de base avec cette nouvelle branche
git branch -vv # Pour vérifier
git checkout master # On revient sur master
```

Ensuite, on lance les services avec Docker Compose et on initialise la base de données.

```bash
docker-compose up -d
docker-compose exec -T app rails db:create db:migrate
```

Puis on crée un premier administrateur system.

```bash
docker-compose exec -T app rails c
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```

Ainsi, on a une instance de Decidim en mode développement sur http://localhost:3000 avec un accès admin configuré pour http://localhost:3000/system.

## Mise à jour à partir de la base

Pour suivre les évolutions effectuées sur la base Decidim d'Octree, on récupère les modifications et on "rebase"
la branche principale.

```bash
git checkout base
git pull
git checkout master
git rebase base
git push
```
## Test du bon fonctionnement

Une fois l'environement local lancé à l'aide docker-compose, les dernières des logs doivent contenir les informations suivante en console:

```bash
* Version 3.12.0 (ruby 2.6.3-p62), codename: Llamas in Pajamas
app_1  | * Min threads: 5, max threads: 5
app_1  | * Environment: development
app_1  | * Listening on tcp://0.0.0.0:3000
app_1  | Use Ctrl-C to stop
```

Ensuite, la consultation de http://localhost:3000/ doit rediriger sur http://localhost:3000/system/admins/sign_in, la page de login.

En vous connectant à l'aide des identifiants de l'admin System créée plus haut, vous êtes redirigé vers le tableau de bord du "System" et vous pouvez ainsi créer des organisations.

## Migrations nécessitant les droits SuperUser

```
/Users/antoinemarmoux/code/ocsin/db/migrate/20190909123110_add_parent_child_relation_to_assemblies.decidim_assemblies.rb
```

```
/Users/antoinemarmoux/code/ocsin/db/migrate/20190909123172_enable_pg_trgm_extension_for_proposals.decidim_proposals.rb
```

## Gemfile et Gemfile.lock

Rails utilise les Gems pour ajouter / gérer différentes fonctionnalités de l'application.
L'ajout / suppression de Gem se fait via le fichier Gemfile.
Au lancement de l'application pour la première fois, le fichier est parcouru pour installer tous les gems nécessaire.
Un fichier Gemfile.lock est alors créer, listant les gems installé avec leur version. Ce fichier est alors comparé avec Gemfile et n'installera que les gems manquants.

Pour lister tous les gems installé:

```bash
docker-compose exec -T app gem list
```

Cette liste nous indique également quelles fonctionnalités Decidim sont installées (nom des gems commençant par "Decidim").

## Changer mot de passe admin System

```bash
docker-compose exec -T app rails c
Decidim::System::Admin.last.update_attributes(password: "<nouveau_mdp>", password_confirmation: "<nouveau_mdp>")
```

L'opération doit renvoyer "=> true" en console, qui confirme la sauvegarde en base de donnée de la nouvelle valeur.

## Résolution de bugs

### Problèmes de routes

Message d'erreur rails: 
    ```
    Routing Error
    No routes matches
    ```
L'url consulté ne corrspond à aucune route de l'application.
Pour obtenir la liste de toutes les routes de l'application:

```bash
docker-compose exec -T app rails c
```
Puis une fois dans la console rails:

```bash
rails routes
```

Pour cibler une route en particulière:
```bash
rails routes |grep mot_contenu_dans_la_route
```

### Problèmes de migration

Si à la consultaiton de http://localhost:3000/ une page d'erreur s'affiche avec le message suivant: "ActiveRecord::PendingMigrationError", une ou plusieurs migrations n'ont pas été effectuée. Il faut donc exécuter en console la commande:

```bash
docker-compose exec -T app rails db:migrate
```

