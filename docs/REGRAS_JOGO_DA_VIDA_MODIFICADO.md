# Regras do Jogo da Vida Modificado — Animais

Este documento descreve as regras em vigor na simulação **Animais**, conforme implementadas em `uSimulacao.pas` e `uTabuleiro.pas`. O objetivo é representar um pequeno ecossistema didático, com produtores, consumidores, decompositores, fome, reprodução, locomoção, morte e matéria orgânica.

A regra central é separar claramente alimentação e decomposição.

```text
Planta viva -> Herbívoro -> Carnívoro
Ser morto -> Matéria orgânica -> Bactéria
```

A bactéria não come planta viva. A bactéria come matéria orgânica gerada por planta ou animal morto.

Mutação, subespécies e toxicidade **não** fazem parte das regras atuais.

---

## 1. Tabuleiro

O ecossistema é uma grade bidimensional (80×80 na configuração padrão), sem ligação entre as bordas. Cada célula contém no máximo um ser.

O tabuleiro tem dois estados: o atual (`FBoard`) e o próximo (`FNextBoard`). Durante o ciclo, cada ser processado migra do atual para o próximo; no fim, os estados são trocados (`Commit`) e os mortos são liberados.

A vizinhança de uma célula são as 8 células ao redor.

---

## 2. Tipos de ser

| Tipo | Papel | Come | Sente fome | Vira matéria ao morrer |
|---|---|---|---|---|
| Planta | Produtor | nada | não | sim |
| Herbívoro | Consumidor | planta | sim | sim |
| Carnívoro | Consumidor | herbívoro | sim | sim |
| Bactéria | Decompositor | matéria orgânica | sim | não (apenas some) |
| Matéria orgânica | Resto de ser morto | nada | não | não |

---

## 3. População inicial

No início são semeados, em células vazias sorteadas, bactérias, plantas e herbívoros, nas proporções `PctBacteria`, `PctPlanta` e `PctHerbivoro`.

Os carnívoros entram uma única vez, no ciclo `CicloEntradaCarnivoro`, na proporção `PctCarnivoro`. Se forem extintos, não voltam.

---

## 4. Ordem de um ciclo

1. O contador de ciclo avança.
2. Se for o ciclo de entrada, os carnívoros são semeados.
3. O próximo estado é esvaziado.
4. As células são percorridas (coluna a coluna) e cada ser vivo é processado uma vez.
5. Os estados são trocados e os mortos são liberados.

---

## 5. Processamento de cada ser

Na ordem abaixo.

### 5.1 Idade

A idade aumenta em 1. Ao atingir a vida máxima do tipo:

- planta, herbívoro e carnívoro viram matéria orgânica na própria célula;
- bactéria apenas some.

### 5.2 Matéria orgânica

A matéria não come, não se move e não se reproduz. Quando sua idade atinge `DegradaMateria`, ela vira uma bactéria na própria célula.

### 5.3 Comer

O ser procura uma presa do tipo certo nas 8 células vizinhas, considerando os dois estados do tabuleiro (ou seja, também quem já foi processado no ciclo). Havendo mais de uma, sorteia.

Ao comer:

- a presa morre e some (presa comida não vira matéria orgânica);
- a fome do predador volta a zero;
- o predador fica marcado como alimentado;
- o predador ocupa a célula da presa.

### 5.4 Fome

Herbívoro, carnívoro e bactéria que não comeram no ciclo acumulam 1 de fome. Ao atingir a fome máxima do tipo:

- herbívoro e carnívoro viram matéria orgânica;
- bactéria apenas some.

`FomeBacteria = 0` desliga a fome da bactéria.

### 5.5 Movimento

Herbívoro, carnívoro e bactéria que não comeram no ciclo têm 20% de chance de se mover para uma célula vizinha livre, sorteada. Planta não se move. É no máximo um passo por ciclo.

### 5.6 Reprodução

O contador de reprodução aumenta em 1 a cada ciclo. Quando atinge o valor do tipo e existe célula vizinha livre:

- a planta gera um filho;
- herbívoro, carnívoro e bactéria geram um filho **somente se tiverem comido desde a última reprodução**.

Ao gerar o filho, o contador volta a zero e o ser deixa de estar marcado como alimentado. É no máximo um filho por vez.

---

## 6. Parâmetros

Todos ficam em `TConfig` (`uConfig.pas`). Valores de `ConfigPadrao`:

| Parâmetro | Bactéria | Planta | Herbívoro | Carnívoro |
|---|---|---|---|---|
| Proporção inicial | 8% | 36% | 3% | 2,6% |
| Vida máxima | 13 | 38 | 37 | 74 |
| Fome máxima | 3 | — | 5 | 25 |
| Ciclos para reproduzir | 5 | 3 | 17 | 11 |

- Degradação da matéria orgânica: 7 ciclos.
- Entrada dos carnívoros: ciclo 200.

Com esses valores, os quatro grupos permaneceram vivos aos 10.000 ciclos nas sementes 0 a 9. O equilíbrio depende das regras: ao alterá-las, os valores precisam ser reajustados.

---

## 7. Semente

O motor é determinístico: a mesma `TConfig.Seed` produz sempre a mesma simulação. Na tela, quando `Seed = 0`, uma semente é sorteada a cada nova simulação e exibida no cartão **Semente**.
