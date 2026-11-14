# Guia do Usuário — Animais

Este guia descreve a versão atual da aplicação **Animais**, uma simulação visual simplificada de ecossistema feita em **Lazarus / Free Pascal**.

A aplicação mostra uma grade 2D onde diferentes tipos de seres aparecem, se movem, se alimentam, reproduzem, morrem e podem gerar matéria orgânica.

---

## O que aparece na tela

- **Barra superior**: nome, tamanho da grade e os botões Configurações, Exportar histórico e Sobre.
- **Controles**: Iniciar/Pausar, Avançar 1 ciclo, Reiniciar e velocidade.
- **Tabuleiro**: a simulação em tempo real.
- **Cartões**: ciclo atual, semente em uso e tempo médio por ciclo.
- **População**: quantidade, percentual e barra de cada grupo.
- **Histórico**: gráfico dos últimos 600 ciclos.

---

## Cores da simulação

| Cor | Tipo |
|---|---|
| Preto | Célula vazia |
| Amarelo | Bactéria |
| Verde | Planta |
| Azul claro | Herbívoro |
| Laranja-avermelhado | Carnívoro |
| Marrom | Matéria orgânica |

---

## Controles

### Iniciar / Pausar

Liga ou desliga a execução dos ciclos. Atalho: **Espaço**.

### Avançar 1 ciclo

Executa um único ciclo, com a simulação pausada ou não. Atalho: **seta para a direita**.

### Reiniciar

Cria uma nova simulação com as configurações atuais e uma nova semente sorteada (se o campo Semente estiver em 0). Atalho: **R**.

### Velocidade

Define quantos ciclos são executados a cada atualização da tela: 1, 4 ou 16.

---

## Histórico

O gráfico mostra uma linha por grupo, nas mesmas cores do tabuleiro. A escala vertical é logarítmica (linhas de referência em 10, 100 e 1000), para que grupos pequenos, como os carnívoros, apareçam junto com os grandes, como as plantas.

---

## Configurações

Abre uma tela com os parâmetros da simulação:

- **Tabuleiro**: largura, altura, semente, ciclo de entrada dos carnívoros e degradação da matéria orgânica.
- **Espécies**: proporção inicial, vida máxima, fome máxima e ciclos para reproduzir.

**Aplicar e reiniciar** valida os campos e inicia uma nova simulação. **Restaurar padrão** recarrega os valores de `uConfig.pas`. **Cancelar** fecha sem alterar.

Os valores alterados valem até o programa ser fechado.

Para repetir uma simulação, copie o número do cartão **Semente** para o campo Semente. Com 0, a semente é sorteada a cada reinício.

---

## Exportar histórico

Grava um arquivo CSV com uma linha por ciclo, desde o início da simulação atual, com as colunas: ciclo, bactérias, plantas, herbívoros, carnívoros, matéria orgânica e células vazias.

---

## Como usar

1. Abra o projeto `src/animal.lpi` no Lazarus (ou instale pelo instalador e abra o programa pelo menu Iniciar).
2. Compile e execute.
3. Clique em **Iniciar**.
4. Acompanhe a população e o histórico no painel à direita.
5. Use **Pausar** e **Avançar 1 ciclo** para examinar um momento específico.
6. Use **Exportar histórico** para analisar os dados em uma planilha.

---

## Limitações da versão atual

A versão atual ainda não possui:

- gravação das configurações em arquivo;
- cenários pré-configurados;
- subespécies e mutações;
- relatório detalhado de mortes;
- integração completa com todos os componentes `AI Simulation` da biblioteca `CHATGPT`.
