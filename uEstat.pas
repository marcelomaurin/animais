unit uEstat;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TEstat = record
    Ciclo: Int64;
    Bacterias: Integer;
    Plantas: Integer;
    Herbivoros: Integer;
    Carnivoros: Integer;
    Materia: Integer;
    Vazios: Integer;
  end;

implementation

end.
