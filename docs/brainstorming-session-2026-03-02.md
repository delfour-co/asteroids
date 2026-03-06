---
title: 'Game Brainstorming Session'
date: '2026-03-02'
author: 'Kevin'
version: '1.0'
stepsCompleted: [1, 2, 3, 4]
status: 'complete'
---

# Game Brainstorming Session

## Session Info

- **Date:** 2026-03-02
- **Facilitator:** Game Designer Agent
- **Participant:** Kevin

---

## Brainstorming Approach

**Selected Mode:** Freeform

**Techniques Used:** Player Fantasy Mining, Core Loop Brainstorming, Verbs Before Nouns, Genre Mashup, Failure State Design, Emergence Engineering, Reward Schedule Architecture, Emotion Targeting, Game Feel Playground, Constraint-Based Creativity, Progression Curve Sculpting, Meta-Game Layer Design

---

## Concept: Neon Asteroids

**Pitch:** Un remake moderne d'Asteroids en esthétique néon cyberpunk. Le dernier survivant de la Terre se réveille d'un cryo-sommeil dans un espace stellaire magnifique et dangereux. Sessions arcade hypnotiques avec narration fragmentée qui se révèle au fil des runs.

**Genre Mashup:** Arcade classique + Roguelite léger + Narration fragmentée + Contemplation spatiale

**Tech:** Flutter + Flame Engine | Mobile (iOS, Android) + Desktop

---

## Player Fantasy

- **Qui :** Le dernier survivant pilote spatial de la Terre, réveillé d'un cryo-sommeil
- **Où :** Un espace stellaire vivant avec un ciel qui évolue (constellations, étoiles filantes, voie lactée)
- **Feeling :** Flow hypnotique entre contemplation et intensité arcade
- **Musique :** Ambient électronique

---

## Core Loop

**Verbes principaux :**
- **Core :** Tourner, Accélérer, Tirer, Esquiver
- **Exploration :** Scanner, Collecter, Décoder
- **Survie :** Réparer, Recharger, Améliorer
- **Mouvement :** Dasher (offensif — traverser les astéroïdes), Freiner, Warper

**Structure :** Vagues infinies avec difficulté croissante, fragments de mémoire débloqués tous les 10 vagues

**Modes de jeu :** Sessions courtes (2-5 min) arcade + Sessions longues (10-15 min) immersives

---

## Systèmes de jeu

### Astéroïdes
- Formes uniques générées procéduralement
- Variété de comportements (magnétiques, explosifs, division multiple)
- Certains contiennent des épaves de vaisseaux humains

### Épaves (système risque/récompense)
- Apparaissent dans les débris d'astéroïdes détruits
- Dérivent et disparaissent si non récupérées à temps
- Contiennent : upgrades temporaires OU fragments d'histoire
- Choix micro-décisionnel : risquer sa vie pour récupérer ou survivre
- Collecte automatique au passage (voler dessus)

### Upgrades temporaires (run only)
- **Armes :** Tir triple, laser, missiles
- **Défensif :** Bouclier temporaire, extra vie
- **Mouvement :** Vitesse, dash infini temporaire

### UFOs
- Liés à l'histoire narrative
- Différents types selon la progression narrative
- Intelligence et patterns de mouvement variés
- Apparaissent à partir de la vague 5-10 comme événement surprise
- Boss UFO tous les X vagues

### Système de score
- Gros astéroïde : 20 pts | Moyen : 50 pts | Petit : 100 pts | UFO : 500 pts
- Vie supplémentaire tous les 10,000 points

---

## Progression & Narration

- **Pendant le run :** Upgrades temporaires, score
- **Entre les runs :** Seuls les fragments d'histoire persistent (permanent)
- **Narration :** Mode histoire léger révélé par fragments tous les 10 vagues
- **Motivation "one more run" :** Voir la prochaine vague / prochain type d'ennemi / prochain fragment

### Courbe de difficulté
- **Vagues 1-5 :** Démarrage direct dans l'action, astéroïdes lents, apprentissage organique (pas de tutoriel)
- **Vagues 5-10 :** Introduction des premiers UFOs comme événement surprise
- **Vagues 10+ :** Mix progressif — plus d'astéroïdes, plus rapides, nouveaux types, UFOs plus agressifs
- **Tous les X vagues :** Boss UFO
- **Rythme :** Court moment de calme entre les vagues pour souffler

---

## Game Feel

### Destruction d'astéroïde
- Fragments qui volent avec des traînées lumineuses comme des feux d'artifice
- Son différent selon la taille (petit = aigu, gros = grave profond)
- Les débris repoussent les autres astéroïdes proches (réactions en chaîne possibles)
- Effets de couleur différents selon le type d'astéroïde
- Destructions "parfaites" avec bonus visuel quand le joueur est précis

### Tir
- Trait fin et rapide style laser néon
- Tir rapide en continu tant que le joueur appuie
- Petit flash lumineux à la sortie du canon

### Dash (move signature)
- Bouton dédié sur l'écran (pouce droit, au-dessus du tir)
- Vaisseau translucide/fantomatique pendant la traversée
- Traînée néon longue derrière le vaisseau (effet comète)
- L'astéroïde traversé explose de manière spectaculaire (plus beau qu'un tir normal)
- Jauge d'énergie qui se recharge pour le cooldown

---

## Séquence de mort

1. La musique ambient se distord
2. Ralenti bullet-time dramatique avant l'impact
3. Explosion néon du vaisseau
4. Écran "SIGNAL PERDU" style terminal rétro
5. Relance

---

## Arc émotionnel

| Moment | Émotion |
|--------|---------|
| Réveil du cryo | Solitude, mystère |
| Premières vagues | Confiance, apprentissage |
| Montée en difficulté | Tension, concentration |
| Épave qui apparaît | Excitation, dilemme |
| Dash offensif | Puissance, adrénaline |
| Fragment de mémoire | Curiosité, récompense émotionnelle |
| Ciel qui évolue | Émerveillement |
| Musique qui distord | Panique |
| Bullet-time de mort | Cinématique, regret |
| "Signal Perdu" | Mélancolie, détermination |

**Ton global :** Contemplatif au début → Intense quand ça monte

---

## Style visuel & audio

- **Palette :** Cyan, magenta, jaune avec effets glow
- **Géométrie :** Formes vectorielles Line2D avec antialiasing
- **Effets :** Particules, explosions, trails lumineux (traînée néon du dash)
- **Background :** Ciel stellaire vivant qui évolue — plus on avance, plus c'est beau/spectaculaire
- **Audio :** Ambient électronique, réactive à l'intensité du gameplay

---

## Contrôles (Mobile)

- **Main gauche :** Stick de direction
- **Main droite :** Propulsion (bas) + Tir (milieu) + Dash (haut)
- **Automatique :** Collecte d'épaves au passage
- **Warp :** Mécanique séparée du dash (upgrade ou feature future)

---

## Méta-jeu & Rétention

### Menu principal
- Menu minimaliste néon avec le vaisseau qui flotte

### Journal de bord
- Log accessible depuis le menu pour consulter les fragments d'histoire débloqués

### Déblocages
- Skins de vaisseau (couleurs néon différentes)
- Effets de traînée / explosion différents
- Backgrounds stellaires alternatifs
- Musiques / ambiances sonores

### Scores
- Leaderboard local simple
- Meilleur vague atteinte + meilleur score

---

## Domaines à explorer (sessions futures)

- Monétisation (free-to-play ? payant ? pubs ?)
- Audio design détaillé (musique adaptative)
- Accessibilité
- Contenu narratif concret (que racontent les fragments ?)
- Multijoueur éventuel
- Types d'astéroïdes spécifiques et leurs comportements
- Types d'UFOs spécifiques et leurs patterns

---

## Session Complete

**Date:** 2026-03-02
**Participant:** Kevin

### Output

This brainstorming session generated:

- 1 fully developed game concept (Neon Asteroids)
- 12 game design domains explored
- 7 domains identified for future exploration

### Document Status

Status: Complete
Steps Completed: [1, 2, 3, 4]
