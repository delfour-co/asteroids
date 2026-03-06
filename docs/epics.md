# Neon Asteroids - Development Epics

## Epic Overview

| # | Epic | Scope | Dependencies | Est. Stories |
|---|------|-------|-------------|-------------|
| 1 | Fondations | Projet Flutter+Flame, vaisseau, contrôles, mouvement, wrap-around | Aucune | 5-7 |
| 2 | Core Combat | Tir, astéroïdes, collisions, destruction néon | Epic 1 | 6-8 |
| 3 | Game Loop | Vagues, scoring, vies, game over, SIGNAL PERDU, relance | Epic 2 | 5-7 |
| 4 | Dash Fantomatique | Dash, translucidité, traînée, destruction amplifiée, jauge | Epic 2 | 4-5 |
| 5 | Ennemis | UFOs (3 types), tirs ennemis, spawn system progressif | Epic 3 | 6-8 |
| 6 | Épaves & Upgrades | Épaves, dérive, collecte, upgrades temporaires | Epic 3 | 5-7 |
| 7 | UI & Menus | Menu, HUD, leaderboard, écran contrôles, sauvegarde locale | Epic 3 | 6-8 |
| 8 | Narration & Progression | Fragments, terminal rétro, journal, déblocables, milestones | Epic 6, 7 | 5-7 |
| 9 | Polish Visuel | Background stellaire, particules avancées, glow, optimisation | Epic 5, 6 | 4-6 |
| 10 | Audio | Musique ambient, SFX, intégration réactive | Epic 9 | 4-5 |

---

## Epic 1: Fondations

### Goal

Mettre en place le projet Flutter + Flame Engine et obtenir un vaisseau contrôlable à l'écran avec les contrôles mobiles.

### Scope

**Includes:**
- Initialisation projet Flutter + Flame Engine
- Structure du projet (dossiers, architecture de base)
- Rendu du vaisseau vectoriel néon (polygone programmatique)
- Stick directionnel virtuel (main gauche)
- Bouton propulsion (main droite, bas)
- Physique de mouvement : rotation, accélération, inertie spatiale, freinage
- Wrap-around : sortir d'un côté = réapparaître de l'autre
- Fond noir avec étoiles statiques basiques
- 60fps sur mobile Android

**Excludes:**
- Tir, astéroïdes, ennemis
- Effets glow avancés
- Audio
- UI/menus

### Dependencies

Aucune — c'est le point de départ.

### Deliverable

Un vaisseau néon qui vole à l'écran avec les contrôles tactiles, physique d'inertie spatiale et wrap-around fonctionnels. Le game feel du mouvement est validé.

### Stories

- As a player, I can see a neon ship rendered on a dark starfield background
- As a player, I can steer the ship using a virtual joystick on the left side of the screen
- As a player, I can accelerate the ship using a thrust button on the right side of the screen
- As a player, I can feel space inertia — the ship drifts when I stop accelerating
- As a player, I can wrap around the screen — exiting one side makes me reappear on the opposite side
- As a developer, I have a clean project structure with Flutter + Flame running at 60fps on Android

---

## Epic 2: Core Combat

### Goal

Ajouter le tir et les astéroïdes pour créer le gameplay Asteroids de base — tirer, détruire, esquiver.

### Scope

**Includes:**
- Bouton tir (main droite, milieu) — maintien = rafale continue
- Projectiles laser néon (trait fin, flash à la sortie du canon)
- Astéroïdes procéduraux (polygones irréguliers générés aléatoirement)
- 3 tailles d'astéroïdes : gros → 2 moyens → 2 petits → détruit
- 1 tir = 1 destruction/division (fidèle à l'original)
- Collisions : projectile vs astéroïde, vaisseau vs astéroïde
- Destruction avec effets néon (fragments géométriques, traînées lumineuses)
- Spawn initial d'astéroïdes

**Excludes:**
- Système de vagues, scoring, vies
- UFOs, dash, épaves
- Effets sonores

### Dependencies

Epic 1 (Fondations) — le vaisseau et les contrôles doivent fonctionner.

### Deliverable

Le joueur peut tirer sur des astéroïdes qui se divisent en 3 tailles avec des explosions néon. Le vaisseau est détruit au contact d'un astéroïde. Le core gameplay Asteroids est jouable.

### Stories

- As a player, I can fire neon laser projectiles by pressing and holding the fire button
- As a player, I can see projectiles travel across the screen and wrap around edges
- As a player, I can see procedurally generated asteroids with unique irregular shapes
- As a player, I can destroy a large asteroid and see it split into 2 medium asteroids
- As a player, I can destroy a medium asteroid and see it split into 2 small asteroids
- As a player, I can destroy a small asteroid and see a satisfying neon explosion
- As a player, my ship is destroyed when it collides with an asteroid
- As a player, I can see neon fragment effects when asteroids are destroyed (luminous trails, geometric debris)

---

## Epic 3: Game Loop

### Goal

Transformer le gameplay en un run complet jouable avec vagues, scoring, vies, game over et relance.

### Scope

**Includes:**
- Système de vagues : vague terminée quand tous les astéroïdes sont détruits
- Difficulté progressive : plus d'astéroïdes, plus rapides par vague
- Moment de calme entre les vagues
- Système de score : gros = 20 pts, moyen = 50 pts, petit = 100 pts
- Système de vies : 3 vies au départ, vie supplémentaire tous les 10,000 pts
- Séquence de mort : explosion néon du vaisseau
- Écran SIGNAL PERDU (terminal rétro) avec score et vague atteinte
- Relance (one more run)
- Respawn avec invincibilité temporaire après perte de vie

**Excludes:**
- UFOs, dash, épaves
- Narration, déblocables
- Menu principal, leaderboard
- Audio

### Dependencies

Epic 2 (Core Combat) — le tir et les astéroïdes doivent fonctionner.

### Deliverable

Un run complet de A à Z : le joueur survit à des vagues d'astéroïdes de difficulté croissante, marque des points, perd des vies, voit l'écran SIGNAL PERDU et peut relancer. C'est le vertical slice — déjà un jeu complet et fun.

### Stories

- As a player, I can complete a wave by destroying all asteroids on screen
- As a player, I experience a brief calm moment between waves before the next one spawns
- As a player, I face progressively harder waves (more asteroids, faster speeds)
- As a player, I can see my score increase as I destroy asteroids (20/50/100 points by size)
- As a player, I start with 3 lives and earn an extra life every 10,000 points
- As a player, I respawn with brief invincibility after losing a life
- As a player, I see a cinematic neon explosion when my ship is destroyed
- As a player, I see the "SIGNAL PERDU" retro terminal screen when all lives are lost, showing my score and wave reached
- As a player, I can restart a new run from the game over screen

---

## Epic 4: Dash Fantomatique

### Goal

Implémenter la mécanique signature du jeu — le dash fantomatique qui permet de traverser les astéroïdes.

### Scope

**Includes:**
- Bouton dash (main droite, haut)
- Activation : le vaisseau devient translucide/fantomatique
- Traversée : le vaisseau passe à travers les astéroïdes pendant le dash
- Destruction amplifiée : l'astéroïde traversé explose de manière spectaculaire
- Traînée néon longue effet comète derrière le vaisseau
- Jauge d'énergie avec cooldown de recharge
- Feedback visuel de la jauge sur le HUD

**Excludes:**
- Upgrade "dash infini temporaire" (Epic 6)
- Effets sonores du dash

### Dependencies

Epic 2 (Core Combat) — les astéroïdes et collisions doivent fonctionner.

### Deliverable

Le joueur peut dasher à travers les astéroïdes avec un effet visuel spectaculaire. La mécanique signature est jouable et satisfaisante.

### Stories

- As a player, I can activate the dash by pressing the dash button
- As a player, I can see my ship become translucent/ghostly during the dash
- As a player, I can pass through asteroids while dashing without being destroyed
- As a player, I can see asteroids I dash through explode with amplified spectacular effects
- As a player, I can see a long neon comet trail behind my ship during the dash
- As a player, I can see an energy gauge that depletes when I dash and recharges over time

---

## Epic 5: Ennemis

### Goal

Ajouter les UFOs comme ennemis actifs qui enrichissent le gameplay au-delà des astéroïdes.

### Scope

**Includes:**
- UFO Éclaireur : traverse l'écran, tir imprécis, trajectoire semi-aléatoire
- UFO Chasseur : poursuite active, esquive les tirs, tir précis
- Boss UFO : résistant (5-10 tirs), patterns d'attaque multiples, tells visuels
- Tirs ennemis : projectiles que le joueur doit esquiver
- Spawn system progressif : Éclaireurs vague 5-10, Chasseurs vague 15-20+, Boss périodique
- Score UFO : 500 pts par UFO standard
- Collisions vaisseau vs UFO, projectile vs UFO
- Fréquence croissante avec la progression

**Excludes:**
- Lien narratif des UFOs (Epic 8)
- Effets sonores des UFOs

### Dependencies

Epic 3 (Game Loop) — le système de vagues doit fonctionner.

### Deliverable

Les 3 types d'UFOs apparaissent progressivement au fil des vagues, tirent sur le joueur, et créent une menace active qui diversifie le gameplay.

### Stories

- As a player, I encounter a Scout UFO as a surprise event around wave 5-10
- As a player, I can see Scout UFOs traverse the screen on semi-random paths while firing inaccurately
- As a player, I encounter Hunter UFOs starting around wave 15-20 that actively pursue me
- As a player, I can see Hunter UFOs dodge my shots and fire with precision
- As a player, I face a Boss UFO periodically that requires multiple hits to destroy
- As a player, I can read visual tells before Boss UFO attacks (flash, color change, preparation animation)
- As a player, I must dodge enemy projectiles fired by UFOs
- As a player, I earn 500 points for destroying a standard UFO

---

## Epic 6: Épaves & Upgrades

### Goal

Implémenter le système de risque/récompense avec les épaves et les upgrades temporaires.

### Scope

**Includes:**
- Épaves dans les débris d'astéroïdes détruits (certains astéroïdes contiennent des épaves)
- Spawns indépendants : épaves qui dérivent occasionnellement dans l'arène
- Comportement : les épaves dérivent et disparaissent après un temps limité
- Collecte automatique au passage (voler dessus)
- Upgrades temporaires (durée fixe) :
  - Tir triple (3 projectiles en éventail)
  - Laser (rayon continu qui traverse)
  - Missiles (auto-guidés)
  - Bouclier temporaire
  - Extra vie
  - Vitesse augmentée
  - Dash infini temporaire
- Feedback visuel de l'upgrade actif

**Excludes:**
- Fragments narratifs dans les épaves (Epic 8)
- Effets sonores de collecte

### Dependencies

Epic 3 (Game Loop) — le système de vagues et scoring doit fonctionner.

### Deliverable

Les épaves apparaissent dans l'arène, dérivent et disparaissent. Le joueur peut les collecter pour obtenir des upgrades temporaires qui changent le gameplay pendant un temps limité.

### Stories

- As a player, I can see wreckage appear in asteroid debris after destroying certain asteroids
- As a player, I can see independent wreckage occasionally drift into the arena
- As a player, I can see wreckage drift and eventually disappear if not collected in time
- As a player, I automatically collect wreckage by flying over it
- As a player, I can get a triple shot upgrade that fires 3 projectiles in a fan pattern
- As a player, I can get a laser upgrade that fires a continuous beam
- As a player, I can get homing missiles that target the nearest enemy
- As a player, I can get a temporary shield, extra life, speed boost, or infinite dash
- As a player, I can see a visual indicator showing my active upgrade and remaining duration

---

## Epic 7: UI & Menus

### Goal

Créer tous les écrans nécessaires pour que le jeu soit complet et publiable.

### Scope

**Includes:**
- Menu principal néon minimaliste (vaisseau flottant en background)
- HUD en jeu : score, vies, vague actuelle, jauge dash
- Leaderboard local (top scores + meilleure vague)
- Écran contrôles (premier lancement + accessible depuis menu)
- Sauvegarde locale (SharedPreferences ou JSON) : high scores, préférences
- Pause (entre les vagues)
- Navigation entre les écrans

**Excludes:**
- Journal de bord / fragments narratifs (Epic 8)
- Déblocables cosmétiques (Epic 8)
- Audio UI

### Dependencies

Epic 3 (Game Loop) — le game loop doit être jouable pour tester l'UI en contexte.

### Deliverable

Le jeu a un menu principal, un HUD fonctionnel, un leaderboard local, et un écran d'explication des contrôles. Le jeu est structurellement publiable.

### Stories

- As a player, I see a minimalist neon main menu with my ship floating in the background
- As a player, I can start a new run from the main menu
- As a player, I can see my score, lives, current wave, and dash gauge during gameplay
- As a player, I can view a local leaderboard with my top scores and best wave reached
- As a player, I see a controls explanation screen on first launch
- As a player, I can access the controls screen from the main menu
- As a player, my high scores and preferences are saved locally between sessions
- As a player, I can pause between waves

---

## Epic 8: Narration & Progression (COMPLETE - v1.5.0)

### Goal

Ajouter la couche narrative et le système de méta-progression qui donnent envie de revenir run après run.

### Scope

**Includes:**
- Fragments de mémoire : débloqués toutes les 10 vagues survivées
- Écran terminal rétro pour afficher les fragments (même écran que SIGNAL PERDU)
- Sauvegarde permanente des fragments débloqués
- Journal de bord accessible depuis le menu (consulter les fragments)
- Déblocables cosmétiques par milestones (vagues atteintes) :
  - Skins de vaisseau
  - Effets de traînée
  - Explosions
  - Backgrounds stellaires
  - Musiques/ambiances
- Écran de sélection des cosmétiques
- Épaves contenant des fragments narratifs (en plus des upgrades)

**Excludes:**
- Contenu narratif concret (à écrire séparément — workflow Narrative)
- Système de crédits / achats in-app

### Dependencies

Epic 6 (Épaves & Upgrades) — les épaves doivent fonctionner pour y inclure les fragments.
Epic 7 (UI & Menus) — la navigation et la sauvegarde doivent être en place.

### Deliverable

Le joueur débloque des fragments de mémoire au fil des runs, peut les consulter dans un journal, et débloque des cosmétiques en atteignant des milestones de vagues. La motivation "one more run" est en place.

### Stories

- As a player, I unlock a memory fragment every 10 waves I survive
- As a player, I see the memory fragment displayed on the retro terminal screen
- As a player, my unlocked fragments are permanently saved between sessions
- As a player, I can access a log/journal from the main menu to read all unlocked fragments
- As a player, I unlock cosmetic items when I reach wave milestones (10, 20, 30, 40, 50+)
- As a player, I can select unlocked ship skins, trail effects, explosions, and backgrounds
- As a player, I can find wreckage containing narrative fragments in addition to upgrades

---

## Epic 9: Polish Visuel (COMPLETE - v1.4.0 + v1.5.0)

### Goal

Élever le spectacle visuel au niveau de la vision — ciel stellaire vivant, effets avancés, optimisation performance.

### Scope

**Includes:**
- Background stellaire évolutif : étoiles, constellations, étoiles filantes, voie lactée
- Le ciel devient plus beau/spectaculaire avec la progression des vagues
- Effets glow avancés sur toutes les entités
- Particules améliorées pour les explosions et traînées
- Séquence de mort complète : distorsion → bullet-time → explosion cinématique
- Destructions "parfaites" avec bonus visuel
- Débris qui repoussent les astéroïdes proches (réactions en chaîne)
- Optimisation performance : profiling GPU, culling, budget particules
- Astéroïdes spéciaux : explosifs (wave 5+) et magnétiques (wave 8+)

**Status:** All items implemented across v1.4.0 (tutorial, wave ring, embers) and v1.5.0 (special asteroids, perfect kills, knockback, shooting stars, evolving nebula, death sequence).

### Dependencies

Epic 5 (Ennemis) et Epic 6 (Épaves) — tous les éléments gameplay doivent être en place pour polir visuellement.

### Deliverable

Le jeu est visuellement spectaculaire — le ciel stellaire vit et évolue, les effets néon sont majestueux, la séquence de mort est cinématique, et tout tourne à 60fps.

### Stories

- As a player, I can see a living starfield background with stars, constellations, and shooting stars
- As a player, I see the sky become more beautiful and spectacular as I progress through waves
- As a player, I can see enhanced glow effects on all game entities
- As a player, I experience a full death sequence: distortion → bullet-time → cinematic explosion
- As a player, I see "perfect destruction" bonus visuals when I'm precise
- As a player, I see debris push nearby asteroids creating chain reaction possibilities
- As a developer, the game maintains 60fps on mid-range Android devices with all effects active

---

## Epic 10: Audio

### Goal

Ajouter l'expérience sonore complète — musique ambient Blade Runner et SFX synthétiques.

### Scope

**Includes:**
- Musique ambient électronique (style Vangelis/Blade Runner)
- Musique réactive : s'intensifie avec la difficulté (layers, tempo, basses)
- Distorsion musicale avant la mort
- SFX tir (laser court et net)
- SFX explosions (3 sons selon taille)
- SFX dash (woosh spatial)
- SFX collecte épave (cristallin)
- SFX UFO (bourdonnement)
- SFX Boss (grave, menaçant)
- SFX UI (navigation menus)
- Sourcing assets gratuits (CC0, OpenGameArt, Freesound, IA)

**Excludes:**
- Voix / dialogue
- Musique adaptative complexe (couches multiples synchronisées)

### Dependencies

Epic 9 (Polish Visuel) — le jeu doit être visuellement complet pour calibrer l'audio.

### Deliverable

Le jeu a une ambiance sonore complète qui renforce le flow hypnotique — musique ambient contemplative qui s'intensifie, SFX satisfaisants pour chaque action.

### Stories

- As a player, I hear ambient electronic music that sets a contemplative mood
- As a player, I notice the music intensifying as waves get harder
- As a player, I hear the music distort as a danger signal before death
- As a player, I hear satisfying laser sounds when firing
- As a player, I hear different explosion sounds based on asteroid size
- As a player, I hear a spatial whoosh when dashing
- As a player, I hear a crystalline sound when collecting wreckage
- As a player, I hear distinctive buzzing sounds from UFOs
