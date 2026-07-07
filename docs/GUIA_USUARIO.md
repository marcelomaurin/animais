# Guia do Usuário — Animais

Este guia descreve a versão atual da aplicação **Animais**, uma simulação visual simplificada de ecossistema feita em **Lazarus / Free Pascal**.

A aplicação mostra uma grade 2D onde diferentes tipos de seres aparecem, se movem, se alimentam, reproduzem, morrem e podem gerar matéria orgânica.

---

## O que aparece na tela

A tela principal é dividida em duas partes:

1. **Área do tabuleiro**: mostra a simulação em tempo real.
2. **Painel lateral**: mostra os contadores e botões de controle.

---

## Cores da simulação

| Cor | Tipo |
|---|---|
| Preto | Célula vazia |
| Amarelo | Bactéria |
| Verde | Planta |
| Azul | Herbívoro / vegetariano |
| Vermelho | Carnívoro |
| Marrom | Matéria orgânica |

---

## Contadores exibidos

O painel lateral mostra:

- ciclo atual;
- quantidade de bactérias;
- quantidade de plantas;
- quantidade de herbívoros / vegetarianos;
- quantidade de carnívoros;
- quantidade de matéria orgânica;
- tempo do último ciclo;
- FPS aproximado.

A versão atual **não possui abas**, **não possui gráfico histórico** e **não possui painel de subespécies**.

---

## Botões disponíveis

### Iniciar

Liga o timer da simulação e começa a executar ciclos.

### Pausar

Desliga temporariamente o timer. A simulação permanece no estado atual.

### Parar

Interrompe a simulação, descarta o estado atual e cria uma nova simulação com a configuração padrão.

### Reiniciar

Cria uma nova simulação usando a configuração padrão.

### Configurações

Na versão atual, este botão apenas informa que a configuração está definida na unit `uConfig.pas`.

Ainda não existe uma tela visual de configuração.

### Exportar CSV

Exporta um arquivo chamado:

```text
export_form.csv
```

O arquivo contém apenas um resumo do estado atual, com:

- ciclo;
- bactérias;
- plantas;
- herbívoros;
- carnívoros;
- matéria orgânica;
- células vazias.

A versão atual **não exporta histórico completo por ciclo**.

### Sobre

Mostra uma mensagem simples sobre o projeto.

---

## Configuração da simulação

Os parâmetros atuais ficam no arquivo:

```text
uConfig.pas
```

A configuração padrão define valores como:

- largura da grade;
- altura da grade;
- porcentagem inicial de bactérias;
- porcentagem inicial de plantas;
- porcentagem inicial de herbívoros;
- porcentagem inicial de carnívoros;
- vida máxima por tipo;
- fome máxima de herbívoros e carnívoros;
- ciclos de reprodução;
- tempo de degradação da matéria orgânica;
- ciclo de entrada dos carnívoros.

---

## Como usar

1. Abra o projeto `animal.lpi` no Lazarus.
2. Compile e execute.
3. Clique em **Iniciar**.
4. Observe a evolução das populações no painel lateral.
5. Use **Pausar** para congelar o estado atual.
6. Use **Exportar CSV** para gravar o resumo atual.
7. Use **Reiniciar** ou **Parar** para recomeçar a simulação.

---

## Limitações da versão atual

A versão atual ainda não possui:

- tela visual de configuração;
- gráfico populacional;
- histórico completo por ciclo;
- subespécies;
- mutações complexas;
- relatório detalhado de mortes;
- salvamento e carregamento de cenários;
- integração completa com todos os componentes `AI Simulation` da biblioteca `CHATGPT`.

Esses itens são candidatos naturais para evolução futura.
