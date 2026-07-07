program teste4;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uConfig, uTipos, uSimulacao;

var
  Cfg: TConfig;
  Sim: TSimulacao;
  X, Y: Integer;
  Ser: TSer;
  ContBacteria, ContPlanta, ContHerbivoro, ContVazio: Integer;
begin
  WriteLn('Iniciando Teste 4: Seeding inicial...');
  
  Cfg := ConfigPadrao;
  // Config 80x80 = 6400 celulas
  // Bacteria: 8% = 512
  // Planta: 15% = 960
  // Herbivoro: 2% = 128
  
  Sim := TSimulacao.Create(Cfg);
  try
    ContBacteria := 0;
    ContPlanta := 0;
    ContHerbivoro := 0;
    ContVazio := 0;
    
    for X := 0 to Sim.Tabuleiro.W - 1 do
    begin
      for Y := 0 to Sim.Tabuleiro.H - 1 do
      begin
        Ser := Sim.Tabuleiro.GetSer(X, Y);
        if Ser = nil then
          Inc(ContVazio)
        else
        begin
          case Ser.Tipo of
            tBacteria: Inc(ContBacteria);
            tPlanta: Inc(ContPlanta);
            tHerbivoro: Inc(ContHerbivoro);
          end;
        end;
      end;
    end;
    
    WriteLn('Contagem observada no tabuleiro:');
    WriteLn('Bacterias: ', ContBacteria, ' (esperado ~512)');
    WriteLn('Plantas: ', ContPlanta, ' (esperado ~960)');
    WriteLn('Herbivoros: ', ContHerbivoro, ' (esperado ~128)');
    WriteLn('Vazios: ', ContVazio, ' (esperado ~4800)');
    
  finally
    Sim.Free;
  end;
  
  WriteLn('Teste 4 concluído com sucesso.');
end.
