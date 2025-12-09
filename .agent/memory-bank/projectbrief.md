# Project Brief: Shape Editor

## Overview
`shape_editor` (also known as `flutter_diagram_editor`) is a Flutter library designed for creating and editing custom diagrams. It provides a flexible `DiagramEditor` widget that allows developers to customize editor design and behavior through a policy-based architecture.

## Core Features
- **DiagramEditor Widget**: The central widget for embedding the editor.
- **Policy-Based Customization**: Behavior and design are defined using a `PolicySet` composed of various mixins (e.g., `InitPolicy`, `CanvasPolicy`, `ComponentPolicy`).
- **Canvas Management**: scalable and pannable canvas.
- **Component & Link Management**: Support for adding, moving, and connecting components.
- **Customizable Widgets**: Developers can define how components and the canvas look.

## Goals
- Provide a generic and highly customizable diagram editor for Flutter applications.
- implementation of custom logic for interactions (tap, drag, etc.) via policies.
- Support for complex diagram structures with components and links.
