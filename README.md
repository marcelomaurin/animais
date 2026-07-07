# Animais — Simulação de Ecossistema Simplificado

**Animais** é uma simulação visual de ecossistema desenvolvida em **Lazarus / Free Pascal**.

O projeto demonstra um ambiente em grade 2D com seres simples, regras de sobrevivência, alimentação, reprodução, morte, matéria orgânica e estatísticas básicas em tempo real.

Ele também funciona como um **demo prático do pacote [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT)**, pois o projeto depende do pacote `openai_simulation` e a classe `TSer` herda de `TAISimEntity`.

---

## Estado atual do projeto

Esta versão é uma simulação **simplificada e funcional**, com foco em demonstrar:

- uso de uma grade bidimensional;
- agentes/seres vivos representados por objetos;
- ciclo de simulação por timer;
- alimentação entre espécies;
- reprodução;
- morte por idade ou fome;
- transformação de seres mortos em matéria orgânica;
- degradação da matéria orgânica em bactéria;
- renderização visual simples;
- contagem populacional;
- exportação de um resumo CSV.

Recursos como subespécies, gráficos históricos, mutações avançadas e painéis complexos de biodiversidade **não fazem parte do código atual**. Eles podem ser tratados como evolução futura.

---

## Entidades da simulação

A simulação trabalha com cinco tipos principais:

| Tipo | Cor na interface | Comportamento atual |
|---|---|---|
| **Bactéria** | Amarelo | Pode consumir matéria orgânica, mover-se aleatoriamente e reproduzir-se. |
| **Planta** | Verde | Serve de alimento para herbívoros e pode reproduzir-se. |
| **Herbívoro** | Azul | Alimenta-se de plantas, move-se e morre por idade ou fome. |
| **Carnívoro** | Vermelho | Entra no ciclo configurado, alimenta-se de herbívoros e morre por idade ou fome. |
| **Matéria orgânica** | Marrom | Surge da morte de plantas, herbívoros e carnívoros; após degradar, vira bactéria. |

---

## Funcionamento do ciclo

A classe `TSimulacao` controla o ciclo principal.

A cada ciclo:

1. o contador de ciclo é incrementado;
2. carnívoros são introduzidos quando o ciclo configurado é atingido;
3. o próximo estado do tabuleiro é preparado;
4. cada célula ativa é processada;
5. idade, fome, alimentação, movimento e reprodução são avaliados;
6. o próximo estado é confirmado no tabuleiro;
7. a interface redesenha a grade e atualiza os contadores.

---

## Estrutura de código

| Arquivo | Responsabilidade |
|---|---|
| `animal.lpr` | Programa principal Lazarus. Carrega o formulário e as units do projeto. |
| `animal.lpi` | Arquivo de projeto Lazarus. Declara dependência do pacote `openai_simulation`. |
| `form2.pas` / `form2.lfm` | Interface visual principal: desenho do tabuleiro, botões, timer e exportação. |
| `uTipos.pas` | Define `TTipo` e a classe `TSer`, que herda de `TAISimEntity`. |
| `uConfig.pas` | Define `TConfig` e os parâmetros padrão da simulação. |
| `uTabuleiro.pas` | Implementa a grade com `FBoard` e `FNextBoard`. |
| `uSimulacao.pas` | Implementa o motor de regras ecológicas e o ciclo da simulação. |
| `uEstat.pas` | Define o record `TEstat` usado para contagem populacional. |

---

## Interface atual

A tela principal possui:

- área visual do tabuleiro;
- painel lateral com contadores;
- botão **Iniciar**;
- botão **Pausar**;
- botão **Parar**;
- botão **Reiniciar**;
- botão **Configurações**;
- botão **Exportar CSV**;
- botão **Sobre**.

A configuração ainda é estática e fica definida na unit `uConfig.pas`. O botão **Configurações** apenas informa isso ao usuário.

O botão **Exportar CSV** grava um arquivo simples chamado `export_form.csv`, contendo o estado populacional atual.

---

## Relação com a biblioteca CHATGPT

Este projeto é um exemplo do que pode ser feito usando a biblioteca [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT), especialmente a área **AI Simulation**.

No estado atual, o projeto ainda não usa todos os componentes de simulação da biblioteca. A integração principal está em:

- dependência do pacote `openai_simulation` no projeto Lazarus;
- classe `TSer` herdando de `TAISimEntity`;
- estrutura conceitual compatível com simulações baseadas em entidades, grade, ciclos e métricas.

Assim, o repositório serve como uma base didática para evoluir uma simulação própria em direção ao uso mais completo dos componentes de `AI Simulation` do projeto `CHATGPT`.

---

## Como compilar

### Requisitos

- Lazarus IDE;
- Free Pascal Compiler;
- biblioteca [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) disponível localmente;
- pacote `openai_simulation` instalado ou acessível ao Lazarus.

### Passos

```bash
git clone https://github.com/marcelomaurin/animais.git
cd animais
lazbuild animal.lpi
```

Ou abra `animal.lpi` no Lazarus e compile pela IDE.

---

## Pontos de atenção

- O caminho do pacote `CHATGPT` no arquivo `.lpi` pode precisar ser ajustado conforme a máquina do desenvolvedor.
- A simulação atual usa configuração estática em `uConfig.pas`.
- A exportação CSV atual é apenas um snapshot simples, não um histórico completo.
- A documentação antiga mencionava subespécies, gráficos e relatórios avançados; esses recursos não correspondem ao código atual.

---

## Próximos passos sugeridos

1. Criar uma tela real de configuração em vez de mensagem estática.
2. Gravar histórico por ciclo e exportar CSV completo.
3. Adicionar gráficos populacionais.
4. Evoluir `TSer` para usar mais propriedades de `TAISimEntity`.
5. Aproximar `TTabuleiro` dos componentes `TAIGridWorld` e `TAIGridCell`.
6. Trocar regras fixas por um motor de regras configurável.
7. Criar salvamento/carregamento de cenários em JSON.
8. Adicionar testes ou rotina de validação de ciclo.

---

## Licença

Este projeto é distribuído sob a licença **GPL-3.0**.
