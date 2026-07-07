# Animais — Simulação de Ecossistema Simplificado (Lazarus / Free Pascal)

**Animais** é uma simulação visual de ecossistema baseada em agentes desenvolvida em **Lazarus / Free Pascal**. O projeto é integrado à biblioteca **CHATGPT** (especificamente utilizando os componentes de simulação do pacote `openai_simulation`), demonstrando a aplicação prática de redes celulares, regras evolutivas e controle de ciclo com duplo buffer seguro.

---

## Idiomas / Languages

- [Português (PT-BR)](README.md)
- [English (EN)](README_EN.md)
- [Español (ES)](README_ES.md)
- [Français (FR)](README_FR.md)
- [中文 (ZH)](README_ZH.md)
- [العربية (AR)](README_AR.md)

---

## O que o projeto faz

A simulação modela a dinâmica de sobrevivência e reprodução de um ecossistema simplificado em uma grade bidimensional de $80 \times 80$. A dinâmica é regida por 5 tipos de entidades:

| Tipo | Cor | Comportamento |
|---|---|---|
| **Planta** | Verde | Recurso primário, reproduz-se após alguns ciclos se houver espaço. |
| **Herbívoro** | Azul | Movimenta-se e alimenta-se de plantas. Morre por idade ou inanição (fome). |
| **Carnívoro** | Vermelho | Entra no ciclo 200, alimenta-se de herbívoros. Morre por idade ou fome. |
| **Matéria Orgânica** | Marrom | Gerada pela morte de plantas, herbívoros ou carnívoros. Degrada-se após alguns ciclos. |
| **Bactéria** | Amarelo | Surge a partir da degradação da matéria orgânica, consome matéria e se reproduz. |

---

## Princípios de Projeto & Estabilidade

Esta versão foi totalmente reestruturada para garantir estabilidade e evitar vazamentos de memória (Access Violations e Double-Frees):

1. **Duplo Buffer Seguro**: O tabuleiro (`TTabuleiro`) mantém `FBoard` (estado ativo) e `FNextBoard` (próximo estado). Todas as modificações são escritas no `FNextBoard` e aplicadas no final do ciclo.
2. **Dono Único**: Um objeto vivo (`TSer`) pertence a apenas um buffer por vez.
3. **Liberação Segura**: Entidades que morrem são marcadas com `Morto := True` e removidas da simulação de forma limpa. A liberação de memória (`Free`) é realizada exclusivamente no método `Commit` do tabuleiro.
4. **Seed Fixa**: Utiliza uma semente pseudo-aleatória fixa no início da simulação para fins de reprodutibilidade científica.

---

## Integração com a biblioteca CHATGPT

A classe fundamental `TSer` (em `uTipos.pas`) herda diretamente de `TAISimEntity` do pacote `openai_simulation`. Isso permite utilizar o ecossistema como um ambiente simulado para treinamento de modelos de IA, tomada de decisões por agentes lógicos e análise de dados ecológicos.

---

## Estrutura de Código

* **`uTipos.pas`**: Classe `TSer` que estende `TAISimEntity`.
* **`uTabuleiro.pas`**: Gerenciador da grade com duplo buffer e tratamento seguro contra vazamento de memória.
* **`uConfig.pas`**: Record `TConfig` com parâmetros ecológicos calibrados.
* **`uSimulacao.pas`**: Mecanismo que processa os passos de simulação e aplica regras biológicas.
* **`uEstat.pas`**: Registro estatístico de contagem populacional por ciclo.
* **`form2.pas` / `form2.lfm`**: Interface visual de controle com botões Iniciar, Pausar, Parar, Reiniciar e exportação de dados.

---

## Como Compilar e Rodar

### Requisitos
- Lazarus IDE
- Free Pascal Compiler (FPC)
- Biblioteca CHATGPT (pasta `pacote` acessível no caminho configurado no `.lpi`)

### Compilação
Abra o terminal na pasta do projeto e execute:
```bash
lazbuild animal.lpi
```

Ou abra `animal.lpi` diretamente na IDE do Lazarus e pressione **F9**.

---

## Licença
Este projeto é distribuído sob a licença **GPL-3.0**.
