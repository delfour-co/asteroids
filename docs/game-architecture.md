---
title: 'Game Architecture'
project: 'mobilegame--asteroids'
date: '2026-03-03'
author: 'Kevin'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'
engine: 'Flutter + Flame Engine v1.35.1'
platform: 'Android (Google Play Store)'

# Source Documents
gdd: '_bmad-output/gdd.md'
epics: '_bmad-output/epics.md'
brief: '_bmad-output/game-brief.md'
---

# Game Architecture — Asteroids Neon

## Executive Summary

**Asteroids Neon** architecture is designed for **Flutter + Flame Engine v1.35.1** (Dart) targeting **Android** (Google Play Store).

**Key Architectural Decisions:**

- **Rendu Glow** — MaskFilter.blur + double draw pour les effets néon sur GPU mobile
- **State Management** — RouterComponent (navigation écrans) + State Machine (gameplay)
- **Communication** — Event Bus exclusif avec événements typés synchrones
- **Structure** — Layers hiérarchiques (Background → Game → Effects → UI)
- **Dash Fantomatique** — Sensor Mode Collision natif Flame
- **Persistance** — JSON local (`save_data.json`)
- **Performance** — Object pooling via Factory+Pool par type d'entité

**Project Structure:** By Feature avec 17 dossiers couvrant 14 systèmes.

**Implementation Patterns:** 9 patterns définis assurant la cohérence des agents IA.

**Error Reporting:** Firebase Crashlytics (fail-silent) avec message in-universe pour les crashs critiques.

**Ready for:** Sprint planning et implémentation des epics.

---

## Project Context

### Game Overview

**Asteroids Neon** — Shooter arcade néon qui réinvente le classique Asteroids dans un univers stellaire contemplatif. Infinite run par vagues avec narration fragmentée et dash fantomatique signature.

### Technical Scope

**Platform:** Android (Google Play Store)
**Genre:** Shooter (arcade)
**Engine:** Flutter + Flame Engine / Dart
**Project Level:** Moyenne-haute complexité

### Core Systems

| Système | Complexité | Epic(s) | Description |
|---------|-----------|---------|-------------|
| **Rendu vectoriel néon** | Haute | 1, 9 | Formes programmatiques, glow, traînées, particules, explosions |
| **Physique spatiale** | Moyenne | 1 | Inertie, rotation, accélération, wrap-around écran |
| **Système de collisions** | Moyenne | 2 | Projectile/astéroïde, vaisseau/astéroïde, vaisseau/UFO, collecte épaves |
| **Dash fantomatique** | Haute | 4 | Translucidité, traversée sans collision, destruction amplifiée, traînée comète, jauge énergie |
| **Système de vagues** | Moyenne | 3, 5 | Spawn progressif, difficulté croissante, moment de calme, événements |
| **IA ennemis (UFOs)** | Moyenne | 5 | 3 types (Éclaireur, Chasseur, Boss), patterns de mouvement, tirs |
| **Épaves & Upgrades** | Moyenne | 6 | Spawn, dérive, disparition, collecte auto, 7 types d'upgrades temporaires |
| **Génération procédurale** | Moyenne | 2, 9 | Astéroïdes (formes irrégulières), ciel stellaire évolutif |
| **Contrôles tactiles** | Moyenne | 1 | Stick virtuel, 3 boutons (propulsion, tir, dash), zones de touch |
| **Sauvegarde locale** | Basse | 7 | High scores, fragments narratifs, déblocables, préférences |
| **UI/Menus** | Basse | 7, 8 | Menu néon, HUD, terminal rétro, journal, leaderboard |
| **Audio** | Basse | 10 | Musique ambient, SFX, intégration réactive (post-MVP) |

### Technical Requirements

- **Frame rate :** 60fps constant sur Android milieu de gamme
- **Rendu :** 100% programmatique (zéro asset externe visuel)
- **Résolution :** Adaptatif, paysage uniquement, multi aspect-ratio
- **Démarrage :** <1 seconde (splash → menu)
- **Réseau :** Aucun — 100% offline
- **Stockage :** Local uniquement (SharedPreferences ou JSON)
- **Taille APK :** Minimale (estimé <20MB)

### Complexity Drivers

**Haute complexité :**
- Rendu glow/néon à 60fps sur GPU mobile — effets de halo lumineux continus, particules, traînées
- Dash fantomatique — mécanique unique nécessitant un pattern custom (traversée au lieu de collision)

**Complexité moyenne :**
- Génération procédurale d'astéroïdes aux formes uniques
- Ciel stellaire évolutif (background qui change avec la progression)
- Gestion de nombreux objets simultanés (astéroïdes + débris + particules + projectiles + UFOs)

### Technical Risks

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|------------|------------|
| Performance glow/particules à 60fps | Élevé | Moyenne | Approche incrémentale, profiling GPU régulier, budget particules |
| Limitations Flame Engine (shaders, blend modes) | Moyen | Moyenne | Évaluer les capacités de rendu de Flame, solutions custom si nécessaire |
| Nombreux objets à l'écran simultanément | Moyen | Moyenne | Object pooling, culling, optimisation des collisions |
| Thermique/batterie sur sessions longues | Moyen | Faible | Profiling thermique, optimisation du render loop |

---

## Engine & Framework

### Selected Engine

**Flutter + Flame Engine** v1.35.1 (Dart)

**Rationale :**
- Framework open source, gratuit, activement maintenu (dernière mise à jour février 2026)
- Export Android natif via Flutter build system
- Système de composants (FCS) adapté aux jeux 2D arcade
- Rendu Canvas programmatique — parfait pour le 100% vectoriel néon
- Communauté active (Flame Game Jam 2026 en cours)
- Code Dart lisible et pédagogique — aligné avec la mission du projet

### Project Initialization

```bash
flutter create --org com.delfour asteroids_neon
cd asteroids_neon
flutter pub add flame
flutter pub add flame_audio
```

**Approche : Partir de zéro** — Pas de starter template. Chaque ligne de code est intentionnelle et compréhensible pour les jeunes en reconversion professionnelle.

### Engine-Provided Architecture

| Composant | Solution fournie | Package | Notes |
|-----------|-----------------|---------|-------|
| **Game Loop** | FlameGame (60fps) | flame | Boucle update/render intégrée |
| **Composants** | Flame Component System (FCS) | flame | Entity-component pour organiser les objets |
| **Rendu 2D** | Canvas API via Flutter | flame | Dessin programmatique de formes |
| **Collisions** | Collision detection | flame | Hitboxes, overlap detection |
| **Input tactile** | Gesture handling | flame | Tap, drag, joystick support natif |
| **Particules** | Particle system | flame | Émetteurs, comportements configurables |
| **Audio** | Audio playback | flame_audio | Musique et SFX (post-MVP) |
| **Build/Deploy** | Flutter build system | flutter | `flutter build apk` pour Android |

### Remaining Architectural Decisions

Les décisions suivantes doivent être prises explicitement :

1. **Rendu glow/néon** — Comment implémenter les effets de halo lumineux (BlendMode, shaders custom, multi-pass rendering)
2. **Game state management** — State machine pour les états du jeu (menu, playing, paused, game over)
3. **Système de vagues** — Pattern pour le spawn progressif et la difficulté croissante
4. **Dash fantomatique** — Pattern pour la traversée sans collision avec destruction au passage
5. **Object pooling** — Recyclage des projectiles, particules, débris pour la performance
6. **Sauvegarde locale** — SharedPreferences vs fichier JSON pour la persistance
7. **Structure du projet** — Organisation des dossiers et séparation des responsabilités
8. **Patterns d'implémentation** — Conventions de code pour la consistance des agents IA

### AI Tooling (MCP Servers)

| MCP | Repo | Usage |
|-----|------|-------|
| **Flame MCP Server** | [salihgueler/flame_mcp_server](https://github.com/salihgueler/flame_mcp_server) | Documentation Flame à jour, tutoriels, recherche dans la doc |
| **Context7** | [upstash/context7](https://github.com/upstash/context7) | Documentation Flutter/Dart à jour, lookup API en temps réel |

---

## Architectural Decisions

### Decision 1: Neon Glow Rendering

| | |
|---|---|
| **Decision** | MaskFilter.blur + Double Draw |
| **Options Considered** | Custom shaders, Multi-pass rendering, MaskFilter.blur |
| **Rationale** | Compatible avec l'API Canvas de Flame, performant sur GPU mobile, ne nécessite pas de shaders custom (risque de compatibilité). Le principe : dessiner chaque forme deux fois — une fois en flou large (halo) puis une fois nette par-dessus. |
| **Trade-offs** | Double draw = double drawcalls, mais les formes vectorielles simples restent légères. Budget GPU à surveiller avec beaucoup d'objets. |
| **Affected Systems** | Rendu vectoriel néon, Particules, Effets visuels, Performance |

```dart
// Principe de rendu glow
final glowPaint = Paint()
  ..color = neonColor.withOpacity(0.6)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
final solidPaint = Paint()..color = neonColor;

canvas.drawPath(shape, glowPaint);  // Halo
canvas.drawPath(shape, solidPaint); // Forme nette
```

### Decision 2: Game State Management

| | |
|---|---|
| **Decision** | Hybrid — RouterComponent + State Machine |
| **Options Considered** | Pure state machine, RouterComponent only, Hybrid |
| **Rationale** | RouterComponent gère la navigation entre écrans (menu, game, pause, game over). Une state machine légère gère les sous-états du gameplay (spawning, playing, wave_complete, boss_incoming). Séparation claire des responsabilités. |
| **Trade-offs** | Deux systèmes à maintenir, mais chacun reste simple. RouterComponent est natif Flame. |
| **Affected Systems** | Navigation, Game Loop, UI, Pause, Game Over |

### Decision 3: Component Structure

| | |
|---|---|
| **Decision** | Hierarchical Layers |
| **Options Considered** | Flat structure, Hierarchical layers, ECS custom |
| **Rationale** | Organisation en couches visuelles et logiques. Chaque layer gère ses propres composants. Permet le z-ordering naturel et l'isolation des systèmes. |
| **Trade-offs** | Moins flexible qu'un ECS pur, mais plus lisible et pédagogique — aligné avec la mission du projet. |
| **Affected Systems** | Tous les systèmes de jeu |

```
FlameGame (AsteroidsNeonGame)
├── BackgroundLayer    — Ciel stellaire, étoiles
├── GameLayer          — Vaisseau, astéroïdes, projectiles, UFOs, épaves
│   ├── Ship
│   ├── AsteroidManager
│   ├── ProjectileManager
│   ├── UFOManager
│   └── WreckageManager
├── EffectsLayer       — Particules, traînées, explosions
└── UILayer            — HUD, score, vies, jauge énergie
```

### Decision 4: Save System

| | |
|---|---|
| **Decision** | Local JSON File |
| **Options Considered** | SharedPreferences, JSON file, SQLite |
| **Rationale** | Plus flexible que SharedPreferences pour des données structurées (fragments narratifs, déblocages). Plus simple que SQLite pour un jeu offline sans requêtes complexes. Un seul fichier `save_data.json`. |
| **Trade-offs** | Lecture/écriture fichier entier à chaque sauvegarde, mais les données restent petites (<100KB). |
| **Affected Systems** | High scores, Fragments narratifs, Déblocages, Préférences |

### Decision 5: Wave System

| | |
|---|---|
| **Decision** | Hybrid — Procedural Scaling + Data Tables |
| **Options Considered** | Pure procedural, Pure data-driven, Hybrid |
| **Rationale** | Les data tables définissent les événements spéciaux (apparition UFOs, types d'astéroïdes par vague, moments de calme). Le scaling procédural gère la difficulté croissante (nombre, vitesse, taille). Équilibre entre contrôle créatif et scalabilité infinie. |
| **Trade-offs** | Tables à maintenir manuellement pour les événements, mais le scaling automatique évite de définir chaque vague individuellement. |
| **Affected Systems** | Spawn, Difficulté, Ennemis, Game Loop |

### Decision 6: Ghost Dash Pattern

| | |
|---|---|
| **Decision** | Sensor Mode Collision |
| **Options Considered** | Disable collision, Layer switching, Sensor mode |
| **Rationale** | En mode dash, le vaisseau passe en mode "sensor" : il détecte les overlaps (pour déclencher la destruction amplifiée) sans subir de dégâts. Le composant collision reste actif mais change de comportement. Pattern propre et natif Flame. |
| **Trade-offs** | Nécessite une gestion soignée des transitions (activation/désactivation du mode sensor synchronisée avec l'animation). |
| **Affected Systems** | Dash fantomatique, Collisions, Effets visuels, Énergie |

```dart
// Principe du dash sensor
class Ship extends PositionComponent with CollisionCallbacks {
  bool isDashing = false;

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (isDashing) {
      // Sensor mode: detect but don't take damage
      if (other is Asteroid) other.destroy(amplified: true);
    } else {
      // Normal mode: take damage
      takeDamage();
    }
  }
}
```

### Decision 7: Object Pooling

| | |
|---|---|
| **Decision** | Simple Pool per Type |
| **Options Considered** | No pooling, Simple pools, Generic pool system |
| **Rationale** | Un pool dédié par type d'objet fréquent (projectiles, particules, débris). Réutilisation des instances au lieu de create/destroy. Simple à implémenter, efficace pour réduire le GC pressure. |
| **Trade-offs** | Code pool à écrire pour chaque type, mais reste simple (~30 lignes par pool). Pas de pool générique over-engineered. |
| **Affected Systems** | Projectiles, Particules, Débris, Performance |

### Decision Summary

| # | Décision | Choix | Risque |
|---|----------|-------|--------|
| 1 | Rendu Glow | MaskFilter.blur + double draw | Moyen — surveiller budget GPU |
| 2 | Game State | RouterComponent + State Machine | Faible |
| 3 | Structure | Layers hiérarchiques | Faible |
| 4 | Sauvegarde | JSON local | Faible |
| 5 | Vagues | Hybride procédural + data tables | Faible |
| 6 | Dash | Sensor mode collision | Moyen — transitions à soigner |
| 7 | Object Pooling | Pool simple par type | Faible |

---

## Cross-cutting Concerns

Ces patterns s'appliquent à **TOUS** les systèmes et doivent être suivis par chaque implémentation.

### Error Handling

**Stratégie :** Fail-silent + Firebase Crashlytics

**Niveaux d'erreur :**

| Niveau | Comportement | Visible joueur |
|--------|-------------|----------------|
| **Récupérable** | Silencieuse, loguée sur Crashlytics, le jeu continue | Non |
| **Runtime critique** | Le jeu ne peut pas continuer, message in-universe, retour au menu | Oui — thématique |

**Message crash joueur :**
> "Défaillance critique du vaisseau... la tour de contrôle a été informée."

**Exemple :**

```dart
try {
  waveManager.spawnWave(waveNumber);
} catch (e, stack) {
  // Erreur récupérable — silencieuse
  FirebaseCrashlytics.instance.recordError(e, stack);
}

// Erreur critique — message in-universe + retour menu
void onCriticalError(Object error, StackTrace stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  game.router.pushRoute(CrashScreen(
    message: 'Défaillance critique du vaisseau...\nLa tour de contrôle a été informée.',
  ));
}
```

### Logging

**Format :** Natif Dart/Flutter
**Destination :** Console (dev) + Firebase Crashlytics (production)
**Niveaux actifs :** ERROR et WARN uniquement

| Niveau | Usage | Destination |
|--------|-------|-------------|
| **ERROR** | Quelque chose a cassé | Console + Crashlytics |
| **WARN** | Inattendu mais géré | Console + Crashlytics |

**Exemption performance :** Les chemins critiques (render loop, collisions) sont exemptés de logging sauf boucles détectées.

```dart
import 'dart:developer' as dev;

void logError(String system, String message, [Object? error]) {
  dev.log('[$system] ERROR: $message', error: error);
  FirebaseCrashlytics.instance.log('[$system] $message');
}

void logWarn(String system, String message) {
  dev.log('[$system] WARN: $message');
  FirebaseCrashlytics.instance.log('[$system] $message');
}
```

### Configuration

**Approche :** Classe(s) Dart centralisée(s) avec constantes statiques

```dart
abstract class GameConfig {
  // Vaisseau
  static const double shipMaxSpeed = 300.0;
  static const int startingLives = 3;
  static const int extraLifeScore = 10000;

  // Dash
  static const double dashDuration = 0.5;
  static const double dashCooldown = 3.0;

  // Scoring
  static const int largeAsteroidPoints = 20;
  static const int mediumAsteroidPoints = 50;
  static const int smallAsteroidPoints = 100;
  static const int ufoPoints = 500;

  // Upgrades
  static const double upgradeDuration = 12.0;
  static const double wreckageLifetime = 8.0;
}
```

**Préférences joueur :** `save_data.json` (décision 4)
**Paramètres plateforme :** Détectés au runtime

### Event System

**Pattern :** Event Bus central avec événements typés

**Règles :**
- Chaque événement est une classe Dart dédiée
- Traitement synchrone (même frame)
- Les systèmes communiquent **uniquement** via le bus — aucune référence directe
- Historique des événements en mode dev uniquement

```dart
// Événement typé
class AsteroidDestroyedEvent {
  final Vector2 position;
  final AsteroidSize size;
  final bool byDash;
  AsteroidDestroyedEvent(this.position, this.size, this.byDash);
}

// Event Bus
class EventBus {
  final _listeners = <Type, List<Function>>{};

  void on<T>(void Function(T event) listener) {
    _listeners.putIfAbsent(T, () => []).add(listener);
  }

  void emit<T>(T event) {
    for (final listener in _listeners[T] ?? []) {
      (listener as void Function(T))(event);
    }
  }
}

// Usage
eventBus.on<AsteroidDestroyedEvent>((e) {
  score += pointsFor(e.size);
});
```

### Debug Tools

**Outils disponibles :**

| Outil | Description |
|-------|-------------|
| Overlay collisions | Hitboxes visibles de tous les objets |
| Overlay performance | FPS, nombre d'objets actifs, drawcalls |
| Invincibilité | Mode God — le vaisseau ne prend pas de dégâts |
| Skip de vague | Sauter directement à la vague X |
| Spawn manuel | Faire apparaître un ennemi ou upgrade spécifique |
| Event log | Flux temps réel des événements du bus |
| Slow motion | Ralentir le jeu (0.25x, 0.5x) |

**Activation :** Flag de compilation (`kDebugMode`)
**Production :** Strictement retirés via tree-shaking — aucun code debug en release build

---

## Project Structure

### Organization Pattern

**Pattern :** By Feature

**Rationale :** Chaque système du jeu est regroupé dans son propre dossier. Un développeur (ou un agent IA) ouvre le dossier correspondant et trouve tout ce qui concerne ce système. Aligné avec la mission pédagogique — lisibilité maximale pour les jeunes en reconversion.

### Directory Structure

```
asteroids_neon/
├── lib/                                # Code source du jeu
│   ├── main.dart                       # Point d'entrée
│   ├── app.dart                        # Configuration FlameGame (AsteroidsNeonGame)
│   │
│   ├── core/                           # Systèmes centraux partagés
│   │   ├── event_bus.dart              # Event Bus central
│   │   ├── game_config.dart            # Constantes et balancing
│   │   ├── game_state.dart             # State machine (spawning, playing, wave_complete...)
│   │   ├── save_manager.dart           # Lecture/écriture save_data.json
│   │   └── logger.dart                 # Fonctions logError / logWarn
│   │
│   ├── ship/                           # Vaisseau du joueur
│   │   ├── ship.dart                   # Composant principal
│   │   ├── ship_controller.dart        # Gestion des inputs
│   │   └── dash.dart                   # Mécanique dash fantomatique + jauge
│   │
│   ├── asteroids/                      # Astéroïdes
│   │   ├── asteroid.dart               # Composant astéroïde
│   │   ├── asteroid_manager.dart       # Spawn, pool, gestion du cycle de vie
│   │   └── asteroid_generator.dart     # Génération procédurale des formes
│   │
│   ├── projectiles/                    # Projectiles (joueur + ennemis)
│   │   ├── projectile.dart             # Composant projectile de base
│   │   ├── projectile_manager.dart     # Pool et gestion
│   │   └── weapon_upgrades.dart        # Tir triple, laser, missiles
│   │
│   ├── enemies/                        # UFOs
│   │   ├── ufo.dart                    # Composant UFO de base
│   │   ├── ufo_scout.dart              # Éclaireur
│   │   ├── ufo_hunter.dart             # Chasseur
│   │   ├── ufo_boss.dart               # Boss Vaisseau-mère
│   │   └── ufo_manager.dart            # Spawn et gestion
│   │
│   ├── waves/                          # Système de vagues
│   │   ├── wave_manager.dart           # Orchestration des vagues
│   │   ├── wave_data.dart              # Data tables (événements spéciaux)
│   │   └── difficulty_scaler.dart      # Scaling procédural
│   │
│   ├── wreckage/                       # Épaves et upgrades
│   │   ├── wreckage.dart               # Composant épave
│   │   ├── wreckage_manager.dart       # Spawn, dérive, disparition
│   │   └── upgrade.dart                # Types d'upgrades temporaires
│   │
│   ├── effects/                        # Effets visuels
│   │   ├── neon_renderer.dart          # Rendu glow (MaskFilter.blur + double draw)
│   │   ├── explosion.dart              # Explosions néon
│   │   ├── trail.dart                  # Traînées lumineuses
│   │   └── particle_pool.dart          # Pool de particules
│   │
│   ├── background/                     # Ciel stellaire
│   │   ├── starfield.dart              # Étoiles, constellations
│   │   └── background_layer.dart       # Layer évolutif
│   │
│   ├── ui/                             # Interface utilisateur
│   │   ├── hud.dart                    # Score, vies, vague, jauge dash
│   │   ├── main_menu.dart              # Menu principal
│   │   ├── game_over_screen.dart       # Écran SIGNAL PERDU
│   │   ├── crash_screen.dart           # Écran défaillance critique (error handler)
│   │   ├── controls_screen.dart        # Explication des contrôles
│   │   ├── leaderboard_screen.dart     # Top scores locaux
│   │   ├── journal_screen.dart         # Fragments de mémoire
│   │   └── cosmetics_screen.dart       # Sélection déblocables
│   │
│   ├── narrative/                      # Narration
│   │   ├── memory_fragment.dart        # Modèle de fragment
│   │   ├── narrative_manager.dart      # Déblocage et progression
│   │   └── terminal_display.dart       # Affichage terminal rétro
│   │
│   ├── progression/                    # Méta-progression
│   │   ├── milestone_manager.dart      # Déblocages par vagues atteintes
│   │   └── cosmetic.dart               # Modèle cosmétique (skins, traînées...)
│   │
│   ├── audio/                          # Audio (post-MVP)
│   │   ├── audio_manager.dart          # Lecture musique et SFX
│   │   └── reactive_music.dart         # Intensification selon difficulté
│   │
│   ├── input/                          # Contrôles tactiles
│   │   ├── joystick.dart               # Stick directionnel virtuel
│   │   └── action_buttons.dart         # Boutons propulsion, tir, dash
│   │
│   └── debug/                          # Outils debug (retirés en release)
│       ├── debug_overlay.dart          # Collisions, performance, event log
│       ├── debug_commands.dart         # Invincibilité, skip vague, spawn manuel
│       └── slow_motion.dart            # Ralenti
│
├── assets/                             # Assets non-code
│   ├── audio/
│   │   ├── music/                      # Pistes ambient électronique
│   │   └── sfx/                        # Effets sonores
│   ├── data/
│   │   └── wave_events.json            # Data tables des événements de vagues
│   └── fonts/
│       └── retro_mono.ttf              # Police monospace pour le terminal rétro
│
├── test/                               # Tests
├── docs/                               # Documentation
├── android/                            # Config Android (généré par Flutter)
├── pubspec.yaml                        # Dépendances Dart/Flutter
└── README.md
```

### System Location Mapping

| Système | Location | Responsabilité |
|---------|----------|----------------|
| Rendu vectoriel néon | `lib/effects/neon_renderer.dart` | Glow MaskFilter.blur + double draw pour tous les composants |
| Physique spatiale | `lib/ship/ship.dart` | Inertie, rotation, accélération |
| Collisions | Chaque composant (mixins Flame) | Hitboxes via CollisionCallbacks natif Flame |
| Dash fantomatique | `lib/ship/dash.dart` | Sensor mode, traversée, jauge énergie |
| Système de vagues | `lib/waves/` | Orchestration, scaling, data tables |
| IA ennemis | `lib/enemies/` | 3 types UFO, patterns, tirs |
| Épaves & Upgrades | `lib/wreckage/` | Spawn, dérive, collecte, upgrades temporaires |
| Génération procédurale | `lib/asteroids/asteroid_generator.dart` | Formes irrégulières procédurales |
| Contrôles tactiles | `lib/input/` | Joystick + boutons action |
| Sauvegarde locale | `lib/core/save_manager.dart` | JSON file read/write |
| UI/Menus | `lib/ui/` | Tous les écrans |
| Narration | `lib/narrative/` | Fragments, terminal, journal |
| Progression | `lib/progression/` | Milestones, cosmétiques |
| Audio | `lib/audio/` | Musique, SFX, réactivité |
| Event Bus | `lib/core/event_bus.dart` | Communication inter-systèmes |
| Configuration | `lib/core/game_config.dart` | Constantes et balancing |
| Debug | `lib/debug/` | Overlays, commandes, slow motion |

### Naming Conventions

#### Files

| Type | Convention | Exemple |
|------|-----------|---------|
| Fichiers Dart | `snake_case.dart` | `asteroid_manager.dart` |
| Assets audio | `snake_case.ext` | `laser_fire.ogg`, `ambient_01.ogg` |
| Données | `snake_case.json` | `wave_events.json` |

#### Code Elements

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Classes | `PascalCase` | `AsteroidManager`, `UfoScout` |
| Fonctions/Méthodes | `camelCase` | `spawnWave()`, `takeDamage()` |
| Variables | `camelCase` | `currentWave`, `dashEnergy` |
| Constantes | `camelCase` statiques | `GameConfig.dashCooldown` |
| Privés | `_camelCase` | `_isInvincible`, `_spawnTimer` |
| Événements | `PascalCase` + `Event` | `AsteroidDestroyedEvent`, `WaveCompletedEvent` |
| Enums | `PascalCase` / `camelCase` values | `AsteroidSize.large`, `GameState.playing` |

#### Game Assets

| Type | Convention | Exemple |
|------|-----------|---------|
| Musique | `snake_case` descriptif | `ambient_contemplative.ogg` |
| SFX | `action_snake_case` | `laser_fire.ogg`, `explosion_large.ogg` |
| Polices | `snake_case` | `retro_mono.ttf` |

### Architectural Boundaries

1. **Un fichier = une responsabilité** — Pas de fichier fourre-tout
2. **Les features ne s'importent pas entre elles directement** — Communication via Event Bus uniquement
3. **`core/` est importable par tous** — C'est le seul dossier à dépendance transversale
4. **`debug/` est conditionnel** — Tout le contenu est derrière `kDebugMode`
5. **Pas d'import circulaire** — Si A importe B, B ne peut pas importer A

---

## Implementation Patterns

Ces patterns assurent une implémentation cohérente par tous les agents IA.

### Communication Pattern

**Pattern :** Event Bus exclusif — toute communication passe par le bus, y compris au sein d'une même feature.

**Règle :** Aucun composant n'a de référence directe vers un autre composant. Seul `core/` est importable par tous.

```dart
// INTERDIT — référence directe
class Ship {
  final Dash dash; // NON
  void onTap() => dash.activate();
}

// CORRECT — via Event Bus
class Ship {
  void onTap() => eventBus.emit(DashRequestedEvent());
}

class Dash {
  Dash() {
    eventBus.on<DashRequestedEvent>((_) => activate());
  }
}
```

### Entity Creation Pattern

**Pattern :** Factory + Pool — chaque type d'entité a une factory qui encapsule le pool.

**Règle :** Les managers ne connaissent pas les pools. Ils appellent la factory, qui gère le recyclage en interne.

```dart
class ProjectileFactory {
  final _pool = ObjectPool<Projectile>(() => Projectile(), size: 50);

  Projectile createLaser(Vector2 position, Vector2 direction) {
    final p = _pool.acquire();
    p.init(position: position, direction: direction, type: ProjectileType.laser);
    return p;
  }

  void recycle(Projectile p) => _pool.release(p);
}

// Usage dans le manager
final projectile = projectileFactory.createLaser(ship.position, ship.direction);
gameLayer.add(projectile);
```

### State Transition Pattern

**Pattern :** Mix — Enum + switch par défaut, State Machine formelle pour les IA complexes.

| Entité | Pattern | Raison |
|--------|---------|--------|
| Ship | Enum + switch | 4 états simples (normal, dashing, invincible, dead) |
| Wreckage | Enum + switch | 3 états simples (drifting, collected, expired) |
| UFO Scout | Enum + switch | 4 états linéaires (entering, moving, shooting, exiting) |
| UFO Hunter | Enum + switch | 3 états simples (pursuing, dodging, shooting) |
| UFO Boss | State Machine | États complexes avec transitions multiples et patterns d'attaque |

```dart
// Enum + switch (entités simples)
enum ShipState { normal, dashing, invincible, dead }

class Ship extends PositionComponent {
  ShipState state = ShipState.normal;

  @override
  void update(double dt) {
    switch (state) {
      case ShipState.normal:
        handleMovement(dt);
      case ShipState.dashing:
        handleDash(dt);
      case ShipState.invincible:
        handleInvincibility(dt);
      case ShipState.dead:
        break;
    }
  }
}

// State Machine (IA complexe — UFO Boss)
abstract class BossState {
  void onEnter(UfoBoss boss);
  void onUpdate(UfoBoss boss, double dt);
  void onExit(UfoBoss boss);
}

class BossIdleState implements BossState {
  @override
  void onEnter(UfoBoss boss) => boss.startIdleAnimation();
  @override
  void onUpdate(UfoBoss boss, double dt) {
    if (boss.playerInRange) boss.changeState(BossChargingState());
  }
  @override
  void onExit(UfoBoss boss) {}
}
```

### Data Access Pattern

**Pattern :** Event Bus only — l'état runtime est distribué. Chaque système est maître de ses données et émet des événements pour informer les autres.

**Règle :** Pas d'objet GameSession centralisé. Le score vit dans le scoring system, les vies dans le ship system, la vague dans le wave system.

```dart
// Le scoring system gère le score
class ScoringSystem {
  int _score = 0;

  ScoringSystem() {
    eventBus.on<AsteroidDestroyedEvent>((e) {
      _score += GameConfig.pointsFor(e.size);
      eventBus.emit(ScoreChangedEvent(_score));
    });
  }
}

// Le HUD écoute les changements
class Hud {
  Hud() {
    eventBus.on<ScoreChangedEvent>((e) => updateScoreDisplay(e.score));
    eventBus.on<LivesChangedEvent>((e) => updateLivesDisplay(e.lives));
    eventBus.on<WaveChangedEvent>((e) => updateWaveDisplay(e.wave));
  }
}

// SaveManager écoute les événements de fin de run
class SaveManager {
  SaveManager() {
    eventBus.on<GameOverEvent>((e) {
      saveHighScore(e.finalScore);
      saveUnlockedFragments(e.fragments);
    });
  }
}
```

### Consistency Rules

| Pattern | Convention | Application |
|---------|-----------|-------------|
| Communication | Event Bus uniquement | Toute interaction entre composants |
| Création | Factory + Pool | Toute entité fréquemment créée/détruite |
| État simple | Enum + switch | Ship, Wreckage, UFO Scout, UFO Hunter |
| État complexe | State Machine (onEnter/onUpdate/onExit) | UFO Boss uniquement |
| Données runtime | Distribué via Event Bus | Score, vies, vague, upgrades |
| Données persistantes | SaveManager centralisé | High scores, fragments, déblocables |
| Constantes | GameConfig statique | Toute valeur de balancing |

---

## Architecture Validation

### Validation Summary

| Check | Résultat | Notes |
|-------|----------|-------|
| Decision Compatibility | ✅ PASS | Aucun conflit entre les 7 décisions |
| GDD Coverage | ✅ PASS | 14/14 systèmes, 6/6 requirements techniques |
| Pattern Completeness | ✅ PASS | 9 patterns définis avec exemples |
| Epic Mapping | ✅ PASS | 10/10 epics mappées à des locations |
| Document Completeness | ✅ PASS | Toutes les sections requises présentes |

### Coverage Report

**Systèmes couverts :** 14/14
**Patterns définis :** 9
**Décisions prises :** 7

### Epic to Architecture Mapping

| Epic | Location | Patterns |
|------|----------|----------|
| 1 - Fondations | `ship/`, `input/`, `background/`, `core/` | Event Bus, Enum+switch |
| 2 - Core Combat | `asteroids/`, `projectiles/`, `effects/` | Factory+Pool, Event Bus |
| 3 - Game Loop | `waves/`, `core/game_state.dart`, `ui/game_over_screen.dart` | RouterComponent+StateMachine, Event Bus |
| 4 - Dash Fantomatique | `ship/dash.dart`, `effects/trail.dart` | Sensor Mode, Enum+switch |
| 5 - Ennemis | `enemies/` | Factory+Pool, Mix State |
| 6 - Épaves & Upgrades | `wreckage/` | Factory+Pool, Event Bus |
| 7 - UI & Menus | `ui/`, `core/save_manager.dart` | RouterComponent |
| 8 - Narration & Progression | `narrative/`, `progression/` | Event Bus, SaveManager |
| 9 - Polish Visuel | `effects/`, `background/` | neon_renderer, particle_pool |
| 10 - Audio | `audio/` | flame_audio, Event Bus |

### Validation Date

2026-03-03

---

## Development Environment

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (bundled with Flutter)
- Android Studio ou VS Code avec extensions Flutter/Dart
- Android SDK (API 21+)
- Appareil Android physique ou émulateur pour le profiling
- Compte Google Play Developer (déjà en place)
- Projet Firebase (pour Crashlytics)

### AI Tooling (MCP Servers)

| MCP Server | Purpose | Repo |
|------------|---------|------|
| **Flame MCP Server** | Documentation Flame à jour, tutoriels, recherche dans la doc | [salihgueler/flame_mcp_server](https://github.com/salihgueler/flame_mcp_server) |
| **Context7** | Documentation Flutter/Dart à jour, lookup API en temps réel | [upstash/context7](https://github.com/upstash/context7) |

### Setup Commands

```bash
flutter create --org com.delfour asteroids_neon
cd asteroids_neon
flutter pub add flame
flutter pub add flame_audio
flutter pub add firebase_core
flutter pub add firebase_crashlytics
```

### First Steps

1. Exécuter les setup commands ci-dessus
2. Configurer Firebase Crashlytics (FlutterFire CLI)
3. Configurer les MCP servers pour l'assistance IA
4. Créer la structure de dossiers dans `lib/` selon l'architecture
5. Implémenter `core/event_bus.dart` et `core/game_config.dart` en premier

---

_Generated by BMAD Decision Architecture Workflow v2.0_
_Date: 2026-03-03_
_For: Kevin_
