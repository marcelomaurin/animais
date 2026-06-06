unit uTabuleiro;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Types, Math, uTiposAnimais, uSeres;

type
  TListaCoordenadas = record
    Coords: array[0..7] of TPoint;
    Count: Integer;
  end;

  TCelula = record
    Tipo: TTipoSer;
    Ent: TSer;
  end;

  TTabuleiro = class
  private
    FBoard: array of array of TCelula;
    FNextBoard: array of array of TCelula;
    FW: Integer;
    FH: Integer;
    
    procedure Clr(var ACel: TCelula); inline;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure SetTamanho(AW, AH: Integer);
    procedure Zerar;
    procedure PrepareNextBoard;
    procedure CommitNextBoard;
    
    function InBounds(x, y: Integer): Boolean; inline;
    function GetTipoAt(x, y: Integer): TTipoSer; inline;
    function GetEntAt(x, y: Integer): TSer; inline;
    function GetEntNextAt(x, y: Integer): TSer; inline;
    function IsCellEmptyBoth(x, y: Integer): Boolean; inline;
    
    function GetEmptyNeighborsBoth(x, y: Integer; out AEmpty: array of TPoint; out ACount: Integer): Boolean; deprecated;
    function ListaVizinhosLivres(x, y: Integer): TListaCoordenadas;
    
    procedure CopyCellToNext(x, y, nx, ny: Integer);
    procedure SpawnCellToNext(ATipo: TTipoSer; nx, ny: Integer; ALifeMax, AReproMax: Integer; ACome: TTipoSer = tsNone; AMata: TTipoSer = tsNone;
      ATamanho: TTamanhoAnimal = taMedio; AToxicidade: TToxicidade = txNenhuma;
      AResistenciaVeneno: TResistenciaVeneno = rvNenhuma; AResistenciaToxina: TResistenciaToxina = rtNenhuma);
    procedure FreeCell(x, y: Integer);
    procedure FreeCellNext(x, y: Integer);
    procedure ConsumeCell(x, y: Integer);
    
    function ColocaSerAleatorio(ATipo: TTipoSer; AQuantidade: Integer; ALifeMax, AReproMax: Integer; ACome: TTipoSer = tsNone; AMata: TTipoSer = tsNone;
      ATamanho: TTamanhoAnimal = taMedio; AToxicidade: TToxicidade = txNenhuma;
      AResistenciaVeneno: TResistenciaVeneno = rvNenhuma; AResistenciaToxina: TResistenciaToxina = rtNenhuma): Integer;
      
    function ColocaSerNiche(ATipo: TTipoSer; AQuantidade: Integer; ALifeMax, AReproMax: Integer; ACome: TTipoSer = tsNone; AMata: TTipoSer = tsNone;
      ATamanho: TTamanhoAnimal = taMedio; AToxicidade: TToxicidade = txNenhuma;
      AResistenciaVeneno: TResistenciaVeneno = rvNenhuma; AResistenciaToxina: TResistenciaToxina = rtNenhuma): Integer;
    
    property W: Integer read FW;
    property H: Integer read FH;
  end;

procedure EmbaralhaCoordenadas(var ALista: TListaCoordenadas);

implementation

constructor TTabuleiro.Create;
begin
  inherited Create;
  FW := 0;
  FH := 0;
end;

destructor TTabuleiro.Destroy;
begin
  Zerar;
  inherited Destroy;
end;

procedure TTabuleiro.Clr(var ACel: TCelula);
begin
  ACel.Tipo := tsNone;
  ACel.Ent := nil;
end;

procedure TTabuleiro.Zerar;
var
  x, y: Integer;
begin
  for x := 0 to FW - 1 do
    for y := 0 to FH - 1 do
    begin
      if FBoard[x, y].Ent <> nil then
        FBoard[x, y].Ent.Free;
      Clr(FBoard[x, y]);
      
      if FNextBoard[x, y].Ent <> nil then
        FNextBoard[x, y].Ent.Free;
      Clr(FNextBoard[x, y]);
    end;
end;

procedure TTabuleiro.SetTamanho(AW, AH: Integer);
begin
  Zerar;
  FW := AW;
  FH := AH;
  SetLength(FBoard, FW, FH);
  SetLength(FNextBoard, FW, FH);
  PrepareNextBoard;
end;

procedure TTabuleiro.PrepareNextBoard;
var
  x, y: Integer;
begin
  for x := 0 to FW - 1 do
    for y := 0 to FH - 1 do
      Clr(FNextBoard[x, y]);
end;

procedure TTabuleiro.CommitNextBoard;
var
  Temp: array of array of TCelula;
  x, y: Integer;
begin
  // Swap buffers
  Temp := FBoard;
  FBoard := FNextBoard;
  FNextBoard := Temp;
  
  // FNextBoard now contains the old board cells.
  // We need to clear them without freeing, because any surviving/moved objects
  // are now in the active FBoard.
  // We must free any remaining entities that were NOT copied over (i.e. those that died).
  for x := 0 to FW - 1 do
    for y := 0 to FH - 1 do
    begin
      if FNextBoard[x, y].Ent <> nil then
      begin
        FNextBoard[x, y].Ent.Free;
      end;
      Clr(FNextBoard[x, y]);
    end;
end;

function TTabuleiro.InBounds(x, y: Integer): Boolean;
begin
  Result := (x >= 0) and (x < FW) and (y >= 0) and (y < FH);
end;

function TTabuleiro.GetTipoAt(x, y: Integer): TTipoSer;
begin
  if InBounds(x, y) then
    Result := FBoard[x, y].Tipo
  else
    Result := tsNone;
end;

function TTabuleiro.GetEntAt(x, y: Integer): TSer;
begin
  if InBounds(x, y) then
    Result := FBoard[x, y].Ent
  else
    Result := nil;
end;

function TTabuleiro.GetEntNextAt(x, y: Integer): TSer;
begin
  if InBounds(x, y) then
    Result := FNextBoard[x, y].Ent
  else
    Result := nil;
end;

function TTabuleiro.IsCellEmptyBoth(x, y: Integer): Boolean;
begin
  Result := InBounds(x, y) and (FBoard[x, y].Tipo = tsNone) and (FNextBoard[x, y].Tipo = tsNone);
end;

function TTabuleiro.GetEmptyNeighborsBoth(x, y: Integer; out AEmpty: array of TPoint; out ACount: Integer): Boolean;
var
  dx, dy, nx, ny: Integer;
begin
  ACount := 0;
  for dx := -1 to 1 do
    for dy := -1 to 1 do
    begin
      if (dx = 0) and (dy = 0) then Continue;
      nx := x + dx; ny := y + dy;
      if IsCellEmptyBoth(nx, ny) then
      begin
        AEmpty[ACount].X := nx;
        AEmpty[ACount].Y := ny;
        Inc(ACount);
      end;
    end;
  Result := ACount > 0;
end;

function TTabuleiro.ListaVizinhosLivres(x, y: Integer): TListaCoordenadas;
var
  dx, dy, nx, ny: Integer;
begin
  Result.Count := 0;
  for dx := -1 to 1 do
    for dy := -1 to 1 do
    begin
      if (dx = 0) and (dy = 0) then Continue;
      nx := x + dx; ny := y + dy;
      if IsCellEmptyBoth(nx, ny) then
      begin
        Result.Coords[Result.Count].X := nx;
        Result.Coords[Result.Count].Y := ny;
        Inc(Result.Count);
      end;
    end;
end;

procedure EmbaralhaCoordenadas(var ALista: TListaCoordenadas);
var
  i, j: Integer;
  temp: TPoint;
begin
  for i := ALista.Count - 1 downto 1 do
  begin
    j := Random(i + 1);
    temp := ALista.Coords[i];
    ALista.Coords[i] := ALista.Coords[j];
    ALista.Coords[j] := temp;
  end;
end;

procedure TTabuleiro.CopyCellToNext(x, y, nx, ny: Integer);
begin
  if InBounds(x, y) and InBounds(nx, ny) then
  begin
    // Free whatever was in NextBoard target just in case
    if FNextBoard[nx, ny].Ent <> nil then
      FNextBoard[nx, ny].Ent.Free;
      
    FNextBoard[nx, ny].Ent := FBoard[x, y].Ent;
    FNextBoard[nx, ny].Tipo := FBoard[x, y].Tipo;
    Clr(FBoard[x, y]);
  end;
end;

procedure TTabuleiro.SpawnCellToNext(ATipo: TTipoSer; nx, ny: Integer; ALifeMax, AReproMax: Integer; ACome: TTipoSer = tsNone; AMata: TTipoSer = tsNone;
  ATamanho: TTamanhoAnimal = taMedio; AToxicidade: TToxicidade = txNenhuma;
  AResistenciaVeneno: TResistenciaVeneno = rvNenhuma; AResistenciaToxina: TResistenciaToxina = rtNenhuma);
begin
  if InBounds(nx, ny) then
  begin
    if FNextBoard[nx, ny].Ent <> nil then
      FNextBoard[nx, ny].Ent.Free;
      
    FNextBoard[nx, ny].Ent := CriarSerPorTipo(ATipo, ALifeMax, AReproMax);
    if FNextBoard[nx, ny].Ent <> nil then
    begin
      FNextBoard[nx, ny].Ent.Come := ACome;
      FNextBoard[nx, ny].Ent.Mata := AMata;
      FNextBoard[nx, ny].Ent.Tamanho := ATamanho;
      FNextBoard[nx, ny].Ent.Toxicidade := AToxicidade;
      FNextBoard[nx, ny].Ent.ResistenciaVeneno := AResistenciaVeneno;
      FNextBoard[nx, ny].Ent.ResistenciaToxina := AResistenciaToxina;
    end;
    FNextBoard[nx, ny].Tipo := ATipo;
  end;
end;

procedure TTabuleiro.FreeCell(x, y: Integer);
begin
  if InBounds(x, y) then
  begin
    if FBoard[x, y].Ent <> nil then
      FBoard[x, y].Ent.Free;
    Clr(FBoard[x, y]);
  end;
end;

procedure TTabuleiro.FreeCellNext(x, y: Integer);
begin
  if InBounds(x, y) then
  begin
    if FNextBoard[x, y].Ent <> nil then
      FNextBoard[x, y].Ent.Free;
    Clr(FNextBoard[x, y]);
  end;
end;

procedure TTabuleiro.ConsumeCell(x, y: Integer);
begin
  if InBounds(x, y) then
  begin
    if FNextBoard[x, y].Ent <> nil then
    begin
      FNextBoard[x, y].Ent.Free;
      FNextBoard[x, y].Ent := nil;
      FNextBoard[x, y].Tipo := tsNone;
    end;
    if FBoard[x, y].Ent <> nil then
    begin
      FBoard[x, y].Ent.Free;
      FBoard[x, y].Ent := nil;
      FBoard[x, y].Tipo := tsNone;
    end;
  end;
end;

function TTabuleiro.ColocaSerAleatorio(ATipo: TTipoSer; AQuantidade: Integer; ALifeMax, AReproMax: Integer; ACome: TTipoSer = tsNone; AMata: TTipoSer = tsNone;
  ATamanho: TTamanhoAnimal = taMedio; AToxicidade: TToxicidade = txNenhuma;
  AResistenciaVeneno: TResistenciaVeneno = rvNenhuma; AResistenciaToxina: TResistenciaToxina = rtNenhuma): Integer;
var
  i, x, y, tries: Integer;
  placed: Integer;
begin
  placed := 0;
  for i := 1 to AQuantidade do
  begin
    tries := 0;
    while tries < 5000 do
    begin
      x := Random(FW);
      y := Random(FH);
      if (FBoard[x, y].Tipo = tsNone) and (FBoard[x, y].Ent = nil) then
      begin
        FBoard[x, y].Ent := CriarSerPorTipo(ATipo, ALifeMax, AReproMax);
        if FBoard[x, y].Ent <> nil then
        begin
          FBoard[x, y].Ent.Come := ACome;
          FBoard[x, y].Ent.Mata := AMata;
          FBoard[x, y].Ent.Tamanho := ATamanho;
          FBoard[x, y].Ent.Toxicidade := AToxicidade;
          FBoard[x, y].Ent.ResistenciaVeneno := AResistenciaVeneno;
          FBoard[x, y].Ent.ResistenciaToxina := AResistenciaToxina;
        end;
        FBoard[x, y].Tipo := ATipo;
        Inc(placed);
        Break;
      end;
      Inc(tries);
    end;
  end;
  Result := placed;
end;

function TTabuleiro.ColocaSerNiche(ATipo: TTipoSer; AQuantidade: Integer; ALifeMax, AReproMax: Integer; ACome: TTipoSer = tsNone; AMata: TTipoSer = tsNone;
  ATamanho: TTamanhoAnimal = taMedio; AToxicidade: TToxicidade = txNenhuma;
  AResistenciaVeneno: TResistenciaVeneno = rvNenhuma; AResistenciaToxina: TResistenciaToxina = rtNenhuma): Integer;
var
  i, x, y, tries: Integer;
  placed: Integer;
  nx, ny, rx, ry: Integer;
begin
  placed := 0;
  nx := FW div 2;
  ny := FH div 2;
  rx := Max(10, Min(25, FW div 6));
  ry := Max(10, Min(25, FH div 6));
  
  for i := 1 to AQuantidade do
  begin
    tries := 0;
    while tries < 5000 do
    begin
      x := nx - rx + Random(2 * rx + 1);
      y := ny - ry + Random(2 * ry + 1);
      
      // Ensure bounds
      if x < 0 then x := 0;
      if x >= FW then x := FW - 1;
      if y < 0 then y := 0;
      if y >= FH then y := FH - 1;
      
      if (FBoard[x, y].Tipo = tsNone) and (FBoard[x, y].Ent = nil) then
      begin
        FBoard[x, y].Ent := CriarSerPorTipo(ATipo, ALifeMax, AReproMax);
        if FBoard[x, y].Ent <> nil then
        begin
          FBoard[x, y].Ent.Come := ACome;
          FBoard[x, y].Ent.Mata := AMata;
          FBoard[x, y].Ent.Tamanho := ATamanho;
          FBoard[x, y].Ent.Toxicidade := AToxicidade;
          FBoard[x, y].Ent.ResistenciaVeneno := AResistenciaVeneno;
          FBoard[x, y].Ent.ResistenciaToxina := AResistenciaToxina;
        end;
        FBoard[x, y].Tipo := ATipo;
        Inc(placed);
        Break;
      end;
      Inc(tries);
    end;
  end;
  Result := placed;
end;

end.
