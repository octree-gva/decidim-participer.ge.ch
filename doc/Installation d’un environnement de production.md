# Installation d’un environnement de production

## 1. Récupération des sources

Dans un premier temps, on récupère les sources depuis le dépôt Git.

```bash
git clone ssh://git@git.octree.ch:6118/decidim/ocsin.git decidim
cd decidim
```

## 2. Configuration

La configuration de l’application est faite uniquement par l’intermédiaire de variables d’environnement passées au container Docker Decidim avec un fichier `.env`.

Pour chaque nouvel environnement d’exécution, il est nécessaire de le créer à partir du fichier template `.env.tmpl` présent dans le dépôt du projet.

```bash
cp .env.tmpl .env
vi .env
```

> Pour le SMTP, c’est le port 587 (TLS) qui est utilisé avec une authentification *plain*. Cela n’est pas modifiable par des variables d’environnement.

## 3. Lancement de l’application

Une fois la configuration faite, on peut lancer le container Decidim avec Docker Compose.

```bash
docker-compose -f docker-compose-prod.yml up -d
```

Après quelques secondes, le container se met en écoute sur le port 80 de l’hôte mais retourne une erreur 500 en attendant que la base de données soit initialisée.

## 4. Initialisation de la base de données

Lorsque le container Decidim est lancé, on peut lancer la migration des schémas de la base de données pour l’initialiser.

```bash
docker-compose -f docker-compose-prod.yml exec -T app rails db:migrate
```

Si la connexion au serveur Postgres est correcte et que la base de données précisée dans le fichier `.env` existe, alors la migration devrait s’effectuer sans problème.

## 5. Création d’un administrateur système

L’application est désormais accessible sur le port 80 mais il n’est pas possible de se connecter car il faut créer un premier administrateur système.

```bash
docker-compose -f docker-compose-prod.yml exec app rails c
```

Une fois dans la console Rails:

```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```

On peut ensuite se connecter sur l’interface Système (`/system`) de Decidim en tant qu’administrateur.

## 6. Création d’une première organisation

Sur l’interface Système, dans l’onglet *Organizations*, on crée une nouvelle organisation avec les paramètres désirés.

Pour le champ *Host*, il est nécessaire de préciser le nom de domaine sur lequel l’organisation doit être accédée.

> **Attention**: lors de l’ajout d’une organisation, un e-mail est envoyé à l’admin (de l’organisation). Si les e-mails ne sont pas ou sont mals configurés, un message d’erreur s’affiche et l’organisation n’est pas créée.