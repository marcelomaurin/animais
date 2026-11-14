unit uFormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uConfig;

type
  { TFormConfig }

  // Tela de configuracoes. Os controles sao criados em codigo (nao ha .lfm).
  TFormConfig = class(TForm)
  private
    // Tabuleiro: largura, altura, semente, entrada dos carnivoros, degradacao
    FTab: array[0..4] of TEdit;
    // Especies (linhas: planta, herbivoro, carnivoro, bacteria) x
    // (colunas: proporcao, vida, fome, reproducao). [0, 2] nao existe (planta).
    FEsp: array[0..3, 0..3] of TEdit;

    function NovoRotulo(AParent: TWinControl; X, Y: Integer; const T: string;
      Cor: TColor; Tam: Integer; Negrito: Boolean = False): TLabel;
    function NovoEdit(AParent: TWinControl; X, Y, W: Integer): TEdit;
    function NovoBotao(X, Y, W: Integer; const T: string; Fundo, CorTexto: TColor;
      Negrito: Boolean; AoClicar: TNotifyEvent): TPanel;
    function NovoCartao(X, Y, W, H: Integer): TPanel;
    procedure Montar;
    procedure Preencher(const Cfg: TConfig);
    function Ler(out Cfg: TConfig): Boolean;
    procedure AplicarClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
    procedure PadraoClick(Sender: TObject);
  public
    Resultado: TConfig;
    constructor Create(AOwner: TComponent); override;
  end;

// Abre a tela; devolve True e atualiza Cfg quando o usuario aplica.
function EditarConfig(var Cfg: TConfig): Boolean;

implementation

const
  {$IFDEF WINDOWS}
  FonteTexto = 'Segoe UI';
  FonteMono = 'Consolas';
  {$ELSE}
  FonteTexto = 'default';
  FonteMono = 'Monospace';
  {$ENDIF}

  CorFundo   = TColor($11130D);
  CorCartao  = TColor($1A1D15);
  CorBorda2  = TColor($3D4533);
  CorTexto   = TColor($E9EEE7);
  CorTexto2  = TColor($AFB8A9);
  CorPlanta    = TColor($62A837);
  CorHerbivoro = TColor($FFA96A);
  CorCarnivoro = TColor($4A6BFF);
  CorBacteria  = TColor($5ED3F4);
  CorSobreVerde = TColor($0B1206);

function EditarConfig(var Cfg: TConfig): Boolean;
var
  F: TFormConfig;
begin
  F := TFormConfig.Create(Application);
  try
    F.Preencher(Cfg);
    Result := F.ShowModal = mrOk;
    if Result then
      Cfg := F.Resultado;
  finally
    F.Free;
  end;
end;

function Pct(V: Double): string;
begin
  Result := StringReplace(FormatFloat('0.##', V * 100), '.', ',', []);
end;

{ TFormConfig }

constructor TFormConfig.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Configurações';
  BorderStyle := bsDialog;
  Position := poMainFormCenter;
  Color := CorFundo;
  Font.Name := FonteTexto;
  Font.Color := CorTexto;
  Montar;
end;

function TFormConfig.NovoRotulo(AParent: TWinControl; X, Y: Integer; const T: string;
  Cor: TColor; Tam: Integer; Negrito: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Left := Scale96ToForm(X);
  Result.Top := Scale96ToForm(Y);
  Result.Caption := T;
  Result.ParentFont := False;
  Result.Font.Name := FonteTexto;
  Result.Font.Height := -Scale96ToForm(Tam);
  Result.Font.Color := Cor;
  if Negrito then
    Result.Font.Style := [fsBold];
end;

function TFormConfig.NovoEdit(AParent: TWinControl; X, Y, W: Integer): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.Parent := AParent;
  Result.AutoSize := False;
  Result.SetBounds(Scale96ToForm(X), Scale96ToForm(Y), Scale96ToForm(W), Scale96ToForm(32));
  Result.ParentFont := False;
  Result.Font.Name := FonteMono;
  Result.Font.Height := -Scale96ToForm(15);
  Result.Font.Color := CorTexto;
  Result.Color := CorFundo;
end;

function TFormConfig.NovoBotao(X, Y, W: Integer; const T: string; Fundo, CorTexto: TColor;
  Negrito: Boolean; AoClicar: TNotifyEvent): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(Scale96ToForm(X), Scale96ToForm(Y), Scale96ToForm(W), Scale96ToForm(44));
  Result.BevelOuter := bvNone;
  Result.ParentBackground := False;
  Result.ParentColor := False;
  Result.Color := Fundo;
  Result.ParentFont := False;
  Result.Font.Name := FonteTexto;
  Result.Font.Height := -Scale96ToForm(14);
  Result.Font.Color := CorTexto;
  if Negrito then
    Result.Font.Style := [fsBold];
  Result.Caption := T;
  Result.Cursor := crHandPoint;
  Result.OnClick := AoClicar;
end;

function TFormConfig.NovoCartao(X, Y, W, H: Integer): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(Scale96ToForm(X), Scale96ToForm(Y), Scale96ToForm(W), Scale96ToForm(H));
  Result.BevelOuter := bvNone;
  Result.ParentBackground := False;
  Result.ParentColor := False;
  Result.Color := CorCartao;
  Result.Caption := '';
end;

procedure TFormConfig.Montar;
const
  RotTab: array[0..4] of string = ('Largura', 'Altura', 'Semente (0 sorteia)',
    'Entrada dos carnívoros', 'Degradação da matéria');
  RotCol: array[0..3] of string = ('Proporção inicial (%)', 'Vida máxima',
    'Fome máxima', 'Ciclos para reproduzir');
  RotEsp: array[0..3] of string = ('Plantas', 'Herbívoros', 'Carnívoros', 'Bactérias');
  CorEsp: array[0..3] of TColor = (CorPlanta, CorHerbivoro, CorCarnivoro, CorBacteria);
var
  Cartao: TPanel;
  I, J, X, Y: Integer;
  Marca: TShape;
begin
  ClientWidth := Scale96ToForm(880);
  ClientHeight := Scale96ToForm(650);

  NovoRotulo(Self, 24, 20, 'Configurações', CorTexto, 26, True);
  NovoRotulo(Self, 24, 58, 'Os valores valem para a próxima simulação. Aplicar reinicia o tabuleiro.',
    CorTexto2, 14);

  // ---- Tabuleiro
  Cartao := NovoCartao(24, 92, 832, 128);
  NovoRotulo(Cartao, 20, 16, 'Tabuleiro', CorTexto, 16, True);
  for I := 0 to 4 do
  begin
    X := 20 + I * 160;
    NovoRotulo(Cartao, X, 50, RotTab[I], CorTexto2, 12);
    FTab[I] := NovoEdit(Cartao, X, 74, 148);
  end;

  // ---- Especies
  Cartao := NovoCartao(24, 236, 832, 322);
  NovoRotulo(Cartao, 20, 16, 'Espécies', CorTexto, 16, True);
  for J := 0 to 3 do
    NovoRotulo(Cartao, 190 + J * 158, 52, RotCol[J], CorTexto2, 12);
  for I := 0 to 3 do
  begin
    Y := 78 + I * 46;
    Marca := TShape.Create(Self);
    Marca.Parent := Cartao;
    Marca.SetBounds(Scale96ToForm(20), Scale96ToForm(Y + 9), Scale96ToForm(14), Scale96ToForm(14));
    Marca.Brush.Color := CorEsp[I];
    Marca.Pen.Color := CorEsp[I];
    NovoRotulo(Cartao, 44, Y + 6, RotEsp[I], CorTexto, 14);
    for J := 0 to 3 do
    begin
      FEsp[I, J] := nil;
      if (I = 0) and (J = 2) then
        NovoRotulo(Cartao, 190 + J * 158, Y + 8, 'não se aplica', CorTexto2, 13)
      else
        FEsp[I, J] := NovoEdit(Cartao, 190 + J * 158, Y, 146);
    end;
  end;
  NovoRotulo(Cartao, 20, 274,
    'Animais e bactérias só se reproduzem depois de comer. Fome máxima 0 desliga a fome da bactéria.',
    CorTexto2, 13);

  // ---- Botoes
  NovoBotao(24, 582, 150, 'Restaurar padrão', CorCartao, CorTexto, False, @PadraoClick);
  NovoBotao(566, 582, 100, 'Cancelar', CorFundo, CorTexto2, False, @CancelarClick);
  NovoBotao(676, 582, 180, 'Aplicar e reiniciar', CorPlanta, CorSobreVerde, True, @AplicarClick);
end;

procedure TFormConfig.Preencher(const Cfg: TConfig);
begin
  FTab[0].Text := IntToStr(Cfg.Largura);
  FTab[1].Text := IntToStr(Cfg.Altura);
  FTab[2].Text := IntToStr(Cfg.Seed);
  FTab[3].Text := IntToStr(Cfg.CicloEntradaCarnivoro);
  FTab[4].Text := IntToStr(Cfg.DegradaMateria);

  FEsp[0, 0].Text := Pct(Cfg.PctPlanta);
  FEsp[0, 1].Text := IntToStr(Cfg.VidaPlanta);
  FEsp[0, 3].Text := IntToStr(Cfg.ReproPlanta);

  FEsp[1, 0].Text := Pct(Cfg.PctHerbivoro);
  FEsp[1, 1].Text := IntToStr(Cfg.VidaHerbivoro);
  FEsp[1, 2].Text := IntToStr(Cfg.FomeHerbivoro);
  FEsp[1, 3].Text := IntToStr(Cfg.ReproHerbivoro);

  FEsp[2, 0].Text := Pct(Cfg.PctCarnivoro);
  FEsp[2, 1].Text := IntToStr(Cfg.VidaCarnivoro);
  FEsp[2, 2].Text := IntToStr(Cfg.FomeCarnivoro);
  FEsp[2, 3].Text := IntToStr(Cfg.ReproCarnivoro);

  FEsp[3, 0].Text := Pct(Cfg.PctBacteria);
  FEsp[3, 1].Text := IntToStr(Cfg.VidaBacteria);
  FEsp[3, 2].Text := IntToStr(Cfg.FomeBacteria);
  FEsp[3, 3].Text := IntToStr(Cfg.ReproBacteria);
end;

// Le os campos. Em caso de valor invalido, avisa, foca o campo e devolve False.
function TFormConfig.Ler(out Cfg: TConfig): Boolean;
var
  Ok: Boolean;

  function Inteiro(E: TEdit; Min, Max: Integer; const Nome: string): Integer;
  begin
    Result := Min;
    if not Ok then Exit;
    if (not TryStrToInt(Trim(E.Text), Result)) or (Result < Min) or (Result > Max) then
    begin
      Ok := False;
      MessageDlg(Format('%s: informe um número inteiro entre %d e %d.', [Nome, Min, Max]),
        mtWarning, [mbOK], 0);
      E.SetFocus;
    end;
  end;

  function Proporcao(E: TEdit; const Nome: string): Double;
  var
    FS: TFormatSettings;
    T: string;
  begin
    Result := 0;
    if not Ok then Exit;
    FS := DefaultFormatSettings;
    FS.DecimalSeparator := '.';
    T := StringReplace(Trim(E.Text), ',', '.', []);
    if (not TryStrToFloat(T, Result, FS)) or (Result < 0) or (Result > 100) then
    begin
      Ok := False;
      MessageDlg(Format('%s: informe um percentual entre 0 e 100.', [Nome]),
        mtWarning, [mbOK], 0);
      E.SetFocus;
    end;
    Result := Result / 100;
  end;

begin
  Ok := True;
  Cfg := ConfigPadrao;
  Cfg.Largura := Inteiro(FTab[0], 10, 300, 'Largura');
  Cfg.Altura := Inteiro(FTab[1], 10, 300, 'Altura');
  Cfg.Seed := Inteiro(FTab[2], 0, MaxInt, 'Semente');
  Cfg.CicloEntradaCarnivoro := Inteiro(FTab[3], 1, 1000000, 'Entrada dos carnívoros');
  Cfg.DegradaMateria := Inteiro(FTab[4], 1, 1000, 'Degradação da matéria');

  Cfg.PctPlanta := Proporcao(FEsp[0, 0], 'Plantas, proporção inicial');
  Cfg.VidaPlanta := Inteiro(FEsp[0, 1], 1, 10000, 'Plantas, vida máxima');
  Cfg.ReproPlanta := Inteiro(FEsp[0, 3], 1, 10000, 'Plantas, ciclos para reproduzir');

  Cfg.PctHerbivoro := Proporcao(FEsp[1, 0], 'Herbívoros, proporção inicial');
  Cfg.VidaHerbivoro := Inteiro(FEsp[1, 1], 1, 10000, 'Herbívoros, vida máxima');
  Cfg.FomeHerbivoro := Inteiro(FEsp[1, 2], 1, 10000, 'Herbívoros, fome máxima');
  Cfg.ReproHerbivoro := Inteiro(FEsp[1, 3], 1, 10000, 'Herbívoros, ciclos para reproduzir');

  Cfg.PctCarnivoro := Proporcao(FEsp[2, 0], 'Carnívoros, proporção inicial');
  Cfg.VidaCarnivoro := Inteiro(FEsp[2, 1], 1, 10000, 'Carnívoros, vida máxima');
  Cfg.FomeCarnivoro := Inteiro(FEsp[2, 2], 1, 10000, 'Carnívoros, fome máxima');
  Cfg.ReproCarnivoro := Inteiro(FEsp[2, 3], 1, 10000, 'Carnívoros, ciclos para reproduzir');

  Cfg.PctBacteria := Proporcao(FEsp[3, 0], 'Bactérias, proporção inicial');
  Cfg.VidaBacteria := Inteiro(FEsp[3, 1], 1, 10000, 'Bactérias, vida máxima');
  Cfg.FomeBacteria := Inteiro(FEsp[3, 2], 0, 10000, 'Bactérias, fome máxima');
  Cfg.ReproBacteria := Inteiro(FEsp[3, 3], 1, 10000, 'Bactérias, ciclos para reproduzir');

  if Ok and (Cfg.PctPlanta + Cfg.PctHerbivoro + Cfg.PctCarnivoro + Cfg.PctBacteria > 1.0) then
  begin
    Ok := False;
    MessageDlg('A soma das proporções iniciais não pode passar de 100%.', mtWarning, [mbOK], 0);
  end;
  Result := Ok;
end;

procedure TFormConfig.AplicarClick(Sender: TObject);
begin
  if Ler(Resultado) then
    ModalResult := mrOk;
end;

procedure TFormConfig.CancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormConfig.PadraoClick(Sender: TObject);
begin
  Preencher(ConfigPadrao);
end;

end.
