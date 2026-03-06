---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
inputDocuments:
  - "_bmad-output/game-brief.md"
  - "_bmad-output/brainstorming-session-2026-03-02.md"
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 1
  projectDocs: 0
workflowType: 'gdd'
lastStep: 0
project_name: 'mobilegame--asteroids'
user_name: 'Kevin'
date: '2026-03-02'
game_type: 'shooter'
game_name: 'Neon Asteroids'
---

# Neon Asteroids - Game Design Document

**Author:** Kevin
**Game Type:** Shooter (arcade)
**Target Platform(s):** {{platforms}}

---

## Executive Summary

### Game Name

Neon Asteroids

### Core Concept

Neon Asteroids est un shooter arcade néon qui réinvente le classique Asteroids dans un univers stellaire contemplatif. Le dernier survivant de la Terre se réveille d'un cryo-sommeil pour découvrir que l'humanité a disparu. Seul dans un espace magnifique et dangereux, il survit vague après vague contre des astéroïdes et des UFOs mystérieux.

Le jeu mêle la pureté du gameplay arcade original — tirer, esquiver, détruire — à des mécaniques modernes : un dash fantomatique signature permettant de traverser les astéroïdes, un système d'épaves à récupérer sous pression, et une narration fragmentée qui se dévoile run après run à travers un terminal rétro.

L'expérience oscille entre contemplation hypnotique — portée par un ciel stellaire vivant et une ambient électronique — et chaos néon intense, créant un flow addictif conçu pour des sessions courtes sur mobile.

### Game Type

**Type :** Shooter (arcade)
**Framework :** Ce GDD utilise le template shooter avec des sections spécifiques pour les systèmes d'armes, le combat, le design d'ennemis et le design d'arènes.

---

## Target Platform(s)

### Primary Platform

Android (Google Play Store)

### Platform Considerations

- **Engine :** Flutter + Flame Engine / Dart
- **Performance :** 60fps visé sur mobile
- **Taille app :** Légère — assets vectoriels programmatiques, aucun sprite externe
- **Online :** Aucun — pas de backend, leaderboard local uniquement
- **Distribution :** Google Play Store (compte développeur déjà en place)
- **Contraintes thermiques/batterie :** Optimisation nécessaire pour le rendu néon continu

### Control Scheme

- **Main gauche :** Stick de direction virtuel
- **Main droite :** Propulsion (bas) + Tir (milieu) + Dash (haut)
- **Automatique :** Collecte d'épaves au passage
- **Design tactile :** Zones de touch généreuses, feedback visuel clair sur les inputs

---

## Target Audience

### Demographics

- **Âge :** 15-45 ans
- **Plateforme :** Mobile Android
- **Profil :** Joueurs cherchant des jeux accessibles pour des sessions courtes

### Gaming Experience

Casual à core — joueurs qui apprécient un gameplay simple à comprendre mais avec de la profondeur pour la maîtrise

### Genre Familiarity

Mixte — certains connaissent le classique Asteroids (nostalgiques), d'autres découvrent le genre (nouvelle génération). Le jeu ne requiert aucune connaissance préalable.

### Session Length

2-5 minutes — sessions pause café, transports, moments d'attente. Possibilité de sessions plus longues (10-15 min) pour les joueurs investis.

### Player Motivations

- Rentrer facilement dans le jeu sans friction
- Décompresser avec un gameplay satisfaisant visuellement
- Progression et curiosité narrative qui donnent envie de revenir
- Challenge croissant qui récompense la maîtrise

### Unique Selling Points (USPs)

1. **Dash fantomatique** — Mécanique signature inexistante dans les remakes d'Asteroids. Le vaisseau devient translucide et traverse les astéroïdes avec une traînée néon spectaculaire et une destruction amplifiée.
2. **Narration fragmentée par runs** — Tous les 10 vagues, un fragment de mémoire se débloque via un terminal rétro. L'histoire persiste entre les runs.
3. **Ciel stellaire vivant** — Background évolutif qui devient plus beau avec la progression. La beauté comme récompense de la survie.
4. **Arc émotionnel contemplatif → intense** — Flow hypnotique unique de la contemplation calme au chaos néon pur.

---

## Goals and Context

### Project Goals

1. **Publication** — Publier Neon Asteroids sur le Google Play Store, jouable et fonctionnel
2. **Exemplarité pédagogique** — Produire un code propre, documenté et structuré servant d'exemple concret pour des jeunes en reconversion professionnelle dans le développement de jeux
3. **Vision intergénérationnelle** — Prouver qu'un gameplay intemporel n'a besoin que d'un écrin moderne pour toucher toutes les générations — la nostalgie des uns devient l'émerveillement des autres

### Background and Rationale

Neon Asteroids naît d'une passion personnelle : Kevin, développeur né en 1982, a grandi avec les jeux d'arcade qui ont défini une génération. Ce projet est à la fois un hommage à ces classiques et un véhicule pédagogique — démontrer qu'un solo dev peut livrer un jeu mobile complet avec Flutter + Flame, des outils gratuits et open source, en partant d'un concept simple et en l'enrichissant méthodiquement. Le jeu est gratuit, sans enjeu commercial, mais avec une mission : inspirer et former.

### Competitive Positioning

Jeu gratuit, projet passion et pédagogique. Neon Asteroids ne cherche pas à concurrencer commercialement mais à se démarquer par son identité : le seul remake d'Asteroids qui transforme un classique arcade en expérience contemplative et narrative.

---

## Core Gameplay

### Game Pillars

1. **Accessibilité immédiate** — Le joueur entre dans le jeu en 2 secondes, comprend en 5. Aucune barrière à l'entrée, apprentissage organique sans tutoriel. Chaque feature doit être intuitive au premier contact.

2. **Flow hypnotique** — Le mélange musique ambient électronique + visuels néon + gameplay crée un état de transe. Le joueur perd la notion du temps. Le rythme alterne calme contemplatif et intensité croissante.

3. **Spectacle visuel** — Chaque action produit un résultat visuellement satisfaisant et majestueux. Explosions néon, traînées lumineuses, feux d'artifice de fragments. Le jeu doit être aussi beau à regarder qu'à jouer.

4. **Découverte narrative** — L'histoire se révèle au fil des runs via des fragments de mémoire. Le joueur est motivé par la curiosité : que s'est-il passé ? Qui sont les UFOs ? Pourquoi l'humanité a disparu ?

**Pillar Prioritization :** Quand deux piliers sont en conflit, le plus majestueux gagne. Priorité : Spectacle visuel > Flow hypnotique > Accessibilité immédiate > Découverte narrative.

### Core Gameplay Loop

Le joueur répète un cycle d'action-récompense à deux échelles temporelles :

**Micro-loop (secondes) :**
Tourner/Accélérer → Viser → Tirer/Dasher → Détruire astéroïde → Feedback visuel (explosion néon) → Esquiver débris → Recommencer

**Macro-loop (minutes) :**
Débuter une vague → Survivre et détruire → Collecter épaves (risque/récompense) → Compléter la vague → Moment de calme → Vague suivante (difficulté +) → Tous les 10 vagues : fragment de mémoire → Mort → SIGNAL PERDU → One more run

**Loop Diagram :**
```
[Spawn vague] → [Tirer/Esquiver/Dasher] → [Détruire astéroïdes]
       ↑                                          ↓
       |                                   [Épaves apparaissent]
       |                                          ↓
       |                                [Risque : collecter ?]
       |                                          ↓
       |                                 [Vague terminée]
       |                                          ↓
       |                                [Moment de calme]
       |                                          ↓
       |← ← ← ← ← ← ← ← ← ← ← ← ← [Vague suivante]
                                                  ↓
                                        [Toutes les 10 vagues]
                                                  ↓
                                       [Fragment de mémoire]
                                                  ↓
                                         [Mort éventuelle]
                                                  ↓
                                          [SIGNAL PERDU]
                                                  ↓
                                          [One more run]
```

**Loop Timing :** Micro-loop = 2-5 secondes | Macro-loop (une vague) = 30-60 secondes | Run complète = 2-15 minutes

**Loop Variation :** Chaque itération est différente grâce à : nouveaux types d'astéroïdes, UFOs qui apparaissent progressivement, upgrades temporaires aléatoires dans les épaves, ciel stellaire qui évolue visuellement, boss UFO périodiques.

### Win/Loss Conditions

#### Victory Conditions

Pas de "win state" définitif — Neon Asteroids est un infinite run. Le succès se mesure par :
- **Score** — Battre son high score personnel (leaderboard local)
- **Survie** — Atteindre la vague la plus haute possible
- **Narration** — Débloquer tous les fragments de mémoire pour reconstituer l'histoire complète
- **Collection** — Débloquer tous les éléments cosmétiques (skins, traînées, backgrounds, musiques)

#### Failure Conditions

- Le vaisseau est détruit quand il entre en contact avec un astéroïde, un projectile ennemi ou un UFO
- Chaque destruction coûte une vie
- Perte de toutes les vies = fin du run

#### Failure Recovery

1. La musique ambient se distord (signal de danger)
2. Ralenti bullet-time dramatique avant l'impact final
3. Explosion néon cinématique du vaisseau
4. Écran "SIGNAL PERDU" sur terminal rétro
5. Affichage du score, vague atteinte, fragments débloqués
6. Les fragments de mémoire débloqués pendant le run sont sauvegardés (permanents)
7. Les upgrades temporaires sont perdus
8. Le joueur relance — motivé par le prochain fragment, la prochaine vague, le prochain record

---

## Game Mechanics

### Primary Mechanics

**1. Tourner / Accélérer (Mouvement)**
- **Fréquence :** Constante — le joueur se déplace en permanence
- **Compétence testée :** Positionnement, anticipation des trajectoires
- **Feeling :** Physique arcade classique — inertie du vaisseau, glisse dans l'espace. Le vaisseau ne freine pas instantanément, il faut anticiper.
- **Piliers servis :** Accessibilité immédiate (intuitif dès la première seconde), Flow hypnotique (mouvement fluide et continu)

**2. Tirer (Combat)**
- **Fréquence :** Constante — tir rapide en continu tant que le joueur appuie
- **Compétence testée :** Visée, timing, priorisation des cibles
- **Feeling :** Trait fin et rapide style laser néon. Petit flash lumineux à la sortie du canon. Tir satisfaisant et responsive.
- **Progression :** Upgrades temporaires dans les épaves (tir triple, laser, missiles)
- **Piliers servis :** Accessibilité immédiate (appuyer = tirer), Spectacle visuel (traînées laser néon)

**3. Dasher (Combat / Mouvement — Mécanique Signature)**
- **Fréquence :** Situationnelle — utilisé stratégiquement pour traverser ou détruire
- **Compétence testée :** Timing, prise de risque, lecture de la situation
- **Feeling :** Le vaisseau devient translucide/fantomatique. Traînée néon longue effet comète. L'astéroïde traversé explose de manière spectaculaire (plus beau qu'un tir normal).
- **Ressource :** Jauge d'énergie qui se recharge (cooldown)
- **Piliers servis :** Spectacle visuel (explosion amplifiée, traînée comète), Flow hypnotique (moment de puissance dans le flow)

**4. Collecter Épaves (Interaction / Risque-Récompense)**
- **Fréquence :** Situationnelle — quand une épave apparaît dans les débris
- **Compétence testée :** Évaluation du risque, positionnement sous pression
- **Feeling :** Collecte automatique au passage (voler dessus). L'épave dérive et disparaît si non récupérée à temps. Tension entre survie et récompense.
- **Contenu :** Upgrades temporaires (armes, défensif, mouvement) OU fragments d'histoire
- **Piliers servis :** Découverte narrative (fragments de mémoire), Flow hypnotique (micro-décision dans le flow)

**5. Esquiver (Mouvement / Survie)**
- **Fréquence :** Constante — esquive passive via le mouvement
- **Compétence testée :** Lecture de l'espace, réflexes, anticipation
- **Feeling :** Passer entre les astéroïdes, éviter les débris, se faufiler dans le chaos. Pas de bouton dédié — l'esquive EST le mouvement.
- **Piliers servis :** Accessibilité immédiate (pas de mécanique supplémentaire à apprendre), Flow hypnotique (le danger constant maintient la transe)

### Mechanic Interactions

| Mécanique A | + Mécanique B | = Interaction |
|-------------|---------------|---------------|
| **Dasher** | + **Tirer** | Choix tactique : dash à travers OU tirer à distance |
| **Dasher** | + **Collecter** | Dasher vers une épave en traversant un astéroïde au passage |
| **Esquiver** | + **Collecter** | Dévier sa trajectoire sûre pour récupérer une épave (risque) |
| **Tirer** | + **Esquiver** | Détruire les obstacles sur sa trajectoire d'esquive |

### Mechanic Progression

Les mécaniques ne s'upgradent pas de manière permanente — Neon Asteroids est un infinite run arcade. La progression passe par :

- **Upgrades temporaires (run only)** — Trouvés dans les épaves : tir triple, laser, missiles, bouclier temporaire, extra vie, vitesse, dash infini temporaire
- **Maîtrise du joueur** — Le joueur s'améliore naturellement : meilleur timing de dash, lecture des patterns d'astéroïdes, gestion du risque épaves

---

## Controls and Input

### Control Scheme (Android Mobile)

| Zone écran | Input | Action | Fréquence |
|------------|-------|--------|-----------|
| **Main gauche** | Stick virtuel | Tourner / Accélérer | Constante |
| **Main droite (bas)** | Bouton | Propulsion | Fréquente |
| **Main droite (milieu)** | Bouton (maintien) | Tir continu | Constante |
| **Main droite (haut)** | Bouton | Dash | Situationnelle |
| **Automatique** | Proximité | Collecte d'épaves | Passive |

### Input Feel

- **Stick directionnel :** Responsive, zone de dead-zone petite, feedback visuel clair (le stick s'illumine)
- **Tir :** Zéro latence perçue, appui maintenu = rafale continue, feedback flash néon
- **Dash :** Pression franche, activation immédiate, feedback visuel spectaculaire (translucidité + traînée)
- **Propulsion :** Accélération progressive avec inertie spatiale
- **Zones de touch :** Généreuses — pas de précision pixel requise, adaptées au jeu mobile

### Accessibility Controls

- Non défini pour le MVP — à explorer post-lancement selon les retours joueurs

---

## Shooter Specific Design

### Weapon Systems

**Primary Weapon — Laser Néon**
- **Type :** Projectile rapide directionnel (le vaisseau tire droit devant lui)
- **Cadence :** Rapide — tir continu tant que le joueur maintient le bouton
- **Portée :** Traverse tout l'écran (wrap-around inclus)
- **Dégâts :** 1 tir = 1 destruction/division (fidèle à l'original)
- **Feeling :** Trait fin et rapide style laser néon, flash lumineux à la sortie du canon

**Dash Offensif — Traversée Fantomatique**
- **Type :** Arme de mêlée/traversée (mécanique signature)
- **Dégâts :** Détruit l'astéroïde traversé avec explosion amplifiée
- **Ressource :** Jauge d'énergie avec cooldown de recharge
- **Feeling :** Vaisseau translucide, traînée comète néon, explosion spectaculaire

**Upgrades Temporaires (durée fixe)**
- **Tir Triple** — 3 projectiles en éventail, même cadence. Couvre plus de zone, idéal pour les vagues denses.
- **Laser** — Rayon continu qui traverse tout. Puissance brute, spectacle visuel maximal.
- **Missiles** — Auto-guidés vers la cible la plus proche. Moins de skill requis, plus de destruction.
- **Durée :** Temps fixe (à calibrer en playtest — estimation : 10-15 secondes)
- **Source :** Trouvés dans les épaves d'astéroïdes détruits

### Aiming and Combat Mechanics

**Aiming System**
- **Type :** Directionnel fixe — le vaisseau tire dans la direction de son nez
- **Précision :** Pas de spread, pas de recul. La visée = le positionnement du vaisseau.
- **Skill expression :** Tourner pour viser + anticiper les trajectoires des astéroïdes en mouvement

**Hit Detection**
- **Type :** Projectile — les tirs sont des entités visibles qui voyagent à haute vitesse
- **Collisions :** Projectile vs astéroïde, projectile vs UFO, projectile vs projectile ennemi

**Damage Model (fidèle à l'original)**

| Cible | Tirs requis | Résultat |
|-------|-------------|----------|
| Gros astéroïde | 1 | Se brise en 2 moyens (20 pts) |
| Moyen astéroïde | 1 | Se brise en 2 petits (50 pts) |
| Petit astéroïde | 1 | Détruit — explosion néon (100 pts) |
| UFO | 1 | Détruit (500 pts) |
| Boss UFO | Plusieurs | Voir section Enemy Design |

### Enemy Design and AI

**UFO Standard — Éclaireur**
- **Apparition :** À partir de la vague 5-10, comme événement surprise
- **Comportement :** Traverse l'écran en tirant — trajectoire semi-aléatoire (fidèle à l'original)
- **Tir :** Imprécis au début, de plus en plus précis avec la progression des vagues
- **Fréquence :** Devient régulier après première apparition, de plus en plus fréquent

**UFO Avancé — Chasseur**
- **Apparition :** Vagues 15-20+
- **Comportement :** Poursuite active du joueur, esquive les tirs, mouvements en cercles
- **Tir :** Précis, cadence plus rapide
- **Lien narratif :** Lié à la progression de l'histoire — qui sont-ils ? Pourquoi poursuivent-ils le joueur ?

**Boss UFO — Vaisseau-mère**
- **Apparition :** Périodique (tous les X vagues — à calibrer en playtest)
- **Résistance :** Plusieurs tirs nécessaires pour le détruire (5-10 selon progression)
- **Pattern :** Patterns de mouvement spéciaux, attaques multiples (tirs en éventail, charges, mines)
- **Tells :** Signaux visuels avant chaque attaque (flash, changement de couleur, animation préparatoire)
- **Récompense :** Score élevé + épave garantie avec upgrade ou fragment narratif

**Spawn System**
- Vagues 1-4 : Astéroïdes uniquement (apprentissage)
- Vagues 5-10 : Premier UFO Éclaireur (surprise)
- Vagues 10+ : UFOs réguliers, fréquence croissante
- Vagues 15-20+ : Introduction des Chasseurs
- Tous les X vagues : Boss UFO
- Scaling : Plus de variété, plus rapides, plus agressifs avec la progression

### Arena and Level Design

**Zone de jeu**
- **Taille :** 1 écran fixe, taille constante quelle que soit la vague
- **Wrap-around :** Fidèle à l'original — sortir d'un côté = réapparaître de l'autre (vaisseau, astéroïdes, projectiles, UFOs)
- **Background :** Ciel stellaire vivant évolutif (plus spectaculaire avec la progression)

**Flow de l'arène**
- Espace ouvert à 360° — pas de murs, pas de couverture, pas d'obstacles fixes
- La densité d'objets crée naturellement des zones de danger et des corridors de fuite
- Le wrap-around ajoute une couche stratégique : fuir par un bord pour réapparaître en sécurité

**Power-up Placement**
- **Épaves dans les débris :** Apparaissent quand un astéroïde contenant une épave est détruit
- **Spawns indépendants :** Des épaves dérivent aussi occasionnellement dans l'arène, indépendamment des destructions
- **Comportement :** Les épaves dérivent et disparaissent après un temps limité
- **Collecte :** Automatique au passage (voler dessus)

### Multiplayer Considerations

Non applicable — Neon Asteroids est une expérience solo uniquement. Pas de multijoueur prévu.

---

## Progression and Balance

### Player Progression

Neon Asteroids combine trois types de progression complémentaires :

#### Progression par Maîtrise (Skill)
- **Nature :** Le joueur s'améliore naturellement au fil des runs
- **Compétences :** Timing du dash, lecture des trajectoires, gestion du risque épaves, priorisation des cibles
- **Pacing :** Immédiat — chaque run enseigne quelque chose. Maîtrise perceptible après 5-10 runs.
- **Pilier servi :** Accessibilité immédiate → Flow hypnotique (la maîtrise crée le flow)

#### Progression Narrative (Fragments de mémoire)
- **Nature :** Permanente entre les runs — les fragments débloqués sont sauvegardés définitivement
- **Déclencheur :** Un fragment se débloque toutes les 10 vagues survivées
- **Consultation :** Journal/log accessible depuis le menu principal
- **Pacing :** Un joueur moyen (mort vague 15-20) débloque 1 fragment par run. Un bon joueur peut en débloquer 2-3.
- **Pilier servi :** Découverte narrative (motivation "one more run")

#### Progression par Collection (Déblocables)
- **Nature :** Permanente — les cosmétiques débloqués persistent
- **Système :** Déblocage par milestones de vagues atteintes (meilleur record personnel)
- **Contenu :** Skins de vaisseau, effets de traînée, explosions, backgrounds stellaires, musiques/ambiances
- **Pacing :** Répartis sur toute la courbe de progression — premiers déblocages accessibles (vague 10), derniers exigeants (vague 50+)
- **Pilier servi :** Spectacle visuel (personnalisation de l'expérience)

#### Progression Tableau

| Milestone (vague atteinte) | Déblocage exemple |
|---------------------------|-------------------|
| Vague 10 | Premier skin de vaisseau alternatif |
| Vague 20 | Nouvelle traînée néon |
| Vague 30 | Nouvelle explosion |
| Vague 40 | Background stellaire alternatif |
| Vague 50+ | Déblocables rares / prestige |

*Milestones et déblocables précis à définir en phase de production.*

### Difficulty Curve

**Pattern : Sawtooth (dents de scie)**

Montée progressive en difficulté avec moments de respiration entre les vagues et spikes aux boss UFO.

```
Difficulté
    ▲
    │                                          ╱Boss
    │                                    ╱────╱
    │                              ╱────╱ ↓calm
    │                  Boss╱─────╱
    │              ╱──────╱ ↓calm
    │        ╱────╱
    │  ╱────╱ ↓calm
    │╱─╱
    └──────────────────────────────────────────→ Vagues
     1    5    10   15   20   25   30   35
```

#### Challenge Scaling

| Vagues | Contenu | Difficulté |
|--------|---------|------------|
| **1-4** | Astéroïdes lents, peu nombreux | Apprentissage organique |
| **5-10** | Plus d'astéroïdes, premier UFO Éclaireur (surprise) | Introduction tension |
| **10-15** | UFOs réguliers, astéroïdes plus rapides, premier Boss UFO | Montée sérieuse |
| **15-20** | Introduction UFO Chasseur, densité élevée | Challenge confirmé |
| **20-30** | Mix intense de tout, Boss UFO récurrents | Maîtrise requise |
| **30+** | Chaos néon maximal, tous types d'ennemis, vitesse élevée | Mode expert |

#### Éléments de scaling

- **Nombre d'astéroïdes** par vague : augmente progressivement
- **Vitesse des astéroïdes** : augmente
- **Fréquence des UFOs** : augmente
- **Précision des tirs UFO** : augmente
- **Résistance Boss UFO** : augmente (plus de tirs nécessaires)
- **Moment de calme entre vagues** : se raccourcit légèrement

#### Difficulty Options

Pas de sélection de difficulté — la courbe est unique et progressive. La difficulté s'adapte naturellement par la durée de survie : chaque joueur atteint son "mur" personnel et progresse par la maîtrise.

### Economy and Resources

Pas d'économie in-game au lancement. Les déblocages se font par milestones uniquement (vagues atteintes).

**Ressources in-run uniquement :**
- **Vies** — Début avec 3 vies, vie supplémentaire tous les 10,000 points
- **Jauge de dash** — Se recharge automatiquement (cooldown)
- **Upgrades temporaires** — Durée fixe, perdus à la mort

**Évolution future possible :** Si le jeu rencontre un succès significatif, un système de crédits avec achats in-app pourra être envisagé. Non prévu pour le MVP.

---

## Level Design Framework

### Structure Type

**Endless (Infinite Run par Vagues)**

Neon Asteroids n'a pas de niveaux distincts. Le jeu est un run infini structuré par des vagues successives dans une arène fixe. Chaque run est unique grâce à la variation procédurale.

### Level Types

Pas de niveaux au sens classique — le contenu est structuré par des **phases de vagues** :

| Phase | Vagues | Composition | Ambiance |
|-------|--------|-------------|----------|
| **Éveil** | 1-4 | Astéroïdes lents, peu nombreux | Calme, contemplatif |
| **Premiers contacts** | 5-10 | Densité croissante, premier UFO Éclaireur | Tension naissante |
| **Escalade** | 10-20 | Mix astéroïdes + UFOs réguliers, premier Boss | Intensité croissante |
| **Chaos maîtrisé** | 20-30 | Tous types d'ennemis, Boss récurrents | Challenge soutenu |
| **Néon pur** | 30+ | Densité maximale, vitesse élevée, chaos total | Mode expert |

Chaque vague est un **mix progressif** — pas de vagues thématiques, mais une augmentation continue de la variété et de l'intensité.

#### Tutorial Integration

**Premier lancement uniquement :** Un écran d'explication s'affiche au tout premier démarrage du jeu, montrant les contrôles (stick directionnel, boutons tir/propulsion/dash). Cet écran est consultable depuis le menu principal par la suite.

Après cet écran, **apprentissage 100% organique** — les vagues 1-4 servent de tutoriel implicite : peu d'astéroïdes, lents, le joueur expérimente naturellement tourner, tirer, esquiver.

#### Événements spéciaux

- **Premier UFO (vague 5-10)** — Événement surprise "oh c'est quoi ça" qui brise la routine astéroïdes
- **Boss UFO (périodique)** — Spike de difficulté, récompense garantie
- **Fragments de mémoire (toutes les 10 vagues)** — Récompense narrative, moment de pause

### Level Progression

**Modèle : Progression infinie linéaire avec variation procédurale**

- **Pas de sélection de niveau** — le joueur lance un run et survit le plus longtemps possible
- **Pas de déblocage de niveaux** — tout le contenu est accessible dès le premier run, il faut juste survivre assez longtemps pour le voir
- **Rejouabilité par variation** — chaque run est différent grâce à :

#### Éléments de variation entre les runs

- **Spawns d'astéroïdes** — Positions, tailles et trajectoires aléatoires à chaque vague
- **Types d'astéroïdes** — Variation procédurale des formes et comportements (magnétiques, explosifs, division multiple)
- **Timing des UFOs** — Apparition dans une fenêtre aléatoire (pas toujours la même vague exacte)
- **Contenu des épaves** — Upgrades aléatoires (tir triple, laser, missiles, bouclier, vie, vitesse, dash infini)
- **Événements aléatoires** — Pluie d'astéroïdes, vague dense surprise, épave rare

#### Replayability

La rejouabilité repose sur 4 piliers :
1. **Variation procédurale** — Chaque run est unique
2. **Score** — Chase au high score, leaderboard local
3. **Narration** — Fragments de mémoire à débloquer
4. **Collection** — Déblocables cosmétiques par milestones

### Level Design Principles

1. **Enseigner par le jeu, jamais par le texte** — Les vagues 1-4 sont le tutoriel implicite
2. **Quelque chose de nouveau toutes les 5 vagues** — Nouvel élément ou événement pour maintenir l'intérêt
3. **Respirer entre les vagues** — Court moment de calme pour souffler et apprécier le ciel stellaire
4. **Le chaos est une récompense** — Plus on survit, plus c'est spectaculaire visuellement

---

## Art and Audio Direction

### Art Style

**Vectoriel Néon Programmatique**

Style 100% code — aucun sprite externe, aucune texture importée. Toutes les formes sont dessinées programmatiquement : lignes géométriques, polygones, cercles avec antialiasing et effets glow néon.

#### Visual References

- **Tron (1982 / Legacy 2010)** — L'esthétique néon sur fond sombre, les traînées lumineuses, les formes géométriques épurées qui brillent dans l'obscurité. C'est LA référence visuelle principale.
- **Asteroids (1979)** — La simplicité vectorielle originale, les formes reconnaissables en quelques lignes
- **Geometry Wars** — L'intensité visuelle néon, les particules, le chaos lumineux maîtrisé

#### Color Palette

| Couleur | Usage | Hex estimé |
|---------|-------|------------|
| **Cyan** | Vaisseau, tirs, UI principale | #00FFFF |
| **Magenta** | Astéroïdes, danger, explosions | #FF00FF |
| **Jaune** | Épaves, récompenses, points | #FFFF00 |
| **Blanc** | Étoiles, texte, accents | #FFFFFF |
| **Noir profond** | Background spatial | #000011 |

Effets glow sur toutes les couleurs — halo lumineux autour des formes, comme des néons dans l'obscurité.

#### Camera and Perspective

- **Vue :** Top-down 2D classique (fidèle à l'original)
- **Caméra :** Fixe — l'arène complète est toujours visible, pas de scrolling ni de suivi
- **Orientation :** Paysage (landscape) sur mobile

#### Visual Effects

- **Explosions :** Fragments géométriques avec traînées lumineuses (feux d'artifice néon)
- **Traînées :** Lignes lumineuses derrière le vaisseau, les projectiles, le dash
- **Glow :** Halo néon sur toutes les entités actives
- **Particules :** Limitées au départ, ajout progressif après profiling performance
- **Background :** Ciel stellaire vivant — étoiles, constellations, étoiles filantes, voie lactée. Évolue et devient plus spectaculaire avec la progression des vagues.

### Audio and Music

#### Music Style

**Ambient électronique — inspiration Blade Runner (Vangelis)**

- **Ambiance :** Synthétiseurs lents, nappes atmosphériques, réverbération spatiale
- **Ton :** Contemplatif et mélancolique en début de run, montée en tension progressive
- **Réactivité :** La musique s'intensifie avec la difficulté — layers supplémentaires, tempo qui accélère, basses plus présentes
- **Mort :** La musique se distord avant l'impact final (signal de danger)
- **Source :** Assets gratuits à sourcer (OpenGameArt, Freesound, IA générative, etc.)

#### Sound Design

**Synthétique moderne — inspiré rétro mais pas 8-bit**

- **Tir :** Son laser court et net, synthétique
- **Explosion astéroïde :** Son différent selon la taille (petit = aigu, gros = grave profond)
- **Dash :** Woosh spatial avec réverbération
- **Collecte épave :** Son positif, cristallin
- **UFO :** Bourdonnement distinctif, inquiétant
- **Boss :** Son grave, menaçant
- **MVP :** Le jeu se lance sans audio — ajout progressif post-MVP

#### Voice/Dialogue

Aucune voix — la narration passe exclusivement par du texte sur l'écran terminal rétro.

### Aesthetic Goals

L'art et l'audio servent directement les 4 piliers :

| Pilier | Contribution Art | Contribution Audio |
|--------|-----------------|-------------------|
| **Accessibilité immédiate** | Formes simples et lisibles, couleurs distinctes par type | Sons clairs qui confirment les actions |
| **Flow hypnotique** | Mouvement fluide des étoiles, glow pulsant | Ambient Vangelis qui installe la transe |
| **Spectacle visuel** | Explosions néon, traînées lumineuses, chaos majestueux | Intensification sonore qui amplifie le spectacle |
| **Découverte narrative** | Terminal rétro immersif, ciel qui évolue | Distorsion musicale à la mort, silence contemplatif |

---

## Technical Specifications

### Performance Requirements

#### Frame Rate Target

- **Cible :** 60fps constant sur mobile Android
- **Priorité :** Frame rate > fidelité visuelle. Si les effets impactent la performance, réduire les particules/glow avant de baisser le framerate.
- **Profiling :** Tests réguliers sur appareils milieu de gamme pour garantir la fluidité

#### Resolution Support

- **Rendering :** Adaptatif — le jeu s'adapte à la résolution native de l'écran
- **Orientation :** Paysage (landscape) uniquement
- **Aspect ratios :** Support des ratios courants (16:9, 18:9, 19.5:9, 20:9) — l'arène s'adapte avec des marges si nécessaire

#### Load Times

- **Objectif :** Le plus rapide possible — démarrage quasi-instantané
- **Avantage :** Pas de textures à charger, pas de modèles 3D, pas d'audio lourd au MVP. Assets 100% code = chargement minimal.
- **Cible réaliste :** <1 seconde pour le premier écran (splash → menu)

### Platform-Specific Details

#### Android Requirements

- **API level minimum :** Compatible avec la version minimum supportée par Flame Engine (à vérifier lors de l'init projet — actuellement Android 5.0 / API 21+)
- **Distribution :** Google Play Store (compte développeur déjà en place)
- **Orientation :** Paysage uniquement
- **Offline :** 100% offline — aucune connexion internet requise
- **In-app purchases :** Non prévu au MVP. Possible en évolution future si succès.
- **Permissions :** Aucune permission spéciale requise (pas de caméra, micro, localisation, etc.)
- **Notifications :** Non prévues

### Asset Requirements

#### Art Assets

**Zéro asset externe** — tout est dessiné en code :

| Catégorie | Approche | Quantité estimée |
|-----------|----------|-----------------|
| **Vaisseau** | Polygone dessiné programmatiquement | 1 base + skins (variations couleur/forme) |
| **Astéroïdes** | Formes procédurales (polygones irréguliers) | Générés à la volée |
| **UFOs** | Formes géométriques codées | 3 types (Éclaireur, Chasseur, Boss) |
| **Projectiles** | Lignes/cercles avec glow | 4-5 types (base + upgrades) |
| **Particules** | Points/lignes avec traînées | Système procédural |
| **UI** | Texte + formes géométriques | Menu, HUD, terminal rétro |
| **Background** | Étoiles procédurales, constellations | Système procédural évolutif |

#### Audio Assets

**Assets gratuits à sourcer post-MVP :**

| Catégorie | Quantité estimée | Source |
|-----------|-----------------|--------|
| **Musique ambient** | 2-3 pistes | OpenGameArt, Freesound, IA |
| **SFX tir** | 3-4 sons (base + upgrades) | Freesound, synthèse |
| **SFX explosion** | 3 sons (petit, moyen, gros) | Freesound, synthèse |
| **SFX dash** | 1 son | Freesound, synthèse |
| **SFX collecte** | 1 son | Freesound, synthèse |
| **SFX UFO** | 2-3 sons | Freesound, synthèse |
| **SFX UI** | 2-3 sons | Freesound, synthèse |

#### External Assets

- **Visuels :** Aucun — 100% programmatique
- **Audio :** Assets gratuits uniquement (CC0, open source, IA générative)
- **Polices :** Police monospace pour le terminal rétro (Google Fonts ou embarquée Flutter)

### Technical Constraints

- **Thermique/Batterie :** Le rendu néon continu (glow, particules, traînées) peut solliciter le GPU mobile. Optimisation nécessaire : limiter les particules, utiliser le culling, profiler régulièrement.
- **Mémoire :** Impact faible — assets procéduraux, pas de textures lourdes en mémoire.
- **Stockage local :** Sauvegarde légère — high scores, fragments débloqués, cosmétiques débloqués, préférences. SharedPreferences ou fichier JSON local.
- **Pas de cloud save** — données locales uniquement, perdues si l'app est désinstallée.

---

## Development Epics

### Epic Overview

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

### Recommended Sequence

```
Epic 1: Fondations
  └→ Epic 2: Core Combat
       ├→ Epic 3: Game Loop
       │    ├→ Epic 5: Ennemis
       │    ├→ Epic 6: Épaves & Upgrades
       │    └→ Epic 7: UI & Menus
       │         └→ Epic 8: Narration & Progression
       └→ Epic 4: Dash Fantomatique
                    └→ Epic 9: Polish Visuel
                         └→ Epic 10: Audio
```

**Rationale :** Fondations → Core Combat → Game Loop forme le vertical slice : un run complet jouable. Ensuite les epics 4-7 enrichissent en parallèle. UI & Menus (epic 7) rend le jeu publiable. Narration et polish viennent en dernier pour enrichir une base solide.

### Vertical Slice

**Le premier milestone jouable (Epic 1-3) :** Un vaisseau qui vole avec les contrôles mobiles, tire sur des astéroïdes qui se divisent en 3 tailles avec des explosions néon, des vagues successives avec scoring et système de vies, un game over avec écran SIGNAL PERDU et relance. C'est déjà un jeu complet et fun.

---

## Success Metrics

### Technical Metrics

#### Key Technical KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Frame rate** | 60fps stable, pas de drops sous 55fps | Profiling Flame/Flutter DevTools sur appareils milieu de gamme |
| **Crash rate** | 0 crash en session normale | Tests manuels intensifs + rapports Play Store |
| **Temps de démarrage** | <1 seconde (splash → menu) | Chronomètre manuel sur plusieurs appareils |
| **Taille APK** | La plus légère possible (estimé <20MB vu le 100% code) | Build size monitoring |
| **Mémoire RAM** | Pas de memory leak, usage stable dans le temps | Flutter DevTools memory profiler |
| **Batterie/thermique** | Pas de surchauffe après 15 min de jeu | Test sur appareils physiques |

### Gameplay Metrics

#### Key Gameplay KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Durée de session** | 2-5 min en moyenne (objectif design) | Playtesting personnel + retours utilisateurs |
| **Envie de relancer** | Le joueur relance au moins 2-3 runs par session | Observation playtesting |
| **Vague moyenne atteinte** | Vague 10-15 pour un joueur moyen après quelques runs | Playtesting |
| **Temps avant maîtrise du dash** | Le joueur utilise le dash naturellement après 3-5 runs | Observation playtesting |
| **Découverte des mécaniques** | Le joueur découvre toutes les mécaniques de base sans tutoriel | Observation premier lancement |

### Qualitative Success Criteria

| Critère | Indicateur de succès |
|---------|---------------------|
| **Note Google Play Store** | 4+ étoiles — la métrique principale de satisfaction |
| **Retours joueurs** | Les reviews mentionnent le fun, le visuel, l'envie de rejouer |
| **Mission pédagogique** | Des jeunes en reconversion consultent et s'inspirent du code |
| **Satisfaction personnelle** | Kevin est fier du résultat — le jeu reflète sa vision |
| **Piliers validés** | Les joueurs décrivent l'expérience avec les mots des piliers (beau, hypnotique, accessible, curieux) |

### Metric Review Cadence

- **Pendant le développement :** Profiling technique à chaque epic terminée
- **Playtesting :** Sessions de test personnel à chaque milestone (fin d'epic 3, 5, 7, 9)
- **Post-lancement :** Suivi des reviews et notes Google Play Store, retours utilisateurs

---

## Out of Scope

### Features hors scope v1.0

- **Multijoueur** — Aucun mode multijoueur (local ou online)
- **Autres plateformes** — Pas de iOS, Desktop ou Web au lancement (Android uniquement)
- **Backend / Serveur** — Aucune infrastructure online, pas de leaderboard en ligne
- **Cloud save** — Pas de synchronisation cloud, données locales uniquement
- **Achats in-app / Monétisation** — Jeu 100% gratuit, aucune microtransaction
- **Localisation** — Pas de traduction en d'autres langues
- **Accessibilité avancée** — Pas de fonctionnalités d'accessibilité dédiées au MVP
- **Musique adaptative complexe** — Pas de layers synchronisés au gameplay en temps réel

### Différé post-lancement

- Système de crédits / achats in-app (si succès significatif)
- Nouveaux types d'astéroïdes spéciaux (magnétiques, explosifs, division multiple)
- Musique adaptative complexe (layers multiples synchronisés)
- Portage sur plateformes secondaires (iOS, Desktop, Web)
- Accessibilité (à explorer selon retours utilisateurs)

---

## Assumptions and Dependencies

### Key Assumptions

- Flutter + Flame Engine reste stable, maintenu et compatible avec les versions récentes d'Android
- Le compte développeur Google Play reste actif et fonctionnel
- Des assets audio gratuits de qualité suffisante existent (CC0, OpenGameArt, Freesound, IA)
- Un seul développeur peut livrer les 10 epics dans un délai raisonnable
- Le rendu vectoriel néon avec effets glow est réalisable à 60fps sur mobile milieu de gamme
- Le gameplay Asteroids classique reste fun et engageant sur mobile tactile

### External Dependencies

| Dépendance | Type | Risque |
|-----------|------|--------|
| **Flutter SDK** | Framework | Faible — largement adopté, activement maintenu par Google |
| **Flame Engine** | Game engine | Moyen — communauté plus petite, mais stable et open source |
| **Google Play Store** | Distribution | Faible — plateforme établie, compte déjà en place |
| **Assets audio gratuits** | Contenu | Moyen — qualité variable, sourcing nécessaire |
| **Police monospace** | Asset | Faible — Google Fonts ou polices embarquées Flutter |

### Risk Factors

- **Performance néon à 60fps** — Le rendu glow/particules sur GPU mobile peut nécessiter des optimisations significatives. Mitigation : approche incrémentale, profiling régulier.
- **Flame Engine limitations** — Fonctionnalités spécifiques (shaders, effets avancés) peuvent ne pas être supportées nativement. Mitigation : solutions alternatives ou custom rendering.
- **Motivation solo dev** — Risque d'abandon sur un projet long. Mitigation : mission pédagogique claire, epics qui délivrent de la valeur jouable à chaque étape.

---

## Document Information

**Document :** Neon Asteroids - Game Design Document
**Version :** 1.0
**Created :** 2026-03-02
**Author :** Kevin
**Status :** Complete

### Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-03-02 | Initial GDD complete |
