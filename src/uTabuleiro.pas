unit uTabuleiro;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uTipos;

type
  { TTabuleiro }

  TTabuleiro = class
  private
    FBoard: array of array of TSer;
    FNextBoard: array of array of TSer;
    FW: Integer;
    FH: Integer;
    // Seres mortos que ja nao estao em nenhum tabuleiro; liberados no Commit
    FMortos: TFPList;
    procedure LiberarMortos;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetTamanho(AW, AH: Integer);
    function InBounds(X, Y: Integer): Boolean;
    function GetSer(X, Y: Integer): TSer;
    function GetSerNext(X, Y: Integer): TSer;
    function GetSerVivo(X, Y: Integer): TSer;
    function CelulaLivreNext(X, Y: Integer): Boolean;
    procedure PrepararProximo;
    function Mover(X, Y, NX, NY: Integer): Boolean;
    procedure Colocar(ASer: TSer; X, Y: Integer);
    procedure ColocarNoBoard(ASer: TSer; X, Y: Integer);
    procedure MarcarMorto(X, Y: Integer);
    procedure Commit;

    property W: Integer read FW;
    property H: Integer read FH;
  end;

implementation

{ TTabuleiro }

constructor TTabuleiro.Create;
begin
  FW := 0;
  FH := 0;
  FMortos := TFPList.Create;
end;

destructor TTabuleiro.Destroy;
var
  X, Y: Integer;
begin
  LiberarMortos;
  FMortos.Free;

  // Libera todos os objetos que estiverem no FBoard
  for X := 0 to FW - 1 do
  begin
    for Y := 0 to FH - 1 do
    begin
      if Assigned(FBoard[X, Y]) then
      begin
        // O mesmo ser pode estar nos dois tabuleiros (materia recem-criada)
        if FNextBoard[X, Y] = FBoard[X, Y] then
          FNextBoard[X, Y] := nil;
        FBoard[X, Y].Free;
        FBoard[X, Y] := nil;
      end;
    end;
  end;
  
  // Libera todos os objetos que estiverem no FNextBoard
  for X := 0 to FW - 1 do
  begin
    for Y := 0 to FH - 1 do
    begin
      if Assigned(FNextBoard[X, Y]) then
      begin
        FNextBoard[X, Y].Free;
        FNextBoard[X, Y] := nil;
      end;
    end;
  end;

  inherited Destroy;
end;

procedure TTabuleiro.SetTamanho(AW, AH: Integer);
var
  X, Y: Integer;
begin
  FW := AW;
  FH := AH;
  SetLength(FBoard, FW, FH);
  SetLength(FNextBoard, FW, FH);

  for X := 0 to FW - 1 do
  begin
    for Y := 0 to FH - 1 do
    begin
      FBoard[X, Y] := nil;
      FNextBoard[X, Y] := nil;
    end;
  end;
end;

function TTabuleiro.InBounds(X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (X < FW) and (Y >= 0) and (Y < FH);
end;

function TTabuleiro.GetSer(X, Y: Integer): TSer;
begin
  if not InBounds(X, Y) then
    Exit(nil);
  Result := FBoard[X, Y];
end;

function TTabuleiro.GetSerNext(X, Y: Integer): TSer;
begin
  if not InBounds(X, Y) then
    Exit(nil);
  Result := FNextBoard[X, Y];
end;

// Retorna o ser vivo que ocupa a celula neste momento do ciclo, olhando
// primeiro o proximo tabuleiro (quem ja foi processado) e depois o atual.
function TTabuleiro.GetSerVivo(X, Y: Integer): TSer;
begin
  Result := nil;
  if not InBounds(X, Y) then
    Exit;
  if Assigned(FNextBoard[X, Y]) and (not FNextBoard[X, Y].Morto) then
    Result := FNextBoard[X, Y]
  else if Assigned(FBoard[X, Y]) and (not FBoard[X, Y].Morto) then
    Result := FBoard[X, Y];
end;

procedure TTabuleiro.LiberarMortos;
var
  I: Integer;
begin
  for I := 0 to FMortos.Count - 1 do
    TSer(FMortos[I]).Free;
  FMortos.Clear;
end;

function TTabuleiro.CelulaLivreNext(X, Y: Integer): Boolean;
begin
  if not InBounds(X, Y) then
    Exit(False);
  Result := FNextBoard[X, Y] = nil;
end;

procedure TTabuleiro.PrepararProximo;
var
  X, Y: Integer;
begin
  for X := 0 to FW - 1 do
  begin
    for Y := 0 to FH - 1 do
    begin
      FNextBoard[X, Y] := nil;
    end;
  end;
end;

function TTabuleiro.Mover(X, Y, NX, NY: Integer): Boolean;
begin
  Result := False;
  if not InBounds(X, Y) then
    Exit;
  if not InBounds(NX, NY) then
    Exit;

  if CelulaLivreNext(NX, NY) then
  begin
    FNextBoard[NX, NY] := FBoard[X, Y];
    FBoard[X, Y] := nil;
    if Assigned(FNextBoard[NX, NY]) then
    begin
      FNextBoard[NX, NY].X := NX;
      FNextBoard[NX, NY].Y := NY;
    end;
    Result := True;
  end;
end;

procedure TTabuleiro.Colocar(ASer: TSer; X, Y: Integer);
begin
  if InBounds(X, Y) then
  begin
    FNextBoard[X, Y] := ASer;
    if Assigned(ASer) then
    begin
      ASer.X := X;
      ASer.Y := Y;
    end;
  end;
end;

procedure TTabuleiro.ColocarNoBoard(ASer: TSer; X, Y: Integer);
begin
  if InBounds(X, Y) then
  begin
    FBoard[X, Y] := ASer;
    if Assigned(ASer) then
    begin
      ASer.X := X;
      ASer.Y := Y;
    end;
  end;
end;

procedure TTabuleiro.MarcarMorto(X, Y: Integer);
var
  Ser: TSer;
begin
  // Mata o ser vivo da celula, esteja ele no tabuleiro atual (ainda nao
  // processado) ou no proximo (ja processado neste ciclo).
  Ser := GetSerVivo(X, Y);
  if not Assigned(Ser) then
    Exit;

  Ser.Morto := True;
  if FNextBoard[X, Y] = Ser then
  begin
    FNextBoard[X, Y] := nil;
    // Se nao esta tambem no tabuleiro atual, ninguem mais aponta para ele:
    // guarda na lista para liberar no Commit.
    if FBoard[X, Y] <> Ser then
      FMortos.Add(Ser);
  end;
  // Se esta no tabuleiro atual, o Commit libera ao varrer o tabuleiro antigo.
end;

procedure TTabuleiro.Commit;
var
  Temp: array of array of TSer;
  X, Y: Integer;
begin
  // Swap buffers
  Temp := FBoard;
  FBoard := FNextBoard;
  FNextBoard := Temp;

  // FNextBoard agora contem o antigo FBoard.
  // Precisamos varrer e liberar apenas quem foi marcado como Morto.
  // Quem nao foi marcado como Morto ja migrou para FBoard (que era FNextBoard)
  // e portanto seu ponteiro ja foi limpo no FNextBoard antigo (pelo metodo Mover).
  // Se sobrou algum ponteiro no FNextBoard que NAO esta marcado como Morto,
  // significa que ele foi migrado e nao precisamos libera-lo (apenas setar nil).
  // Se for Morto, liberamos o objeto.
  for X := 0 to FW - 1 do
  begin
    for Y := 0 to FH - 1 do
    begin
      if Assigned(FNextBoard[X, Y]) then
      begin
        if FNextBoard[X, Y].Morto then
        begin
          FNextBoard[X, Y].Free;
        end;
        FNextBoard[X, Y] := nil;
      end;
    end;
  end;

  // Libera quem foi morto depois de ja ter migrado para o proximo tabuleiro
  LiberarMortos;
end;

end.
