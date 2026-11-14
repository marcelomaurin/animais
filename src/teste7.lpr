program teste7;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uConfig, uTipos, uTabuleiro, uSimulacao, uEstat;

var
  Cfg: TConfig;
  Sim: TSimulacao;
  Est: TEstat;
  I: Integer;
begin
  WriteLn('Iniciando Teste 7: Rodando 2000 ciclos para equilíbrio...');
  
  Cfg := ConfigPadrao;
  Sim := TSimulacao.Create(Cfg);
  try
    for I := 1 to 2000 do
    begin
      Sim.ExecutarCiclo;
      if I mod 200 = 0 then
      begin
        Est := Sim.Contar;
        WriteLn(Format('Ciclo %4d: Bact=%d, Plant=%d, Herb=%d, Carn=%d, Mat=%d, Vazios=%d', [
          Est.Ciclo,
          Est.Bacterias,
          Est.Plantas,
          Est.Herbivoros,
          Est.Carnivoros,
          Est.Materia,
          Est.Vazios
        ]));
      end;
    end;
    
    Est := Sim.Contar;
    WriteLn('--- STATUS FINAL (Ciclo 2000) ---');
    WriteLn('Bacterias: ', Est.Bacterias);
    WriteLn('Plantas: ', Est.Plantas);
    WriteLn('Herbivoros: ', Est.Herbivoros);
    WriteLn('Carnivoros: ', Est.Carnivoros);
    WriteLn('Materia Organica: ', Est.Materia);
    WriteLn('Vazios: ', Est.Vazios);
    
    if (Est.Plantas > 0) and (Est.Herbivoros > 0) then
      WriteLn('SUCESSO: Plantas e Herbivoros sobreviveram!')
    else
      WriteLn('FALHA: Extincao detectada.');
      
  finally
    Sim.Free;
  end;
  
  WriteLn('Teste 7 concluído.');
end.
