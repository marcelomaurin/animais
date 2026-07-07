# Animaux — Simulation d'Écosystème Simplifié

**Animaux** est une simulation visuelle d'écosystème développée avec **Lazarus / Free Pascal**.

Le projet démontre un environnement en grille 2D avec des êtres simples, des règles de survie, d'alimentation, de reproduction, de mort, de matière organique et des statistiques de base en temps réel.

Il sert aussi de démo pratique de la bibliothèque [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT), car le projet dépend du package `openai_simulation` et la classe `TSer` hérite de `TAISimEntity`.

---

## État actuel du projet

Cette version est une simulation **simplifiée et fonctionnelle**, centrée sur :

- une grille bidimensionnelle ;
- des agents/êtres vivants représentés par des objets ;
- un cycle de simulation piloté par timer ;
- l'alimentation entre espèces ;
- la reproduction ;
- la mort par âge ou par faim ;
- la transformation des êtres morts en matière organique ;
- la dégradation de la matière organique en bactéries ;
- un rendu visuel simple ;
- des compteurs de population ;
- l'exportation d'un résumé CSV simple.

Les sous-espèces, graphiques historiques, mutations complexes, écrans visuels de configuration et panneaux avancés de biodiversité **ne sont pas implémentés dans le code actuel**. Ils doivent être considérés comme des améliorations futures.

---

## Entités de la simulation

| Type | Couleur dans l'interface | Comportement actuel |
|---|---|---|
| **Bactérie** | Jaune | Peut consommer la matière organique, se déplacer aléatoirement et se reproduire. |
| **Plante** | Vert | Sert de nourriture aux herbivores et peut se reproduire. |
| **Herbivore** | Bleu | Mange les plantes, se déplace et meurt par âge ou par faim. |
| **Carnivore** | Rouge | Entre au cycle configuré, mange les herbivores et meurt par âge ou par faim. |
| **Matière organique** | Marron | Provient des plantes, herbivores et carnivores morts ; se dégrade ensuite en bactéries. |

---

## Structure du code

| Fichier | Responsabilité |
|---|---|
| `animal.lpr` | Programme Lazarus principal. |
| `animal.lpi` | Fichier de projet Lazarus, avec dépendance à `openai_simulation`. |
| `form2.pas` / `form2.lfm` | Interface visuelle principale, timer, dessin et export CSV. |
| `uTipos.pas` | Définit `TTipo` et `TSer`, qui hérite de `TAISimEntity`. |
| `uConfig.pas` | Définit `TConfig` et les paramètres par défaut. |
| `uTabuleiro.pas` | Implémente la grille avec `FBoard` et `FNextBoard`. |
| `uSimulacao.pas` | Implémente les règles écologiques et le cycle de simulation. |
| `uEstat.pas` | Définit le record `TEstat` utilisé pour les compteurs de population. |

---

## Relation avec la bibliothèque CHATGPT

Ce projet est un exemple de ce qui peut être construit avec la bibliothèque [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT), en particulier avec la zone **AI Simulation**.

Dans la version actuelle, l'intégration reste minimale :

- le projet Lazarus dépend de `openai_simulation` ;
- `TSer` hérite de `TAISimEntity` ;
- la structure suit les concepts de simulation : entités, grille, cycles et métriques.

Le projet sert de base didactique pour évoluer vers une utilisation plus complète des composants `AI Simulation`.

---

## Compilation

### Prérequis

- Lazarus IDE ;
- Free Pascal Compiler ;
- copie locale de [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) ;
- package `openai_simulation` installé ou visible par Lazarus.

### Construire

```bash
git clone https://github.com/marcelomaurin/animais.git
cd animais
lazbuild animal.lpi
```

Ou ouvrez `animal.lpi` dans Lazarus et compilez depuis l'IDE.

---

## Limitations actuelles

- La configuration est statique dans `uConfig.pas`.
- L'export CSV est seulement un snapshot simple.
- Il n'y a pas encore d'historique complet par cycle.
- Il n'y a pas de graphiques ni d'onglets.
- Il n'y a pas de sous-espèces ni de mutations avancées dans le code actuel.
- Le projet n'utilise pas encore tous les composants de `AI Simulation`.

---

## Licence

Ce projet est distribué sous licence **GPL-3.0**.
