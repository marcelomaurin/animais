unit uTipos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, aisimentity;

type
  TTipo = (tNada, tBacteria, tPlanta, tHerbivoro, tCarnivoro, tMateria);

  { TSer }

  TSer = class(TAISimEntity)
  public
    Tipo: TTipo;
    Idade: Integer;
    VidaMax: Integer;
    Fome: Integer;
    FomeMax: Integer;
    Repro: Integer;
    ReproMax: Integer;
    Morto: Boolean;

    constructor CreateSer(ATipo: TTipo; AVidaMax, AFomeMax, AReproMax: Integer);
  end;

implementation

{ TSer }

constructor TSer.CreateSer(ATipo: TTipo; AVidaMax, AFomeMax, AReproMax: Integer);
begin
  inherited Create(nil);
  Tipo := ATipo;
  VidaMax := AVidaMax;
  FomeMax := AFomeMax;
  ReproMax := AReproMax;
  Idade := 0;
  Fome := 0;
  Repro := 0;
  Morto := False;
end;

end.
