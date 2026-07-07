unit uSimulacao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, uTipos, uTabuleiro, uConfig, uEstat;

type
  { TSimulacao }

  TSimulacao = class
  private
    FTab: TTabuleiro;
    FCfg: TConfig;
    FCiclo: Int64;

    procedure Semear;
    procedure ProcessarCelula(X, Y: Integer);
    procedure MorrerVirandoMateria(X, Y: Integer; ASer: TSer);
    function ObterVizinhosLivresNext(X, Y: Integer; out NX, NY: Integer): Boolean;
    function ObterPreyAdjacente(X, Y: Integer; ATipoPrey: TTipo; out PX, PY: Integer): Boolean;
  public
    constructor Create(const ACfg: TConfig);
    destructor Destroy; override;

    procedure ExecutarCiclo;
    procedure SemearCarnivoros;
    function Contar: TEstat;

    property Tabuleiro: TTabuleiro read FTab;
    property Ciclo: Int64 read FCiclo;
    property Config: TConfig read FCfg;
  end;

implementation

{ TSimulacao }

constructor TSimulacao.Create(const ACfg: TConfig);
begin
  FCfg := ACfg;
  FCiclo := 0;
  FTab := TTabuleiro.Create;
  FTab.SetTamanho(FCfg.Largura, FCfg.Altura);
  RandSeed := FCfg.Seed;
  Semear;
end;

destructor TSimulacao.Destroy;
begin
  FTab.Free;
  inherited Destroy;
end;

procedure TSimulacao.Semear;
  procedure SemearTipo(ATipo: TTipo; Pct: Double; Vida, Fome, Repro: Integer);
  var
    Total, Cont, X, Y, Tentativas: Integer;
    Ser: TSer;
  begin
    Total := Round(Pct * FTab.W * FTab.H);
    Cont := 0;
    Tentativas := 0;
    while (Cont < Total) and (Tentativas < Total * 10) do
    begin
      Inc(Tentativas);
      X := Random(FTab.W);
      Y := Random(FTab.H);
      if FTab.GetSer(X, Y) = nil then
      begin
        Ser := TSer.CreateSer(ATipo, Vida, Fome, Repro);
        // Coloca diretamente no FBoard para o inicio
        FTab.ColocarNoBoard(Ser, X, Y);
        Inc(Cont);
      end;
    end;
  end;

begin
  SemearTipo(tBacteria, FCfg.PctBacteria, FCfg.VidaBacteria, 0, FCfg.ReproBacteria);
  SemearTipo(tPlanta, FCfg.PctPlanta, FCfg.VidaPlanta, 0, FCfg.ReproPlanta);
  SemearTipo(tHerbivoro, FCfg.PctHerbivoro, FCfg.VidaHerbivoro, FCfg.FomeHerbivoro, FCfg.ReproHerbivoro);
end;

procedure TSimulacao.SemearCarnivoros;
var
  Total, Cont, X, Y, Tentativas: Integer;
  Ser: TSer;
begin
  Total := Round(FCfg.PctCarnivoro * FTab.W * FTab.H);
  Cont := 0;
  Tentativas := 0;
  while (Cont < Total) and (Tentativas < Total * 10) do
  begin
    Inc(Tentativas);
    X := Random(FTab.W);
    Y := Random(FTab.H);
    // Nota: carnívoro entra no meio da simulação, semeia no FBoard
    if FTab.GetSer(X, Y) = nil then
    begin
      Ser := TSer.CreateSer(tCarnivoro, FCfg.VidaCarnivoro, FCfg.FomeCarnivoro, FCfg.ReproCarnivoro);
      FTab.ColocarNoBoard(Ser, X, Y);
      Inc(Cont);
    end;
  end;
end;

procedure TSimulacao.ExecutarCiclo;
var
  X, Y: Integer;
  Ser: TSer;
begin
  Inc(FCiclo);
  if FCiclo = FCfg.CicloEntradaCarnivoro then
  begin
    SemearCarnivoros;
  end;

  FTab.PrepararProximo;

  for X := 0 to FTab.W - 1 do
  begin
    for Y := 0 to FTab.H - 1 do
    begin
      Ser := FTab.GetSer(X, Y);
      if (Ser <> nil) and (not Ser.Morto) then
      begin
        ProcessarCelula(X, Y);
      end;
    end;
  end;

  FTab.Commit;
end;

function TSimulacao.ObterVizinhosLivresNext(X, Y: Integer; out NX, NY: Integer): Boolean;
var
  DX, DY, TargetX, TargetY, Cont, I: Integer;
  Posicoes: array[0..7] of TPoint;
begin
  Cont := 0;
  for DX := -1 to 1 do
  begin
    for DY := -1 to 1 do
    begin
      if (DX <> 0) or (DY <> 0) then
      begin
        TargetX := X + DX;
        TargetY := Y + DY;
        if FTab.InBounds(TargetX, TargetY) and FTab.CelulaLivreNext(TargetX, TargetY) and (FTab.GetSer(TargetX, TargetY) = nil) then
        begin
          Posicoes[Cont] := Point(TargetX, TargetY);
          Inc(Cont);
        end;
      end;
    end;
  end;

  if Cont > 0 then
  begin
    I := Random(Cont);
    NX := Posicoes[I].X;
    NY := Posicoes[I].Y;
    Exit(True);
  end;
  Result := False;
end;

function TSimulacao.ObterPreyAdjacente(X, Y: Integer; ATipoPrey: TTipo; out PX, PY: Integer): Boolean;
var
  DX, DY, TargetX, TargetY, Cont, I: Integer;
  Posicoes: array[0..7] of TPoint;
  SerVizinho: TSer;
begin
  Cont := 0;
  for DX := -1 to 1 do
  begin
    for DY := -1 to 1 do
    begin
      if (DX <> 0) or (DY <> 0) then
      begin
        TargetX := X + DX;
        TargetY := Y + DY;
        if FTab.InBounds(TargetX, TargetY) then
        begin
          SerVizinho := FTab.GetSer(TargetX, TargetY);
          if (SerVizinho <> nil) and (not SerVizinho.Morto) and (SerVizinho.Tipo = ATipoPrey) then
          begin
            Posicoes[Cont] := Point(TargetX, TargetY);
            Inc(Cont);
          end;
        end;
      end;
    end;
  end;

  if Cont > 0 then
  begin
    // Escolhe uma presa aleatoriamente entre as disponiveis
    I := Random(Cont);
    PX := Posicoes[I].X;
    PY := Posicoes[I].Y;
    Exit(True);
  end;
  Result := False;
end;

procedure TSimulacao.MorrerVirandoMateria(X, Y: Integer; ASer: TSer);
begin
  if ASer.Tipo in [tPlanta, tHerbivoro, tCarnivoro] then
  begin
    // Transforma em materia organica
    ASer.Tipo := tMateria;
    ASer.Idade := 0;
    ASer.Morto := False;
    ASer.Fome := 0;
    ASer.Repro := 0;
    FTab.Colocar(ASer, X, Y);
  end;
end;

procedure TSimulacao.ProcessarCelula(X, Y: Integer);
var
  Ser: TSer;
  PreyX, PreyY, NextX, NextY, FilhoX, FilhoY: Integer;
  Movido: Boolean;
  Filho: TSer;
begin
  Ser := FTab.GetSer(X, Y);
  
  // 1. Idade
  Inc(Ser.Idade);
  if Ser.Idade >= Ser.VidaMax then
  begin
    if Ser.Tipo in [tBacteria, tMateria] then
      Ser.Morto := True
    else
      MorrerVirandoMateria(X, Y, Ser);
    Exit;
  end;

  // Se for Materia Organica, trata sua degradacao especifica
  if Ser.Tipo = tMateria then
  begin
    if Ser.Idade >= FCfg.DegradaMateria then
    begin
      // Degrada e vira bacteria
      Ser.Tipo := tBacteria;
      Ser.Idade := 0;
      Ser.VidaMax := FCfg.VidaBacteria;
      Ser.FomeMax := 0;
      Ser.ReproMax := FCfg.ReproBacteria;
      Ser.Fome := 0;
      Ser.Repro := 0;
      Ser.Morto := False;
    end;
    FTab.Mover(X, Y, X, Y); // Fica parado
    Exit;
  end;

  Movido := False;

  // 2. Comer
  if Ser.Tipo = tHerbivoro then
  begin
    if ObterPreyAdjacente(X, Y, tPlanta, PreyX, PreyY) then
    begin
      FTab.MarcarMorto(PreyX, PreyY);
      Ser.Fome := 0;
      FTab.Mover(X, Y, PreyX, PreyY);
      Movido := True;
    end;
  end
  else if Ser.Tipo = tCarnivoro then
  begin
    if ObterPreyAdjacente(X, Y, tHerbivoro, PreyX, PreyY) then
    begin
      FTab.MarcarMorto(PreyX, PreyY);
      Ser.Fome := 0;
      FTab.Mover(X, Y, PreyX, PreyY);
      Movido := True;
    end;
  end
  else if Ser.Tipo = tBacteria then
  begin
    if ObterPreyAdjacente(X, Y, tMateria, PreyX, PreyY) then
    begin
      FTab.MarcarMorto(PreyX, PreyY);
      Ser.Fome := 0;
      FTab.Mover(X, Y, PreyX, PreyY);
      Movido := True;
    end;
  end;

  // 3. Fome
  if (Ser.Tipo in [tHerbivoro, tCarnivoro]) and (not Movido) then
  begin
    Inc(Ser.Fome);
    if Ser.Fome >= Ser.FomeMax then
    begin
      MorrerVirandoMateria(X, Y, Ser);
      Exit;
    end;
  end;

  // 4. Mover
  if (Ser.Tipo in [tHerbivoro, tCarnivoro, tBacteria]) and (not Movido) then
  begin
    // 20% de chance de movimento aleatorio
    if Random(100) < 20 then
    begin
      if ObterVizinhosLivresNext(X, Y, NextX, NextY) then
      begin
        FTab.Mover(X, Y, NextX, NextY);
        Movido := True;
      end;
    end;
  end;

  // Se nao moveu (ou e planta), fica parado no NextBoard
  if not Movido then
  begin
    FTab.Mover(X, Y, X, Y);
  end;

  // 5. Reproduzir
  Inc(Ser.Repro);
  if Ser.Repro >= Ser.ReproMax then
  begin
    // Procura vizinho livre a partir de onde o ser esta agora (no FNextBoard)
    if ObterVizinhosLivresNext(Ser.X, Ser.Y, FilhoX, FilhoY) then
    begin
      if Ser.Tipo = tPlanta then
        Filho := TSer.CreateSer(tPlanta, FCfg.VidaPlanta, 0, FCfg.ReproPlanta)
      else if Ser.Tipo = tHerbivoro then
        Filho := TSer.CreateSer(tHerbivoro, FCfg.VidaHerbivoro, FCfg.FomeHerbivoro, FCfg.ReproHerbivoro)
      else if Ser.Tipo = tCarnivoro then
        Filho := TSer.CreateSer(tCarnivoro, FCfg.VidaCarnivoro, FCfg.FomeCarnivoro, FCfg.ReproCarnivoro)
      else if Ser.Tipo = tBacteria then
        Filho := TSer.CreateSer(tBacteria, FCfg.VidaBacteria, 0, FCfg.ReproBacteria)
      else
        Filho := nil;

      if Filho <> nil then
      begin
        FTab.Colocar(Filho, FilhoX, FilhoY);
        Ser.Repro := 0;
      end;
    end;
  end;
end;

function TSimulacao.Contar: TEstat;
var
  X, Y: Integer;
  Ser: TSer;
begin
  Result.Ciclo := FCiclo;
  Result.Bacterias := 0;
  Result.Plantas := 0;
  Result.Herbivoros := 0;
  Result.Carnivoros := 0;
  Result.Materia := 0;
  Result.Vazios := 0;

  for X := 0 to FTab.W - 1 do
  begin
    for Y := 0 to FTab.H - 1 do
    begin
      Ser := FTab.GetSer(X, Y);
      if Ser = nil then
        Inc(Result.Vazios)
      else
      begin
        case Ser.Tipo of
          tBacteria: Inc(Result.Bacterias);
          tPlanta: Inc(Result.Plantas);
          tHerbivoro: Inc(Result.Herbivoros);
          tCarnivoro: Inc(Result.Carnivoros);
          tMateria: Inc(Result.Materia);
        end;
      end;
    end;
  end;
end;

end.
