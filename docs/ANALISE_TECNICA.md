# Análise Técnica — Animais

Este documento apresenta uma análise crítica do projeto **Animais**, considerando os fontes atuais disponíveis no repositório.

---

## Resumo executivo

O projeto implementa uma simulação visual inspirada no Jogo da Vida, usando Lazarus / Free Pascal.

A ideia é boa e didática: sair do modelo clássico de células vivas/mortas e simular um pequeno ecossistema com bactérias, plantas, vegetarianos e carnívoros.

O projeto, porém, ainda está em estágio experimental. A base conceitual existe, mas há inconsistências estruturais e pontos técnicos que precisam correção antes de considerar a aplicação estável.

---

## Pontos fortes

### 1. Ideia simples e visual

A proposta é fácil de entender e pode ser usada para ensino de programação, autômatos celulares e simulações.

### 2. Uso de Lazarus / Free Pascal

O projeto valoriza um ambiente nativo, leve e multiplataforma, alinhado a aplicações desktop simples.

### 3. Código direto

A lógica principal está em uma unit única, o que facilita a leitura inicial para estudantes.

### 4. Uso de orientação a objetos

Mesmo que ainda simples, o projeto já separa uma classe base `TSer` e classes derivadas para cada espécie.

### 5. Renderização direta

O uso de `TBitmap.ScanLine` é uma escolha melhor do que desenhar célula por célula com métodos gráficos de alto nível.

---

## Limitações identificadas

### 1. Inconsistência entre formulário e código

O código Pascal usa `TForm1`, enquanto o arquivo `.lfm` declara `Form2: TForm2`.

Esse é um problema importante porque o Lazarus depende da compatibilidade entre a classe visual e a classe Pascal.

### 2. Eventos dos botões não aparecem ligados no `.lfm`

Os métodos existem no fonte, mas o arquivo visual analisado não apresenta as associações `OnClick`.

Isso pode fazer com que os botões apareçam na tela, mas não executem nenhuma ação.

### 3. Lógica concentrada demais em `ProximoCiclo`

O método `ProximoCiclo` concentra muitas responsabilidades:

- incremento de ciclo;
- introdução de espécies;
- contagem de vida;
- análise de vizinhança;
- regras de morte;
- regras de reprodução;
- regras de movimento.

Isso dificulta manutenção e evolução.

### 4. Alto custo de memória e CPU

O tabuleiro fixo de 1000x1000 gera um milhão de células.

Além disso, cada célula ocupada pode conter um objeto. Com 20% de bactérias iniciais, o programa pode criar cerca de 200.000 objetos logo no início.

### 5. Controle de fome do carnívoro com estado local

A variável `carnivoreHunger` está dentro de `ProximoCiclo`.

Isso é problemático porque fome é estado do animal ou do tabuleiro ao longo do tempo. Se a matriz for recriada a cada ciclo, a informação histórica pode ser perdida.

### 6. Movimento perde estado interno

O método `MoveAnimal` cria outro ser no destino e libera a origem.

Isso faz o animal perder idade, ciclo de reprodução e qualquer futuro atributo interno.

### 7. Documentação anterior citava recurso não encontrado no fonte

A documentação anterior mencionava propriedades `Come` e `Mata` e evolução de instintos a cada 500 ciclos.

Essas propriedades não aparecem no código atual analisado. Por isso, foram removidas da documentação principal e tratadas apenas como ideia futura.

---

## Riscos técnicos

| Risco | Impacto | Prioridade |
|---|---|---|
| Divergência `TForm1` x `TForm2` | Pode impedir compilação ou carregamento correto do formulário | Alta |
| Eventos dos botões não associados | Interface pode não responder | Alta |
| Tabuleiro muito grande | Lentidão e alto consumo de memória | Alta |
| Estado de fome não persistente | Regra ecológica incorreta | Média |
| Movimento recriando objeto | Comportamento artificial inconsistente | Média |
| Lógica muito concentrada | Dificuldade de manutenção | Média |

---

## Recomendações imediatas

### 1. Corrigir formulário

Escolher um único nome para o formulário.

Sugestão:

- manter `TForm1` no Pascal;
- alterar o `.lfm` para `object Form1: TForm1`.

Ou, alternativamente, renomear o Pascal para `TForm2`.

### 2. Ligar eventos no `.lfm`

Garantir que os botões tenham:

```pascal
OnClick = btnStartClick
OnClick = btnPauseClick
OnClick = btnStopClick
```

E que o timer tenha:

```pascal
OnTimer = tmCycleTimer
```

### 3. Adicionar `FormDestroy`

Atualmente `Tab` é criado no `FormCreate`, mas é recomendável liberar explicitamente no fechamento do formulário.

Exemplo:

```pascal
procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Tab);
end;
```

### 4. Tornar fome atributo persistente

A fome poderia ser campo de `TSer`:

```pascal
CiclosSemComida: Integer;
```

Ou campo específico de `TCarnivoro`.

### 5. Criar estatísticas

Adicionar contadores de população:

- total de bactérias;
- total de plantas;
- total de vegetarianos;
- total de carnívoros.

Isso transformaria o projeto em uma simulação mais compreensível.

---

## Melhorias de médio prazo

### Separar units

A estrutura atual funciona para protótipo, mas para evolução recomenda-se separar:

- `uSeres.pas` — classes dos seres;
- `uTabuleiro.pas` — matriz e regras de simulação;
- `uRender.pas` — desenho do tabuleiro;
- `uMain.pas` — interface gráfica;
- `uConfig.pas` — parâmetros configuráveis.

### Parametrizar a simulação

Hoje vários valores estão fixos no código.

Exemplos que deveriam virar parâmetros:

- tamanho do tabuleiro;
- percentual inicial de bactérias;
- ciclo de introdução das espécies;
- vida máxima de cada espécie;
- tempo de reprodução;
- velocidade do timer.

### Criar modo didático

Um modo didático poderia usar tabuleiro menor e mostrar números na tela.

Exemplo:

- ciclo atual;
- população por espécie;
- taxa de crescimento;
- eventos importantes.

### Criar modo desempenho

Um modo desempenho poderia evitar objetos por célula e usar arrays compactos.

Exemplo:

```pascal
TTipoSerArray = array of TTipoSer;
TVidaArray = array of SmallInt;
TReproArray = array of SmallInt;
```

---

## Sugestão de evolução comercial

Para dar uma aparência mais profissional ao projeto, recomenda-se incluir:

1. Tela inicial com descrição da simulação.
2. Painel lateral de parâmetros.
3. Gráfico populacional em tempo real.
4. Botão para exportar CSV.
5. Presets de simulação.
6. Imagens ou GIFs no README.
7. Instalador para Windows.
8. Release binária no GitHub.
9. Licença clara.
10. Roadmap público.

---

## Classificação de maturidade

| Critério | Avaliação |
|---|---|
| Ideia | Boa |
| Valor didático | Alto |
| Organização do código | Inicial |
| Estabilidade | Experimental |
| Documentação anterior | Básica |
| Documentação atual | Reestruturada |
| Pronto para usuário final | Ainda não |
| Pronto para estudo e evolução | Sim |

---

## Conclusão

O projeto **Animais** tem uma boa semente: uma simulação visual, simples, intuitiva e com potencial didático.

A prioridade agora deve ser corrigir a base técnica mínima para garantir compilação, eventos funcionando e comportamento coerente das regras.

Depois disso, o projeto pode crescer para uma ferramenta visual de ensino sobre ecossistemas artificiais, autômatos celulares e programação orientada a objetos em Lazarus.
