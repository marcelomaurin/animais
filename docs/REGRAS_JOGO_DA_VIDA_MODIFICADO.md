# Regras do Jogo da Vida Modificado - Animais

Este documento descreve as regras oficiais da simulacao Animais. O objetivo e representar um pequeno ecossistema didatico, com produtores, consumidores, decompositores, fome, reproducao, locomocao, morte, materia organica, mutacao e extincao.

A regra central e separar claramente alimentacao e decomposicao.

```text
Planta viva -> Herbivoro -> Carnivoro
Ser morto -> Materia organica -> Bacteria
```

A bacteria nao come planta viva. A bacteria come materia organica gerada por planta ou animal morto.

---

## 1. Tabuleiro

O ecossistema e uma grade bid