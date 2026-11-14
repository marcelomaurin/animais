unit Form2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Math, Forms, Controls, Graphics, Dialogs, ExtCtrls, LCLType,
  uConfig, uTipos, uTabuleiro, uSimulacao, uEstat, uFormConfig;

type
  TBotaoId = (bNenhum, bAlternar, bPasso, bReiniciar, bVel1, bVel4, bVel16,
              bConfig, bExportar, bSobre);

  TBotao = record
    R: TRect;
    Id: TBotaoId;
  end;

  { TForm2 }

  // A tela inteira e desenhada em pbTela (um bitmap de apoio evita piscar).
  // Os botoes sao areas clicaveis registradas em FBotoes a cada desenho.
  TForm2 = class(TForm)
    pbTela: TPaintBox;
    tmCycle: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pbTelaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbTelaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbTelaPaint(Sender: TObject);
    procedure tmCycleTimer(Sender: TObject);
  private
    FSimulacao: TSimulacao;
    FCfg: TConfig;
    FSemente: Integer;
    FBuf: TBitmap;
    FBotoes: array of TBotao;
    FHist: array of TEstat;
    FHistN: Integer;
    FVel: Integer;
    FMs: Double;
    FAcMs: QWord;
    FAcCiclos: Integer;

    procedure NovaSimulacao;
    procedure RegistrarHistorico;
    procedure Avancar(K: Integer);
    procedure Acionar(Id: TBotaoId);
    procedure ExportarHistorico;
    function BotaoEm(X, Y: Integer): TBotaoId;

    function S(V: Integer): Integer;
    procedure PrepararFonte(C: TCanvas; Tam: Integer; Negrito, Mono: Boolean; Cor: TColor);
    procedure Texto(C: TCanvas; X, Y: Integer; const T: string; Cor: TColor;
      Tam: Integer; Negrito: Boolean = False; Mono: Boolean = False);
    procedure TextoDir(C: TCanvas; XDir, Y: Integer; const T: string; Cor: TColor;
      Tam: Integer; Negrito: Boolean = False; Mono: Boolean = False);
    procedure Caixa(C: TCanvas; const R: TRect; Fundo, Borda: TColor; Raio: Integer);
    procedure Botao(C: TCanvas; const R: TRect; const Legenda: string; Id: TBotaoId;
      Fundo, Borda, CorTexto: TColor; Negrito: Boolean = False; Mono: Boolean = False);
    procedure DesenharTabuleiro(C: TCanvas; const R: TRect);
    procedure DesenharPopulacao(C: TCanvas; const R: TRect; const E: TEstat);
    procedure DesenharHistorico(C: TCanvas; const R: TRect);
    procedure Desenhar;
  end;

var
  frmform2: TForm2;

implementation

{$R *.lfm}

const
  {$IFDEF WINDOWS}
  FonteTexto = 'Segoe UI';
  FonteMono = 'Consolas';
  {$ELSE}
  FonteTexto = 'default';
  FonteMono = 'Monospace';
  {$ENDIF}

  // Paleta (TColor = $00BBGGRR)
  CorFundo     = TColor($11130D);
  CorCartao    = TColor($1A1D15);
  CorBorda     = TColor($2A3022);
  CorBorda2    = TColor($3D4533);
  CorTexto     = TColor($E9EEE7);
  CorTexto2    = TColor($AFB8A9);
  CorTabuleiro = TColor($090B07);
  CorBotao     = TColor($1E2218);
  CorPlanta    = TColor($62A837);
  CorHerbivoro = TColor($FFA96A);
  CorCarnivoro = TColor($4A6BFF);
  CorBacteria  = TColor($5ED3F4);
  CorMateria   = TColor($4E6A8A);
  CorVazia     = TColor($68715F);
  CorSobreVerde   = TColor($0B1206);
  CorSobreAmarelo = TColor($03161B);

  JanelaHistorico = 600;

function Milhar(V: Int64): string;
var
  I: Integer;
begin
  Result := IntToStr(V);
  I := Length(Result) - 3;
  while I > 0 do
  begin
    Insert('.', Result, I + 1);
    Dec(I, 3);
  end;
end;

function Decimal1(V: Double): string;
begin
  Result := StringReplace(FormatFloat('0.0', V), '.', ',', []);
  Result := StringReplace(Result, ',,', ',', []);
end;

function CorDoTipo(T: TTipo): TColor;
begin
  case T of
    tBacteria: Result := CorBacteria;
    tPlanta: Result := CorPlanta;
    tHerbivoro: Result := CorHerbivoro;
    tCarnivoro: Result := CorCarnivoro;
    tMateria: Result := CorMateria;
  else
    Result := CorTabuleiro;
  end;
end;

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  Randomize;
  FSimulacao := nil;
  FBuf := TBitmap.Create;
  FVel := 1;
  FCfg := ConfigPadrao;
  NovaSimulacao;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  tmCycle.Enabled := False;
  FreeAndNil(FSimulacao);
  FreeAndNil(FBuf);
end;

// Descarta a simulacao atual e cria outra a partir de FCfg. Com Seed = 0 a
// semente e sorteada; o valor usado aparece no cartao "Semente".
procedure TForm2.NovaSimulacao;
var
  Cfg: TConfig;
begin
  FreeAndNil(FSimulacao);
  Cfg := FCfg;
  if Cfg.Seed = 0 then
    Cfg.Seed := Random(MaxInt - 1) + 1;
  FSemente := Cfg.Seed;
  FSimulacao := TSimulacao.Create(Cfg);
  FHistN := 0;
  FMs := 0;
  FAcMs := 0;
  FAcCiclos := 0;
  RegistrarHistorico;
  pbTela.Invalidate;
end;

procedure TForm2.RegistrarHistorico;
begin
  if FHistN >= Length(FHist) then
    SetLength(FHist, Max(1024, Length(FHist) * 2));
  FHist[FHistN] := FSimulacao.Contar;
  Inc(FHistN);
end;

procedure TForm2.Avancar(K: Integer);
var
  I: Integer;
  T0: QWord;
begin
  T0 := GetTickCount64;
  for I := 1 to K do
  begin
    FSimulacao.ExecutarCiclo;
    RegistrarHistorico;
  end;
  // Media sobre varios ciclos: o relogio do sistema tem resolucao baixa
  FAcMs := FAcMs + (GetTickCount64 - T0);
  Inc(FAcCiclos, K);
  if FAcCiclos >= 50 then
  begin
    FMs := FAcMs / FAcCiclos;
    FAcMs := 0;
    FAcCiclos := 0;
  end;
  pbTela.Invalidate;
end;

procedure TForm2.tmCycleTimer(Sender: TObject);
begin
  Avancar(FVel);
end;

procedure TForm2.Acionar(Id: TBotaoId);
var
  Rodava: Boolean;
begin
  case Id of
    bAlternar: tmCycle.Enabled := not tmCycle.Enabled;
    bPasso: Avancar(1);
    bReiniciar: NovaSimulacao;
    bVel1: FVel := 1;
    bVel4: FVel := 4;
    bVel16: FVel := 16;
    bConfig:
      begin
        Rodava := tmCycle.Enabled;
        tmCycle.Enabled := False;
        if EditarConfig(FCfg) then
          NovaSimulacao;
        tmCycle.Enabled := Rodava;
      end;
    bExportar: ExportarHistorico;
    bSobre:
      ShowMessage('Simulação Simplificada do Ecossistema' + sLineBreak +
                  'Integrada com componentes CHATGPT' + sLineBreak +
                  'Desenvolvido em Lazarus / Free Pascal');
  end;
  pbTela.Invalidate;
end;

procedure TForm2.ExportarHistorico;
var
  Dlg: TSaveDialog;
  F: TextFile;
  I: Integer;
  Rodava: Boolean;
begin
  Rodava := tmCycle.Enabled;
  tmCycle.Enabled := False;
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Title := 'Exportar histórico';
    Dlg.Filter := 'Arquivo CSV|*.csv';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName := Format('historico_semente_%d.csv', [FSemente]);
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if Dlg.Execute then
    begin
      AssignFile(F, Dlg.FileName);
      Rewrite(F);
      try
        WriteLn(F, 'Ciclo,Bacterias,Plantas,Herbivoros,Carnivoros,Materia,Vazios');
        for I := 0 to FHistN - 1 do
          WriteLn(F, Format('%d,%d,%d,%d,%d,%d,%d', [FHist[I].Ciclo,
            FHist[I].Bacterias, FHist[I].Plantas, FHist[I].Herbivoros,
            FHist[I].Carnivoros, FHist[I].Materia, FHist[I].Vazios]));
      finally
        CloseFile(F);
      end;
    end;
  finally
    Dlg.Free;
    tmCycle.Enabled := Rodava;
  end;
end;

function TForm2.BotaoEm(X, Y: Integer): TBotaoId;
var
  I: Integer;
begin
  Result := bNenhum;
  for I := 0 to High(FBotoes) do
    if PtInRect(FBotoes[I].R, Point(X, Y)) then
      Exit(FBotoes[I].Id);
end;

procedure TForm2.pbTelaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Id: TBotaoId;
begin
  if Button <> mbLeft then Exit;
  Id := BotaoEm(X, Y);
  if Id <> bNenhum then
    Acionar(Id);
end;

procedure TForm2.pbTelaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if BotaoEm(X, Y) <> bNenhum then
    pbTela.Cursor := crHandPoint
  else
    pbTela.Cursor := crDefault;
end;

// Atalhos: Espaco inicia/pausa, seta direita avanca 1 ciclo, R reinicia.
procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_SPACE: Acionar(bAlternar);
    VK_RIGHT: Acionar(bPasso);
    VK_R: Acionar(bReiniciar);
  else
    Exit;
  end;
  Key := 0;
end;

procedure TForm2.pbTelaPaint(Sender: TObject);
begin
  Desenhar;
end;

{ ---- desenho ---- }

function TForm2.S(V: Integer): Integer;
begin
  Result := Scale96ToForm(V);
end;

procedure TForm2.PrepararFonte(C: TCanvas; Tam: Integer; Negrito, Mono: Boolean; Cor: TColor);
begin
  if Mono then
    C.Font.Name := FonteMono
  else
    C.Font.Name := FonteTexto;
  C.Font.Height := -S(Tam);
  if Negrito then
    C.Font.Style := [fsBold]
  else
    C.Font.Style := [];
  C.Font.Color := Cor;
end;

procedure TForm2.Texto(C: TCanvas; X, Y: Integer; const T: string; Cor: TColor;
  Tam: Integer; Negrito: Boolean; Mono: Boolean);
begin
  PrepararFonte(C, Tam, Negrito, Mono, Cor);
  C.Brush.Style := bsClear;
  C.TextOut(X, Y, T);
  C.Brush.Style := bsSolid;
end;

procedure TForm2.TextoDir(C: TCanvas; XDir, Y: Integer; const T: string; Cor: TColor;
  Tam: Integer; Negrito: Boolean; Mono: Boolean);
begin
  PrepararFonte(C, Tam, Negrito, Mono, Cor);
  C.Brush.Style := bsClear;
  C.TextOut(XDir - C.TextWidth(T), Y, T);
  C.Brush.Style := bsSolid;
end;

procedure TForm2.Caixa(C: TCanvas; const R: TRect; Fundo, Borda: TColor; Raio: Integer);
begin
  C.Brush.Style := bsSolid;
  C.Brush.Color := Fundo;
  C.Pen.Style := psSolid;
  C.Pen.Width := 1;
  C.Pen.Color := Borda;
  C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, S(Raio) * 2, S(Raio) * 2);
end;

procedure TForm2.Botao(C: TCanvas; const R: TRect; const Legenda: string; Id: TBotaoId;
  Fundo, Borda, CorTexto: TColor; Negrito: Boolean; Mono: Boolean);
var
  N, Tam: Integer;
begin
  Caixa(C, R, Fundo, Borda, 6);
  if Negrito then Tam := 15 else Tam := 14;
  if Mono then Tam := 13;
  PrepararFonte(C, Tam, Negrito, Mono, CorTexto);
  C.Brush.Style := bsClear;
  C.TextOut((R.Left + R.Right - C.TextWidth(Legenda)) div 2,
            (R.Top + R.Bottom - C.TextHeight(Legenda)) div 2, Legenda);
  C.Brush.Style := bsSolid;

  N := Length(FBotoes);
  SetLength(FBotoes, N + 1);
  FBotoes[N].R := R;
  FBotoes[N].Id := Id;
end;

procedure TForm2.DesenharTabuleiro(C: TCanvas; const R: TRect);
var
  X, Y, IX, IY, Lado: Integer;
  CW, CH: Double;
  Ser: TSer;
  Tab: TTabuleiro;
begin
  Caixa(C, R, CorTabuleiro, CorBorda, 8);
  Tab := FSimulacao.Tabuleiro;
  if (Tab.W <= 0) or (Tab.H <= 0) then Exit;

  IX := R.Left + S(8);
  IY := R.Top + S(8);
  Lado := (R.Right - R.Left) - S(16);
  CW := Lado / Tab.W;
  CH := Lado / Tab.H;

  C.Brush.Style := bsSolid;
  for X := 0 to Tab.W - 1 do
    for Y := 0 to Tab.H - 1 do
    begin
      Ser := Tab.GetSer(X, Y);
      if Ser <> nil then
      begin
        C.Brush.Color := CorDoTipo(Ser.Tipo);
        C.FillRect(IX + Round(X * CW), IY + Round(Y * CH),
                   IX + Round((X + 1) * CW), IY + Round((Y + 1) * CH));
      end;
    end;
end;

procedure TForm2.DesenharPopulacao(C: TCanvas; const R: TRect; const E: TEstat);
var
  Total, Y, XE, XD: Integer;

  procedure Linha(const Nome: string; Cor, CorBarra: TColor; V: Integer);
  var
    LB: Integer;
  begin
    Caixa(C, Rect(XE, Y + S(3), XE + S(14), Y + S(17)), Cor, CorBorda2, 3);
    Texto(C, XE + S(24), Y, Nome, CorTexto, 14);
    TextoDir(C, XD - S(62), Y, Milhar(V), CorTexto, 14, False, True);
    TextoDir(C, XD, Y + S(2), Decimal1(100.0 * V / Total) + '%', CorTexto2, 12, False, True);
    // barra de proporcao
    C.Brush.Color := CorBorda;
    C.FillRect(XE + S(24), Y + S(24), XD, Y + S(28));
    LB := Round((XD - XE - S(24)) * (V / Total));
    if LB > 0 then
    begin
      C.Brush.Color := CorBarra;
      C.FillRect(XE + S(24), Y + S(24), XE + S(24) + LB, Y + S(28));
    end;
    Inc(Y, S(36));
  end;

begin
  Caixa(C, R, CorCartao, CorBorda, 8);
  Texto(C, R.Left + S(16), R.Top + S(14), 'População', CorTexto, 15, True);
  Total := Max(1, FSimulacao.Tabuleiro.W * FSimulacao.Tabuleiro.H);
  XE := R.Left + S(16);
  XD := R.Right - S(16);
  Y := R.Top + S(48);
  Linha('Plantas', CorPlanta, CorPlanta, E.Plantas);
  Linha('Herbívoros', CorHerbivoro, CorHerbivoro, E.Herbivoros);
  Linha('Carnívoros', CorCarnivoro, CorCarnivoro, E.Carnivoros);
  Linha('Bactérias', CorBacteria, CorBacteria, E.Bacterias);
  Linha('Matéria orgânica', CorMateria, CorMateria, E.Materia);
  Linha('Células vazias', CorTabuleiro, CorVazia, E.Vazios);
end;

procedure TForm2.DesenharHistorico(C: TCanvas; const R: TRect);
var
  XE, XD, YT, YB, N, Ini, Total: Integer;
  LogTotal: Double;

  function YDe(V: Integer): Integer;
  begin
    Result := YB - Round(Ln(Max(1, V)) / LogTotal * (YB - YT));
  end;

  procedure Grade(V: Integer);
  var
    Y: Integer;
  begin
    if V >= Total then Exit;
    Y := YDe(V);
    C.Pen.Color := CorBorda;
    C.Pen.Width := 1;
    C.Line(XE, Y, XD, Y);
    TextoDir(C, XE - S(6), Y - S(7), IntToStr(V), CorTexto2, 11, False, True);
  end;

  function Valor(const E: TEstat; T: TTipo): Integer;
  begin
    case T of
      tBacteria: Result := E.Bacterias;
      tPlanta: Result := E.Plantas;
      tHerbivoro: Result := E.Herbivoros;
      tCarnivoro: Result := E.Carnivoros;
    else
      Result := E.Materia;
    end;
  end;

  procedure Serie(T: TTipo);
  var
    I, X: Integer;
  begin
    if N < 2 then Exit;
    C.Pen.Color := CorDoTipo(T);
    C.Pen.Width := S(2);
    for I := 0 to N - 1 do
    begin
      X := XE + Round(I * (XD - XE) / (JanelaHistorico - 1));
      if I = 0 then
        C.MoveTo(X, YDe(Valor(FHist[Ini + I], T)))
      else
        C.LineTo(X, YDe(Valor(FHist[Ini + I], T)));
    end;
    C.Pen.Width := 1;
  end;

begin
  Caixa(C, R, CorCartao, CorBorda, 8);
  Texto(C, R.Left + S(16), R.Top + S(14), 'Histórico', CorTexto, 15, True);
  if R.Right - R.Left >= S(340) then
    TextoDir(C, R.Right - S(16), R.Top + S(17),
      Format('últimos %d ciclos · escala logarítmica', [JanelaHistorico]), CorTexto2, 12);

  Total := Max(2, FSimulacao.Tabuleiro.W * FSimulacao.Tabuleiro.H);
  LogTotal := Ln(Total);
  XE := R.Left + S(56);
  XD := R.Right - S(16);
  YT := R.Top + S(52);
  YB := R.Bottom - S(18);
  if (XD - XE < S(60)) or (YB - YT < S(40)) then Exit;

  Grade(10);
  Grade(100);
  Grade(1000);
  C.Pen.Color := CorBorda2;
  C.Pen.Width := 1;
  C.Line(XE, YB, XD, YB);

  N := Min(FHistN, JanelaHistorico);
  Ini := FHistN - N;
  Serie(tMateria);
  Serie(tBacteria);
  Serie(tPlanta);
  Serie(tHerbivoro);
  Serie(tCarnivoro);
end;

procedure TForm2.Desenhar;
var
  C: TCanvas;
  W, H, P, Topo, CW, X, XR, RX, RW, MW, Y0, Y1, I, LB: Integer;
  E: TEstat;
  R: TRect;
  Fundo, Borda, CorT: TColor;
const
  Vels: array[0..2] of Integer = (16, 4, 1);
  VelIds: array[0..2] of TBotaoId = (bVel16, bVel4, bVel1);
begin
  if (FSimulacao = nil) or (FBuf = nil) then Exit;
  W := pbTela.ClientWidth;
  H := pbTela.ClientHeight;
  if (W <= 0) or (H <= 0) then Exit;
  if (FBuf.Width <> W) or (FBuf.Height <> H) then
    FBuf.SetSize(W, H);
  C := FBuf.Canvas;
  SetLength(FBotoes, 0);
  P := S(24);

  C.Brush.Style := bsSolid;
  C.Brush.Color := CorFundo;
  C.FillRect(0, 0, W, H);

  // ---- barra superior
  C.Brush.Color := CorPlanta;    C.FillRect(P, S(18), P + S(12), S(30));
  C.Brush.Color := CorHerbivoro; C.FillRect(P + S(16), S(18), P + S(28), S(30));
  C.Brush.Color := CorBacteria;  C.FillRect(P, S(34), P + S(12), S(46));
  C.Brush.Color := CorCarnivoro; C.FillRect(P + S(16), S(34), P + S(28), S(46));
  Texto(C, P + S(40), S(11), 'Animais', CorTexto, 20, True);
  Texto(C, P + S(40), S(38), Format('Ecossistema em grade %d × %d',
    [FSimulacao.Tabuleiro.W, FSimulacao.Tabuleiro.H]), CorTexto2, 12);
  C.Pen.Color := CorBorda;
  C.Pen.Width := 1;
  C.Line(0, S(64), W, S(64));

  X := W - P;
  Botao(C, Rect(X - S(72), S(10), X, S(54)), 'Sobre', bSobre, CorFundo, CorFundo, CorTexto2);
  Dec(X, S(72) + S(8));
  Botao(C, Rect(X - S(150), S(10), X, S(54)), 'Exportar histórico', bExportar, CorFundo, CorBorda2, CorTexto);
  Dec(X, S(150) + S(8));
  Botao(C, Rect(X - S(130), S(10), X, S(54)), 'Configurações', bConfig, CorFundo, CorBorda2, CorTexto);

  // ---- coluna do tabuleiro
  Topo := S(88);
  CW := Min(S(640), Min(H - Topo - P - S(60), W - 3 * P - S(360)));
  if CW < S(360) then CW := S(360);

  X := P;
  if tmCycle.Enabled then
    Botao(C, Rect(X, Topo, X + S(96), Topo + S(44)), 'Pausar', bAlternar, CorBacteria, CorBacteria, CorSobreAmarelo, True)
  else
    Botao(C, Rect(X, Topo, X + S(96), Topo + S(44)), 'Iniciar', bAlternar, CorPlanta, CorPlanta, CorSobreVerde, True);
  Inc(X, S(96) + S(8));
  Botao(C, Rect(X, Topo, X + S(132), Topo + S(44)), 'Avançar 1 ciclo', bPasso, CorBotao, CorBorda2, CorTexto);
  Inc(X, S(132) + S(8));
  Botao(C, Rect(X, Topo, X + S(92), Topo + S(44)), 'Reiniciar', bReiniciar, CorBotao, CorBorda2, CorTexto);
  Inc(X, S(92));

  XR := P + CW;
  for I := 0 to 2 do
  begin
    if FVel = Vels[I] then
    begin
      Fundo := CorTexto; Borda := CorTexto; CorT := CorFundo;
    end
    else
    begin
      Fundo := CorBotao; Borda := CorBorda2; CorT := CorTexto;
    end;
    Botao(C, Rect(XR - S(48), Topo, XR, Topo + S(44)), IntToStr(Vels[I]) + '×', VelIds[I],
      Fundo, Borda, CorT, False, True);
    Dec(XR, S(48) + S(6));
  end;
  PrepararFonte(C, 12, False, False, CorTexto2);
  if XR - C.TextWidth('Velocidade') > X + S(12) then
    TextoDir(C, XR, Topo + S(14), 'Velocidade', CorTexto2, 12);

  DesenharTabuleiro(C, Rect(P, Topo + S(60), P + CW, Topo + S(60) + CW));

  // ---- coluna de dados
  RX := P + CW + P;
  RW := W - RX - P;
  if RW >= S(220) then
  begin
    E := FHist[FHistN - 1];
    MW := (RW - S(16)) div 2;

    R := Rect(RX, Topo, RX + MW, Topo + S(92));
    Caixa(C, R, CorCartao, CorBorda, 8);
    Texto(C, R.Left + S(16), R.Top + S(14), 'CICLO', CorTexto2, 12);
    Texto(C, R.Left + S(16), R.Top + S(36), Milhar(E.Ciclo), CorTexto, 34, False, True);

    R := Rect(RX + MW + S(16), Topo, RX + RW, Topo + S(92));
    Caixa(C, R, CorCartao, CorBorda, 8);
    Texto(C, R.Left + S(16), R.Top + S(14), 'SEMENTE', CorTexto2, 12);
    Texto(C, R.Left + S(16), R.Top + S(34), IntToStr(FSemente), CorTexto, 20, False, True);
    Texto(C, R.Left + S(16), R.Top + S(66), Decimal1(FMs) + ' ms por ciclo', CorTexto2, 12);

    Y0 := Topo + S(108);
    DesenharPopulacao(C, Rect(RX, Y0, RX + RW, Y0 + S(276)), E);

    Y1 := Y0 + S(276) + S(16);
    LB := H - P;
    if LB - Y1 >= S(120) then
      DesenharHistorico(C, Rect(RX, Y1, RX + RW, LB));
  end;

  pbTela.Canvas.Draw(0, 0, FBuf);
end;

end.
