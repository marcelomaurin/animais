unit Form2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  uConfig, uTipos, uTabuleiro, uSimulacao, uEstat;

type

  { TForm2 }

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
    FLastTime: QWord;
    
    procedure Desenha;
    procedure AtualizarStats;
  end;

var
  frmform2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  FSimulacao := TSimulacao.Create(ConfigPadrao);
  FLastTime := GetTickCount64;
  Desenha;
  AtualizarStats;
end;

procedure TForm2.btnStartClick(Sender: TObject);
begin
  tmCycle.Enabled := True;
end;

procedure TForm2.btnPauseClick(Sender: TObject);
begin
  tmCycle.Enabled := False;
end;

procedure TForm2.btnStopClick(Sender: TObject);
begin
  tmCycle.Enabled := False;
  FSimulacao.Free;
  FSimulacao := TSimulacao.Create(ConfigPadrao);
  Desenha;
  AtualizarStats;
end;

procedure TForm2.btnRestartClick(Sender: TObject);
begin
  FSimulacao.Free;
  FSimulacao := TSimulacao.Create(ConfigPadrao);
  Desenha;
  AtualizarStats;
end;

procedure TForm2.tmCycleTimer(Sender: TObject);
var
  T1, T2: QWord;
begin
  T1 := GetTickCount64;
  FSimulacao.ExecutarCiclo;
  T2 := GetTickCount64;
  
  // Calcula FPS e tempo gasto
  lblTimeMs.Caption := Format('Tempo: %d ms', [T2 - T1]);
  if T2 > FLastTime then
    lblFPS.Caption := Format('FPS: %d', [Round(1000.0 / (T2 - FLastTime))]);
  FLastTime := T2;

  Desenha;
  AtualizarStats;
end;

procedure TForm2.Desenha;
var
  X, Y: Integer;
  CellW, CellH: Double;
  Ser: TSer;
  R: TRect;
begin
  if FSimulacao = nil then Exit;
  
  // Limpa imagem com preto
  imgBoard.Canvas.Brush.Color := clBlack;
  imgBoard.Canvas.FillRect(imgBoard.ClientRect);
  
  CellW := imgBoard.Width / FSimulacao.Tabuleiro.W;
  CellH := imgBoard.Height / FSimulacao.Tabuleiro.H;
  
  for X := 0 to FSimulacao.Tabuleiro.W - 1 do
  begin
    for Y := 0 to FSimulacao.Tabuleiro.H - 1 do
    begin
      Ser := FSimulacao.Tabuleiro.GetSer(X, Y);
      if Ser <> nil then
      begin
        case Ser.Tipo of
          tBacteria: imgBoard.Canvas.Brush.Color := clYellow;
          tPlanta: imgBoard.Canvas.Brush.Color := clGreen;
          tHerbivoro: imgBoard.Canvas.Brush.Color := clBlue;
          tCarnivoro: imgBoard.Canvas.Brush.Color := clRed;
          tMateria: imgBoard.Canvas.Brush.Color := RGBToColor(139, 69, 19); // Marrom
        end;
        
        R.Left := Round(X * CellW);
        R.Top := Round(Y * CellH);
        R.Right := Round((X + 1) * CellW);
        R.Bottom := Round((Y + 1) * CellH);
        imgBoard.Canvas.FillRect(R);
      end;
    end;
  end;
end;

procedure TForm2.AtualizarStats;
var
  Est: TEstat;
begin
  if FSimulacao = nil then Exit;
  
  Est := FSimulacao.Contar;
  lblCycle.Caption := Format('Ciclo: %d', [Est.Ciclo]);
  lblBacterias.Caption := Format('Bactérias: %d', [Est.Bacterias]);
  lblPlantas.Caption := Format('Plantas: %d', [Est.Plantas]);
  lblVegetarianos.Caption := Format('Vegetarianos: %d', [Est.Herbivoros]);
  lblCarnivoros.Caption := Format('Carnívoros: %d', [Est.Carnivoros]);
  lblVazios.Caption := Format('Matéria Orgânica: %d', [Est.Materia]);
end;

procedure TForm2.btnConfigClick(Sender: TObject);
begin
  ShowMessage('Configuração estática definida na unit uConfig.');
end;

procedure TForm2.btnExportClick(Sender: TObject);
var
  F: TextFile;
  Est: TEstat;
begin
  if FSimulacao = nil then Exit;
  Est := FSimulacao.Contar;
  AssignFile(F, 'export_form.csv');
  Rewrite(F);
  try
    WriteLn(F, 'Ciclo,Bacterias,Plantas,Herbivoros,Carnivoros,Materia,Vazios');
    WriteLn(F, Format('%d,%d,%d,%d,%d,%d,%d', [
      Est.Ciclo,
      Est.Bacterias,
      Est.Plantas,
      Est.Herbivoros,
      Est.Carnivoros,
      Est.Materia,
      Est.Vazios
    ]));
  finally
    CloseFile(F);
  end;
  ShowMessage('Estatísticas atuais exportadas para export_form.csv');
end;

procedure TForm2.btnAboutClick(Sender: TObject);
begin
  ShowMessage('Simulação Simplificada do Ecossistema' + sLineBreak +
              'Integrada com componentes CHATGPT' + sLineBreak +
              'Desenvolvido em Lazarus / Free Pascal');
end;

end.
