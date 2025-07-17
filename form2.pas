unit form2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Math;

const
  BOARD_W = 1000;
  BOARD_H = 1000;

type
  TTipoSer = (tsNone, tsBacteria, tsPlanta, tsVegetariano, tsCarnivoro);

  { ------------ Classe base ------------ }
  TSer = class
  public
    CicloVidaMax   : Integer;
    CicloReproMax  : Integer;
    CicloVidaAtual : Integer;
    CicloReproAtual: Integer;
    constructor Create(ALife, ARepro: Integer);
    procedure ResetCounters; inline;
  end;

  { ------------ Classes específicas ------------ }
  TBacteria     = class(TSer);
  TPlanta       = class(TSer);
  TVegetariano  = class(TSer);
  TCarnivoro    = class(TSer);

  { ------------ Tabuleiro ------------ }
  PCelula = ^TCelula;
  TCelula = record
    Tipo : TTipoSer;
    Ent  : TSer;          // ponteiro para o ser (nil se vazio)
  end;

  TTabuleiro = class
  private
    FCiclos : Int64;
    Board   : array[0..BOARD_W-1, 0..BOARD_H-1] of TCelula;
    procedure Libera(x, y: Integer);
    procedure Reproduz(x, y: Integer);
    procedure MoveAnimal(x, y: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Zera;
    procedure InicializaBacterias;
    procedure ColocaNovoSer(SerType: TTipoSer; x, y: Integer);
    procedure ProximoCiclo;
    property Ciclos: Int64 read FCiclos;
  end;

  { ------------ Form ------------ }

  { TForm2 }

  TForm2 = class(TForm)
    Panel1: TPanel;
    PanelButtons: TPanel;   // ➊ novo painel
    btnPause: TButton;
    btnStart: TButton;
    btnStop:  TButton;
    imgBoard: TImage;
    tmCycle: TTimer;

    procedure btnPauseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmCycleStartTimer(Sender: TObject);
    procedure tmCycleStopTimer(Sender: TObject);
    procedure tmCycleTimer(Sender: TObject);
  private
    Tab: TTabuleiro;
    procedure Desenha;
  end;


var
  frmform2: TForm2;

implementation

{$R *.lfm}

{ ======== TSer ======== }
constructor TSer.Create(ALife, ARepro: Integer);
begin
  CicloVidaMax   := ALife;
  CicloReproMax  := ARepro;
  ResetCounters;
end;

procedure TSer.ResetCounters;
begin
  CicloVidaAtual   := 0;
  CicloReproAtual  := 0;
end;

{ ======== TTabuleiro ======== }
constructor TTabuleiro.Create;
begin
  inherited Create;
  FCiclos := 0;      // ← inicialização explícita
  Zera;
  //InicializaBacterias;
end;

destructor TTabuleiro.Destroy;
var
  x,y: Integer;
begin
  for x:=0 to BOARD_W-1 do
    for y:=0 to BOARD_H-1 do
      Libera(x,y);
  inherited Destroy;
end;

procedure TTabuleiro.Zera;
var x,y: Integer;
begin
  FCiclos:=0;
  for x:=0 to BOARD_W-1 do
    for y:=0 to BOARD_H-1 do
    begin
      Board[x,y].Tipo := tsNone;
      Board[x,y].Ent  := nil;
    end;
end;

procedure TTabuleiro.InicializaBacterias;
var x,y: Integer;
begin
  // garante que todo o tabuleiro está vazio
  Zera;

  // coloca UMA bactéria na posição (1,1)
  ColocaNovoSer(tsBacteria, 1, 1);
end;

procedure TTabuleiro.Libera(x,y: Integer);
begin
  if Board[x,y].Ent<>nil then
    Board[x,y].Ent.Free;
  Board[x,y].Ent  := nil;
  Board[x,y].Tipo := tsNone;
end;

procedure TTabuleiro.ColocaNovoSer(SerType: TTipoSer; x, y: Integer);
begin
  Libera(x,y);
  case SerType of
    tsBacteria     : Board[x,y].Ent := TBacteria.Create(1,1);
    tsPlanta       : Board[x,y].Ent := TPlanta.Create(10,3);
    tsVegetariano  : Board[x,y].Ent := TVegetariano.Create(20,6);
    tsCarnivoro    : Board[x,y].Ent := TCarnivoro.Create(40,12);
  end;
  Board[x,y].Tipo := SerType;
end;

procedure TTabuleiro.Reproduz(x, y: Integer);
var dx,dy,nx,ny: Integer;
begin
  for dx:=-1 to 1 do for dy:=-1 to 1 do
  begin
    if (dx=0) and (dy=0) then Continue;
    nx:=x+dx; ny:=y+dy;
    if (nx<0) or (ny<0) or (nx>=BOARD_W) or (ny>=BOARD_H) then Continue;
    if Board[nx,ny].Tipo=tsNone then
      ColocaNovoSer(Board[x,y].Tipo, nx, ny);
  end;
end;

procedure TTabuleiro.MoveAnimal(x,y: Integer);
var empty: array[0..7] of TPoint;
    n,i: Integer;
    nx,ny,idx: Integer;
begin
  n:=0;
  for nx:=Max(0,x-1) to Min(BOARD_W-1,x+1) do
    for ny:=Max(0,y-1) to Min(BOARD_H-1,y+1) do
      if (nx<>x) or (ny<>y) then
        if Board[nx,ny].Tipo=tsNone then
        begin
          empty[n].X:=nx; empty[n].Y:=ny; Inc(n);
        end;
  if n=0 then Exit;
  idx:=Random(n);
  ColocaNovoSer(Board[x,y].Tipo, empty[idx].X, empty[idx].Y);
  Libera(x,y);
end;


procedure TTabuleiro.ProximoCiclo;
var
  x, y, nx, ny: Integer;
  ent: TSer;
  toRepro, toDie, toMove: Boolean;
  viz, food, carnNearby, bactCount: Integer;
  CyclesWithoutFood: Integer;
  carnivoreHunger: array[0..BOARD_W-1, 0..BOARD_H-1] of Integer;
begin
  Inc(FCiclos);

  // Introduções em ciclos específicos
  if FCiclos = 100 then ColocaNovoSer(tsPlanta, 1, 1);
  if FCiclos = 300 then ColocaNovoSer(tsVegetariano, 1, 1);
  if FCiclos = 600 then ColocaNovoSer(tsCarnivoro, 1, 1);

  // Fase de ciclo
  for x := 0 to BOARD_W - 1 do
    for y := 0 to BOARD_H - 1 do
      if Board[x, y].Ent <> nil then
        begin
          Board[x, y].Ent.CicloVidaAtual += 1;
          Board[x, y].Ent.CicloReproAtual += 1;
        end;

  for x := 0 to BOARD_W - 1 do
    for y := 0 to BOARD_H - 1 do
    begin
      ent := Board[x, y].Ent;
      if ent = nil then Continue;

      toDie   := False;
      toRepro := False;
      toMove  := False;
      viz     := 0;
      food    := 0;
      carnNearby := 0;
      bactCount := 0;

      for nx := Max(0, x - 1) to Min(BOARD_W - 1, x + 1) do
        for ny := Max(0, y - 1) to Min(BOARD_H - 1, y + 1) do
          if (nx <> x) or (ny <> y) then
          begin
            if Board[nx, ny].Tipo <> tsNone then
              Inc(viz);

            case Board[x, y].Tipo of
              tsVegetariano:
                begin
                  if Board[nx, ny].Tipo = tsPlanta then Inc(food);
                  if Board[nx, ny].Tipo = tsCarnivoro then Inc(carnNearby);
                end;

              tsCarnivoro:
                begin
                  if Board[nx, ny].Tipo = tsVegetariano then Inc(food);
                  if Board[nx, ny].Tipo = tsBacteria then Inc(bactCount);
                end;
            end;
          end;

      case Board[x, y].Tipo of
        tsBacteria:
          begin
            if viz > 3 then toDie := True;
            if ent.CicloReproAtual >= ent.CicloReproMax then
            begin
              toRepro := True;
              ent.CicloReproAtual := 0;
            end;
          end;

        tsPlanta:
          begin
            if ent.CicloVidaAtual >= ent.CicloVidaMax then toDie := True;
            if ent.CicloReproAtual >= ent.CicloReproMax then
            begin
              toRepro := True;
              ent.CicloReproAtual := 0;
            end;
          end;

        tsVegetariano:
          begin
            if food = 0 then
            begin
              toMove := True;
              if ent.CicloVidaAtual >= ent.CicloVidaMax then toDie := True;
            end;

            if carnNearby > 0 then
              toMove := True;

            if ent.CicloReproAtual >= ent.CicloReproMax then
            begin
              toRepro := True;
              ent.CicloReproAtual := 0;
            end;
          end;

        tsCarnivoro:
          begin
            // Morre mais rápido se houver bactérias próximas
            if bactCount > 0 then
              ent.CicloVidaAtual += (3 * bactCount); // morte acelerada

            // Controle de fome por 3 ciclos
            if food = 0 then
            begin
              Inc(carnivoreHunger[x, y]);
              if carnivoreHunger[x, y] >= 3 then
                toDie := True
              else
                toMove := True;
            end
            else
              carnivoreHunger[x, y] := 0;

            if ent.CicloVidaAtual >= ent.CicloVidaMax then toDie := True;

            if ent.CicloReproAtual >= ent.CicloReproMax then
            begin
              toRepro := True;
              ent.CicloReproAtual := 0;
            end;
          end;
      end;

      // Executa ações
      if toDie then
        Libera(x, y)
      else
      begin
        if toRepro then Reproduz(x, y);
        if toMove then MoveAnimal(x, y);
      end;
    end;
end;

{ ======== Form2 ======== }
procedure TForm2.FormCreate(Sender: TObject);
begin
  Randomize;
  imgBoard.Picture.Bitmap.SetSize(BOARD_W, BOARD_H);
  Tab := TTabuleiro.Create;
  Desenha;
end;

procedure TForm2.tmCycleStartTimer(Sender: TObject);
begin

end;

procedure TForm2.tmCycleStopTimer(Sender: TObject);
begin

end;

procedure TForm2.btnStartClick(Sender: TObject);
begin
  if Tab.Ciclos = 0 then
    begin
      Tab.InicializaBacterias;
      Desenha;
    end;

    tmCycle.Enabled := True;
end;

procedure TForm2.btnPauseClick(Sender: TObject);
begin
  tmCycle.Enabled:=not tmCycle.Enabled;
end;

procedure TForm2.btnStopClick(Sender: TObject);
begin
  tmCycle.Enabled:=False;
  Tab.Free;
  Tab := TTabuleiro.Create;
  Desenha;
end;

procedure TForm2.tmCycleTimer(Sender: TObject);
begin
  Tab.ProximoCiclo;
  Desenha;
  Caption:=Format('Ciclos: %d',[Tab.Ciclos]);
end;

procedure TForm2.Desenha;
var
  x, y: Integer;
  bmp: TBitmap;
  c: TColor;
  Line: PInteger;
begin
  bmp := imgBoard.Picture.Bitmap;
  bmp.BeginUpdate;
  for y := 0 to BOARD_H - 1 do
  begin
    Line := bmp.ScanLine[y];
    for x := 0 to BOARD_W - 1 do
    begin
      case Tab.Board[x, y].Tipo of
        tsBacteria    : c := $00FFFF;   // amarelo (BGR)
        tsPlanta      : c := $00FF00;   // verde   (BGR)
        tsVegetariano : c := $0000FF;   // azul    (BGR)
        tsCarnivoro   : c := $FF0000;   // vermelho(BGR)
      else
        c := $000000;                   // preto
      end;
      Line[x] := c;
    end;
  end;
  bmp.EndUpdate;
  imgBoard.Invalidate;
end;


end.

