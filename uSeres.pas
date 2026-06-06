unit uSeres;

{$mode objfpc}{$H+}

interface

uses
  uTiposAnimais;

type
  TSer = class
  private
    FTipo: TTipoSer;
    FCicloVidaMax: Integer;
    FCicloReproMax: Integer;
    FCicloVidaAtual: Integer;
    FCicloReproAtual: Integer;
    FCiclosSemComida: Integer;
    FCome: TTipoSer;
    FMata: TTipoSer;
    
    // Novas propriedades evolutivas (Seção 22.4)
    FTamanho: TTamanhoAnimal;
    FToxicidade: TToxicidade;
    FResistenciaVeneno: TResistenciaVeneno;
    FResistenciaToxina: TResistenciaToxina;
    
    // Pontos de Matéria Orgânica (Seção 7)
    FPontos: Integer;
  public
    constructor Create(ATipo: TTipoSer; ALife, ARepro: Integer); virtual;
    procedure ResetCounters; inline;
    
    property Tipo: TTipoSer read FTipo;
    property CicloVidaMax: Integer read FCicloVidaMax write FCicloVidaMax;
    property CicloReproMax: Integer read FCicloReproMax write FCicloReproMax;
    property CicloVidaAtual: Integer read FCicloVidaAtual write FCicloVidaAtual;
    property CicloReproAtual: Integer read FCicloReproAtual write FCicloReproAtual;
    property CiclosSemComida: Integer read FCiclosSemComida write FCiclosSemComida;
    property Come: TTipoSer read FCome write FCome;
    property Mata: TTipoSer read FMata write FMata;
    
    // Properties for subtypes
    property Tamanho: TTamanhoAnimal read FTamanho write FTamanho;
    property Toxicidade: TToxicidade read FToxicidade write FToxicidade;
    property ResistenciaVeneno: TResistenciaVeneno read FResistenciaVeneno write FResistenciaVeneno;
    property ResistenciaToxina: TResistenciaToxina read FResistenciaToxina write FResistenciaToxina;
    property Pontos: Integer read FPontos write FPontos;
  end;

  TBacteria = class(TSer)
  public
    constructor Create(ATipo: TTipoSer; ALife, ARepro: Integer); override;
  end;

  TPlanta = class(TSer)
  public
    constructor Create(ATipo: TTipoSer; ALife, ARepro: Integer); override;
  end;

  TVegetariano = class(TSer)
  public
    constructor Create(ATipo: TTipoSer; ALife, ARepro: Integer); override;
  end;

  TCarnivoro = class(TSer)
  public
    constructor Create(ATipo: TTipoSer; ALife, ARepro: Integer); override;
  end;

  TMateriaOrganica = class(TSer)
  public
    constructor Create(ATipo: TTipoSer; ALife, ARepro: Integer); override;
  end;

function CriarSerPorTipo(ATipo: TTipoSer; ALifeMax, AReproMax: Integer): TSer;
function NomeSubEspecie(ASer: TSer): string;

implementation

function NomeSubEspecie(ASer: TSer): string;
begin
  if ASer = nil then
  begin
    Result := '';
    Exit;
  end;
  
  case ASer.Tipo of
    tsBacteria:
    begin
      if ASer.Toxicidade = txToxica then
        Result := 'Bactéria tóxica'
      else
        Result := 'Bactéria não tóxica';
    end;
    
    tsPlanta:
    begin
      if (ASer.Toxicidade = txToxica) and (ASer.ResistenciaToxina = rtResistente) then
        Result := 'Planta venenosa resistente à toxina bacteriana'
      else if ASer.Toxicidade = txToxica then
        Result := 'Planta venenosa'
      else if ASer.ResistenciaToxina = rtResistente then
        Result := 'Planta resistente à toxina bacteriana'
      else
        Result := 'Planta comum';
    end;
    
    tsVegetariano:
    begin
      case ASer.Tamanho of
        taPequeno: Result := 'Herbívoro pequeno';
        taMedio:   Result := 'Herbívoro médio';
        taGrande:  Result := 'Herbívoro grande';
        else       Result := 'Herbívoro médio';
      end;
      
      if ASer.ResistenciaVeneno = rvResistente then
        Result := Result + ' resistente a veneno'
      else
        Result := Result + ' comum';
    end;
    
    tsCarnivoro:
    begin
      case ASer.Tamanho of
        taPequeno: Result := 'Carnívoro pequeno';
        taMedio:   Result := 'Carnívoro médio';
        taGrande:  Result := 'Carnívoro grande';
        else       Result := 'Carnívoro médio';
      end;
    end;
    
    tsMateriaOrganica:
    begin
      Result := 'Matéria Orgânica';
    end;
    
    else
      Result := 'Desconhecido';
  end;
end;

{ ======== TSer ======== }

constructor TSer.Create(ATipo: TTipoSer; ALife, ARepro: Integer);
begin
  inherited Create;
  FTipo := ATipo;
  FCicloVidaMax := ALife;
  FCicloReproMax := ARepro;
  ResetCounters;
  FCome := tsNone;
  FMata := tsNone;
  
  // Inicialização padrão de características evolutivas (não mutado)
  FTamanho := taMedio;
  FToxicidade := txNenhuma;
  FResistenciaVeneno := rvNenhuma;
  FResistenciaToxina := rtNenhuma;
  FPontos := 0;
end;

procedure TSer.ResetCounters;
begin
  FCicloVidaAtual := 0;
  FCicloReproAtual := 0;
  FCiclosSemComida := 0;
end;

{ ======== TBacteria ======== }

constructor TBacteria.Create(ATipo: TTipoSer; ALife, ARepro: Integer);
begin
  inherited Create(tsBacteria, ALife, ARepro);
end;

{ ======== TPlanta ======== }

constructor TPlanta.Create(ATipo: TTipoSer; ALife, ARepro: Integer);
begin
  inherited Create(tsPlanta, ALife, ARepro);
end;

{ ======== TVegetariano ======== }

constructor TVegetariano.Create(ATipo: TTipoSer; ALife, ARepro: Integer);
begin
  inherited Create(tsVegetariano, ALife, ARepro);
end;

{ ======== TCarnivoro ======== }

constructor TCarnivoro.Create(ATipo: TTipoSer; ALife, ARepro: Integer);
begin
  inherited Create(tsCarnivoro, ALife, ARepro);
end;

{ ======== TMateriaOrganica ======== }

constructor TMateriaOrganica.Create(ATipo: TTipoSer; ALife, ARepro: Integer);
begin
  inherited Create(tsMateriaOrganica, ALife, ARepro);
end;

{ ======== Factory ======== }

function CriarSerPorTipo(ATipo: TTipoSer; ALifeMax, AReproMax: Integer): TSer;
begin
  case ATipo of
    tsBacteria: Result := TBacteria.Create(tsBacteria, ALifeMax, AReproMax);
    tsPlanta: Result := TPlanta.Create(tsPlanta, ALifeMax, AReproMax);
    tsVegetariano: Result := TVegetariano.Create(tsVegetariano, ALifeMax, AReproMax);
    tsCarnivoro: Result := TCarnivoro.Create(tsCarnivoro, ALifeMax, AReproMax);
    tsMateriaOrganica: Result := TMateriaOrganica.Create(tsMateriaOrganica, ALifeMax, AReproMax);
    else Result := nil;
  end;
end;

end.
