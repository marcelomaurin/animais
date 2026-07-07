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
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetTamanho(AW, AH: Integer);
    function InBounds(X, Y: Integer): Boolean;
    function GetSer(X, Y: Integer): TSer;
    function GetSerNext(X, Y: Integer): TSer;
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
end;

destructor TTabuleiro.Destroy;
var
  X, Y: Integer;
begin
  // Libera todos os objetos que estiverem no FBoard
  for X := 0 to FW - 1 do
  begin
    for Y := 0 to FH - 1 do
    begin
      if Assigned(FBoard[X, Y]) then
      begin
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
  if not InBounds(X, Y) then
    Exit(False);
  if not InBounds(NX, NY) then
    Exit(False);

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
  Ser := GetSer(X, Y);
  if Assigned(Ser) then
  begin
    Ser.Morto := True;
    if InBounds(X, Y) then
    begin
      if FNextBoard[X, Y] = Ser then
        FNextBoard[X, Y] := nil;
    end;
  end;
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
end;

end.
