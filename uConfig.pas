unit uConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TConfig = record
    Largura: Integer;
    Altura: Integer;
    Seed: Integer;
    PctBacteria: Double;
    PctPlanta: Double;
    PctHerbivoro: Double;
    PctCarnivoro: Double;
    VidaBacteria: Integer;
    VidaPlanta: Integer;
    VidaHerbivoro: Integer;
    VidaCarnivoro: Integer;
    FomeHerbivoro: Integer;
    FomeCarnivoro: Integer;
    ReproPlanta: Integer;
    ReproHerbivoro: Integer;
    ReproCarnivoro: Integer;
    ReproBacteria: Integer;
    DegradaMateria: Integer;
    CicloEntradaCarnivoro: Integer;
  end;

function ConfigPadrao: TConfig;

implementation

function ConfigPadrao: TConfig;
begin
  Result.Largura := 80;
  Result.Altura := 80;
  Result.Seed := 0;
  
  Result.PctBacteria := 0.08;
  Result.PctPlanta := 0.20;
  Result.PctHerbivoro := 0.06;
  Result.PctCarnivoro := 0.015;
  
  Result.VidaBacteria := 12;
  Result.VidaPlanta := 45;
  Result.VidaHerbivoro := 40;
  Result.VidaCarnivoro := 60;
  
  Result.FomeHerbivoro := 18;
  Result.FomeCarnivoro := 20;
  
  Result.ReproPlanta := 8;
  Result.ReproHerbivoro := 8;
  Result.ReproCarnivoro := 15;
  Result.ReproBacteria := 3;
  
  Result.DegradaMateria := 5;
  Result.CicloEntradaCarnivoro := 200;
end;

end.
