# Plano de construção — Ecossistema simplificado (Lazarus / Free Pascal)

Instruções para um agente de código. Execute **uma etapa por vez**, na ordem.
Ao fim de cada etapa: **compile e rode** o teste indicado antes de seguir.
Não avance se a etapa anterior não compilar.

## Princípios inegociáveis (valem para todas as etapas)

- **5 tipos apenas:** `tNada, tBacteria, tPlanta, tHerbivoro, tCarnivoro, tMateria`.
- **Um passo de movimento por ciclo.** Proibido loop de multi-movimento.
- **Duplo buffer** (`FBoard` / `FNextBoard`). Cada entidade escreve em **no máximo uma** célula do `FNextBoard` por ciclo.
- **Nunca liberar (`Free`) um objeto no meio da varredura do ciclo.** Marque `Morto := True` e libere só na fase de commit.
- **Dono único:** um `TSer` pertence ao buffer onde está fisicamente. Nunca deixe o mesmo ponteiro nos dois buffers.
- **Seed fixa:** chame `RandSeed := Seed` uma vez in `Inicializar` e nunca mais.
- Sem toxicidade, veneno, resistência, mutação, mutualismo, tamanho ou subespécies. Se aparecer, é escopo errado.

---

## Etapa 1 — Tipos base (`uTipos.pas`)

**Objetivo:** definir o enum e a classe `TSer` enxuta.

Criar `TTipo = (tNada, tBacteria, tPlanta, tHerbivoro, tCarnivoro, tMateria)`.
Criar classe `TSer` com campos públicos: `Tipo: TTipo; Idade, VidaMax, Fome, FomeMax, Repro, ReproMax: Integer; Morto: Boolean;` e um construtor que recebe `(ATipo, AVidaMax, AFomeMax, AReproMax)` e zera `Idade/Fome/Repro/Morto`.

**Validação:** criar um programa `teste1.lpr` que instancia um `TSer`, imprime os campos e libera. Compilar e rodar sem erro nem vazamento.

---

## Etapa 2 — Tabuleiro com duplo buffer (`uTabuleiro.pas`)

**Objetivo:** grade 2D segura, sem double-free.

Classe `TTabuleiro` com `FBoard, FNextBoard: array of array of TSer;` e `FW, FH: Integer`.
Métodos:
- `SetTamanho(AW, AH)` — aloca os dois buffers com `nil`.
- `InBounds(x,y): Boolean`.
- `GetSer(x,y): TSer` (do `FBoard`); fora dos limites ? `nil`.
- `GetSerNext(x,y): TSer` (do `FNextBoard`).
- `CelulaLivreNext(x,y): Boolean` — `True` se `FNextBoard[x,y] = nil`.
- `PrepararProximo` — apenas põe `nil` em todo o `FNextBoard` (NÃO libera; os objetos vivos migram).
- `Mover(x,y,nx,ny): Boolean` — se `CelulaLivreNext(nx,ny)`, move o ponteiro de `FBoard[x,y]` para `FNextBoard[nx,ny]`, põe `FBoard[x,y] := nil`, retorna `True`; senão `False`.
- `Colocar(ser, x, y)` — grava em `FNextBoard[x,y]` (assume livre).
- `Commit` — troca os dois buffers; depois percorre o **novo** `FNextBoard` (que é o antigo board) e para cada célula `<> nil`: libera **somente se** `Morto = True`, senão apenas põe `nil` (o objeto já migrou para o board ativo). Ao final todo o `FNextBoard` fica `nil`.
- `Destroy` — libera tudo que sobrar nos dois buffers.

**Regra de ouro do commit:** um objeto que sobreviveu está no board ativo E não deve aparecer no buffer antigo; garanta isso movendo ponteiros (nunca copiando).

**Validação:** `teste2.lpr` cria tabuleiro 5×5, coloca um ser, faz `PrepararProximo`, `Mover`, `Commit`, confirma que o ser está na posição nova e a antiga é `nil`. Rodar 100 ciclos de mover em vazio e conferir com uma ferramenta de heap (ou contagem manual de `Create`/`Free`) que não há vazamento.

---

## Etapa 3 — Configuração (`uConfig.pas`)

**Objetivo:** um único `record` com todos os números ajustáveis (sem espalhar constantes).

`TConfig = record` com: `Largura, Altura, Seed: Integer;` percentuais iniciais `PctBacteria, PctPlanta, PctHerbivoro, PctCarnivoro: Double;` vidas `VidaBacteria, VidaPlanta, VidaHerbivoro, VidaCarnivoro: Integer;` fome `FomeHerbivoro, FomeCarnivoro: Integer;` reprodução `ReproPlanta, ReproHerbivoro, ReproCarnivoro, ReproBacteria: Integer;` `DegradaMateria: Integer;` `CicloEntradaCarnivoro: Integer;`
Função `ConfigPadrao: TConfig` com os valores sugeridos:
grade 80×80, seed 0; PctBacteria 0.08, PctPlanta 0.15, PctHerbivoro 0.02, PctCarnivoro 0.005; vidas 10/40/25/50; fome 8/12; repro planta 4, herbívoro 8, carnívoro 14, bactéria 3; degrada matéria em 5; carnívoro entra no ciclo 200.

**Validação:** `teste3.lpr` imprime `ConfigPadrao`. Compila e roda.

---

## Etapa 4 — Semeadura inicial (`uSimulacao.pas`, parte 1)

**Objetivo:** classe `TSimulacao` que cria o tabuleiro e o popula.

`TSimulacao` guarda `FTab: TTabuleiro; FCfg: TConfig; FCiclo: Int64;`.
- `Create(const ACfg)` — guarda config, cria tabuleiro, `RandSeed := ACfg.Seed`, chama `Semear`.
- `Semear` — para cada tipo, calcula `round(Pct * W * H)` indivíduos e coloca em células aleatórias vazias do `FBoard` (tentativas limitadas). Carnívoro **não** é semeado aqui (entra depois).
- `Destroy` — libera o tabuleiro.
- Propriedades de leitura: `Tabuleiro`, `Ciclo`.

**Validação:** `teste4.lpr` cria a simulação, varre o board e imprime a contagem por tipo. Os números batem aproximadamente com os percentuais.

---

## Etapa 5 — O ciclo, regra por regra (`uSimulacao.pas`, parte 2)

**Objetivo:** `ExecutarCiclo` implementando a regra simplificada. Uma sub-rotina por comportamento, para facilitar teste.

`ExecutarCiclo`:
1. `Inc(FCiclo)`.
2. Se `FCiclo = Cfg.CicloEntradaCarnivoro`, semear carnívoros.
3. `FTab.PrepararProximo`.
4. Varrer todo o board; para cada célula com ser `<> nil` e `not Morto`, chamar `ProcessarCelula(x,y)`.
5. `FTab.Commit`.

`ProcessarCelula(x,y)` na ordem exata:
1. **Idade:** `Inc(ser.Idade)`. Se `ser.Idade >= ser.VidaMax` ? `MorrerVirandoMateria(x,y)` e sair (bactéria e matéria apenas somem, não viram matéria).
2. **Comer** (só herbívoro/carnívoro): procurar nas 8 vizinhas uma presa válida (herbívoro?planta; carnívoro?herbívoro; bactéria?matéria). Se achar, marcar a presa `Morto := True`, zerar `ser.Fome`. Herbívoro/carnívoro que comeu não precisa mais checar fome neste ciclo.
3. **Fome:** se é animal e não comeu, `Inc(ser.Fome)`; se `ser.Fome >= FomeMax` ? `MorrerVirandoMateria` e sair.
4. **Mover:** UM passo. Se há alvo/comida adjacente conhecida, mover 1 casa na direção (via `Mover`); senão, com 20% de chance, mover para uma vizinha livre aleatória; senão ficar parado (mas ainda assim migrar para o `FNextBoard` na mesma posição via `Mover(x,y,x,y)`).
5. **Reproduzir:** `Inc(ser.Repro)`; se `ser.Repro >= ReproMax` e existe vizinha livre no `FNextBoard`, criar 1 filho do mesmo tipo lá e zerar `ser.Repro`.
6. **Matéria orgânica:** usar `Idade` como contador de degradação; ao passar de `DegradaMateria`, virar `tBacteria` (fecha o ciclo). Bactéria tem seu próprio ciclo de vida/reprodução.

`MorrerVirandoMateria(x,y)`: se o ser é planta/herbívoro/carnívoro, transformar a célula em `tMateria` (reaproveitar o objeto: mudar `Tipo := tMateria`, zerar `Idade`); se bactéria ou matéria, marcar `Morto := True`.

**Cuidado central:** todo objeto que sobrevive precisa ser migrado ao `FNextBoard` por `Mover` (mesmo parado). Quem não for migrado e não estiver `Morto` seria perdido — garanta que todo caminho termina em `Mover` ou em morte.

**Validação:** `teste5.lpr` roda 500 ciclos imprimindo a contagem por tipo a cada 50. Critério de sucesso: **nenhum crash**, populações oscilam mas não zeram todas de imediato nem estouram para 100% da grade.

---

## Etapa 6 — Estatísticas mínimas (`uEstat.pas`)

**Objetivo:** contagem por tipo e por ciclo, sem as 15 subespécies.

`record TEstat = (Ciclo: Int64; Bacterias, Plantas, Herbivoros, Carnivoros, Materia, Vazios: Integer)`.
Função em `TSimulacao`: `Contar: TEstat` varre o board uma vez.

**Validação:** `teste6.lpr` roda 200 ciclos e escreve um CSV `historico.csv` (ciclo, contagens). Abrir e conferir que tem 200 linhas coerentes.

---

## Etapa 7 — Ajuste de equilíbrio (sem código novo)

**Objetivo:** achar parâmetros em que o ecossistema dura = 2000 ciclos sem extinção total.

Rodar `teste6` variando na `TConfig`: se herbívoros somem cedo, aumentar `PctPlanta` ou `FomeHerbivoro`; se plantas tomam tudo, reduzir `ReproPlanta` (número maior = reproduz menos). Registrar o conjunto que estabiliza como novo `ConfigPadrao`.

**Validação:** uma execução de 2000 ciclos termina com pelo menos plantas + herbívoros vivos.

---

## Etapa 8 — Interface visual (`form1` — só depois que a lógica estiver estável)

**Objetivo:** desenhar a grade e um Play/Pause. A lógica **não muda**.

Um `TForm` com `TImage`/`TPaintBox` e um `TTimer`. A cada tick do timer: `Sim.ExecutarCiclo` e redesenhar. Cores fixas: bactéria amarelo, planta verde, herbívoro azul, carnívoro vermelho, matéria marrom, vazio preto. Botões Play/Pause/Reiniciar. Um `TLabel` com o ciclo e as contagens de `Contar`.

**Validação:** abre, roda visualmente fluido em 80×80, sem travar a UI. Se travar, reduzir grade ou aumentar intervalo do timer — nunca voltar a mexer na lógica.

---

## Ordem de dependência (resumo)

```
uTipos ➔ uTabuleiro ➔ uConfig ➔ uSimulacao(semear) ➔ uSimulacao(ciclo) ➔ uEstat ➔ ajuste ➔ GUI
   1          2           3             4                     5              6         7        8
```

Cada arquivo de teste (`testeN.lpr`) é descartável e serve só para validar a etapa. A GUI é a última coisa: só entra quando as etapas 1–7 estiverem sólidas.
