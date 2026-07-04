# مترویار (MetroYar) 🚇

A fast, fully offline route planner and companion app for the Tehran Metro — built with Flutter.

MetroYar helps you get from one station to another without thinking too hard about it: pick your stations (or just tap "use my location"), choose how you'd like to travel, and get a clear route with live-ish train times — all without needing an internet connection.

---

## ✨ Features

- **Smart route finding** — Get from station A to station B in a couple of taps.
- **Multiple search strategies** — Not everyone optimizes for the same thing, so you can choose:
  - 🚉 Fewest stations
  - 📏 Shortest distance
  - 🔁 Fewest line changes
  - ⏱️ Least time (factors in transfer time, not just distance)
- **Location-aware** — Let MetroYar find the nearest station to you automatically using GPS.
- **Pick on the map** — Prefer a visual approach? Choose your origin/destination by tapping a spot on an interactive OpenStreetMap view.
- **Train schedules** — See when the next train arrives at any station, plus an estimated time of arrival at your destination.
- **Interactive offline metro map** — Pan and zoom the full Tehran Metro map, and tap any station to see its details, amenities, and connecting lines.
- **Fully offline** — Station data, line graphs, and schedules are all bundled locally in a SQLite database — no server round-trips needed to plan a route.
- **Persian-first UI** — Native RTL layout, Jalali-friendly design sensibilities, and the Vazirmatn font throughout.
- **Light & dark themes** — Easy on the eyes, day or night.

---

## 🏗️ Architecture

MetroYar follows a **feature-first, layered architecture** with BLoC/Cubit for state management:

```
lib/
├── core/            # App-wide building blocks
│   ├── bloc/        # Shared BLoC utilities
│   ├── constants/   # Dimens, durations, strings
│   ├── database/    # SQLite setup & access
│   ├── di/          # Dependency injection (get_it)
│   ├── routing/     # App routes / navigation
│   ├── services/    # Preferences, shared services
│   └── theme/       # Colors, typography, light/dark themes
├── features/        # One folder per feature, each with its own
│   │                # data / domain / presentation layers
│   ├── app_shell/       # Bottom nav & app scaffold
│   ├── onboarding/      # First-run intro slides
│   ├── route_finder/    # Station selection, strategies, map/location picker
│   ├── route_results/   # Route rendering & step-by-step breakdown
│   ├── metro_map/       # Interactive full metro map viewer
│   ├── station_details/ # Per-station info & amenities
│   ├── train_schedule/  # Timetables & arrival estimates
│   ├── settings/        # Theme & app preferences
│   └── about/           # About screen
└── shared/          # Cross-feature models, enums, widgets & utils
```

This structure keeps each feature self-contained and easy to reason about, while `core/` and `shared/` hold the glue that ties everything together.

### Tech stack

| Purpose | Package |
|---|---|
| State management | `flutter_bloc`, `equatable` |
| Dependency injection | `get_it` |
| Local database | `sqflite` / `sqflite_common_ffi` |
| Preferences | `shared_preferences` |
| Location | `geolocator` |
| Maps | `flutter_map`, `latlong2` |
| SVG rendering | `flutter_svg` |
| Fonts | Vazirmatn (self-hosted, variable weights) |

---

## 🚀 Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.9.0)
- Android Studio / Xcode for platform builds, or just a connected device / emulator

### Run it

```bash
flutter pub get
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

---

## 🗄️ Data

Route-finding and station data live in a bundled SQLite database (`assets/metro.db`), and train timetables are stored as per-line JSON files under `assets/schedules/`. Everything ships with the app, so route planning and schedule look-ups work with no network connection at all.

---

## 🤝 Contributing

This is currently a personal/solo project, but feel free to open an issue if you spot a bug or have an idea — pull requests are welcome too.

---

## 📄 License

No license has been set yet — treat this as "all rights reserved" until stated otherwise.

---

Made with ❤️ (and a lot of Dijkstra) for Tehran metro riders.
