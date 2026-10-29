# API utilisables pour le rendu final

Le rendu final s'appuie sur une API **autre qu'Open Food Facts**. Les API ci-dessous ont été
vérifiées le 2026-08-27, puis le 2026-10-28, sur trois critères :

- **aucune clé d'API** à obtenir ;
- **CORS ouvert** (`access-control-allow-origin: *`) donc utilisable depuis Chrome, qui reste la
  cible de développement ;
- **limites de débit compatibles** avec une douzaine d'équipes travaillant simultanément derrière
  l'adresse IP unique de la faculté.

Ce troisième point est le plus important, et le moins visible. Une API dont les limites sont
comptées par adresse IP considère toute la salle comme un seul client.

Une API hors de cette liste est possible, mais **doit être validée avant la séance 11**, sur les
mêmes critères.

---

## Liste validée

| API | Domaine | Base |
|---|---|---|
| **Open-Meteo** | météo, prévisions, historique | `api.open-meteo.com` |
| **Open Library** | livres, auteurs, couvertures | `openlibrary.org` |
| **PokéAPI** | Pokémon, types, évolutions | `pokeapi.co` |
| **TheMealDB** | recettes de cuisine, ingrédients | `themealdb.com` |
| **TheCocktailDB** | cocktails, ingrédients | `thecocktaildb.com` |
| **Wikipedia REST** | articles, résumés, images | `fr.wikipedia.org/api/rest_v1` |
| **Frankfurter** | taux de change, historique | `api.frankfurter.dev/v1` |
| **GBIF** | biodiversité, taxonomie, observations | `api.gbif.org` |
| **Rick and Morty** | personnages, épisodes, lieux | `rickandmortyapi.com` |

Toutes renvoient `access-control-allow-origin: *` et n'exigent aucune clé à obtenir. TheMealDB et
TheCocktailDB placent une clé publique de test, `1`, dans le chemin (`/api/json/v1/1/`), et
réservent quelques points d'entrée aux abonnés.

Les couvertures d'Open Library se demandent par l'identifiant `cover_i`
(`covers.openlibrary.org/b/id/<cover_i>-M.jpg`) ou par OLID, jamais par ISBN : par ISBN, 100
requêtes par adresse IP toutes les cinq minutes, puis `403 Forbidden`.

## Utilisables avec précaution

| API | Contrainte |
|---|---|
| **MusicBrainz** | `User-Agent` identifiant **obligatoire**, et une requête par seconde et par adresse IP, donc pour toute la salle. Utilisable, mais impose un cache local dès le départ. |
| **Nominatim** (OpenStreetMap) | `User-Agent` obligatoire, une requête par seconde, usage intensif proscrit par les conditions. À réserver à du géocodage ponctuel, jamais à de la recherche à la frappe. |

## Écartée

| API | Raison |
|---|---|
| **REST Countries** | Depuis octobre 2026, `/v3.1/` redirige vers un fichier statique sans en-tête CORS : la requête échoue dans Chrome. |
| **Art Institute of Chicago** | Les requêtes reçoivent une page de vérification Cloudflare (`403`) au lieu des données, depuis un terminal comme depuis Chrome. |
| **Jikan** (MyAnimeList) | Renvoyait `504 Gateway Time-out` lors de la vérification du 2026-08-27. Disponibilité insuffisante pour un rendu noté. |
| **Open Trivia DB** | Une requête toutes les cinq secondes par adresse IP (code de réponse 5), pour toute la salle. |
| **Open Food Facts** | C'est l'API du fil rouge. Le rendu vérifie une transposition, pas une répétition. |

---

## Vérifications avant de retenir une API hors liste

La démarche est celle du cours « évaluer une dépendance » de la séance 8, appliquée à un service.

1. **Clé d'API.** Si une inscription est nécessaire, l'API est écartée : la clé finit dans le dépôt,
   et le quota est individuel.
2. **CORS.** Depuis un terminal :

   ```bash
   curl -sI -H "Origin: http://localhost:8080" "<URL de l'API>" | grep -i access-control
   ```

   En l'absence de `access-control-allow-origin`, l'API est inutilisable depuis Chrome. Elle
   fonctionnerait sur Android, mais la moitié du développement se fait sur navigateur.
3. **Limites de débit.** Chercher « rate limit » dans la documentation. Une limite exprimée **par
   adresse IP** s'applique à toute la salle simultanément.
4. **Conditions d'utilisation.** Certaines API autorisent la lecture mais interdisent le
   stockage ou la redistribution. À lire avant de construire un cache.
5. **Disponibilité.** Interroger l'API à plusieurs moments de la journée. Un service qui répond
   `504` pendant la vérification répondra `504` pendant la démonstration.

## Précautions communes

Les limites par adresse IP se déclenchent en TP, pas en développement individuel. Deux réflexes
suffisent à les éviter :

- **`debounce` sur toute recherche à la frappe.** Sans lui, chaque caractère déclenche une requête.
  Vu en séance 5 : un debounce composé avec `restartable` de `bloc_concurrency`, ou `debounce` de
  `stream_transform`.
- **Cache local des réponses.** Vu en séance 7, diapositive « Trois façons de lire hors ligne ». Une
  réponse déjà obtenue ne se redemande pas.

Ces deux points ne sont pas des optimisations : ce sont les conditions d'utilisation d'une API
publique.
