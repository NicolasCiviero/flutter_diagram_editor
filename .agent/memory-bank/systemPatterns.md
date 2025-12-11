# System Patterns

## Architecture
The project follows a modular architecture centered around the `DiagramEditor` widget.

### Core Concepts

1.  **DiagramEditor**: The main widget. It takes a `DiagramEditorContext`.
2.  **DiagramEditorContext**: Holds the `PolicySet`.
3.  **PolicySet**: A class that aggregates various policies.
4.  **Policies**: Mixins that implement specific interfaces.
    - **InitPolicy**: Initialization logic (e.g., setting canvas color).
    - **CanvasPolicy**: Handling canvas gestures (tap, drag).
    - **ComponentPolicy**: Handling component interaction.
    - **LinkPolicy**: Handling link interaction.
    - **ClusteringPolicy**: Handling vertex clustering logic.
5.  **State Management**:
    - **CanvasReader**: Used to read the current state of the diagram (components, links, canvas position).
    - **CanvasWriter**: Used to modify the state (add components, move items, chang properties).

## Design Patterns

- **Mixin Composition**: heavily used for defining Policies. This allows developers to pick and choose behaviors (e.g., `with MyInitPolicy, CanvasControlPolicy`).
- **Command/Action Pattern**: (Implicit) `CanvasWriter` acts as the executor of actions.
- **Observer/Listener**: The diagram likely listens to state changes to repaint.
- **Separation of Concens**: `CanvasModel` holds data (e.g., clusters), while Policies (e.g., `ClusteringPolicy`) define behavior.

## File Structure (inferred)
- `lib/shape_editor.dart`: Entry point.
- `lib/src/`: Core implementation files.
    - Likely contains `abstraction`, `canvas_context`, `widget`, `policy` subdirectories (based on common patterns, though not verified extensively yet).

## Coding Standards (Inferred)
- Clean separation of interface (Policies) and implementation (Mixins).
- Use of strong typing.
