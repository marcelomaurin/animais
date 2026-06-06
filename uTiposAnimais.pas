unit uTiposAnimais;

{$mode objfpc}{$H+}

interface

uses
  Graphics;

type
  TTipoSer = (tsNone, tsBacteria, tsPlanta, tsVegetariano, tsCarnivoro);
  
  // Variações e características evolutivas (Seção 22.4)
  TTamanhoAnimal = (taPequeno, taMedio, taGrande);
  TToxicidade = (txNenhuma, txToxica);
  TResistenciaVeneno = (rvNenhuma, rvResistente);
  TResistenciaToxina = (rtNenhuma, rtResistente);

  // Tipos de Morte (Seção 22.14)
  TTipoMorte = (
    tmIdade,
    tmFome,
    tmPredacao,
    tmVeneno,
    tmToxina,
    tmAleatoria,
    tmConflito
  );

  // Informações de Subespécie para Biodiversidade (Seção 23.8 & 23.12)
  TSubEspecieInfo = record
    Nome: string;
    TipoPrincipal: TTipoSer;
    Vivos: Integer;
    Mortos: Integer;
    JaExistiu: Boolean;
    Extinta: Boolean;
    CicloExtincao: Int64;
  end;
  
  TSubEspeciesArray = array[0..14] of TSubEspecieInfo;

const
  // Visual color constants in BGR format
  COLOR_NONE = $000000;
  VAL_COLOR_BACTERIA = $00FFFF;
  VAL_COLOR_PLANTA = $00FF00;
  VAL_COLOR_VEGETARIANO = $0000FF;
  VAL_COLOR_CARNIVORO = $FF0000;

type
  TReproducaoConfig = record
    MaxDescendentesPorCiclo: Integer;
    CiclosParaReproduzir: Integer;
    ChanceReproducao: Double;
  end;

  TSimulacaoConfig = record
    Largura: Integer;
    Altura: Integer;
    PercentualBacteriasInicial: Double;
    CicloEntradaPlantas: Integer;
    CicloEntradaVegetarianos: Integer;
    CicloEntradaCarnivoros: Integer;
    QtdPlantasEntrada: Integer;
    QtdVegetarianosEntrada: Integer;
    QtdCarnivorosEntrada: Integer;
    IntervaloTimer: Integer;
    SeedAleatoria: Integer;
    
    // Configurações de Fome
    LimiteFomeBacteria: Integer;
    LimiteFomeVegetariano: Integer;
    LimiteFomeCarnivoro: Integer;
    
    // Configurações de Reprodução por espécie
    ReproBacteria: TReproducaoConfig;
    ReproPlanta: TReproducaoConfig;
    ReproVegetariano: TReproducaoConfig;
    ReproCarnivoro: TReproducaoConfig;
    
    // Proteção de superpopulação
    PercentualMaximoOcupacao: Double;
    
    // Configurações de Mutação (Seção 22.3)
    IntervaloMutacao: Integer;
    ChanceMutacaoPlanta: Double;
    ChanceMutacaoHerbivoro: Double;
    ChanceMutacaoCarnivoro: Double;
    ChanceMutacaoBacteria: Double;
    
    // Configurações de Histórico (Seção 24.9)
    IntervaloRegistroHistorico: Integer;
    MaxPontosHistorico: Integer;
    IntervaloAtualizacaoGrafico: Integer; // (Seção 24.12)
  end;

function ObterConfigPadrao: TSimulacaoConfig;
procedure InicializarSubEspecies(var ASubEspecies: TSubEspeciesArray);

implementation

procedure InicializarSubEspecies(var ASubEspecies: TSubEspeciesArray);
var
  i: Integer;
begin
  ASubEspecies[0].Nome := 'Bactéria não tóxica';
  ASubEspecies[0].TipoPrincipal := tsBacteria;
  
  ASubEspecies[1].Nome := 'Bactéria tóxica';
  ASubEspecies[1].TipoPrincipal := tsBacteria;
  
  ASubEspecies[2].Nome := 'Planta comum';
  ASubEspecies[2].TipoPrincipal := tsPlanta;
  
  ASubEspecies[3].Nome := 'Planta venenosa';
  ASubEspecies[3].TipoPrincipal := tsPlanta;
  
  ASubEspecies[4].Nome := 'Planta resistente à toxina bacteriana';
  ASubEspecies[4].TipoPrincipal := tsPlanta;
  
  ASubEspecies[5].Nome := 'Planta venenosa resistente à toxina bacteriana';
  ASubEspecies[5].TipoPrincipal := tsPlanta;
  
  ASubEspecies[6].Nome := 'Herbívoro pequeno comum';
  ASubEspecies[6].TipoPrincipal := tsVegetariano;
  
  ASubEspecies[7].Nome := 'Herbívoro médio comum';
  ASubEspecies[7].TipoPrincipal := tsVegetariano;
  
  ASubEspecies[8].Nome := 'Herbívoro grande comum';
  ASubEspecies[8].TipoPrincipal := tsVegetariano;
  
  ASubEspecies[9].Nome := 'Herbívoro pequeno resistente a veneno';
  ASubEspecies[9].TipoPrincipal := tsVegetariano;
  
  ASubEspecies[10].Nome := 'Herbívoro médio resistente a veneno';
  ASubEspecies[10].TipoPrincipal := tsVegetariano;
  
  ASubEspecies[11].Nome := 'Herbívoro grande resistente a veneno';
  ASubEspecies[11].TipoPrincipal := tsVegetariano;
  
  ASubEspecies[12].Nome := 'Carnívoro pequeno';
  ASubEspecies[12].TipoPrincipal := tsCarnivoro;
  
  ASubEspecies[13].Nome := 'Carnívoro médio';
  ASubEspecies[13].TipoPrincipal := tsCarnivoro;
  
  ASubEspecies[14].Nome := 'Carnívoro grande';
  ASubEspecies[14].TipoPrincipal := tsCarnivoro;
  
  for i := 0 to 14 do
  begin
    ASubEspecies[i].Vivos := 0;
    ASubEspecies[i].Mortos := 0;
    ASubEspecies[i].JaExistiu := False;
    ASubEspecies[i].Extinta := False;
    ASubEspecies[i].CicloExtincao := 0;
  end;
end;

function ObterConfigPadrao: TSimulacaoConfig;
begin
  Result.Largura := 200;
  Result.Altura := 200;
  Result.PercentualBacteriasInicial := 0.10; // 10%
  Result.CicloEntradaPlantas := 300;
  Result.CicloEntradaVegetarianos := 600;
  Result.CicloEntradaCarnivoros := 900;
  Result.QtdPlantasEntrada := 10;
  Result.QtdVegetarianosEntrada := 5;
  Result.QtdCarnivorosEntrada := 2;
  Result.IntervaloTimer := 10;
  Result.SeedAleatoria := 0;
  
  // Limites de fome padrões
  Result.LimiteFomeCarnivoro := 2;
  Result.LimiteFomeVegetariano := 3;
  Result.LimiteFomeBacteria := 6;
  
  // Configuração reprodutiva padrão de Bactérias
  Result.ReproBacteria.MaxDescendentesPorCiclo := 4;
  Result.ReproBacteria.CiclosParaReproduzir := 2;
  Result.ReproBacteria.ChanceReproducao := 0.80;
  
  // Configuração reprodutiva padrão de Plantas
  Result.ReproPlanta.MaxDescendentesPorCiclo := 3;
  Result.ReproPlanta.CiclosParaReproduzir := 4;
  Result.ReproPlanta.ChanceReproducao := 0.65;
  
  // Configuração reprodutiva padrão de Vegetarianos
  Result.ReproVegetariano.MaxDescendentesPorCiclo := 1;
  Result.ReproVegetariano.CiclosParaReproduzir := 8;
  Result.ReproVegetariano.ChanceReproducao := 0.35;
  
  // Configuração reprodutiva padrão de Carnívoros
  Result.ReproCarnivoro.MaxDescendentesPorCiclo := 1;
  Result.ReproCarnivoro.CiclosParaReproduzir := 12;
  Result.ReproCarnivoro.ChanceReproducao := 0.20;
  
  // Limite de ocupação global padrão
  Result.PercentualMaximoOcupacao := 0.85;
  
  // Valores padrão de mutação
  Result.IntervaloMutacao := 100;
  Result.ChanceMutacaoPlanta := 0.10;
  Result.ChanceMutacaoHerbivoro := 0.10;
  Result.ChanceMutacaoCarnivoro := 0.10;
  Result.ChanceMutacaoBacteria := 0.10;
  
  // Valores padrão de histórico (Seção 24.9)
  Result.IntervaloRegistroHistorico := 1;
  Result.MaxPontosHistorico := 10000;
  Result.IntervaloAtualizacaoGrafico := 10;
end;

end.
