# Animais — Jogo da Vida Evoluído

**Animais** é uma simulação visual de ecossistema interativa desenvolvida em **Lazarus / Free Pascal**, inspirada no clássico **Jogo da Vida** de Conway, mas estendida para representar seres complexos com ciclos de vida, reprodução direcionada, movimentação e relações ecológicas.

O ecossistema é composto por quatro tipos de seres vivos:
- 🟡 **Bactérias** (Amarelo)
- 🟢 **Plantas** (Verde)
- 🔵 **Animais vegetarianos** (Azul)
- 🔴 **Animais carnívoros** (Vermelho)

Esta versão foi completamente refatorada seguindo boas práticas de desenvolvimento de software, separando a lógica de negócio (simulação) da interface gráfica, garantindo alto desempenho, controle preciso de memória e extensibilidade.

---

## Recursos Implementados

1. **Arquitetura Desacoplada (OOP)**: Toda a lógica do ecossistema e do tabuleiro foi extraída do formulário principal e dividida em unidades lógicas dedicadas.
2. **Atualização Segura de Tabuleiro (Double Buffering)**: Introdução do conceito de `BoardAtual` e `BoardProximo` para garantir previsibilidade científica, eliminando o problema de race conditions onde uma célula processada no início influenciava as próximas no mesmo ciclo.
3. **Persistência de Fome de Carnívoros**: A fome agora é armazenada individualmente na instância de cada carnívoro, garantindo comportamento ecológico estável.
4. **Instintos Evolutivos (`Come` e `Mata`)**: A cada 500 ciclos ocorrem mutações comportamentais na espécie. Se um ser possuir 3 ou mais vizinhos da espécie-alvo, ele executará as ações de consumo/ataque.
5. **Redimensionamento Dinâmico**: Permite ao usuário escolher o tamanho do tabuleiro (ex: 200x200 para execução rápida, 500x500 intermediária, 1000x1000 pesada).
6. **Painel de Estatísticas e Telemetria (Biodiversidade e Evolução)**: Sidebar lateral moderna com 5 abas (`Resumo`, `Vivos`, `Mortos`, `Extintos`, `Evolução`). Mostra a contagem de subespécies em tempo real, destaca subespécies em risco (cor amarela) e extintas (cinza/vermelho), rastreia causas de mortes detalhadas, e exibe o ciclo exato em que ocorreu a extinção.
7. **Curva de Evolução por Subespécie**: Gráfico interativo via `TAChart` e tabela de dados que desenha a quantidade de indivíduos vivos ao longo dos ciclos para a subespécie selecionada, exibindo avisos de extinção no título e permitindo a exportação independente da curva em formato CSV.
8. **Exportação CSV**: Permite salvar todo o histórico populacional da simulação no formato padrão de dados de forma neutra em localidade (com separador decimal de ponto). Gera simultaneamente os arquivos `exemplo_saida.csv` e `biodiversidade.csv`.
9. **Configurações Detalhadas**: Modal que permite ajustar dimensões, velocidade, porcentagens iniciais, ciclos de entrada de espécies, limites de fome por espécie, intervalos e limites máximos de histórico na memória, e semente de aleatoriedade (`Seed`).

---

## Estrutura do Projeto

* `animal.lpi` / `animal.lpr`: Arquivos principais do projeto Lazarus.
* `form2.pas` / `form2.lfm`: Formulário principal com interface e renderização rápida de bitmap em 32-bit.
* [uTiposAnimais.pas](file:///D:/projetos/maurinsoft/animais/uTiposAnimais.pas): Definição de tipos, constantes de cores e registro de configurações da simulação.
* [uSeres.pas](file:///D:/projetos/maurinsoft/animais/uSeres.pas): Hierarquia de classes de seres vivos (`TSer`, `TBacteria`, etc.).
* [uTabuleiro.pas](file:///D:/projetos/maurinsoft/animais/uTabuleiro.pas): Matrizes de células e operações de tabuleiro em duas grades (Double Buffer).
* [uSimulacao.pas](file:///D:/projetos/maurinsoft/animais/uSimulacao.pas): Máquina de estado da simulação, regras ecológicas e controle temporal.
* [uEstatisticas.pas](file:///D:/projetos/maurinsoft/animais/uEstatisticas.pas): Agregação de dados históricos e rotina de exportação CSV.
* [uFormConfig.pas](file:///D:/projetos/maurinsoft/animais/uFormConfig.pas) / `uFormConfig.lfm`: Formulário de configuração de parâmetros.
* [docs/](file:///D:/projetos/maurinsoft/animais/docs/): Pasta contendo documentações estendidas.

---

## Como Compilar e Executar

### Requisitos
- **Lazarus IDE** (versão 3.0 ou superior recomendada)
- **Free Pascal Compiler** (versão 3.2.2 ou superior)

### Compilação via Linha de Comando (CLI)
Para compilar o projeto diretamente usando o `lazbuild`:
```bash
lazbuild D:\projetos\maurinsoft\animais\animal.lpi
```

### Compilação via IDE Lazarus
1. Abra o Lazarus.
2. Acesse `Projeto -> Abrir Projeto` e selecione `D:\projetos\maurinsoft\animais\animal.lpi`.
3. Pressione `F9` ou clique no botão verde de execução para compilar e iniciar.

---

## Documentação Adicional

Para mais detalhes sobre as regras ecológicas, operação e detalhes de projeto, consulte:

1. 📖 [Guia de Usuário](file:///D:/projetos/maurinsoft/animais/docs/GUIA_USUARIO.md) — Instruções sobre como operar a simulação e exportar relatórios.
2. 💻 [Guia de Desenvolvedor](file:///D:/projetos/maurinsoft/animais/docs/GUIA_DESENVOLVEDOR.md) — Explicação aprofundada das units, fluxos de ciclo e como estender as espécies.
3. 🔬 [Análise Técnica](file:///D:/projetos/maurinsoft/animais/docs/ANALISE_TECNICA.md) — Análise sobre controle de memória, otimizações de ScanLine e decisões de projeto.
4. 🗺️ [Roadmap de Desenvolvimento](file:///D:/projetos/maurinsoft/animais/docs/ROADMAP.md) — Fases de evolução e melhorias planejadas para o futuro.

---

## Licença

Este projeto é distribuído sob a Licença MIT. Consulte o arquivo [LICENSE](file:///D:/projetos/maurinsoft/animais/LICENSE) para obter detalhes.
