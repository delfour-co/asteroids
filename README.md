# Neon Asteroids

A neon-themed arcade shooter built with Flutter and the Flame game engine. Pilot your ship through waves of asteroids, dodge UFOs, collect power-ups, and chase the high score.

## Features

- Classic asteroids gameplay with modern neon visuals
- Touch controls with virtual joystick and action buttons
- Progressive wave system with increasing difficulty
- Enemy UFOs — Scout (wave 3+) and Hunter (wave 6+)
- Power-ups: shield, multi-shot, slow-motion
- Combo system and score popups
- Screen shake and flash effects
- Space debris easter eggs (Starlink, ISS/MIR, Tesla Roadster)
- Galaxy background with Antennae nebula
- Local leaderboard (top 10)
- Pause, restart, and return to menu
- Arcade-style title screen with INSERT COIN

## Tech Stack

- [Flutter](https://flutter.dev/) 3.41.2
- [Flame](https://flame-engine.org/) 1.35.1
- Dart 3.11.0

## Getting Started

```bash
git clone https://github.com/delfour-co/asteroids.git
cd asteroids
git config core.hooksPath .githooks
cd asteroids_neon
flutter pub get
flutter run
```

## Build Android APK

```bash
cd asteroids_neon
flutter build apk --debug
# or for release
flutter build apk --release
```

## Documentation

Game design documents are available in the [`docs/`](docs/) directory, including the Game Design Document, architecture overview, and epics breakdown.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
