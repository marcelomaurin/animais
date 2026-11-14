# Roteiro de Desenvolvimento — Animais

Este documento registra o que já existe no código e o que está planejado. Regra: só é marcado como concluído o que está implementado.

---

## Concluído

### Motor da simulação

- [x] Tipos e classe `TSer` herdando de `TAISimEntity` (`uTipos.pas`).
- [x] Tabuleiro com dois estados e liberação de mortos no `Commit` (`uTabuleiro.pas`).
- [x] Configuração centralizada em `TConfig` (`uConfig.pas`).
- [x] Semeadura inicial e entrada tardia dos carnívoros.
- [x] Ciclo com idade, alimentação, fome, movimento e reprodução (`uSimulacao.pas`).
- [x] Busca de presa nas 8 direções, nos dois estados do tabuleiro.
- [x] Reprodução de animais e bactérias condicionada à alimentação.
- [x] Fome de bactéria.
- [x] Contagem populacional (`TEstat` e `TSimulacao.Contar`).
- [x] Configuração padrão em que os quatro grupos seguem vivos aos 10.000 ciclos (sementes 0 a 9).

### Interface

- [x] Tela com tema escuro desenhada em código, ajustada ao tamanho da janela.
- [x] Controles Iniciar/Pausar, Avançar 1 ciclo, Reiniciar e velocidade (1×, 4×, 16×), com atalhos de teclado.
- [x] Painel de população com quantidade, percentual e barra por grupo.
- [x] Gráfico de histórico dos últimos 600 ciclos.
- [x] Cartões de ciclo, semente e tempo por ciclo.
- [x] Tela de configurações (`uFormConfig.pas`).
- [x] Exportação do histórico completo em CSV.

### Programas de teste

- [x] `teste1.lpr` a `teste7.lpr`, um por etapa do plano de construção (apenas imprimem resultados).

---

## Pendente

### Usabilidade

- [ ] Gravar e carregar configurações em arquivo.
- [ ] Cenários pré-configurados.
- [ ] Foco por teclado nos botões da tela principal.

### Código

- [ ] Testes com verificação automática.
- [ ] Renderização por scanline para grades maiores.
- [ ] Avaliar o custo de `TAISimEntity` por ser.

### Integração com `openai_simulation`

- [ ] Migrar a grade para `TAIGridWorld`.
- [ ] Usar `TAIMovementEngine` e `TAIRuleEngine`.
- [ ] Usar `TAISimulationStats` e `TAIScenarioConfig`.

### Distribuição

- [x] Fontes em `src/`, executável em `bin/`.
- [x] Roteiro do instalador para Windows com Inno Setup (`instalador/animais.iss` e `gerar_instalador.bat`); o instalador sai em `bin/`.
- [ ] Compilação para Linux via `lazbuild`.
- [ ] Publicação de binários no GitHub.
