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
