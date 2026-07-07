# Animais — Jogo da Vida Evoluído

**Animais** é uma simulação visual de ecossistema desenvolvida em **Lazarus / Free Pascal**. O projeto parte da ideia clássica do **Jogo da Vida**, mas troca o modelo simples de célula viva/morta por um ambiente com seres, espécies, subespécies, reprodução, morte, alimentação, movimentação, mutações e estatísticas.

O objetivo é demonstrar como um sistema de regras simples pode gerar comportamentos coletivos mais complexos, permitindo observar equilíbrio, extinção, crescimento populacional, pressão evolutiva e interação entre espécies.

---

## O que o projeto faz

O projeto simula um ecossistema em uma grade bidimensional. Cada posição do tabuleiro pode estar vazia ou conter um ser vivo. A cada ciclo da simulação, o motor avalia o estado de cada célula e decide o que acontece com cada indivíduo.

A simulação trabalha com os seguintes tipos principais:

| Tipo | Papel na simulação |
|---|---|
| **Bactéria** | Espécie inicial, pode se reproduzir e sofrer mutações de toxicidade. |
| **Planta** | Recurso alimentar dos herbívoros, pode ter variações como planta venenosa ou resistente. |
| **Herbívoro / Vegetariano** | Alimenta-se de plantas, move-se pelo ambiente, pode desenvolver resistência a veneno. |
| **Carnívoro** | Alimenta-se de herbívoros e possui variações de tamanho. |
| **Matéria orgânica** | Elemento de ambiente usado para enriquecer a dinâmica ecológica. |

Além dos tipos principais, o projeto controla **subespécies**. O código mantém uma matriz com 15 variações, incluindo bactéria tóxica, plantas resistentes, herbívoros por tamanho e resistência, e carnívoros pequenos, médios e grandes.

---

## Análise do funcionamento atual

A simulação não é apenas um desenho aleatório na tela. Ela possui um motor de ciclo, um tabuleiro com atualização segura, estatísticas, configuração e regras ecológicas.

### 1. Tabuleiro e espaço da simulação

O ambiente é representado pela classe `TTabuleiro`, que mantém duas matrizes:

- `FBoard`: estado atual do mundo;
- `FNextBoard`: próximo estado calculado.

Esse modelo usa **double buffering**, evitando que uma célula alterada no começo do ciclo interfira injustamente nas células ainda não processadas.

Principais operações do tabuleiro:

- `SetTamanho(AW, AH)`: redimensiona a grade;
- `PrepareNextBoard`: prepara o próximo ciclo;
- `CommitNextBoard`: aplica o ciclo calculado;
- `GetTipoAt(x, y)`: retorna o tipo de ser em uma posição;
- `GetEntAt(x, y)`: retorna o objeto vivo em uma posição;
- `ListaVizinhosLivres(x, y)`: localiza posições livres ao redor;
- `CopyCellToNext`: move ou mantém uma célula no próximo estado;
- `SpawnCellToNext`: cria um novo ser no próximo estado;
- `ConsumeCell`: remove uma célula por alimentação/predação.

### 2. Seres vivos

A hierarquia de seres está concentrada em `uSeres.pas`.

A classe base `TSer` guarda dados como:

- tipo principal (`TTipoSer`);
- idade máxima e idade atual;
- ciclo de reprodução;
- ciclos sem comida;
- instinto `Come`;
- instinto `Mata`;
- tamanho;
- toxicidade;
- resistência a veneno;
- resistência a toxina;
- pontos de matéria orgânica;
- limites de movimento.

Classes derivadas existentes:

- `TBacteria`;
- `TPlanta`;
- `TVegetariano`;
- `TCarnivoro`;
- `TMateriaOrganica`.

A função `NomeSubEspecie` classifica dinamicamente cada ser, permitindo distinguir, por exemplo, uma **bactéria tóxica**, uma **planta venenosa resistente à toxina**, um **herbívoro grande resistente a veneno** ou um **carnívoro pequeno**.

### 3. Tipos, configuração e subespécies

A unit `uTiposAnimais.pas` define os tipos fundamentais da simulação:

```pascal
TTipoSer = (tsNone, tsBacteria, tsPlanta, tsVegetariano, tsCarnivoro, tsMateriaOrganica);
```

Também define características evolutivas:

```pascal
TTamanhoAnimal = (taPequeno, taMedio, taGrande);
TToxicidade = (txNenhuma, txToxica);
TResistenciaVeneno = (rvNenhuma, rvResistente);
TResistenciaToxina = (rtNenhuma, rtResistente);
```

A configuração da simulação fica em `TSimulacaoConfig`, com parâmetros como:

- largura e altura da grade;
- quantidade inicial de bactérias, plantas, herbívoros e carnívoros;
- ciclo de entrada das espécies;
- intervalo do timer;
- seed aleatória;
- limite de fome por espécie;
- parâmetros de reprodução;
- chance de mutação;
- intervalo de histórico;
- raio de busca de herbívoros e carnívoros;
- limite de movimento por ciclo.

### 4. Motor da simulação

A classe `TSimulacao`, em `uSimulacao.pas`, orquestra o ecossistema.

Ela controla:

- tabuleiro;
- configuração;
- histórico estatístico;
- ciclo atual;
- FPS;
- tempo do último ciclo;
- mortes por causa;
- subespécies vivas, mortas e extintas;
- mutações ocorridas;
- ocupação geral do ambiente.

Métodos principais:

- `Inicializar`: prepara o ambiente usando a configuração atual;
- `Configurar`: aplica uma nova configuração;
- `ExecutarCiclo`: processa uma geração da simulação;
- `Reiniciar`: zera e reinicia o ecossistema;
- `CalculaEstatisticas`: consolida os dados populacionais.

Durante cada ciclo, a simulação avalia idade, fome, reprodução, mutação, alimentação, predação, movimento, conflitos e morte.

### 5. Regras ecológicas e evolutivas

O projeto implementa regras como:

- introdução programada de espécies;
- alimentação de herbívoros por plantas;
- alimentação de carnívoros por herbívoros;
- morte por idade;
- morte por fome;
- morte por veneno;
- morte por toxina;
- morte por predação;
- conflito entre seres;
- mutações por espécie;
- variação de tamanho;
- resistência a veneno;
- resistência a toxina;
- comportamento de busca ativa por alimento;
- movimento para perto de presas ou para longe de perigo.

Isso aproxima o projeto de uma pequena simulação ecológica baseada em agentes.

### 6. Estatísticas, gráficos e exportação

O projeto possui histórico estatístico para acompanhar a evolução do ecossistema.

A interface apresenta abas como:

- **Resumo**: ciclo atual, FPS, tempo de processamento, população por espécie e biodiversidade;
- **Vivos**: contagem de indivíduos vivos por subespécie;
- **Mortos**: acumulado de mortes e causas;
- **Extintos**: subespécies que já existiram e desapareceram;
- **Evolução**: curva populacional de uma subespécie selecionada.

A exportação CSV gera dados para análise posterior, permitindo observar tendências populacionais, extinções e oscilações de predador/presa.

---

## Interface

A aplicação possui interface gráfica em Lazarus com:

- área visual do tabuleiro;
- botões para iniciar, pausar, parar e reiniciar;
- tela de configuração da simulação;
- painel lateral de estatísticas;
- visualização por abas;
- gráfico de evolução populacional;
- exportação de dados em CSV.

O desenho do tabuleiro é otimizado usando bitmap e acesso direto por `ScanLine`, evitando a lentidão típica de desenhar célula por célula com `Canvas.Pixels`.

---

## Arquitetura atual

O projeto foi organizado em unidades com responsabilidades separadas:

| Unit | Responsabilidade |
|---|---|
| `uTiposAnimais.pas` | Tipos, enums, cores, configuração e subespécies. |
| `uSeres.pas` | Classes dos seres vivos e classificação de subespécies. |
| `uTabuleiro.pas` | Estrutura física da grade, double buffering e manipulação das células. |
| `uSimulacao.pas` | Motor principal da simulação e regras ecológicas. |
| `uEstatisticas.pas` | Histórico, métricas e exportação de dados. |
| `form2.pas` / `form2.lfm` | Interface principal, renderização e controles visuais. |
| `uFormConfig.pas` | Tela de configuração dos parâmetros da simulação. |

Essa divisão torna o projeto mais fácil de manter, evoluir e conectar com bibliotecas externas.

---

## Como executar

### Requisitos

- Lazarus IDE;
- Free Pascal Compiler;
- LCL instalada;
- ambiente gráfico compatível com aplicações Lazarus.

### Passos

```bash
git clone https://github.com/marcelomaurin/animais.git
cd animais
```

Depois:

1. Abra `animal.lpi` no Lazarus.
2. Compile o projeto.
3. Execute a aplicação.
4. Use os controles da interface para iniciar, pausar, reiniciar e configurar a simulação.

---

## Documentação complementar

A pasta `docs` contém documentação adicional:

- `docs/GUIA_USUARIO.md`: guia de uso da aplicação;
- `docs/GUIA_DESENVOLVEDOR.md`: explicação técnica da arquitetura e das units;
- `docs/ANALISE_TECNICA.md`: análise de problemas resolvidos, decisões arquiteturais e oportunidades de evolução.

---

## Relação com o pacote CHATGPT

Este projeto também serve como **exemplo prático do tipo de aplicação que pode ser construída usando a biblioteca [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT)**.

Dentro da biblioteca `CHATGPT`, a área **AI Simulation** fornece componentes para criar mundos em grade, entidades, motores de movimento, regras, eventos, estatísticas, persistência e exportação de cenários. O projeto **Animais** demonstra uma aplicação concreta desse conceito: um ecossistema visual baseado em agentes, ciclos, regras de sobrevivência, movimentação e métricas.

Assim, o repositório `animais` pode ser usado como referência para entender como a biblioteca `CHATGPT` pode apoiar simulações educacionais, experimentos de IA, treinamento de agentes, análise de comportamento emergente e prototipação de ambientes controlados.

---

## Possibilidades de evolução

Próximos passos recomendados:

1. aproximar a implementação das classes do projeto aos componentes `AI Simulation` da biblioteca `CHATGPT`;
2. substituir partes específicas por componentes reutilizáveis como mundo, entidade, movimento, regras e estatísticas;
3. exportar cenários compatíveis com o formato do pacote `openai_simulation`;
4. gerar datasets para treinamento ou validação de IA;
5. adicionar painel para comparar estratégias de sobrevivência;
6. criar integração com `TCHATGPT` para geração automática de cenários;
7. permitir salvar/carregar simulações em JSON;
8. publicar screenshots ou GIFs no README.

---

## Autor

Projeto criado por **Marcelo Maurin Martins**.

GitHub: [marcelomaurin](https://github.com/marcelomaurin)
