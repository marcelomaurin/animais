# Animais — Jogo da Vida Evoluído

**Animais** é uma simulação visual de ecossistema criada em **Lazarus / Free Pascal**, inspirada no clássico **Jogo da Vida**, mas adaptada para representar seres vivos com ciclos de vida, reprodução, movimentação e relações ecológicas simples.

O projeto trabalha com quatro tipos de seres:

- **Bactérias**
- **Plantas**
- **Animais vegetarianos**
- **Animais carnívoros**

A proposta é transformar o conceito tradicional de células vivas/mortas em uma simulação mais rica, onde cada célula pode representar uma espécie diferente e onde o comportamento muda conforme vizinhança, alimento, ameaça e tempo de vida.

---

## Objetivo do projeto

O objetivo do projeto é servir como uma base didática e experimental para estudar:

- simulações celulares;
- autômatos celulares;
- ecossistemas artificiais;
- programação orientada a objetos em Free Pascal;
- manipulação direta de bitmap com `TImage`;
- regras simples de vida, morte, reprodução e movimento.

É um projeto pequeno, mas com potencial para evoluir para uma simulação ecológica mais sofisticada, incluindo estatísticas, configuração visual de parâmetros, exportação de dados e regras evolutivas mais complexas.

---

## Como a simulação funciona hoje

O código principal está concentrado em `unit1.pas`.

A simulação usa um tabuleiro fixo de:

```pascal
BOARD_W = 1000;
BOARD_H = 1000;
```

Ou seja, são **1.000.000 de células** processadas a cada ciclo.

Cada célula possui:

- um tipo (`TTipoSer`);
- uma referência para um objeto da classe `TSer` ou descendente.

Tipos definidos no código:

```pascal
TTipoSer = (tsNone, tsBacteria, tsPlanta, tsVegetariano, tsCarnivoro);
```

Classes existentes:

```pascal
TSer          // classe base
TBacteria     // bactéria
TPlanta       // planta
TVegetariano  // animal vegetariano
TCarnivoro    // animal carnívoro
```

---

## Espécies simuladas

| Tipo | Cor no tabuleiro | Papel na simulação |
|---|---|---|
| Bactéria | Amarelo | Espécie inicial. Reproduz rapidamente e pode morrer por superpopulação. |
| Planta | Verde | Surge depois do início da simulação e serve como alimento para vegetarianos. |
| Vegetariano | Azul | Move-se quando não encontra alimento ou quando há carnívoros próximos. |
| Carnívoro | Vermelho | Alimenta-se de vegetarianos, sofre com fome e tem morte acelerada perto de bactérias. |
| Vazio | Preto | Célula sem ser vivo. |

---

## Ciclo de vida implementado

A cada ciclo, o método `ProximoCiclo` executa a evolução do tabuleiro.

Atualmente o fluxo principal é:

1. Incrementa o contador global de ciclos.
2. Introduz novas espécies em ciclos específicos:
   - ciclo 100: planta;
   - ciclo 200: vegetariano;
   - ciclo 300: carnívoro.
3. Incrementa os contadores de vida e reprodução de cada ser.
4. Analisa a vizinhança de cada célula.
5. Decide se o ser morre, reproduz ou se move.
6. Redesenha o bitmap no `TImage`.

---

## Regras atuais por espécie

### Bactéria

- Criada inicialmente em aproximadamente 20% do tabuleiro.
- Vida máxima: 1 ciclo.
- Reprodução: a cada 1 ciclo.
- Morre quando possui mais de 3 vizinhos.
- Reproduz ocupando células vazias ao redor.

### Planta

- Introduzida no ciclo 100.
- Vida máxima: 10 ciclos.
- Reprodução: a cada 3 ciclos.
- Reproduz em células vazias ao redor.

### Vegetariano

- Introduzido no ciclo 200.
- Vida máxima: 20 ciclos.
- Reprodução: a cada 6 ciclos.
- Procura plantas na vizinhança.
- Move-se quando não encontra alimento.
- Move-se quando há carnívoro próximo.

### Carnívoro

- Introduzido no ciclo 300.
- Vida máxima: 40 ciclos.
- Reprodução: a cada 12 ciclos.
- Procura vegetarianos na vizinhança.
- Move-se quando não encontra alimento.
- Morre após ciclos sem alimento.
- Tem morte acelerada quando há bactérias próximas.

---

## Interface

A interface gráfica possui:

- área visual do tabuleiro (`TImage`);
- botão **Iniciar**;
- botão **Pausar**;
- botão **Parar**;
- temporizador (`TTimer`) para avançar os ciclos.

O título da janela exibe o número de ciclos processados.

---

## Como executar

### Requisitos

- Lazarus IDE;
- Free Pascal Compiler;
- LCL instalada;
- ambiente gráfico compatível com aplicações Lazarus.

O arquivo `unit1.lfm` indica uso de Lazarus/LCL 4.0.0.4, mas o projeto deve ser revisado no ambiente local antes de empacotamento.

### Passos básicos

1. Clone o repositório:

```bash
git clone https://github.com/marcelomaurin/animais.git
```

2. Abra o projeto no Lazarus.
3. Compile o projeto.
4. Execute a aplicação.
5. Use os botões **Iniciar**, **Pausar** e **Parar** para controlar a simulação.

---

## Observações técnicas importantes

A análise dos fontes mostrou alguns pontos que merecem atenção antes de tratar o projeto como versão final:

- `unit1.pas` declara `TForm1`, mas `unit1.lfm` declara `Form2: TForm2`.
- O arquivo `.lfm` não mostra os eventos `OnClick` dos botões ligados aos métodos do código.
- O tabuleiro 1000x1000 usa muitos objetos e pode exigir otimização.
- O controle de fome do carnívoro usa uma matriz local dentro do ciclo, o que pode não preservar estado entre chamadas.
- A documentação anterior citava instintos `Come` e `Mata`, mas essas propriedades não aparecem no fonte atual analisado.

Esses pontos não anulam a ideia do projeto, mas indicam que ele está em fase experimental e precisa de revisão técnica para ficar mais estável.

---

## Documentação complementar

A documentação detalhada está na pasta [`docs`](docs/):

- [`docs/GUIA_USUARIO.md`](docs/GUIA_USUARIO.md) — guia simples para executar e entender a simulação.
- [`docs/GUIA_DESENVOLVEDOR.md`](docs/GUIA_DESENVOLVEDOR.md) — explicação técnica do código e da arquitetura.
- [`docs/ANALISE_TECNICA.md`](docs/ANALISE_TECNICA.md) — análise crítica dos pontos fortes, limitações e melhorias recomendadas.

---

## Roadmap sugerido

Para tornar o projeto mais apresentável e comercialmente mais forte, os próximos passos recomendados são:

1. Corrigir a divergência entre `TForm1` e `TForm2`.
2. Garantir que os eventos dos botões estejam ligados corretamente no `.lfm`.
3. Adicionar tela de configuração dos parâmetros da simulação.
4. Criar painel estatístico com quantidade de seres por espécie.
5. Permitir escolher tamanho do tabuleiro.
6. Otimizar memória e desempenho.
7. Exportar dados da simulação em CSV.
8. Adicionar gráficos de evolução populacional.
9. Criar versão demonstrativa com instalador.
10. Incluir imagens ou GIFs no README.

---

## Autor

Projeto criado por **Marcelo Maurin Martins**.

GitHub: [marcelomaurin](https://github.com/marcelomaurin)

---

## Licença

Este repositório ainda não possui arquivo de licença identificado na análise atual. Recomenda-se adicionar uma licença, como MIT, GPL ou outra compatível com o objetivo do projeto.
