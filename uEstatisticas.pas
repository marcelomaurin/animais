unit uEstatisticas;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, uTiposAnimais, Math;

type
  TEstatisticasSimulacao = record
    Ciclo: Int64;
    Bacterias: Integer;
    Plantas: Integer;
    Vegetarianos: Integer; // Herbivoros
    Carnivoros: Integer;
    Vazios: Integer;
    TempoCicloMs: Double;
    FPS: Double;
    
    // Rastreamento de mortes por fome
    MortesPorFome: Integer;
    MortesFomeBacteria: Integer;
    MortesFomeVegetariano: Integer;
    MortesFomeCarnivoro: Integer;
    
    // Novas estatísticas evolutivas (Seção 22.16)
    PlantasVenenosas: Integer;
    PlantasResistentesToxina: Integer;
    
    HerbivorosResistentesVeneno: Integer;
    HerbivorosPequenos: Integer;
    HerbivorosMedios: Integer;
    HerbivorosGrandes: Integer;
    
    CarnivorosPequenos: Integer;
    CarnivorosMedios: Integer;
    CarnivorosGrandes: Integer;
    
    BacteriasToxicas: Integer;
    BacteriasNaoToxicas: Integer;
    
    MutacoesOcorridas: Integer;
    MortesPorVeneno: Integer;
    MortesPorToxina: Integer;
    
    // Novas estatísticas de Biodiversidade (Seção 23.12 e 23.5)
    EspeciesVivas: Integer;
    SubEspeciesVivas: Integer;
    EspeciesExtintas: Integer;
    SubEspeciesExtintas: Integer;
    MortesAcumuladas: Integer;
    
    // Rastreamento de mortes detalhado
    MortesIdade: Integer;
    MortesFomeCausa: Integer;
    MortesPredacao: Integer;
    MortesVenenoCausa: Integer;
    MortesToxinaCausa: Integer;
    MortesAleatoria: Integer;
    MortesConflito: Integer;
    
    // Histórico de subespécies por ciclo
    SubEspecies: TSubEspeciesArray;
  end;

  TEstatisticasArray = array of TEstatisticasSimulacao;

  TEstatisticasHistorico = class
  private
    FHistory: TEstatisticasArray;
    FCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Limpar;
    procedure Adicionar(const AStat: TEstatisticasSimulacao; AMaxCount: Integer = 0);
    procedure ExportarCSV(const APath: string);
    
    property History: TEstatisticasArray read FHistory;
    property Count: Integer read FCount;
  end;

implementation

constructor TEstatisticasHistorico.Create;
begin
  inherited Create;
  Limpar;
end;

destructor TEstatisticasHistorico.Destroy;
begin
  Limpar;
  inherited Destroy;
end;

procedure TEstatisticasHistorico.Limpar;
begin
  SetLength(FHistory, 0);
  FCount := 0;
end;

procedure TEstatisticasHistorico.Adicionar(const AStat: TEstatisticasSimulacao; AMaxCount: Integer);
var
  i: Integer;
begin
  if (AMaxCount > 0) and (FCount >= AMaxCount) then
  begin
    // Shifting array entries left to keep MaxPontosHistorico limit (Seção 24.9)
    for i := 1 to FCount - 1 do
      FHistory[i - 1] := FHistory[i];
    FHistory[FCount - 1] := AStat;
  end
  else
  begin
    if FCount >= Length(FHistory) then
    begin
      if Length(FHistory) = 0 then
        SetLength(FHistory, 128)
      else
        SetLength(FHistory, Length(FHistory) * 2);
    end;
    FHistory[FCount] := AStat;
    Inc(FCount);
  end;
end;

procedure TEstatisticasHistorico.ExportarCSV(const APath: string);
var
  List: TStringList;
  i, j: Integer;
  Stat: TEstatisticasSimulacao;
  FS: TFormatSettings;
  BioPath: string;
  BioList: TStringList;
  TipoStr: string;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  
  List := TStringList.Create;
  try
    // Header format with Section 22 and Section 23 columns combined
    List.Add('ciclo,plantas,plantas_venenosas,plantas_resistentes,' +
             'herbivoros,herbivoros_resistentes,carnivoros,carnivoros_pequenos,' +
             'carnivoros_medios,carnivoros_grandes,bacterias,bacterias_toxicas,' +
             'mutacoes,mortes_veneno,mortes_toxina,' +
             'especies_vivas,subespecies_vivas,especies_extintas,subespecies_extintas,mortes_acumuladas');
             
    for i := 0 to FCount - 1 do
    begin
      Stat := FHistory[i];
      List.Add(Format('%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d', [
        Stat.Ciclo,
        Stat.Plantas,
        Stat.PlantasVenenosas,
        Stat.PlantasResistentesToxina,
        Stat.Vegetarianos,
        Stat.HerbivorosResistentesVeneno,
        Stat.Carnivoros,
        Stat.CarnivorosPequenos,
        Stat.CarnivorosMedios,
        Stat.CarnivorosGrandes,
        Stat.Bacterias,
        Stat.BacteriasToxicas,
        Stat.MutacoesOcorridas,
        Stat.MortesPorVeneno,
        Stat.MortesPorToxina,
        Stat.EspeciesVivas,
        Stat.SubEspeciesVivas,
        Stat.EspeciesExtintas,
        Stat.SubEspeciesExtintas,
        Stat.MortesAcumuladas
      ], FS));
    end;
    List.SaveToFile(APath);
  finally
    List.Free;
  end;
  
  // Export separate biodiversidade.csv (Seção 23.15)
  BioPath := ExtractFilePath(APath) + 'biodiversidade.csv';
  BioList := TStringList.Create;
  try
    BioList.Add('ciclo,tipo,nome_subespecie,vivos,mortos,ja_existiu,extinta');
    for i := 0 to FCount - 1 do
    begin
      Stat := FHistory[i];
      for j := 0 to 14 do
      begin
        case Stat.SubEspecies[j].TipoPrincipal of
          tsBacteria:    TipoStr := 'Bactéria';
          tsPlanta:      TipoStr := 'Planta';
          tsVegetariano: TipoStr := 'Herbívoro';
          tsCarnivoro:   TipoStr := 'Carnívoro';
          else           TipoStr := 'Nenhum';
        end;
        
        BioList.Add(Format('%d,%s,%s,%d,%d,%d,%d', [
          Stat.Ciclo,
          TipoStr,
          Stat.SubEspecies[j].Nome,
          Stat.SubEspecies[j].Vivos,
          Stat.SubEspecies[j].Mortos,
          IfThen(Stat.SubEspecies[j].JaExistiu, 1, 0),
          IfThen(Stat.SubEspecies[j].Extinta, 1, 0)
        ]));
      end;
    end;
    BioList.SaveToFile(BioPath);
  finally
    BioList.Free;
  end;
end;

end.
