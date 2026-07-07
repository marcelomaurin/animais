program teste1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uTipos;

var
  Ser: TSer;
begin
  WriteLn('Iniciando Teste 1: Instanciando TSer...');
  
  // Criar um ser (Tipo herbivoro, VidaMax 100, FomeMax 50, ReproMax 10)
  Ser := TSer.CreateSer(tHerbivoro, 100, 50, 10);
  try
    WriteLn('TSer instanciado com sucesso!');
    WriteLn('Tipo: ', Ser.Tipo);
    WriteLn('VidaMax: ', Ser.VidaMax);
    WriteLn('FomeMax: ', Ser.FomeMax);
    WriteLn('ReproMax: ', Ser.ReproMax);
    WriteLn('Morto: ', Ser.Morto);
  finally
    Ser.Free;
  end;
  
  WriteLn('Teste 1 concluído com sucesso.');
end.
