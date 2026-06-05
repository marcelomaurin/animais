# Guia do Desenvolvedor — Animais

Este documento descreve a estrutura técnica do projeto **Animais**, com base na análise dos fontes atuais.

---

## Visão geral da arquitetura

O projeto é uma aplicação gráfica Lazarus / Free Pascal que simula um ecossistema celular.

O código principal analisado está em:

- `unit1.pas` — lógica da simulação, classes, tabuleiro e interface.
- `unit1.lfm` — definição visual do formulário.
- `README.md` — documentação principal.

A aplicação usa:

- `TForm` para a janela principal;
- `TImage` para renderizar o tabuleiro;
- `TTimer` para avançar os ciclos;
- `TButton` para controlar execução;
- `TBitmap.ScanLine` para desenhar pixels diretamente.

---

## Constantes principais

```pascal
const
  BOARD_W = 1000;
  BOARD_H = 1000;
```

Essas constantes definem o tamanho fixo do tabuleiro.

O tabuleiro possui 1.000.000 de células. Isso impacta diretamente memória e desempenho.

---

## Tipos principais

```pascal
TTipoSer = (tsNone, tsBacteria, tsPlanta, tsVegetariano, tsCarnivoro);
```

Esse enum define os possíveis estados de uma célula.

| Tipo | Descrição |
|---|---|
| `tsNone` | célula vazia |
| `tsBacteria` | bactéria |
| `tsPlanta` | planta |
| `tsVegetariano` | animal vegetariano |
| `tsCarnivoro` | animal carnívoro |

---

## Classe base `TSer`

A classe `TSer` representa qualquer ser vivo da simulação.

Campos principais:

```pascal
CicloVidaMax   : Integer;
CicloReproMax  : Integer;
CicloVidaAtual : Integer;
CicloReproAtual: Integer;
```

Responsabilidades:

- armazenar tempo máximo de vida;
- armazenar ciclo necessário para reprodução;
- contar idade atual;
- contar tempo desde a última reprodução.

Métodos:

```pascal
constructor Create(ALife, ARepro: Integer);
procedure ResetCounters;
```

---

## Classes específicas

Atualmente as classes específicas herdam de `TSer`, mas não implementam métodos próprios:

```pascal
TBacteria     = class(TSer);
TPlanta       = class(TSer);
TVegetariano  = class(TSer);
TCarnivoro    = class(TSer);
```

As regras específicas de cada espécie estão concentradas no método `TTabuleiro.ProximoCiclo`.

### Melhoria recomendada

Para melhorar a arquitetura, cada espécie poderia implementar seu próprio comportamento, por exemplo:

```pascal
procedure ProcessarCiclo(ATabuleiro: TTabuleiro; AX, AY: Integer); virtual;
```

Isso reduziria o tamanho do `case` central e deixaria o projeto mais orientado a objetos.

---

## Registro `TCelula`

```pascal
TCelula = record
  Tipo : TTipoSer;
  Ent  : TSer;
end;
```

Cada célula guarda:

- o tipo do ser;
- a instância do objeto correspondente.

Quando a célula está vazia:

```pascal
Tipo = tsNone
Ent = nil
```

---

## Classe `TTabuleiro`

A classe `TTabuleiro` concentra o estado e a lógica da simulação.

Campos principais:

```pascal
FCiclos : Int64;
Board   : array[0..BOARD_W-1, 0..BOARD_H-1] of TCelula;
```

Métodos principais:

| Método | Função |
|---|---|
| `Create` | cria o tabuleiro, zera e inicializa bactérias |
| `Destroy` | libera os objetos existentes no tabuleiro |
| `Zera` | limpa o tabuleiro |
| `InicializaBacterias` | cria bactérias aleatórias no início |
| `ColocaNovoSer` | coloca um novo ser em uma posição |
| `Libera` | remove e libera o ser de uma célula |
| `Reproduz` | tenta reproduzir em células vizinhas vazias |
| `MoveAnimal` | move o ser para uma célula vizinha vazia |
| `ProximoCiclo` | executa a evolução completa do tabuleiro |

---

## Inicialização

No construtor do tabuleiro:

```pascal
Zera;
InicializaBacterias;
```

A função `InicializaBacterias` percorre todo o tabuleiro e cria bactérias com probabilidade de 20%:

```pascal
if Random < 0.2 then
```

Isso significa que, em um tabuleiro 1000x1000, a simulação pode começar com aproximadamente 200.000 bactérias.

---

## Criação de seres

O método `ColocaNovoSer` cria os objetos conforme o tipo:

```pascal
tsBacteria     : TBacteria.Create(1,1);
tsPlanta       : TPlanta.Create(10,3);
tsVegetariano  : TVegetariano.Create(20,6);
tsCarnivoro    : TCarnivoro.Create(40,12);
```

Parâmetros usados:

| Espécie | Vida máxima | Ciclo de reprodução |
|---|---:|---:|
| Bactéria | 1 | 1 |
| Planta | 10 | 3 |
| Vegetariano | 20 | 6 |
| Carnívoro | 40 | 12 |

---

## Reprodução

O método `Reproduz` percorre os oito vizinhos da célula atual.

Se encontrar célula vazia, cria um novo ser do mesmo tipo.

Ponto de atenção: no formato atual, a reprodução pode ocupar múltiplas células vizinhas em um único ciclo, pois não há limite de apenas um descendente por reprodução.

---

## Movimento

O método `MoveAnimal` procura células vazias ao redor e escolhe uma aleatoriamente.

Fluxo:

1. lista vizinhos vazios;
2. sorteia um destino;
3. cria o mesmo tipo no destino;
4. libera a célula original.

Ponto de atenção: o movimento recria o objeto e perde os contadores internos do ser original. Se a intenção for preservar idade e reprodução, o ideal é mover a referência do objeto em vez de criar uma nova.

---

## Processamento do ciclo

O método `ProximoCiclo` é o coração da simulação.

Ele realiza:

1. incremento de `FCiclos`;
2. introdução de novas espécies nos ciclos 100, 200 e 300;
3. incremento dos contadores de vida e reprodução;
4. análise da vizinhança;
5. aplicação das regras de morte, reprodução e movimento.

---

## Renderização

O desenho é feito em `TForm1.Desenha` usando `ScanLine`:

```pascal
Line := bmp.ScanLine[y];
Line[x] := c;
```

Mapeamento de cores:

```pascal
tsBacteria    : c := $00FFFF;
tsPlanta      : c := $00FF00;
tsVegetariano : c := $0000FF;
tsCarnivoro   : c := $FF0000;
else            c := $000000;
```

Observação: os comentários indicam cores em formato BGR.

---

## Pontos técnicos que precisam revisão

### 1. Divergência entre `TForm1` e `TForm2`

`unit1.pas` declara:

```pascal
TForm1 = class(TForm)
```

Mas `unit1.lfm` declara:

```pascal
object Form2: TForm2
```

Isso precisa ser normalizado para evitar erro de carregamento do formulário.

### 2. Eventos dos botões no `.lfm`

O `.lfm` analisado não apresenta `OnClick` nos botões.

Os métodos existem no Pascal:

```pascal
btnStartClick
btnPauseClick
btnStopClick
```

Mas os botões precisam apontar para esses eventos no Lazarus.

### 3. Controle de fome do carnívoro

A matriz abaixo é local dentro de `ProximoCiclo`:

```pascal
carnivoreHunger: array[0..BOARD_W-1, 0..BOARD_H-1] of Integer;
```

Por ser local, ela pode não preservar corretamente o estado entre ciclos. O ideal é transformar esse dado em campo persistente do tabuleiro ou em propriedade do próprio ser.

### 4. Alto consumo de memória

O uso de um milhão de células, com possíveis centenas de milhares de objetos, pode pesar em máquinas simples.

Possíveis soluções:

- reduzir o tabuleiro durante desenvolvimento;
- usar registros em vez de objetos para cada célula;
- armazenar apenas células ocupadas em estrutura esparsa;
- separar lógica e renderização;
- processar por blocos.

### 5. Movimento recriando objeto

`MoveAnimal` cria novo objeto no destino, em vez de mover o existente. Isso simplifica o código, mas altera o comportamento biológico da simulação.

---

## Melhorias recomendadas na arquitetura

1. Criar uma unit separada para modelos de seres.
2. Criar uma unit separada para o tabuleiro.
3. Criar uma unit separada para renderização.
4. Criar configuração externa de parâmetros.
5. Adicionar estatísticas populacionais.
6. Criar testes unitários das regras.
7. Adicionar botão para gerar população inicial personalizada.
8. Permitir salvar/carregar estado da simulação.

---

## Estrutura sugerida futura

```text
animais/
├── README.md
├── docs/
│   ├── GUIA_USUARIO.md
│   ├── GUIA_DESENVOLVEDOR.md
│   └── ANALISE_TECNICA.md
├── src/
│   ├── animais.lpr
│   ├── uMain.pas
│   ├── uMain.lfm
│   ├── uSeres.pas
│   ├── uTabuleiro.pas
│   ├── uRender.pas
│   └── uConfig.pas
└── samples/
    └── configuracoes_exemplo/
```

---

## Conclusão técnica

O projeto já possui uma ideia funcional e didática: transformar o Jogo da Vida em um ecossistema com espécies diferentes.

A lógica principal está implementada, mas concentrada em uma única unit. Para crescer, o projeto deve separar responsabilidades, corrigir inconsistências de formulário e melhorar o controle de estado das espécies.
