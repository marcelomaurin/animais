# animais
Versão de simulação do famoso jogo da vida feita em lazarus

Simulação do Jogo da vida modificado.
https://pt.wikipedia.org/wiki/Jogo_da_vida

Neste contexto, temos 4 raças.

1) Bacteria
2) Plantas
3) Animais Vegetarianos
4) Animais Carnivoros


# Explicação 

# 🧬 Jogo da Vida Evoluído

Simulação visual de um ecossistema dinâmico com seres vivos que nascem, se reproduzem, se alimentam, se movem e morrem ao longo do tempo em um tabuleiro de 1000x1000 células.

## 🚀 Como funciona?

O jogo roda com ciclos de 1 segundo, onde cada célula do tabuleiro pode conter um ser vivo (ou estar vazia). Os seres têm comportamentos distintos conforme sua espécie, e o ecossistema evolui ao longo do tempo.

## 🌱 Tipos de seres vivos

| Tipo            | Cor        | Sobrevive sozinho? | Alimenta-se de     | Pode morrer por                      |
|-----------------|------------|--------------------|--------------------|--------------------------------------|
| 🦠 Bactéria      | Amarelo    | Sim                | —                  | Superpopulação (>3 vizinhos)         |
| 🌿 Planta        | Verde      | Sim                | —                  | Tempo / Vegetarianos                 |
| 🐑 Vegetariano   | Azul       | Não                | Plantas, bactérias | Fome / Carnívoros / Tempo            |
| 🦁 Carnívoro     | Vermelho   | Não                | Vegetarianos       | Fome / Tempo / Muitas bactérias      |

---

## 📊 Regras de reprodução e morte

| Ser           | Reproduz a cada | Morre após | Observações especiais                       |
|---------------|-----------------|------------|---------------------------------------------|
| Bactéria      | 1 ciclo         | 1 ciclo    | Se tiver mais de 3 vizinhos, morre         |
| Planta        | 3 ciclos        | 10 ciclos  | Reproduz se estiver perto de bactérias ou mortos |
| Vegetariano   | 6 ciclos        | 20 ciclos  | Come 1 planta a cada 5 ciclos; move por fome ou ameaça |
| Carnívoro     | 12 ciclos       | 40 ciclos  | Morre após 3 ciclos sem comida, anda se estiver sozinho |

---

## 🧠 Evolução dos instintos

- A cada **500 ciclos**, os animais recebem um "instinto":
  - Propriedades `Come` e `Mata` passam a apontar para uma espécie aleatória.
- Se 3 vizinhos com `Come` forem iguais → 1 deles desaparece.
- Se 3 vizinhos com `Mata` forem iguais → 2 deles desaparecem.

---

## 🕹️ Controles

- **Iniciar**: Começa a simulação. Inicia com 1 bactéria na posição (1,1).
- **Pausar**: Pausa a simulação sem perder o estado atual.
- **Parar**: Reinicia o jogo, apagando o tabuleiro.

---

## 🎨 Cores do tabuleiro

| Cor        | Representa     |
|------------|----------------|
| 🟨 Amarelo  | Bactéria       |
| 🟩 Verde    | Planta         |
| 🟦 Azul     | Vegetariano    |
| 🟥 Vermelho | Carnívoro      |
| ⬛ Preto    | Célula vazia   |

---

## 🛠️ Tecnologias utilizadas

- Lazarus / Free Pascal
- Programação orientada a objetos
- Interface gráfica com `TForm`, `TImage`, `TPanel`, `TTimer`

---

## ❤️ Autor

Simulação criada com carinho por [Marcelo Martins](https://github.com/maurinsoft)

---
