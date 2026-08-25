# Choira Music Player

A Flutter music player app built for the Choira Flutter Developer assessment, using the Jamendo Music API for track discovery, search, and streaming playback.

## Features

- Home/listing screen with track artwork, title, and artist
- Search with live results from the Jamendo API
- Now Playing screen with seek bar, duration, and playback position
- Mini player persisting across the home screen
- Infinite-scroll pagination (loads the next page as you scroll near the bottom)
- Loading, error, and empty states
- Responsive layout (list view on phones, grid view on wider screens)
- Offline caching — falls back to the last successfully loaded tracks when there's no connection

## Setup Instructions

### Prerequisites
- Flutter SDK (stable channel)
- An editor with Flutter/Dart support (VS Code, Android Studio, etc.)
- A connected device or emulator

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/choira-music-player.git
   cd choira-music-player
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure the API client ID — see [API Configuration](#api-configuration) below.

4. Run the app:
   ```bash
   flutter run
   ```

5. Build a release APK:
   ```bash
   flutter build apk --release
   ```
   The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## API Configuration

This app uses the [Jamendo Music API](https://developer.jamendo.com/v3.0) (v3.0).

The API client ID is kept out of source control via a `.env` file:

1. Create a `.env` file in the project root (same level as `pubspec.yaml`):
   ```
   JAMENDO_CLIENT_ID=your_client_id_here
   ```
   See `.env.example` for the expected format.

2. Get your own client ID by registering an app at [developer.jamendo.com](https://developer.jamendo.com/v3.0), or use the one provided for this assessment.

3. `.env` is listed in `.gitignore` and is never committed. Only `.env.example` (with a placeholder value) is tracked in the repository.

**Endpoints used:**
| Purpose | Endpoint |
|---|---|
| Get tracks | `GET /tracks/?client_id={id}&format=json&limit=20&offset=0` |
| Search tracks | `GET /tracks/?client_id={id}&format=json&namesearch={query}&limit=20&offset=0` |

## Architecture & State Management

### State management: Provider

The app uses the `provider` package with two `ChangeNotifier` classes as the single sources of truth for app-wide state:

- **`TrackProvider`** — owns the track list, current search query, pagination offset, and loading/error flags. Handles fetching, searching, and offline-cache fallback. Exposes `fetchTracks()` (with a `loadMore` flag for pagination) and `searchTracks()`.
- **`PlayerProvider`** — wraps a `just_audio` `AudioPlayer` instance. Owns the current playback queue, the currently playing track, and playback state (playing/paused, position, duration). Listens to `just_audio`'s position/duration/state streams and calls `notifyListeners()` so any widget watching it stays in sync automatically — including auto-advancing to the next track when one finishes.

Both providers are registered once at the app root via `MultiProvider`, so any screen can read or react to them without passing state down through constructors.

Widgets access provider state via:
- `context.watch<T>()` / `Consumer<T>` — for anything rendered in the UI that needs to rebuild when state changes (track lists, the mini player, the now-playing screen)
- `context.read<T>()` — for one-off calls inside callbacks (`onTap`, scroll listeners) that trigger an action without needing a rebuild

This keeps playback state consistent everywhere it's shown — the home screen's active-track highlight, the mini player, and the full Now Playing screen all read from the same `PlayerProvider`, so skipping to the next track from any one of them updates the others automatically.

### Project structure

```
lib/
├── main.dart                    # MultiProvider + MaterialApp root
├── Models/
│   └── track.dart               # Tracks model (Jamendo API <-> app data)
├── Providers/
│   ├── track_provider.dart      # Track list, search, pagination, caching
│   └── player_provider.dart     # Playback state via just_audio
├── Screens/
│   ├── home_screen.dart         # Listing, search, responsive layout
│   └── now_playing_screen.dart  # Full player UI
├── Widgets/
│   ├── track_list_item.dart
│   ├── mini_player.dart
│   ├── search_bar.dart
│   └── app_theme.dart           # Shared design tokens (colors, text styles)
└── Utils/
    └── app_theme.dart           # API base URL constant
```

### Pagination

`TrackProvider` fetches tracks in pages of 20 using Jamendo's `limit`/`offset` parameters. A `ScrollController` on the track list triggers `fetchTracks(loadMore: true)` when the user scrolls near the bottom. A guard (`if (isLoading || (!hasMore && loadMore)) return;`) prevents duplicate in-flight requests and stops requesting once the API returns fewer than a full page (signalling the end of the list).

### Error handling

Both `fetchTracks()` and `searchTracks()` wrap their network calls in try/catch, set a `hasError` flag on failure, and reset it at the start of each new attempt. The UI distinguishes three states: loading (spinner), error with nothing cached (retry prompt), and empty search results (distinct messaging) — each rendered from `TrackProvider`'s flags via a `Consumer`.

### Offline caching

On a successful fetch of the first page, the track list is serialized to JSON and saved locally via `shared_preferences`. If a later fetch fails and no tracks are currently loaded, the app falls back to this cached list so the user isn't left with a blank screen.

## Known Limitations

- Cached data is a single static snapshot of the first page — pagination doesn't work while offline.
- Full audio files are streamed, not downloaded for offline playback.