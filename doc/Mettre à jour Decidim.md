# Mettre à jour Decidim

Les mises à jour de l’application Decidim sont facilitées par l’utilisation de Docker. Lors d’une mise à jour, Octree met à disposition une nouvelle image dans le container registry correspondant au projet (git.octree.ch:4567/decidim/ocsin pour l’OCSIN).

On y trouve notamment:

- `git.octree.ch:4567/decidim/ocsin:latest` : Image la plus à jour dans le dépôt
- `git.octree.ch:4567/decidim/ocsin:<git commit hash>` : Image correspondant à la version des sources référencée par le git commit hash.

Pour mettre à jour un environnement déjà en exécution, on utilise ces commandes Docker Compose:

```bash
docker-compose -f docker-compose-prod.yml pull # Retrait de la dernière image depuis le dépôt
docker-compose -f docker-compose-prod.yml up -d # Les containers qui ont une image plus récente disponible sont mis à jour
```

> S’il y a plusieurs instances du même container, Docker Compose fait une mise à jour séquentielle pour assurer la disponibilité du service.