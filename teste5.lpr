program teste5;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uConfig, uTipos, uTabuleiro, uSimulacao;

var
  Cfg: TConfig;
  Sim: TSimulacao;
  CicloIndex, X, Y: Integer;
  Ser: TSer;
  ContB, ContP, ContH, ContC, ContM, ContV: Integer;
begin
  WriteLn('Iniciando Teste 5: Rodando 500 ciclos de simulação...');
  
  Cfg := ConfigPadrao;
  Sim := TSimulacao.Create(Cfg);
  try
    for CicloIndex := 1 to 500 do
    begin
      Sim.ExecutarCiclo;
      
      if (CicloIndex = 1) or (CicloIndex mod 50 = 0) then
      begin
        ContB := 0; ContP := 0; ContH := 0; ContC := 0; ContM := 0; ContV := 0;
        
        for X := 0 to Sim.Tabuleiro.W - 1 do
        begin
          for Y := 0 to Sim.Tabuleiro.H - 1 do
          begin
            Ser := Sim.Tabuleiro.GetSer(X, Y);
            if Ser = nil then
              Inc(ContV)
            else
            begin
              case Ser.Tipo of
                tBacteria: Inc(ContB);
                tPlanta: Inc(ContP);
                tHerbivoro: Inc(ContH);
                tCarnivoro: Inc(ContC);
                tMateria: Inc(ContM);
              end;
            end;
          end;
        end;
        
        WriteLn('Ciclo ', CicloIndex, ' -> Bact: ', ContB, ' | Plant: ', ContP, ' | Herb: ', ContH, ' | Carn: ', ContC, ' | Mat: ', ContM, ' | Vazio: ', ContV);
      end;
    end;
    
  finally
    Sim.Free;
  end;
  
  WriteLn('Teste 5 concluído com sucesso.');
end.
