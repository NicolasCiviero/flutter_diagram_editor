# Product Context

## Problem Statement
Building diagram editors in Flutter from scratch is complex, requiring handling of gestures, canvas coordinate systems, state management for components and links, and customizable interactions. Developers need a reusable foundation that handles the "plumbing" while allowing them to define the "business logic" of their diagrams.

## Solution
`shape_editor` offers a `DiagramEditor` widget that acts as a framework. Instead of enforcing a specific diagram type (like UML or Flowchart), it provides the tools to build *any* node-link diagram.

## User Experience
- **Developer Experience**: The library uses a "Mixins as Policies" approach. Developers create a `PolicySet` class and mix in the behaviors they want. This allows for granular control without subclassing a massive base class.
- **End-User Experience**: Depends on the implementation, but generally supports standard interactions like panning, zooming, selecting items, moving items, and creating connections.

## Key Design Decisions
- **Separation of Logic and UI**: The `DiagramEditor` handles the drawing and gesture detection, while policies handle what happens when those gestures occur.
- **CanvasReader/CanvasWriter**: A state management pattern (likely utilizing `Provider` internally or similar) to separate reading state from modifying it.
