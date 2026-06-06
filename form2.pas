unit Form2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Math, Types, uTiposAnimais, uSeres, uTabuleiro, uSimulacao, uEstatisticas, uFormConfig,
  TAGraph, TASeries, Grids, ComCtrls;

type
  TForm2 = class(TForm)
    pnlSidebar: TPanel;
    lblStatsHeader: TLabel;
    lblCycle: TLabel;
    lblBacterias: TLabel;
    lblPlantas: TLabel;
    lblVegetarianos: TLabel;
    lblCarnivoros: TLabel;
    lblVazios: TLabel;
    lblTimeMs: TLabel;
    lblFPS: TLabel;
    btnStart: TButton;
    btnPause: TButton;
    btnStop: TButton;
    btnRestart: TButton;
    btnConfig: TButton;
    btnExport: TButton;
    btnAbout: TButton;
    imgBoard: TImage;
    tmCycle: TTimer;
    procedure btnStartClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmCycleTimer(Sender: TObject);
  private
    FSimulacao: TSimulacao;
    
    // Dynamic UI Components (Seção 23.10 and 24.2)
    pgcStats: TPageControl;
    tshResumo: TTabSheet;
    tshVivos: TTabSheet;
    tshMortos: TTabSheet;
    tshExtintos: TTabSheet;
    tshEvolucao: TTabSheet;
    
    // Resumo Tab
    lblResumoCycle: TLabel;
    lblResumoBacterias: TLabel;
    lblResumoPlantas: TLabel;
    lblResumoVegetarianos: TLabel;
    lblResumoCarnivoros: TLabel;
    lblResumoVazios: TLabel;
    
    lblResumoEspeciesVivas: TLabel;
    lblResumoEspeciesExtintas: TLabel;
    lblResumoSubEspeciesVivas: TLabel;
    lblResumoSubEspeciesExtintas: TLabel;
    lblResumoMortesAcumuladas: TLabel;
    lblResumoTimeMs: TLabel;
    lblResumoFPS: TLabel;
    
    // Grids for stats
    grdVivos: TStringGrid;
    grdMortos: TStringGrid;
    grdCausas: TStringGrid;
    grdExtintos: TStringGrid;
    
    // Evolution controls
    pnlEvolucaoTop: TPanel;
    lblEvolucaoTipo: TLabel;
    cmbEvolucaoTipo: TComboBox;
    lblEvolucaoSub: TLabel;
    cmbEvolucaoSub: TComboBox;
    btnEvolucaoAtualizar: TButton;
    btnEvolucaoExportar: TButton;
    
    chartEvolucao: TChart;
    seriesEvolucao: TLineSeries;
    grdEvolucaoDados: TStringGrid;

    procedure Desenha;
    procedure AtualizarStats;
    procedure AtualizarBotoes;
    procedure cmbEvolucaoTipoChange(Sender: TObject);
    procedure cmbEvolucaoSubChange(Sender: TObject);
    procedure AtualizaGraficoSubEspecie;
    procedure btnEvolucaoAtualizarClick(Sender: TObject);
    procedure btnEvolucaoExportarClick(Sender: TObject);
    procedure grdVivosPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure grdExtintosPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
  public
    destructor Destroy; override;
  end;

var
  frmForm2: TForm2;

implementation

{$R *.lfm}

procedure TForm2.FormCreate(Sender: TObject);
var
  pnlButtons: TPanel;
begin
  FSimulacao := TSimulacao.Create;
  FSimulacao.Inicializar;
  
  // Set window and sidebar size (Seção 24.1)
  Self.Width := 1150;
  pnlSidebar.Width := 450;
  
  // Hide old stats controls
  lblCycle.Visible := False;
  lblBacterias.Visible := False;
  lblPlantas.Visible := False;
  lblVegetarianos.Visible := False;
  lblCarnivoros.Visible := False;
  lblVazios.Visible := False;
  lblTimeMs.Visible := False;
  lblFPS.Visible := False;
  lblStatsHeader.Visible := False;
  
  // Create Bottom Panel for buttons
  pnlButtons := TPanel.Create(Self);
  pnlButtons.Parent := pnlSidebar;
  pnlButtons.Align := alBottom;
  pnlButtons.Height := 135;
  pnlButtons.Color := pnlSidebar.Color;
  pnlButtons.BevelOuter := bvNone;
  
  // Reparent and position existing buttons in a clean layout
  btnStart.Parent := pnlButtons;
  btnPause.Parent := pnlButtons;
  btnStop.Parent := pnlButtons;
  btnRestart.Parent := pnlButtons;
  btnConfig.Parent := pnlButtons;
  btnExport.Parent := pnlButtons;
  btnAbout.Parent := pnlButtons;
  
  btnStart.SetBounds(10, 10, 130, 30);
  btnPause.SetBounds(150, 10, 130, 30);
  btnStop.SetBounds(290, 10, 130, 30);
  
  btnRestart.SetBounds(10, 50, 130, 30);
  btnConfig.SetBounds(150, 50, 130, 30);
  btnExport.SetBounds(290, 50, 130, 30);
  
  btnAbout.SetBounds(10, 90, 410, 30);
  
  // Create TPageControl
  pgcStats := TPageControl.Create(Self);
  pgcStats.Parent := pnlSidebar;
  pgcStats.Align := alClient;
  
  // Create TabSheets (Seção 23.10 and 24.2)
  tshResumo := TTabSheet.Create(Self);
  tshResumo.PageControl := pgcStats;
  tshResumo.Caption := 'Resumo';
  
  tshVivos := TTabSheet.Create(Self);
  tshVivos.PageControl := pgcStats;
  tshVivos.Caption := 'Vivos';
  
  tshMortos := TTabSheet.Create(Self);
  tshMortos.PageControl := pgcStats;
  tshMortos.Caption := 'Mortos';
  
  tshExtintos := TTabSheet.Create(Self);
  tshExtintos.PageControl := pgcStats;
  tshExtintos.Caption := 'Extintos';
  
  tshEvolucao := TTabSheet.Create(Self);
  tshEvolucao.PageControl := pgcStats;
  tshEvolucao.Caption := 'Evolução';
  
  // Setup Resumo Tab labels
  lblResumoCycle := TLabel.Create(Self); lblResumoCycle.Parent := tshResumo; lblResumoCycle.SetBounds(20, 15, 400, 20); lblResumoCycle.Font.Color := clWhite; lblResumoCycle.Font.Size := 10;
  lblResumoBacterias := TLabel.Create(Self); lblResumoBacterias.Parent := tshResumo; lblResumoBacterias.SetBounds(20, 40, 400, 20); lblResumoBacterias.Font.Color := VAL_COLOR_BACTERIA; lblResumoBacterias.Font.Style := [fsBold];
  lblResumoPlantas := TLabel.Create(Self); lblResumoPlantas.Parent := tshResumo; lblResumoPlantas.SetBounds(20, 65, 400, 20); lblResumoPlantas.Font.Color := VAL_COLOR_PLANTA; lblResumoPlantas.Font.Style := [fsBold];
  lblResumoVegetarianos := TLabel.Create(Self); lblResumoVegetarianos.Parent := tshResumo; lblResumoVegetarianos.SetBounds(20, 90, 400, 20); lblResumoVegetarianos.Font.Color := VAL_COLOR_VEGETARIANO; lblResumoVegetarianos.Font.Style := [fsBold];
  lblResumoCarnivoros := TLabel.Create(Self); lblResumoCarnivoros.Parent := tshResumo; lblResumoCarnivoros.SetBounds(20, 115, 400, 20); lblResumoCarnivoros.Font.Color := VAL_COLOR_CARNIVORO; lblResumoCarnivoros.Font.Style := [fsBold];
  
  lblResumoVazios := TLabel.Create(Self); lblResumoVazios.Parent := tshResumo; lblResumoVazios.SetBounds(20, 145, 400, 20); lblResumoVazios.Font.Color := clGray;
  lblResumoEspeciesVivas := TLabel.Create(Self); lblResumoEspeciesVivas.Parent := tshResumo; lblResumoEspeciesVivas.SetBounds(20, 170, 400, 20); lblResumoEspeciesVivas.Font.Color := clWhite;
  lblResumoSubEspeciesVivas := TLabel.Create(Self); lblResumoSubEspeciesVivas.Parent := tshResumo; lblResumoSubEspeciesVivas.SetBounds(20, 195, 400, 20); lblResumoSubEspeciesVivas.Font.Color := clWhite;
  lblResumoEspeciesExtintas := TLabel.Create(Self); lblResumoEspeciesExtintas.Parent := tshResumo; lblResumoEspeciesExtintas.SetBounds(20, 220, 400, 20); lblResumoEspeciesExtintas.Font.Color := clRed;
  lblResumoSubEspeciesExtintas := TLabel.Create(Self); lblResumoSubEspeciesExtintas.Parent := tshResumo; lblResumoSubEspeciesExtintas.SetBounds(20, 245, 400, 20); lblResumoSubEspeciesExtintas.Font.Color := clRed;
  lblResumoMortesAcumuladas := TLabel.Create(Self); lblResumoMortesAcumuladas.Parent := tshResumo; lblResumoMortesAcumuladas.SetBounds(20, 275, 400, 20); lblResumoMortesAcumuladas.Font.Color := clWhite;
  lblResumoTimeMs := TLabel.Create(Self); lblResumoTimeMs.Parent := tshResumo; lblResumoTimeMs.SetBounds(20, 305, 400, 20); lblResumoTimeMs.Font.Color := clLtGray;
  lblResumoFPS := TLabel.Create(Self); lblResumoFPS.Parent := tshResumo; lblResumoFPS.SetBounds(20, 330, 400, 20); lblResumoFPS.Font.Color := clLtGray;
  
  // Setup grdVivos
  grdVivos := TStringGrid.Create(Self);
  grdVivos.Parent := tshVivos;
  grdVivos.Align := alClient;
  grdVivos.ColCount := 2;
  grdVivos.RowCount := 16;
  grdVivos.FixedCols := 0;
  grdVivos.FixedRows := 1;
  grdVivos.Cells[0, 0] := 'Subespécie';
  grdVivos.Cells[1, 0] := 'Vivos';
  grdVivos.ColWidths[0] := 300;
  grdVivos.ColWidths[1] := 100;
  grdVivos.OnPrepareCanvas := @grdVivosPrepareCanvas;
  
  // Setup grdMortos & grdCausas
  grdMortos := TStringGrid.Create(Self);
  grdMortos.Parent := tshMortos;
  grdMortos.Align := alClient;
  grdMortos.ColCount := 2;
  grdMortos.RowCount := 16;
  grdMortos.FixedCols := 0;
  grdMortos.FixedRows := 1;
  grdMortos.Cells[0, 0] := 'Subespécie';
  grdMortos.Cells[1, 0] := 'Mortos Acum.';
  grdMortos.ColWidths[0] := 200;
  grdMortos.ColWidths[1] := 90;
  
  grdCausas := TStringGrid.Create(Self);
  grdCausas.Parent := tshMortos;
  grdCausas.Align := alRight;
  grdCausas.Width := 130;
  grdCausas.ColCount := 2;
  grdCausas.RowCount := 8;
  grdCausas.FixedCols := 0;
  grdCausas.FixedRows := 1;
  grdCausas.Cells[0, 0] := 'Causa';
  grdCausas.Cells[1, 0] := 'Qtd';
  grdCausas.ColWidths[0] := 75;
  grdCausas.ColWidths[1] := 45;
  grdCausas.Cells[0, 1] := 'Fome';
  grdCausas.Cells[0, 2] := 'Idade';
  grdCausas.Cells[0, 3] := 'Predação';
  grdCausas.Cells[0, 4] := 'Veneno';
  grdCausas.Cells[0, 5] := 'Toxina';
  grdCausas.Cells[0, 6] := 'Aleatória';
  grdCausas.Cells[0, 7] := 'Conflito';
  
  // Setup grdExtintos
  grdExtintos := TStringGrid.Create(Self);
  grdExtintos.Parent := tshExtintos;
  grdExtintos.Align := alClient;
  grdExtintos.ColCount := 2;
  grdExtintos.RowCount := 1;
  grdExtintos.FixedCols := 0;
  grdExtintos.FixedRows := 1;
  grdExtintos.Cells[0, 0] := 'Subespécie';
  grdExtintos.Cells[1, 0] := 'Ciclo Extinção';
  grdExtintos.ColWidths[0] := 300;
  grdExtintos.ColWidths[1] := 100;
  grdExtintos.OnPrepareCanvas := @grdExtintosPrepareCanvas;
  
  // Setup tshEvolucao controls (Seção 24.3)
  pnlEvolucaoTop := TPanel.Create(Self);
  pnlEvolucaoTop.Parent := tshEvolucao;
  pnlEvolucaoTop.Align := alTop;
  pnlEvolucaoTop.Height := 80;
  pnlEvolucaoTop.Color := pnlSidebar.Color;
  pnlEvolucaoTop.BevelOuter := bvNone;
  
  lblEvolucaoTipo := TLabel.Create(Self);
  lblEvolucaoTipo.Parent := pnlEvolucaoTop;
  lblEvolucaoTipo.Caption := 'Tipo Principal';
  lblEvolucaoTipo.SetBounds(10, 5, 120, 15);
  lblEvolucaoTipo.Font.Color := clWhite;
  
  cmbEvolucaoTipo := TComboBox.Create(Self);
  cmbEvolucaoTipo.Parent := pnlEvolucaoTop;
  cmbEvolucaoTipo.Style := csDropDownList;
  cmbEvolucaoTipo.SetBounds(10, 22, 120, 25);
  cmbEvolucaoTipo.Items.Add('Bactéria');
  cmbEvolucaoTipo.Items.Add('Planta');
  cmbEvolucaoTipo.Items.Add('Herbívoro');
  cmbEvolucaoTipo.Items.Add('Carnívoro');
  cmbEvolucaoTipo.ItemIndex := 1; // Planta default
  cmbEvolucaoTipo.OnChange := @cmbEvolucaoTipoChange;
  
  lblEvolucaoSub := TLabel.Create(Self);
  lblEvolucaoSub.Parent := pnlEvolucaoTop;
  lblEvolucaoSub.Caption := 'Subespécie';
  lblEvolucaoSub.SetBounds(140, 5, 200, 15);
  lblEvolucaoSub.Font.Color := clWhite;
  
  cmbEvolucaoSub := TComboBox.Create(Self);
  cmbEvolucaoSub.Parent := pnlEvolucaoTop;
  cmbEvolucaoSub.Style := csDropDownList;
  cmbEvolucaoSub.SetBounds(140, 22, 200, 25);
  cmbEvolucaoSub.OnChange := @cmbEvolucaoSubChange;
  
  btnEvolucaoAtualizar := TButton.Create(Self);
  btnEvolucaoAtualizar.Parent := pnlEvolucaoTop;
  btnEvolucaoAtualizar.Caption := 'Atualizar';
  btnEvolucaoAtualizar.SetBounds(350, 5, 80, 23);
  btnEvolucaoAtualizar.OnClick := @btnEvolucaoAtualizarClick;
  
  btnEvolucaoExportar := TButton.Create(Self);
  btnEvolucaoExportar.Parent := pnlEvolucaoTop;
  btnEvolucaoExportar.Caption := 'Exportar';
  btnEvolucaoExportar.SetBounds(350, 32, 80, 23);
  btnEvolucaoExportar.OnClick := @btnEvolucaoExportarClick;
  
  // grdEvolucaoDados for tabular display (Seção 24.8)
  grdEvolucaoDados := TStringGrid.Create(Self);
  grdEvolucaoDados.Parent := tshEvolucao;
  grdEvolucaoDados.Align := alRight;
  grdEvolucaoDados.Width := 150;
  grdEvolucaoDados.ColCount := 2;
  grdEvolucaoDados.RowCount := 1;
  grdEvolucaoDados.FixedCols := 0;
  grdEvolucaoDados.FixedRows := 1;
  grdEvolucaoDados.Cells[0, 0] := 'Ciclo';
  grdEvolucaoDados.Cells[1, 0] := 'Vivos';
  grdEvolucaoDados.ColWidths[0] := 70;
  grdEvolucaoDados.ColWidths[1] := 60;
  
  // TAChart (Seção 24.6)
  chartEvolucao := TChart.Create(Self);
  chartEvolucao.Parent := tshEvolucao;
  chartEvolucao.Align := alClient;
  chartEvolucao.Title.Text.Add('Evolução populacional da subespécie');
  chartEvolucao.Title.Visible := True;
  chartEvolucao.LeftAxis.Title.Caption := 'Indivíduos vivos';
  chartEvolucao.LeftAxis.Title.Visible := True;
  chartEvolucao.BottomAxis.Title.Caption := 'Ciclo';
  chartEvolucao.BottomAxis.Title.Visible := True;
  chartEvolucao.Color := $1E1E1E; // Dark graph background
  chartEvolucao.BackColor := $1E1E1E;
  chartEvolucao.LeftAxis.Marks.LabelFont.Color := clWhite;
  chartEvolucao.BottomAxis.Marks.LabelFont.Color := clWhite;
  
  seriesEvolucao := TLineSeries.Create(chartEvolucao);
  seriesEvolucao.SeriesColor := clAqua;
  seriesEvolucao.Title := 'Subespécie';
  chartEvolucao.AddSeries(seriesEvolucao);
  
  // Populate initial sub-species list
  cmbEvolucaoTipoChange(nil);
  
  imgBoard.Picture.Bitmap.SetSize(FSimulacao.Tabuleiro.W, FSimulacao.Tabuleiro.H);
  imgBoard.Picture.Bitmap.PixelFormat := pf32bit;
  
  Desenha;
  AtualizarStats;
  AtualizarBotoes;
end;

destructor TForm2.Destroy;
begin
  FSimulacao.Free;
  inherited Destroy;
end;

procedure TForm2.btnStartClick(Sender: TObject);
begin
  if FSimulacao.CicloAtual = 0 then
  begin
    FSimulacao.Inicializar;
    imgBoard.Picture.Bitmap.SetSize(FSimulacao.Tabuleiro.W, FSimulacao.Tabuleiro.H);
    imgBoard.Picture.Bitmap.PixelFormat := pf32bit;
  end;
  
  tmCycle.Interval := FSimulacao.Config.IntervaloTimer;
  tmCycle.Enabled := True;
  
  AtualizarBotoes;
end;

procedure TForm2.btnPauseClick(Sender: TObject);
begin
  tmCycle.Enabled := False;
  AtualizarBotoes;
end;

procedure TForm2.btnStopClick(Sender: TObject);
begin
  tmCycle.Enabled := False;
  FSimulacao.Reiniciar;
  Desenha;
  AtualizarStats;
  AtualizarBotoes;
end;

procedure TForm2.btnRestartClick(Sender: TObject);
begin
  tmCycle.Enabled := False;
  FSimulacao.Reiniciar;
  Desenha;
  AtualizarStats;
  
  tmCycle.Interval := FSimulacao.Config.IntervaloTimer;
  tmCycle.Enabled := True;
  AtualizarBotoes;
end;

procedure TForm2.btnConfigClick(Sender: TObject);
var
  cfg: TSimulacaoConfig;
begin
  cfg := FSimulacao.Config;
  if ObterConfigSimulacao(cfg) then
  begin
    FSimulacao.Configurar(cfg);
    FSimulacao.Inicializar;
    
    imgBoard.Picture.Bitmap.SetSize(FSimulacao.Tabuleiro.W, FSimulacao.Tabuleiro.H);
    imgBoard.Picture.Bitmap.PixelFormat := pf32bit;
    
    Desenha;
    AtualizarStats;
    AtualizarBotoes;
  end;
end;

procedure TForm2.btnExportClick(Sender: TObject);
var
  path: string;
begin
  // Save in the docs folder relative to project root
  path := ExtractFilePath(ParamStr(0)) + 'docs' + PathDelim + 'exemplo_saida.csv';
  
  // Make sure docs folder exists
  ForceDirectories(ExtractFilePath(path));
  
  try
    FSimulacao.Historico.ExportarCSV(path);
    ShowMessage('Histórico populacional exportado com sucesso para:' + sLineBreak + path);
  except
    on E: Exception do
      ShowMessage('Erro ao exportar CSV: ' + E.Message);
  end;
end;

procedure TForm2.btnAboutClick(Sender: TObject);
begin
  ShowMessage(
    'Animais — Jogo da Vida Evoluído' + sLineBreak +
    'Versão 2.0' + sLineBreak + sLineBreak +
    'Uma simulação ecológica interativa construída em Lazarus / Free Pascal.' + sLineBreak +
    'Desenvolvido para fins didáticos de modelagem evolutiva.'
  );
end;

procedure TForm2.tmCycleTimer(Sender: TObject);
begin
  FSimulacao.ExecutarCiclo;
  Desenha;
  AtualizarStats;
end;

procedure TForm2.Desenha;
var
  x, y: Integer;
  bmp: TBitmap;
  c: LongWord;
  Line: PLongWord;
  tab: TTabuleiro;
  ent: TSer;
begin
  tab := FSimulacao.Tabuleiro;
  bmp := imgBoard.Picture.Bitmap;
  
  bmp.BeginUpdate;
  try
    for y := 0 to tab.H - 1 do
    begin
      Line := bmp.ScanLine[y];
      for x := 0 to tab.W - 1 do
      begin
        ent := tab.GetEntAt(x, y);
        if ent <> nil then
        begin
          case ent.Tipo of
            tsBacteria:
            begin
              if ent.Toxicidade = txToxica then
                c := $800080  // Roxo (Bactéria tóxica)
              else
                c := VAL_COLOR_BACTERIA;
            end;
            tsPlanta:
            begin
              if ent.Toxicidade = txToxica then
                c := $008000  // Verde escuro (Planta venenosa)
              else if ent.ResistenciaToxina = rtResistente then
                c := $80FF80  // Verde claro (Planta resistente)
              else
                c := VAL_COLOR_PLANTA;
            end;
            tsVegetariano:
            begin
              if ent.ResistenciaVeneno = rvResistente then
                c := $00FFFF  // Amarelo/Ciano (Herbívoro resistente)
              else
                c := VAL_COLOR_VEGETARIANO;
            end;
            tsCarnivoro:
            begin
              case ent.Tamanho of
                taPequeno: c := $FF8080; // Vermelho claro
                taGrande:  c := $800000; // Vermelho escuro
                else       c := VAL_COLOR_CARNIVORO;
              end;
            end;
            else c := COLOR_NONE;
          end;
        end
        else
          c := COLOR_NONE;
        Line[x] := c;
      end;
    end;
  finally
    bmp.EndUpdate;
  end;
  
  imgBoard.Invalidate;
end;

procedure TForm2.AtualizarStats;
var
  stats: TEstatisticasSimulacao;
  i: Integer;
begin
  stats := FSimulacao.CalculaEstatisticas;
  
  // Update old labels just in case
  lblCycle.Caption := Format('Ciclo: %d', [stats.Ciclo]);
  lblBacterias.Caption := Format('Bactérias: %d', [stats.Bacterias]);
  lblPlantas.Caption := Format('Plantas: %d', [stats.Plantas]);
  lblVegetarianos.Caption := Format('Vegetarianos: %d', [stats.Vegetarianos]);
  lblCarnivoros.Caption := Format('Carnívoros: %d', [stats.Carnivoros]);
  lblVazios.Caption := Format('Células Vazias: %d', [stats.Vazios]);
  lblTimeMs.Caption := Format('Tempo Ciclo: %.1f ms', [stats.TempoCicloMs]);
  lblFPS.Caption := Format('FPS: %.1f', [stats.FPS]);
  
  // 1. Resumo Tab (Seção 23.4, 23.5 & 23.10)
  lblResumoCycle.Caption := Format('Ciclo: %d', [stats.Ciclo]);
  lblResumoBacterias.Caption := Format('Bactérias: %d (Tóxicas: %d, Comuns: %d)', [stats.Bacterias, stats.BacteriasToxicas, stats.BacteriasNaoToxicas]);
  lblResumoPlantas.Caption := Format('Plantas: %d (Venenosas: %d, Resistentes: %d)', [stats.Plantas, stats.PlantasVenenosas, stats.PlantasResistentesToxina]);
  lblResumoVegetarianos.Caption := Format('Vegetarianos: %d (Resistentes: %d, P/M/G: %d/%d/%d)', [stats.Vegetarianos, stats.HerbivorosResistentesVeneno, stats.HerbivorosPequenos, stats.HerbivorosMedios, stats.HerbivorosGrandes]);
  lblResumoCarnivoros.Caption := Format('Carnívoros: %d (P/M/G: %d/%d/%d)', [stats.Carnivoros, stats.CarnivorosPequenos, stats.CarnivorosMedios, stats.CarnivorosGrandes]);
  lblResumoVazios.Caption := Format('Células Vazias: %d', [stats.Vazios]);
  
  lblResumoEspeciesVivas.Caption := Format('Espécies vivas: %d', [stats.EspeciesVivas]);
  lblResumoSubEspeciesVivas.Caption := Format('Subespécies vivas: %d', [stats.SubEspeciesVivas]);
  lblResumoEspeciesExtintas.Caption := Format('Espécies extintas: %d', [stats.EspeciesExtintas]);
  lblResumoSubEspeciesExtintas.Caption := Format('Subespécies extintas: %d', [stats.SubEspeciesExtintas]);
  lblResumoMortesAcumuladas.Caption := Format('Mortes acumuladas: %d', [stats.MortesAcumuladas]);
  
  lblResumoTimeMs.Caption := Format('Tempo Ciclo: %.1f ms', [stats.TempoCicloMs]);
  lblResumoFPS.Caption := Format('FPS: %.1f', [stats.FPS]);
  
  // 2. Vivos Tab (Seção 23.4)
  for i := 0 to 14 do
  begin
    grdVivos.Cells[0, i + 1] := stats.SubEspecies[i].Nome;
    grdVivos.Cells[1, i + 1] := IntToStr(stats.SubEspecies[i].Vivos);
  end;
  
  // 3. Mortos Tab (Seção 23.6)
  for i := 0 to 14 do
  begin
    grdMortos.Cells[0, i + 1] := stats.SubEspecies[i].Nome;
    grdMortos.Cells[1, i + 1] := IntToStr(stats.SubEspecies[i].Mortos);
  end;
  
  grdCausas.Cells[1, 1] := IntToStr(stats.MortesFomeCausa);
  grdCausas.Cells[1, 2] := IntToStr(stats.MortesIdade);
  grdCausas.Cells[1, 3] := IntToStr(stats.MortesPredacao);
  grdCausas.Cells[1, 4] := IntToStr(stats.MortesVenenoCausa);
  grdCausas.Cells[1, 5] := IntToStr(stats.MortesToxinaCausa);
  grdCausas.Cells[1, 6] := IntToStr(stats.MortesAleatoria);
  grdCausas.Cells[1, 7] := IntToStr(stats.MortesConflito);
  
  // 4. Extintos Tab (Seção 23.7 & 23.10)
  grdExtintos.RowCount := 1;
  for i := 0 to 14 do
  begin
    if stats.SubEspecies[i].Extinta then
    begin
      grdExtintos.RowCount := grdExtintos.RowCount + 1;
      grdExtintos.Cells[0, grdExtintos.RowCount - 1] := stats.SubEspecies[i].Nome;
      grdExtintos.Cells[1, grdExtintos.RowCount - 1] := IntToStr(stats.SubEspecies[i].CicloExtincao);
    end;
  end;
  
  // 5. Opção B (atualização automática do gráfico de evolução a cada N ciclos)
  // Seção 24.12
  if (pgcStats.ActivePage = tshEvolucao) and 
     (FSimulacao.Config.IntervaloAtualizacaoGrafico > 0) and
     (stats.Ciclo mod FSimulacao.Config.IntervaloAtualizacaoGrafico = 0) then
  begin
    AtualizaGraficoSubEspecie;
  end;
end;

procedure TForm2.cmbEvolucaoTipoChange(Sender: TObject);
begin
  cmbEvolucaoSub.Items.Clear;
  case cmbEvolucaoTipo.ItemIndex of
    0: // Bactéria
    begin
      cmbEvolucaoSub.Items.Add('Bactéria não tóxica');
      cmbEvolucaoSub.Items.Add('Bactéria tóxica');
    end;
    1: // Planta
    begin
      cmbEvolucaoSub.Items.Add('Planta comum');
      cmbEvolucaoSub.Items.Add('Planta venenosa');
      cmbEvolucaoSub.Items.Add('Planta resistente à toxina bacteriana');
      cmbEvolucaoSub.Items.Add('Planta venenosa resistente à toxina bacteriana');
    end;
    2: // Herbívoro
    begin
      cmbEvolucaoSub.Items.Add('Herbívoro pequeno comum');
      cmbEvolucaoSub.Items.Add('Herbívoro médio comum');
      cmbEvolucaoSub.Items.Add('Herbívoro grande comum');
      cmbEvolucaoSub.Items.Add('Herbívoro pequeno resistente a veneno');
      cmbEvolucaoSub.Items.Add('Herbívoro médio resistente a veneno');
      cmbEvolucaoSub.Items.Add('Herbívoro grande resistente a veneno');
    end;
    3: // Carnívoro
    begin
      cmbEvolucaoSub.Items.Add('Carnívoro pequeno');
      cmbEvolucaoSub.Items.Add('Carnívoro médio');
      cmbEvolucaoSub.Items.Add('Carnívoro grande');
    end;
  end;
  cmbEvolucaoSub.ItemIndex := 0;
  AtualizaGraficoSubEspecie;
end;

procedure TForm2.cmbEvolucaoSubChange(Sender: TObject);
begin
  AtualizaGraficoSubEspecie;
end;

procedure TForm2.AtualizaGraficoSubEspecie;
var
  i, j: Integer;
  hist: TEstatisticasHistorico;
  stat: TEstatisticasSimulacao;
  selSub: string;
  selTipo: TTipoSer;
  Step: Integer;
begin
  seriesEvolucao.Clear;
  grdEvolucaoDados.RowCount := 1;
  
  selSub := cmbEvolucaoSub.Text;
  case cmbEvolucaoTipo.ItemIndex of
    0: selTipo := tsBacteria;
    1: selTipo := tsPlanta;
    2: selTipo := tsVegetariano;
    3: selTipo := tsCarnivoro;
    else selTipo := uTiposAnimais.tsNone;
  end;
  
  // Legenda: Nome da subespécie selecionada (Seção 24.6)
  seriesEvolucao.Title := selSub;
  
  hist := FSimulacao.Historico;
  
  // Limitar quantidade de pontos exibidos se necessário (Seção 24.9)
  // Downsampling to keep UI responsive and prevent interface locking
  Step := 1;
  if hist.Count > 1000 then
    Step := hist.Count div 1000;
    
  i := 0;
  while i < hist.Count do
  begin
    stat := hist.History[i];
    for j := 0 to 14 do
    begin
      if (stat.SubEspecies[j].TipoPrincipal = selTipo) and (stat.SubEspecies[j].Nome = selSub) then
      begin
        // Add point to chart
        seriesEvolucao.AddXY(stat.Ciclo, stat.SubEspecies[j].Vivos);
        
        // Add row to data grid
        grdEvolucaoDados.RowCount := grdEvolucaoDados.RowCount + 1;
        grdEvolucaoDados.Cells[0, grdEvolucaoDados.RowCount - 1] := IntToStr(stat.Ciclo);
        grdEvolucaoDados.Cells[1, grdEvolucaoDados.RowCount - 1] := IntToStr(stat.SubEspecies[j].Vivos);
        
        Break;
      end;
    end;
    
    // Always include the last point in the downsampling to show current state accurately
    if (i < hist.Count - 1) and (i + Step >= hist.Count) then
      i := hist.Count - 1
    else
      i := i + Step;
  end;
  
  // Show extinction banner in title if extinct (Seção 24.11)
  for j := 0 to 14 do
  begin
    if FSimulacao.CalculaEstatisticas.SubEspecies[j].Nome = selSub then
    begin
      if FSimulacao.CalculaEstatisticas.SubEspecies[j].Extinta then
      begin
        chartEvolucao.Title.Text.Clear;
        chartEvolucao.Title.Text.Add(Format('%s (Extinta no ciclo %d)', [
          selSub, FSimulacao.CalculaEstatisticas.SubEspecies[j].CicloExtincao
        ]));
      end
      else
      begin
        chartEvolucao.Title.Text.Clear;
        chartEvolucao.Title.Text.Add('Evolução populacional da subespécie');
      end;
      Break;
    end;
  end;
end;

procedure TForm2.btnEvolucaoAtualizarClick(Sender: TObject);
begin
  AtualizaGraficoSubEspecie;
end;

procedure TForm2.btnEvolucaoExportarClick(Sender: TObject);
var
  path: string;
  list: TStringList;
  i, j: Integer;
  hist: TEstatisticasHistorico;
  stat: TEstatisticasSimulacao;
  selSub: string;
  selTipo: TTipoSer;
  tipoStr: string;
begin
  selSub := cmbEvolucaoSub.Text;
  case cmbEvolucaoTipo.ItemIndex of
    0: begin selTipo := tsBacteria; tipoStr := 'Bactéria'; end;
    1: begin selTipo := tsPlanta; tipoStr := 'Planta'; end;
    2: begin selTipo := tsVegetariano; tipoStr := 'Herbívoro'; end;
    3: begin selTipo := tsCarnivoro; tipoStr := 'Carnívoro'; end;
    else begin selTipo := uTiposAnimais.tsNone; tipoStr := 'Nenhum'; end;
  end;
  
  path := ExtractFilePath(ParamStr(0)) + 'docs' + PathDelim + 'historico_subespecie.csv';
  ForceDirectories(ExtractFilePath(path));
  
  list := TStringList.Create;
  try
    list.Add('ciclo,tipo,subespecie,vivos');
    hist := FSimulacao.Historico;
    for i := 0 to hist.Count - 1 do
    begin
      stat := hist.History[i];
      for j := 0 to 14 do
      begin
        if (stat.SubEspecies[j].TipoPrincipal = selTipo) and (stat.SubEspecies[j].Nome = selSub) then
        begin
          list.Add(Format('%d,%s,%s,%d', [
            stat.Ciclo,
            tipoStr,
            selSub,
            stat.SubEspecies[j].Vivos
          ]));
          Break;
        end;
      end;
    end;
    list.SaveToFile(path);
    ShowMessage('Histórico da subespécie exportado com sucesso para:' + sLineBreak + path);
  finally
    list.Free;
  end;
end;

procedure TForm2.grdVivosPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
var
  grid: TStringGrid;
  valStr: string;
  val: Integer;
begin
  grid := Sender as TStringGrid;
  if (aRow > 0) and (aCol = 1) then
  begin
    valStr := grid.Cells[aCol, aRow];
    val := StrToIntDef(valStr, 0);
    // Destacar subespécies em risco (Seção 23.11)
    if (val > 0) and (val <= 3) then
    begin
      grid.Canvas.Brush.Color := $00FFFF; // Yellow background (BGR $00FFFF = yellow)
      grid.Canvas.Font.Color := clBlack;
    end;
  end;
end;

procedure TForm2.grdExtintosPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
var
  grid: TStringGrid;
begin
  grid := Sender as TStringGrid;
  if aRow > 0 then
  begin
    // Destacar subespécies extintas (Seção 23.11)
    grid.Canvas.Brush.Color := $D0D0D0; // Light Gray background
    grid.Canvas.Font.Color := clRed;    // Red font
  end;
end;

procedure TForm2.AtualizarBotoes;
var
  isRunning, isPaused, isStopped: Boolean;
begin
  isRunning := tmCycle.Enabled;
  isStopped := (FSimulacao.CicloAtual = 0) and (not tmCycle.Enabled);
  isPaused := (FSimulacao.CicloAtual > 0) and (not tmCycle.Enabled);
  
  // Set button enabled states matching Section 8.3 requirements
  if isRunning then
  begin
    btnStart.Enabled := False;
    btnPause.Enabled := True;
    btnStop.Enabled := True;
    btnRestart.Enabled := True;
    btnConfig.Enabled := False;
    btnExport.Enabled := False;
  end
  else if isPaused then
  begin
    btnStart.Enabled := True;
    btnStart.Caption := 'Continuar';
    btnPause.Enabled := False;
    btnStop.Enabled := True;
    btnRestart.Enabled := True;
    btnConfig.Enabled := False;
    btnExport.Enabled := True;
  end
  else if isStopped then
  begin
    btnStart.Enabled := True;
    btnStart.Caption := 'Iniciar';
    btnPause.Enabled := False;
    btnStop.Enabled := False;
    btnRestart.Enabled := False;
    btnConfig.Enabled := True;
    btnExport.Enabled := False;
  end;
end;

end.
