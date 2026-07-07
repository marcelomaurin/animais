# Animaux — Simulation d'Écosystème Simplifié (Lazarus / Free Pascal)

**Animaux** est une simulation visuelle d'écosystème basée sur des agents développée en **Lazarus / Free Pascal**. Le projet est intégré à la bibliothèque **CHATGPT** (en utilisant spécifiquement les composants de simulation du package `openai_simulation`), démontrant l'application pratique des grilles cellulaires, des règles évolutives et d'un cycle à double tampon stable.

---

## Idiomas / Languages

- [Português (PT-BR)](README.md)
- [English (EN)](README_EN.md)
- [Español (ES)](README_ES.md)
- [Français (FR)](README_FR.md)
- [中文 (ZH)](README_ZH.md)
- [العربية (AR)](README_AR.md)

---

## Fonctionnalités

La simulation modélise la dynamique de survie et de reproduction d'un écosystème simplifié sur une grille bidimensionnelle de $80 \times 80$. Le système est régi par 5 types d'entités :

| Type | Couleur | Comportement |
|---|---|---|
| **Plante** | Vert | Ressource primaire, se reproduit après quelques cycles s'il y a de l'espace. |
| **Herbivore** | Bleu | Se déplace et se nourrit de plantes. Meurt de vieillesse ou d'inanition (faim). |
| **Carnivore** | Rouge | Introduit au cycle 200, se nourrit d'herbivores. Meurt de vieillesse ou de faim. |
| **Matière Organique** | Marron | Générée par la mort de plantes, d'herbivores ou de carnivores. Se dégrade après quelques cycles. |
| **Bactérie** | Jaune | Apparaît lors de la dégradation de la matière organique, consomme la matière et se reproduit. |

---

## Principes de Conception & Stabilité

Cette version a été entièrement restructurée pour assurer la stabilité et éviter les fuites de mémoire (Access Violations et Double-Frees) :

1. **Double Tampon Sécurisé** : La grille (`TTabuleiro`) gère `FBoard` (état actif) et `FNextBoard` (état suivant). Toutes les modifications sont écrites dans `FNextBoard` et appliquées à la fin de chaque cycle.
2. **Propriété Unique** : Un objet vivant (`TSer`) appartient à un seul tampon à la fois.
3. **Libération de Mémoire Sécurisée** : Les entités mourantes sont marquées avec `Morto := True` et retirées de la simulation active. La libération de mémoire (`Free`) est gérée exclusivement pendant la phase de `Commit` de la grille.
4. **Graine Fixe** : Utilise une graine pseudo-aléatoire fixe lors de l'initialisation pour la reproductibilité scientifique.

---

## Intégration avec la bibliothèque CHATGPT

La classe fondamentale `TSer` (dans `uTipos.pas`) hérite directement de `TAISimEntity` du package `openai_simulation`. Cela permet d'utiliser l'écosystème comme un environnement simulé pour l'entraînement de modèles d'IA, la prise de décision par agents logiques et l'analyse de données écologiques.

---

## Structure du Code

* **`uTipos.pas`** : Classe `TSer` étendant `TAISimEntity`.
* **`uTabuleiro.pas`** : Gestionnaire de grille avec double tampon et gestion de mémoire sécurisée.
* **`uConfig.pas`** : Enregistrement `TConfig` avec des paramètres écologiques calibrés.
* **`uSimulacao.pas`** : Moteur central qui traite les étapes de simulation et applique les règles biologiques.
* **`uEstat.pas`** : Enregistrement statistique de comptage de population par cycle.
* **`form2.pas` / `form2.lfm`** : Interface de contrôle visuel avec boutons Démarrer, Pause, Arrêter, Réinitialiser et exportation CSV.

---

## Comment Compiler et Exécuter

### Prérequis
- Lazarus IDE
- Free Pascal Compiler (FPC)
- Bibliothèque CHATGPT (dossier `pacote` accessible dans les chemins de recherche définis dans `.lpi`)

### Compilation
Ouvrez le terminal dans le répertoire du projet et exécutez :
```bash
lazbuild animal.lpi
```

Ou ouvrez `animal.lpi` directement dans l'IDE Lazarus et appuyez sur **F9**.

---

## Licence
Ce projet est sous licence **GPL-3.0**.
