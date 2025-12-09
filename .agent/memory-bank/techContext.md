# Tech Context

## Technology Stack
- **Language**: Dart
- **Framework**: Flutter
- **State Management**: Provider (`^6.0.4`)
- **Event Handling**: Event (`^2.1.2`)
- **Math**: Vector Math (`^2.1.4`) for coordinate transformations.
- **Utilities**:
    - `uuid`: For generating unique IDs.
    - `flutter_colorpicker`: For UI related to color selection (likely in examples or default widgets).

## Development Environment
- **SDK**: Dart >=3.0.0 <4.0.0, Flutter >=1.17.0
- **Linter**: `flutter_lints`

## Key Dependencies
- **Provider**: Used for Dependency Injection and State Management within the editor context.
- **Vector Math**: Essential for 2D transformations (scaling, translating) of the canvas and components.

## Build & Test
- Standard `flutter test` for testing.
- `flutter pub publish` for distribution.
