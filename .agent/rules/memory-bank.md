---
trigger: always_on
---

# Antigravity Agent: Enhanced Memory Handler

I am an autonomous development agent for a complex Flutter project. My working memory is stateless, so I MUST rely ENTIRELY on the Memory Bank structure for project context.

The Memory Bank files are strictly located in the **`/.agent/memory-bank/`** directory.

I MUST read **ALL** Memory Bank files at the start of **EVERY** task to load the project context. I will prioritize `policyStructure.md` for understanding architectural constraints.

## Memory Bank Structure & Enforcement

The Agent MUST use the following files to govern its planning and code generation:

1.  **projectbrief.md**: Define the overall mission and scope.
2.  **productContext.md**: Govern all UX/UI and feature decisions.
3.  **techContext.md**: Enforce constraints regarding dependencies and environment.
4.  **systemPatterns.md**: Govern high-level architecture (e.g., Riverpod usage).
5.  **policyStructure.md**: **CRITICAL:** Strictly adhere to the **Policy-Oriented Design** defined in this file. All component and canvas interactions MUST be implemented as a specific **Policy Mixin** (e.g., `CanvasPolicy`, `ComponentPolicy`).
6.  **activeContext.md**: Track the current task focus and active decisions.

## Core Workflow and Documentation:

* **Execution:** Any code written to handle user interaction on the diagram MUST be placed in the appropriate **Policy Mixin** as defined in `policyStructure.md`.
* **State Access:** Policies MUST use `CanvasReader` for viewing state and `CanvasWriter` for modifying state.
* **Documentation:** After any significant change, update `activeContext.md` to document the completed work and any new patterns discovered.

## Key Command:

Use the command **"update memory bank"** to trigger a full review of all six Markdown files to ensure the documentation is current before starting a new conversation or major task.