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
    FomeBacteria: Integer; // 0 = bacteria nao sente fome
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
  
  // Valores ajustados para as regras atuais: presa vista nas 8 direcoes,
  // reproducao de animais e bacterias condicionada a alimentacao e fome de
  // bacteria. Com eles, os quatro grupos seguiram vivos aos 10000 ciclos nas
  // sementes 0 a 9. Ao mudar regras, refaca o ajuste.
  
  Result.PctBacteria := 0.08;
  Result.PctPlanta := 0.36;
  Result.PctHerbivoro := 0.03;
  Result.PctCarnivoro := 0.026;
  
  Result.VidaBacteria := 13;
  Result.VidaPlanta := 38;
  Result.VidaHerbivoro := 37;
  Result.VidaCarnivoro := 74;
  
  Result.FomeHerbivoro := 5;
  Result.FomeCarnivoro := 25;
  Result.FomeBacteria := 3;
  
  Result.ReproPlanta := 3;
  Result.ReproHerbivoro := 17;
  Result.ReproCarnivoro := 11;
  Result.ReproBacteria := 5;
  
  Result.DegradaMateria := 7;
  Result.CicloEntradaCarnivoro := 200;
end;

end.
