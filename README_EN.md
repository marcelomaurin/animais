# Animals — Simplified Ecosystem Simulation

**Animals** is a visual ecosystem simulation developed in **Lazarus / Free Pascal**.

The project demonstrates a 2D grid environment with simple beings, survival rules, feeding, reproduction, death, organic matter and basic real-time statistics.

It also works as a practical demo of the [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) library, because the project depends on the `openai_simulation` package and the `TSer` class inherits from `TAISimEntity`.

---

## Current project state

This version is a **simplified and functional simulation** focused on demonstrating:

- a two-dimensional grid;
- living objects represented as agents;
- timer-based simulation cycles;
- feeding between species;
- reproduction;
- death by age or starvation;
- conversion of dead beings into organic matter;
- conversion of organic matter into bacteria after degradation;
- simple visual rendering;
- population counters;
- export of a simple CSV summary.

Advanced subspecies, historical charts, complex mutations, visual configuration screens and detailed biodiversity panels are **not implemented in the current source code**. They should be considered future improvements.

---

## Simulation entities

| Type | Interface color | Current behavior |
|---|---|---|
| **Bacteria** | Yellow | Can consume organic matter, move randomly and reproduce. |
| **Plant** | Green | Serves as food for herbivores and can reproduce. |
| **Herbivore** | Blue | Eats plants, moves and dies by age or starvation. |
| **Carnivore** | Red | Enters at the configured cycle, eats herbivores and dies by age or starvation. |
| **Organic matter** | Brown | Created from dead plants, herbivores and carnivores; later degrades into bacteria. |

---

## Code structure

| File | Responsibility |
|---|---|
| `animal.lpr` | Main Lazarus program. |
| `animal.lpi` | Lazarus project file, including the `openai_simulation` dependency. |
| `form2.pas` / `form2.lfm` | Main visual interface, timer, drawing and CSV export. |
| `uTipos.pas` | Defines `TTipo` and `TSer`, which inherits from `TAISimEntity`. |
| `uConfig.pas` | Defines `TConfig` and the default simulation parameters. |
| `uTabuleiro.pas` | Implements the grid using `FBoard` and `FNextBoard`. |
| `uSimulacao.pas` | Implements the ecological rules and simulation cycle. |
| `uEstat.pas` | Defines the `TEstat` record used for population counters. |

---

## Relation with the CHATGPT library

This project is an example of what can be built with the [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) library, especially the **AI Simulation** area.

In the current version, the integration is still minimal:

- the Lazarus project depends on `openai_simulation`;
- `TSer` inherits from `TAISimEntity`;
- the structure follows simulation concepts such as entities, grid, cycles and metrics.

The project is a didactic base that can evolve toward a fuller use of the `AI Simulation` components.

---

## How to build

### Requirements

- Lazarus IDE;
- Free Pascal Compiler;
- local copy of [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT);
- `openai_simulation` package installed or visible to Lazarus.

### Build

```bash
git clone https://github.com/marcelomaurin/animais.git
cd animais
lazbuild animal.lpi
```

Or open `animal.lpi` in Lazarus and build from the IDE.

---

## Current limitations

- Configuration is static in `uConfig.pas`.
- CSV export is only a simple snapshot.
- There is no full cycle history yet.
- There are no charts or tabs.
- There are no subspecies or advanced mutations in the current code.
- The project does not yet use the full set of `AI Simulation` components.

---

## License

This project is distributed under the **GPL-3.0** license.
