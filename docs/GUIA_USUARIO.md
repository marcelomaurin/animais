# Guia do Usuário — Animais

Este guia explica como usar o projeto **Animais**, uma simulação visual inspirada no Jogo da Vida, criada em Lazarus / Free Pascal.

---

## O que é o Animais?

O **Animais** é uma simulação de ecossistema em que um grande tabuleiro representa um ambiente vivo.

Cada ponto do tabuleiro pode estar vazio ou conter um dos seguintes seres:

- bactéria;
- planta;
- animal vegetariano;
- animal carnívoro.

A cada ciclo, o sistema recalcula o estado do ambiente. Os seres podem nascer, se reproduzir, se mover ou morrer conforme regras simples.

---

## Cores da simulação

| Cor | Significado |
|---|---|
| Amarelo | Bactéria |
| Verde | Planta |
| Azul | Vegetariano |
| Vermelho | Carnívoro |
| Preto | Espaço vazio |

---

## Controles da tela

### Iniciar

Começa a execução da simulação.

Quando o temporizador está ativo, o programa avança ciclo por ciclo e redesenha o tabuleiro.

### Pausar

Alterna entre pausado e em execução.

Use este botão para congelar a simulação e observar o estado atual do ecossistema.

### Parar

Para a execução e reinicia o tabuleiro.

Ao parar, o estado anterior é perdido e um novo tabuleiro é criado.

---

## Como interpretar a evolução

No início, o tabuleiro é preenchido com bactérias.

Depois, o sistema introduz outras espécies em ciclos específicos:

- ciclo 100: aparece uma planta;
- ciclo 200: aparece um vegetariano;
- ciclo 300: aparece um carnívoro.

A partir daí, a simulação passa a evoluir conforme as regras programadas.

---

## O que observar

Durante a execução, observe:

- se as bactérias dominam rapidamente o tabuleiro;
- se plantas conseguem se expandir;
- se vegetarianos encontram alimento;
- se carnívoros conseguem sobreviver;
- se alguma espécie desaparece completamente;
- como pequenas regras geram padrões complexos.

---

## Requisitos para executar

Para abrir e compilar o projeto, é necessário ter:

- Lazarus IDE instalada;
- Free Pascal Compiler instalado;
- sistema operacional com interface gráfica.

---

## Possíveis problemas

### O botão não funciona

Se os botões não responderem, verifique no Lazarus se os eventos estão ligados corretamente:

- `btnStartClick`
- `btnPauseClick`
- `btnStopClick`

Na análise atual, o arquivo `.lfm` não mostra claramente os eventos `OnClick` associados aos botões.

### A tela abre com nome Form2

O arquivo visual `unit1.lfm` declara `Form2: TForm2`, enquanto o código Pascal declara `TForm1`. Isso deve ser corrigido no Lazarus para evitar inconsistência.

### A simulação fica pesada

O tabuleiro possui 1000x1000 células, totalizando 1 milhão de posições. Em computadores mais simples, a simulação pode consumir bastante processamento.

---

## Dicas de uso

Para testes rápidos, uma melhoria futura recomendada é permitir alterar o tamanho do tabuleiro, por exemplo:

- 100x100 para testes rápidos;
- 300x300 para simulação média;
- 1000x1000 para simulação completa.

Atualmente, o tamanho está fixo no código.
