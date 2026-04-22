# GP1

A Godot game project.

## Getting Started

1. Install [Godot 4.x](https://godotengine.org/download).
2. Open the Godot editor and **Import** this folder as a project. Godot will create `project.godot` on first open.
3. Start building scenes under a `scenes/` directory and scripts under `scripts/` (suggested; adjust to taste).

## Agents

This project includes two OpenCode subagents under `.opencode/agent/`. Use them from the main OpenCode session when you want focused, role-specific feedback.

### `game-designer`
- **Role:** Player-perspective game designer. Advocates for fun, clarity, and player experience.
- **Tools:** Read-only (read, grep, glob, webfetch).
- **Invoke when you want:** design critique, mechanic proposals, fun / clarity evaluation, difficulty balancing, onboarding review, player journey mapping.
- **Not for:** code, architecture, or technical feasibility — those go to the tech-director.

### `tech-director`
- **Role:** Senior engineer and technical director. Owns code quality, architecture, and feasibility. Godot-first, engine-aware.
- **Tools:** Full access (read, grep, glob, bash, edit, write, webfetch).
- **Default behavior:** Review-only. Reports findings and recommendations. Only applies edits when you explicitly ask.
- **Invoke when you want:** code review, architecture decisions, Godot guidance, performance analysis, feasibility checks on design ideas, refactors, or tech stack choices.
- **Not for:** deciding what is fun or making player-facing design calls — those go to the game-designer.

### Typical Workflow

1. Game Designer proposes or critiques a mechanic.
2. Tech Director assesses feasibility, cost, and risks.
3. If a constraint surfaces, Game Designer reframes the mechanic to preserve the player value.
4. Tech Director reviews or implements once the shape is agreed.

## Project Structure

```
GP1/
├── .opencode/
│   └── agent/
│       ├── game-designer.md
│       └── tech-director.md
├── .gitignore
└── README.md
```

`project.godot` and the Godot asset folders will appear once the project is opened in the Godot editor.
