# Análise Técnica — Animais

Este documento registra a análise técnica da versão atual do projeto **Animais**.

A versão atual é uma simulação simplificada de ecossistema em grade 2D, desenvolvida em Lazarus / Free Pascal, com integração inicial ao pacote `openai_simulation` da biblioteca `CHATGPT`.

---

## 1. Diagnóstico geral

O projeto está em uma fase funcional e didática.

Ele demonstra bem:

- simulação por ciclos;
- entidades em grade 2D;
- relação simples presa/recurso;
- entrada tardia de predadores;
- transformação de mortos em matéria orgânica;
- degradação da matéria orgânica em bactéria;
- uso de duplo buffer para reduzir inconsistência durante o ciclo;
- integração inicial com `TAISimEntity`.

Por outro lado, a documentação antiga descrevia recursos que não estão no código atual, como subespécies, gráficos históricos, relatórios avançados, mutações complexas e telas de configuração. Esses itens devem ser tratados como evolução futura, não como funcionalidade existente.

---

## 2. Arquitetura real do projeto

A arquitetura atual é pequena e direta:

| Arquivo | Papel |
|---|---|
| `animal.lpr` | Inicializa a aplicação Lazarus. |
| `animal.lpi` | Define o projeto e a dependência do pacote `openai_simulation`. |
| `form2.pas` / `form2.lfm` | Interface visual desenhada em código, timer, histórico e exportação. |
| `uFormConfig.pas` | Tela de configurações. |
| `uTipos.pas` | Define `TTipo` e `TSer`, herdando de `TAISimEntity`. |
| `uConfig.pas` | Configuração estática da simulação. |
| `uTabuleiro.pas` | Grade 2D com `FBoard` e `FNextBoard`. |
| `uSimulacao.pas` | Motor ecológico e regras de ciclo. |
| `uEstat.pas` | Record de contagem populacional. |

---

## 3. Pontos positivos

### 3.1 Integração inicial com `CHATGPT / openai_simulation`

O projeto já depende do pacote `openai_simulation` no `.lpi` e a classe `TSer` herda de `TAISimEntity`.

Isso torna o projeto um exemplo mínimo de integração com a biblioteca `CHATGPT` e abre caminho para evoluir a simulação usando componentes como:

- `TAIGridWorld`;
- `TAIGridCell`;
- `TAIMovementEngine`;
- `TAIRuleEngine`;
- `TAISimulationStats`;
- `TAIScenarioConfig`.

### 3.2 Separação mínima de responsabilidades

A lógica não está toda no formulário. O projeto já separa:

- tipos;
- configuração;
- tabuleiro;
- simulação;
- estatísticas;
- interface.

Isso facilita evolução posterior.

### 3.3 Duplo buffer

O uso de `FBoard` e `FNextBoard` reduz o problema clássico de atualizar uma grade diretamente enquanto ela está sendo percorrida.

Esse padrão evita que uma entidade processada no começo do ciclo seja processada novamente no mesmo ciclo após se mover.

### 3.4 Regras ecológicas simples e compreensíveis

As regras atuais são fáceis de entender:

- herbívoros comem plantas;
- carnívoros comem herbívoros;
- bactérias comem matéria orgânica;
- morte por idade ou fome;
- reprodução por contador;
- movimento aleatório básico.

Isso torna o projeto bom como demo didático.

---

## 4. Pontos críticos encontrados

### 4.1 Documentação antiga estava fora da realidade

A documentação anterior descrevia:

- subespécies;
- gráficos por aba;
- histórico completo;
- relatórios `exemplo_saida.csv` e `biodiversidade.csv`;
- mutações avançadas;
- configuração visual;
- renderização por `ScanLine`.

O código atual não implementa esses recursos.

Essa divergência foi corrigida na documentação atual, mas é importante manter a regra: **documentar apenas o que existe no código**.

### 4.2 Busca de presa em apenas 4 direções (corrigido)

`ObterPreyAdjacente` consultava somente `FBoard`. Como os vizinhos já processados no ciclo já tinham migrado para `FNextBoard`, herbívoros e carnívoros só comiam para a direita e para baixo, e derivavam nesse sentido.

Correção aplicada: `TTabuleiro.GetSerVivo` olha os dois estados, e `MarcarMorto` mata também quem já migrou, liberando esses seres no `Commit` pela lista `FMortos`.

### 4.3 Correções pequenas já aplicadas

- `TTabuleiro.Mover` inicia `Result := False`.
- `TForm2.FormDestroy` libera `FSimulacao`.
- O desenho acompanha o redimensionamento da janela.
- O painel mostra matéria orgânica e células vazias separadamente.
- A tela sorteia a semente a cada nova simulação.
- Reprodução de animais e bactérias depende de alimentação; bactéria tem fome.
- `ConfigPadrao` foi reajustado para as regras atuais.

### 4.4 Interface refeita

A tela principal passou a ser desenhada por inteiro em um `TPaintBox`, com tema escuro, painel de população, gráfico de histórico, avanço por ciclo e controle de velocidade. A configuração ganhou tela própria (`uFormConfig.pas`) e a exportação grava o histórico completo.

Pontos de atenção que ficaram:

- os botões da tela principal não são controles da LCL (sem foco por teclado, fora do editor de formulários);
- as configurações alteradas não são gravadas em disco;
- o histórico cresce um registro por ciclo, sem limite;
- o tabuleiro é desenhado com `FillRect` por célula, o que pode pesar em grades grandes.

### 4.7 Regras estão fixas no código

As regras ecológicas estão codificadas dentro de `TSimulacao.ProcessarCelula`.

Isso é simples, mas dificulta customização. Uma futura versão poderia migrar para um motor de regras mais próximo de `TAIRuleEngine`.

---

## 5. Maturidade atual

| Área | Avaliação |
|---|---|
| Ideia do projeto | Boa |
| Valor didático | Alto |
| Integração com `CHATGPT` | Inicial |
| Interface | Completa para demonstração |
| Configuração | Editável na tela, sem gravação em disco |
| Estatísticas | População e histórico por ciclo |
| Exportação | Histórico completo em CSV |
| Arquitetura | Pequena, compreensível, mas ainda específica |
| Uso como demo de AI Simulation | Válido, mas ainda mínimo |
| Pronto para ensino/demonstração | Sim |
| Pronto como motor reutilizável | Ainda não |

---

## 6. Próximas correções recomendadas

### Prioridade 0 — Correções pequenas e importantes

1. Conferir os caminhos do `CHATGPT` no `.lpi`: há um relativo (`..\..\CHATGPT\pacote`) e o antigo em `P:\`; ambos são redundantes com a dependência do pacote `openai_simulation`.
2. Transformar os `testeN.lpr` em testes com verificação automática.

### Prioridade 1 — Melhorias funcionais

3. Gravar e carregar configurações em arquivo.
4. Melhorar renderização usando scanline.
5. Avaliar o custo de `TAISimEntity` por ser (GUID e `TJSONObject` criados a cada nascimento).
6. Limitar ou compactar o histórico em execuções muito longas.

### Prioridade 2 — Evolução como demo do `CHATGPT`

11. Migrar a grade para `TAIGridWorld`.
12. Migrar seres para entidades mais completas com propriedades dinâmicas.
13. Substituir movimento fixo por `TAIMovementEngine`.
14. Substituir regras fixas por `TAIRuleEngine`.
15. Usar `TAISimulationStats` para métricas.
16. Usar `TAIScenarioConfig` para salvar/carregar cenários.
17. Criar geração de cenários com `TCHATGPT`.

---

## 7. Conclusão

O projeto **Animais** é um bom exemplo didático de simulação baseada em agentes em Lazarus.

Ele já demonstra os conceitos centrais de um ambiente simulado: entidades, grade, ciclo, movimento, alimentação, morte, reprodução e estatísticas simples.

Como demo da biblioteca `CHATGPT`, ele é válido porque já depende de `openai_simulation` e usa `TAISimEntity`. Porém, ainda é uma integração mínima. A próxima etapa natural é migrar gradualmente partes da simulação para os componentes completos da área **AI Simulation**.
