program teste2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, uTipos, uTabuleiro;

var
  Tab: TTabuleiro;
  Ser: TSer;
  I: Integer;
begin
  WriteLn('Iniciando Teste 2...');
  
  Tab := TTabuleiro.Create;
  try
    Tab.SetTamanho(5, 5);
    
    // Cria e coloca um ser
    Ser := TSer.CreateSer(tHerbivoro, 10, 10, 5);
    Tab.Colocar(Ser, 0, 0); // coloca no NextBoard
    Tab.Commit; // transfere para Board
    
    if Tab.GetSer(0, 0) = Ser then
      WriteLn('Ser inserido com sucesso em (0,0)')
    else
      WriteLn('ERRO: Ser nao encontrado em (0,0)');
      
    // Prepara proximo ciclo
    Tab.PrepararProximo;
    
    // Move de (0,0) para (1,1)
    if Tab.Mover(0, 0, 1, 1) then
      WriteLn('Ser movido com sucesso para (1,1)')
    else
      WriteLn('ERRO: Falha ao mover ser');
      
    Tab.Commit;
    
    if Tab.GetSer(0, 0) = nil then
      WriteLn('Posicao antiga (0,0) esta nil: OK')
    else
      WriteLn('ERRO: Posicao antiga (0,0) nao esta nil');
      
    if Tab.GetSer(1, 1) = Ser then
      WriteLn('Ser esta na nova posicao (1,1): OK')
    else
      WriteLn('ERRO: Ser nao encontrado na posicao (1,1)');
      
    // 100 ciclos de mover em vazio para testar vazamento
    WriteLn('Rodando 100 ciclos de movimento...');
    for I := 1 to 100 do
    begin
      Tab.PrepararProximo;
      // Move de (1,1) para (2,2) no ciclo impar, e volta no par
      if (I mod 2) = 1 then
        Tab.Mover(1, 1, 2, 2)
      else
        Tab.Mover(2, 2, 1, 1);
      Tab.Commit;
    end;
    
    WriteLn('Movimento concluído.');
  finally
    Tab.Free;
  end;
  
  WriteLn('Teste 2 concluído com sucesso.');
end.
