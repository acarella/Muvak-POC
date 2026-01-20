# Muvak POC

A meditation app proof-of-concept built with SwiftUI, featuring a clean dark theme UI and unidirectional data flow architecture.

## Demo


https://github.com/user-attachments/assets/af45dca3-caf5-4922-8e35-f54ff379425f


## Features

- **Session List** - Browse meditation sessions with animated type-specific icons
- **Session Detail** - Full media player interface with performance tracking
- **Audio Visualizer** - Animated equalizer bars that respond to playback state
- **Performance Tracking** - Daily progress and weekly streaks
- **Experience System** - Level progression for meditation practice

## Architecture

This project implements a **Unidirectional Data Flow (UDF)** pattern in pure Swift:

```
Action → Store → Reducer → State → View
```

### Key Components

| Component | Description |
|-----------|-------------|
| **State** | Immutable data representing the UI |
| **Action** | Events that trigger state changes |
| **Reducer** | Pure functions that produce new state |
| **Store** | ObservableObject holding state and dispatching actions |
| **Effect** | Combine publishers for async operations |

### Project Structure

```
Muvak-POC/
├── Features/
│   ├── SessionList/
│   │   ├── SessionListState.swift
│   │   ├── SessionListAction.swift
│   │   ├── SessionListReducer.swift
│   │   ├── SessionListDependencies.swift
│   │   ├── SessionListStore.swift
│   │   ├── SessionListView.swift
│   │   └── SessionIconView.swift
│   └── SessionDetail/
│       ├── SessionDetailState.swift
│       ├── SessionDetailAction.swift
│       ├── SessionDetailReducer.swift
│       ├── SessionDetailDependencies.swift
│       ├── SessionDetailStore.swift
│       ├── SessionDetailView.swift
│       └── AudioVisualizerView.swift
├── Models/
│   └── Session.swift
├── Navigation/
│   └── AppRootView.swift
└── StyleKit/
    ├── ColorPalette.swift
    └── Typography.swift
```

## Tech Stack

- **SwiftUI** - Declarative UI framework
- **Combine** - Reactive programming for effects
- **XCTest** - Unit testing

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Getting Started

1. Clone the repository
2. Open `Muvak-POC.xcodeproj` in Xcode
3. Build and run on simulator or device

## Testing

Run tests with:

```bash
xcodebuild test -scheme Muvak-POC -destination 'platform=iOS Simulator,name=iPhone 17'
```

## License

MIT
