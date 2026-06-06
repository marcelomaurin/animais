# Regras do Jogo da Vida Modificado — Animais

Este documento detalha o conjunto de regras lógicas e biológicas que regem a evolução e a dinâmica de populações na simulação.

---

## 1. Tabuleiro e Estrutura Espacial
O ecossistema é representado por uma grade retangular bidimensional de células (tabuleiro). O tamanho é dinâmico e configurável através do painel de opções da simulação (sugestões de `200x200`, `500x500` ou `1000x1000`).

Cada coordenada do tabuleiro representa uma célula discreta que pode conter:
* Um espaço vazio (tsNone);
* Uma instância ativa de uma espécie de ser vivo (`TSer`).

---

## 2. As Espécies e seus Atributos

### 🟡 Bactéria (`tsBacteria`)
* **Papel**: Base microbiana inicial.
* **Ciclo de Vida (Idade Máxima)**: 1 ciclo.
* **Maturidade Reprodutiva**: 2 ciclos.
* **Comportamento**: Extremamente prolífica, mas sensível à superpopulação.

### 🟢 Planta (`tsPlanta`)
* **Papel**: Produtor primário (alimento para vegetarianos).
* **Ciclo de Vida (Idade Máxima)**: 10 ciclos.
* **Maturidade Reprodutiva**: 4 ciclos.
* **Comportamento**: Depende de bactérias próximas para sua reprodução. Não sofre de fome.

### 🔵 Vegetariano (`tsVegetariano`)
* **Papel**: Consumidor primário (presa).
* **Ciclo de Vida (Idade Máxima)**: 20 ciclos.
* **Maturidade Reprodutiva**: 8 ciclos.
* **Alimento**: Plantas (`tsPlanta`) ou Bactérias (`tsBacteria`).
* **Comportamento**: Move-se ao não encontrar alimento ou ao avistar carnívoros.

### 🔴 Carnívoro (`tsCarnivoro`)
* **Papel**: Predador topo de cadeia.
* **Ciclo de Vida (Idade Máxima)**: 40 ciclos.
* **Maturidade Reprodutiva**: 12 ciclos.
* **Alimento**: Vegetarianos (`tsVegetariano`).
* **Comportamento**: Envelhece três vezes mais rápido se houver bactérias na vizinhança. Morre rapidamente se privado de presas.

---

## 3. Dinâmica Temporal e Concorrência
A simulação avança em passos discretos (ciclos) sincronizados por um timer. Para garantir integridade e evitar inconsistências computacionais:
1. **Varredura Isolada**: Durante o ciclo, todos os contadores, vizinhanças e tomadas de decisão são calculados utilizando a grade atual estática (`BoardAtual`).
2. **Double Buffering**: Os resultados das ações (nascimentos, mortes, movimentações) são gravados em uma grade secundária de escrita (`BoardProximo`).
3. **Sincronização**: Ao final do ciclo, as referências das grades são trocadas (swap) e as células mortas são permanentemente eliminadas da memória RAM.

---

## 4. Regras de Sobrevivência e Fome

Animais e bactérias devem possuir controle persistente de fome, com limites configuráveis por espécie.

### Mecanismo de Starvation
A cada ciclo, se um ser vivo com fome obrigatória **não** conseguir se alimentar na sua vizinhança imediata, o seu contador interno `CiclosSemComida` é incrementado. Caso ele encontre alimento e se alimente, o contador é imediatamente zerado.

Se o contador `CiclosSemComida` atingir o limite estipulado para a espécie, o ser morre por inanição.

### Limites Padrão de Fome
* **Carnívoro**: 2 ciclos sem comida (predadores morrem de fome muito rapidamente se não caçarem).
* **Vegetariano**: 3 ciclos sem comida (herbívoros resistem um pouco mais procurando vegetação).
* **Bactéria**: 6 ciclos (valor padrão preparado para evolução futura. Nesta versão, a fome real para bactérias está desativada por padrão, sendo controladas pelo ciclo de vida fixo).
* **Planta**: Isenta (plantas realizam fotossíntese abstrata e não morrem de fome).

---

## 5. Regras de Reprodução Estocástica

A reprodução é individualizada e controlada por probabilidade e capacidade de descendência por ciclo.

### Parâmetros Reprodutivos por Espécie
| Espécie | Max Descendentes / Ciclo | Ciclos para Maturidade | Chance de Sucesso |
|---|---:|---:|---:|
| **Bactéria** | 4 | 2 | 80% |
| **Planta** | 3 | 4 | 65% |
| **Vegetariano** | 1 | 8 | 35% |
| **Carnívoro** | 1 | 12 | 20% |

### Regras Operacionais de Reprodução
Quando um ser atinge a sua maturidade reprodutiva (idade reprodutiva atual maior ou igual aos ciclos configurados):
1. **Verificação de Fome**: Animais famintos (`CiclosSemComida > 0`) têm sua reprodução completamente bloqueada.
2. **Verificação Ambiental (Vegetariano)**: O vegetariano só se reproduz se houver pelo menos uma Planta (`tsPlanta`) em sua vizinhança.
3. **Verificação Ambiental (Planta)**: A planta só se reproduz se existir pelo menos uma Bactéria (`tsBacteria`) em sua vizinhança.
4. **Proteção contra Superpopulação**: Se o preenchimento total do tabuleiro for maior ou igual ao limite de ocupação global de **85%** (`PercentualMaximoOcupacao = 0.85`), a reprodução de todas as espécies é suspensa.
5. **Geração**: Se a chance estocástica da espécie for bem-sucedida, o sistema mapeia os vizinhos livres, embaralha a lista aleatoriamente e gera até `MaxDescendentes` novos seres, resetando o contador de reprodução do progenitor.

---

## 6. Regras de Movimento
* Apenas animais (**Vegetarianos** e **Carnívoros**) se movem.
* Um animal se move se não encontrou alimento no ciclo ou se estiver sob estresse (no caso do vegetariano, se houver um carnívoro por perto).
* O animal escolhe uma célula vazia aleatória na sua vizinhança de 8 células e move-se para lá, mantendo intactos seus contadores de idade, ciclo reprodutivo e fome acumulada.

---

## 7. Mutações e Evolução (Seção 22)
A cada **100 gerações** (ciclos múltiplos de 100), o sistema avalia a possibilidade de ocorrer uma mutação aleatória ao nascer para novos seres (Opção B - Mutação no nascimento). A mutação é governada por chances individuais configuráveis na simulação (padrão de 10%).

### As Características Evolutivas e Subespécies
Os indivíduos continuam pertencendo aos enums principais (`tsBacteria`, `tsPlanta`, `tsVegetariano`, `tsCarnivoro`), mas adquirem características secundárias que formam as **subespécies**:
1. **Tamanho Animal** (`taPequeno`, `taMedio`, `taGrande`)
2. **Toxicidade** (`txNenhuma`, `txToxica`)
3. **Resistência a Veneno** (`rvNenhuma`, `rvResistente`)
4. **Resistência a Toxina Bacteriana** (`rtNenhuma`, `rtResistente`)

### Regras de Interação Ecológica
* **Plantas Venenosas**: Plantas comuns mutam para venenosas (`txToxica`). Herbívoros sem resistência morrem instantaneamente de veneno ao comê-las. Herbívoros resistentes comem-nas normalmente.
* **Herbívoros Grandes Protegidos**: Um carnívoro não pode predar um vegetariano de tamanho maior que o seu.
* **Cadeia Alimentar de Carnívoros**: Carnívoros maiores podem caçar e comer carnívoros menores.
* **Bactérias Tóxicas**: Bactérias com toxicidade (`txToxica`) aceleram o envelhecimento de plantas comuns adjacentes. Plantas resistentes à toxina bacteriana (`rtResistente`) não sofrem essa penalidade.

---

## 8. Monitoramento de Biodiversidade e Extinção (Seção 23)
O ecossistema rastreia continuamente a sobrevivência e extinção das espécies e subespécies:
* **Espécie/Subespécie Viva**: Tem pelo menos 1 indivíduo ativo no tabuleiro.
* **Espécie/Subespécie Extinta**: A quantidade atual de indivíduos vivos é 0, mas já existiu pelo menos um indivíduo ativo anteriormente na simulação (não se consideram extintas as subespécies que nunca surgiram).
* **Ciclo de Extinção**: O exato ciclo em que a contagem de vivos de uma subespécie caiu para 0 após ter existido.
* **Morte por Causa**: Toda morte é processada e contabilizada sob causas específicas: Idade, Fome, Predação, Veneno, Toxina, Aleatória ou Conflito.

