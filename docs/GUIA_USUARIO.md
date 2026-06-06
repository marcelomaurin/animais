# Guia do Usuário — Animais / Jogo da Vida Evoluído

Este guia explica como utilizar a aplicação **Animais — Jogo da Vida Evoluído**, fornecendo instruções de uso dos novos controles, visualização de estatísticas e configuração da simulação.

---

## O que é a Simulação?

A simulação representa um ecossistema dinâmico onde seres de diferentes espécies coexistem em uma grade espacial (tabuleiro). Cada ser possui regras biológicas simples de sobrevivência, movimento e reprodução, mas a sua interação coletiva produz comportamentos ecológicos emergentes e padrões visuais complexos.

### Identificação Visual (Cores e Subespécies)
- ⬛ **Preto**: Célula vazia.
- 🟡 **Amarelo**: **Bactéria não tóxica** (comum).
- 🟪 **Roxo**: **Bactéria tóxica** (mutada, envelhece plantas).
- 🟢 **Verde brilhante**: **Planta comum**.
- 🌲 **Verde escuro**: **Planta venenosa** (mata herbívoros não resistentes).
- 🌿 **Verde claro**: **Planta resistente à toxina bacteriana**.
- 🔵 **Azul**: **Herbívoro comum**.
- 🌐 **Ciano**: **Herbívoro resistente a veneno**.
- 🔴 **Vermelho**: **Carnívoro médio** (comum).
- 💮 **Vermelho claro**: **Carnívoro pequeno**.
- 🩸 **Vermelho escuro**: **Carnívoro grande**.

---

## Estrutura da Interface

A tela principal do sistema está dividida em duas áreas fundamentais:
1. **Área de Visualização (Esquerda)**: Renderiza o tabuleiro da simulação em tempo real, dimensionando-se automaticamente ao tamanho configurado.
2. **Painel de Controle e Estatísticas (Direita)**: Uma barra lateral contendo o painel de abas de estatísticas e a área inferior de botões.

### Abas de Biodiversidade e Evolução

O painel de estatísticas está organizado em 5 abas:

#### 1. Aba "Resumo"
Exibe uma visão geral e de alto nível do ecossistema:
- Ciclo atual, FPS e tempo de processamento.
- Contagem por espécie e as variações ativas.
- Total de espécies e subespécies vivas, extintas e mortes acumuladas.

#### 2. Aba "Vivos"
Uma tabela listando as 15 subespécies possíveis e a quantidade de indivíduos vivos em tempo real. Subespécies em risco de extinção (com população entre 1 e 3 indivíduos) aparecem **destacadas em amarelo**.

#### 3. Aba "Mortos"
Exibe o acumulado histórico de mortes por subespécie e uma tabela lateral com a distribuição das causas de mortes (Fome, Idade, Predação, Veneno, Toxina, Aleatória, Conflito).

#### 4. Aba "Extintos"
Tabela que lista subespécies que já existiram na simulação mas que no momento possuem 0 indivíduos vivos. Exibe o nome da subespécie e o ciclo exato em que ocorreu sua extinção. Aparecem **destacadas em cinza/vermelho**.

#### 5. Aba "Evolução"
Permite acompanhar graficamente o histórico de uma subespécie específica:
1. Selecione o **Tipo Principal** (Bactéria, Planta, Herbívoro, Carnívoro) no primeiro ComboBox.
2. Selecione a **Subespécie** desejada no segundo ComboBox.
3. Clique em **Atualizar** para carregar a curva de evolução populacional no gráfico (eixo X = Ciclos, eixo Y = Indivíduos vivos) e na tabela de dados adjacente.
4. Se a subespécie estiver extinta, o título do gráfico exibirá o ciclo da extinção.
5. Clique em **Exportar** para salvar o histórico da subespécie selecionada no arquivo `docs/historico_subespecie.csv`.

---

## Controles de Ação

Os botões habilitam-se de acordo com o estado da simulação para evitar inconsistências:
- **Iniciar / Continuar**: Inicia a simulação ou retoma a execução a partir do estado pausado.
- **Pausar**: Congela temporariamente a simulação. Permite analisar as populações e habilita a exportação de dados.
- **Parar**: Interrompe a simulação e limpa o tabuleiro de volta ao estado inicial vazio.
- **Reiniciar**: Zera a simulação atual e inicia uma nova execução imediatamente usando as configurações vigentes.
- **Configurações**: Abre a tela de parâmetros (somente quando a simulação estiver parada).
- **Exportar CSV**: Salva o histórico populacional (disponível quando pausado).
- **Sobre**: Informações de autoria e versão do software.

---

## Configurando a Simulação

Clicando em **Configurações** (com a simulação parada), você pode ajustar os seguintes parâmetros:
- **Largura e Altura**: O tamanho da grade de simulação.
- **Intervalo do Timer (ms)**: A velocidade da simulação.
- **Bactérias Iniciais (%)**: A densidade inicial de bactérias no tabuleiro ao iniciar.
- **Entrada e Quantidade das Espécies**: Parâmetros de introdução programada para Plantas, Vegetarianos e Carnívoros.
- **Limite Fome**: Limites de sobrevivência sem comida para Vegetarianos e Carnívoros.
- **Intervalo e Limite de Histórico**: Controla a taxa de amostragem do histórico (ex: registrar a cada ciclo ou a cada N ciclos) e o número máximo de pontos mantidos na memória (padrão de 10.000 para evitar lentidão ou consumo excessivo de RAM).
- **Seed Aleatória**: Semente do gerador de números aleatórios.

---

## Exportando Dados Populacionais

Ao pausar a simulação e clicar em **Exportar CSV**, o sistema gera dois arquivos de relatório na pasta `docs`:

1. **`exemplo_saida.csv`**: Histórico populacional geral, contendo as populações das espécies principais, contadores específicos de subtipos (tamanho, toxicidade, etc.) e as métricas de biodiversidade de espécies/subespécies vivas, extintas e causas de morte.
2. **`biodiversidade.csv`**: Relatório detalhado por subespécie contendo a série temporal de indivíduos vivos, mortos e se está extinta em cada ciclo.

Ambos os relatórios utilizam separadores de vírgula e formato numérico com ponto decimal, ideal para importação e análise em planilhas eletrônicas.

