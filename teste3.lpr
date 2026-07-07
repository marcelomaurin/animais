program teste3;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uConfig;

var
  Cfg: TConfig;
begin
  WriteLn('Iniciando Teste 3...');
  Cfg := ConfigPadrao;
  
  WriteLn('Largura: ', Cfg.Largura);
  WriteLn('Altura: ', Cfg.Altura);
  WriteLn('Seed: ', Cfg.Seed);
  WriteLn('PctBacteria: ', Cfg.PctBacteria:0:4);
  WriteLn('PctPlanta: ', Cfg.PctPlanta:0:4);
  WriteLn('PctHerbivoro: ', Cfg.PctHerbivoro:0:4);
  WriteLn('PctCarnivoro: ', Cfg.PctCarnivoro:0:4);
  WriteLn('VidaBacteria: ', Cfg.VidaBacteria);
  WriteLn('VidaPlanta: ', Cfg.VidaPlanta);
  WriteLn('VidaHerbivoro: ', Cfg.VidaHerbivoro);
  WriteLn('VidaCarnivoro: ', Cfg.VidaCarnivoro);
  WriteLn('FomeHerbivoro: ', Cfg.FomeHerbivoro);
  WriteLn('FomeCarnivoro: ', Cfg.FomeCarnivoro);
  WriteLn('ReproPlanta: ', Cfg.ReproPlanta);
  WriteLn('ReproHerbivoro: ', Cfg.ReproHerbivoro);
  WriteLn('ReproCarnivoro: ', Cfg.ReproCarnivoro);
  WriteLn('ReproBacteria: ', Cfg.ReproBacteria);
  WriteLn('DegradaMateria: ', Cfg.DegradaMateria);
  WriteLn('CicloEntradaCarnivoro: ', Cfg.CicloEntradaCarnivoro);
  
  WriteLn('Teste 3 concluído com sucesso.');
end.
