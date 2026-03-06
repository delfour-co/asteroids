---
project_name: 'mobilegame--asteroids'
user_name: 'Kevin'
date: '2026-03-03'
sections_completed: ['technology_stack', 'engine_rules', 'performance_rules', 'code_organization', 'testing_rules', 'platform_build', 'critical_rules']
status: 'complete'
---

# Project Context for AI Agents — Neon Asteroids

_This file contains critical rules and patterns that AI agents must follow when implementing game code in this project. Focus on unobvious details that agents might otherwise miss._

_Reference: `_bmad-output/game-architecture.md` for full architectural decisions and project structure._

---

## Technology Stack & Versions

- **Engine:** Flutter + Flame Engine v1.35.1 (Dart)
- **Packages:** `flame`, `flame_audio`, `firebase_core`, `firebase_crashlytics`
- **Target:** Android (API 21+), Google Play Store
- **Frame rate:** 60fps constant
- **Orientation:** Paysage uniquement
- **Network:** 100% offline (Crashlytics only in background)
- **Assets visuels:** 100% programmatique — zéro sprite/texture externe

---

## Critical Implementation Rules

### Flame Engine-Specific Rules

**Lifecycle:**
- `onLoad()` pour l'initialisation — **pas** le constructeur
- `update(double dt)` — toujours multiplier par `dt` pour le mouvement frame-independent
- `render(Canvas canvas)` — dessin uniquement, **jamais** de logique de jeu
- `onRemove()` — désabonner les listeners Event Bus ici

**FCS (Flame Component System):**
- Tout objet de jeu est un `Component` ou `PositionComponent` — jamais en dehors du FCS
- `add()` est asynchrone — le composant n'est pas disponible immédiatement
- `removeFromParent()` prend effet à la fin du tick — ne pas réutiliser l'objet immédiatement
- Utiliser `children` pour accéder aux enfants, jamais de listes externes parallèles

**CollisionCallbacks:**
- Toujours ajouter un `Hitbox` (CircleHitbox, PolygonHitbox) — pas de collision sans hitbox
- `onCollisionStart` pour les événements one-shot (dégâts), `onCollision` pour le contact continu

**Canvas API:**
- `canvas.save()` / `canvas.restore()` obligatoire avec transformations dans `render()`
- Les `Paint` objects créés une fois comme propriétés de classe, **jamais** dans `render()`

**RouterComponent:**
- Routes = constantes string — éviter les typos
- `pushRoute()` empile, `pushReplacementRoute()` remplace — ne pas empiler sans fin

---

### Performance Rules

**Frame Budget:**
- 60fps = 16.67ms par frame max
- Si budget dépassé : réduire particules/glow AVANT de baisser le framerate

**Hot Path (update/render):**
- **JAMAIS** d'allocation dans `update()` ou `render()` — pas de `new List()`, `Paint()`, `Vector2()` temporaires
- Pré-alloquer les objets réutilisables comme propriétés de classe
- Pas de `toString()`, string interpolation, logging dans les hot paths

**Object Pooling:**
- Obligatoire pour : projectiles, particules, débris d'explosion
- Via Factory+Pool — le manager appelle la factory, jamais le pool directement
- `recycle()` au lieu de `removeFromParent()` + `add()` pour les entités poolées

**Rendu Glow (MaskFilter.blur + double draw):**
- Double draw = double drawcalls — surveiller le nombre d'objets actifs
- `MaskFilter.blur` est GPU-intensive — réduire `glowRadius` si performance dégradée
- Envisager de désactiver le glow sur les petits objets si nécessaire

**Profiling:**
- Tester sur appareil physique milieu de gamme, pas uniquement en émulateur
- Flutter DevTools pour frame budget et memory profiler

---

### Code Organization Rules

**Import Rules:**
- `core/` est importable par tous les dossiers
- Les features ne s'importent **JAMAIS** entre elles — communication via Event Bus uniquement
- Pas d'import circulaire — si A importe B, B ne peut pas importer A
- `debug/` derrière `kDebugMode` — jamais importé hors d'un bloc conditionnel

**File Rules:**
- Un fichier = une responsabilité
- Un fichier = une classe principale (+ classes privées liées si nécessaire)

**Component Rules:**
- Chaque entité de jeu hérite de `PositionComponent`
- Les managers gèrent le cycle de vie de leurs entités
- Les factories encapsulent les pools — les managers ne connaissent pas les pools

**Event Bus Rules:**
- Chaque événement = une classe Dart dédiée dans le dossier de la feature émettrice
- Nommage : `PascalCase` + `Event` suffix (`AsteroidDestroyedEvent`, `DashRequestedEvent`)
- S'abonner dans `onLoad()`, se désabonner dans `onRemove()`
- Traitement synchrone (même frame)
- Aucune référence directe entre composants — Event Bus uniquement, y compris intra-feature

---

### Testing Rules

**Organization:**
- Tests mirrorent la structure `lib/` — `test/ship/ship_test.dart` teste `lib/ship/ship.dart`
- Nommage : `snake_case_test.dart`

**Categories:**
- **Unit tests** — Logique isolée : GameConfig, EventBus, ScoringSystem, DifficultyScaler, SaveManager
- **Component tests** — Composants Flame dans un `FlameGame` de test : Ship, Asteroid, UFO, collisions
- **Widget tests** — Écrans UI : menus, HUD, leaderboard

**Patterns:**
- Tester via Event Bus — émettre un événement, vérifier la réaction
- Mocker l'Event Bus pour isoler les systèmes
- Pas de tests dans `render()` — tester la logique dans `update()` et les handlers
- Factories et pools : tests dédiés (acquire, recycle, overflow)

**Toujours tester :**
- Transitions d'état (ShipState.normal → dashing → normal)
- Scoring (points par taille, extra life à 10000)
- Wave scaling (nombre d'astéroïdes, vitesse par vague)
- SaveManager round-trip (sauvegarde/chargement JSON)

---

### Platform & Build Rules

**Android:**
- API minimum 21 (Android 5.0)
- Orientation paysage forcée dans `AndroidManifest.xml`
- Aucune permission spéciale requise
- 100% offline — seul Crashlytics envoie en background

**Build:**
- `flutter build apk` pour le release
- `kDebugMode` sépare debug/release — code `debug/` disparaît via tree-shaking
- Firebase Crashlytics activé uniquement en release

**Input:**
- Touch uniquement — pas de clavier, pas de manette
- Zones de touch généreuses — pas de précision pixel
- Joystick (gauche) + 3 boutons (droite : propulsion, tir, dash)

---

### Critical Don't-Miss Rules

**Anti-patterns à éviter :**
- **JAMAIS** de référence directe entre features — toujours Event Bus
- **JAMAIS** d'allocation dans `update()` / `render()` — pré-alloquer
- **JAMAIS** de `Paint()` créé dans `render()` — stocker comme propriété
- **JAMAIS** de logique de jeu dans `render()` — render = dessin uniquement
- **JAMAIS** d'état partagé mutable — chaque système est maître de ses données

**Gotchas Flame :**
- `add()` est asynchrone — le composant n'existe pas encore dans le tick suivant
- `removeFromParent()` prend effet à la fin du tick
- `onCollisionStart` vs `onCollision` — utiliser `Start` pour les dégâts one-shot
- `canvas.save()`/`restore()` obligatoire avec transformations

**Gotchas projet :**
- Message d'erreur critique = in-universe : "Défaillance critique du vaisseau..." — jamais de stacktrace au joueur
- Fragments narratifs = permanents entre runs. Upgrades = perdus à la mort. Ne pas confondre.
- Le wrap-around s'applique à **TOUT** : vaisseau, astéroïdes, projectiles, UFOs — ne l'oublier pour aucun type d'entité

---

## v1.5.0 Systems — Additional Rules

### Special Asteroids
- **ExplosiveAsteroid** (wave 5+, 8% chance) — orange-red neon, pulsing inner glow. On destroy: emits `KnockbackEvent` pushing nearby asteroids + extra screen shake.
- **MagneticAsteroid** (wave 8+, 12% chance) — purple neon, pulsing field ring. Curves trajectory toward ship when within `magneticPullRadius` (150px). Ship lookup: `parent?.parent?.children.whereType<Ship>()` (parent is AsteroidManager, parent.parent is GameLayer).
- Both share the same `AsteroidSize` enum and `AsteroidDestroyedEvent` as regular asteroids.

### Narration System
- **FragmentManager** — Component at game root, survives restarts. Listens to `WaveStartedEvent`, unlocks fragment every 10 waves. Persists via `SharedPreferences`.
- **FragmentData** — Static list of 11 `NarrativeFragment` objects (wave 0 to 100). Fragment id=-1 (AWAKENING) is always visible.
- **JournalOverlay** — Two-mode overlay (list view + detail view). Uses `_EntryRect` hit-testing for tappable entries. DragCallbacks pattern.
- **FragmentOverlay** — Shown in-game when a fragment is unlocked during gameplay.

### Cosmetics System
- **CosmeticsManager** — Plain Dart class (NOT a Component). Manages ship color unlocks/selection via `SharedPreferences`.
- Ship colors unlocked by wave milestones: `[10, 20, 30, 50]` → indices `[1, 2, 3]` (cyan always unlocked at 0).
- Ship constructor accepts optional `Color? color` parameter.

### Death Sequence
- **DeathSequence** — Component at game root, priority 900. Triggered by `DeathSlowMoEvent`.
- Three phases: radial gradient overlay (0-0.6s), "SIGNAL PERDU" with scanlines (0.6-1.0s), fade out (1.0-2.5s).
- `containsLocalPoint => false` — never intercepts input.

### Perfect Kill & Knockback
- **Perfect kill** — When asteroid destroyed within 60px of ship, emits `PerfectKillEvent` with 2x bonus. Golden "PERFECT" popup.
- **Knockback** — `KnockbackEvent` listened by regular asteroids. Pushes nearby asteroids away from explosion center.

### Shooting Stars
- **ShootingStarManager** — Component at game root. Spawns shooting stars at random intervals (8-20s, decreasing by 10% per wave).
- Stars travel from screen edges toward center area with glow+core dual rendering.

### Evolving Nebula
- **NebulaLayer** — Listens to `WaveStartedEvent`. `_waveIntensity` scales 0→1 over 50 waves, adding violet/rose overlay tint.

---

_Generated by BMAD Generate Project Context Workflow_
_Date: 2026-03-03_
_For: Kevin_
