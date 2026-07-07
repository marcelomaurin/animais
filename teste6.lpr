program teste6;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uConfig, uTipos, uTabuleiro, uSimulacao, uEstat;

var
  Cfg: TConfig;
  Sim: TSimulacao;
  F: TextFile;
  Est: TEstat;
  I: Integer;
begin
  WriteLn('Iniciando Teste 6: Gravando historico.csv...');
  
  Cfg := ConfigPadrao;
  Sim := TSimulacao.Create(Cfg);
  
  AssignFile(F, 'historico.csv');
  Rewrite(F);
  try
    WriteLn(F, 'Ciclo,Bacterias,Plantas,Herbivoros,Carnivoros,Materia,Vazios');
    
    for I := 1 to 200 do
    begin
      Sim.ExecutarCiclo;
      Est := Sim.Contar;
      WriteLn(F, Format('%d,%d,%d,%d,%d,%d,%d', [
        Est.Ciclo,
        Est.Bacterias,
        Est.Plantas,
        Est.Herbivoros,
        Est.Carnivoros,
        Est.Materia,
        Est.Vazios
      ]));
    end;
    
  finally
    CloseFile(F);
    Sim.Free;
  end;
  
  WriteLn('Teste 6 concluído com sucesso. historico.csv foi gerado.');
end.
