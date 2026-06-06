unit uSimulacao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Math, uTiposAnimais, uSeres, uTabuleiro, uEstatisticas;

const
  LIFE_BACTERIA = 1;     REPRO_BACTERIA = 1;
  LIFE_PLANTA = 10;      REPRO_PLANTA = 3;
  LIFE_VEGETARIANO = 20; REPRO_VEGETARIANO = 6;
  LIFE_CARNIVORO = 40;   REPRO_CARNIVORO = 12;

type
  TSimulacao = class
  private
    FTabuleiro: TTabuleiro;
    FConfig: TSimulacaoConfig;
    FHistorico: TEstatisticasHistorico;
    
    // Class-wide mutation parameters
    FClassCome: array[TTipoSer] of TTipoSer;
    FClassMata: array[TTipoSer] of TTipoSer;
    
    FCicloAtual: Int64;
    FLastFPSTime: QWord;
    FCyclesSinceLastFPS: Integer;
    FFPS: Double;
    FLastCycleMs: Double;
    
    // Contadores de estatísticas por ciclo
    FMortesFomeBacteria: Integer;
    FMortesFomeVegetariano: Integer;
    FMortesFomeCarnivoro: Integer;
    FMortesPorFome: Integer;
    FOcupacaoGeral: Double;
    
    // Novas estatísticas (Seção 22.16)
    FMutacoesOcorridas: Integer;
    FMortesPorVeneno: Integer;
    FMortesPorToxina: Integer;
    
    // Novas estatísticas de Biodiversidade e causas (Seção 23.5 e 23.13)
    FSubEspecies: TSubEspeciesArray;
    FMortesIdade: Integer;
    FMortesFomeCausa: Integer;
    FMortesPredacao: Integer;
    FMortesVenenoCausa: Integer;
    FMortesToxinaCausa: Integer;
    FMortesAleatoria: Integer;
    FMortesConflito: Integer;
    
    FMortesAcumuladasBacteria: Integer;
    FMortesAcumuladasPlanta: Integer;
    FMortesAcumuladasVegetariano: Integer;
    FMortesAcumuladasCarnivoro: Integer;
    
    procedure RegistraMorte(ASer: TSer; ACausa: TTipoMorte);
    
    procedure ProcessarEcolgicoInstintos;
    procedure MutarInstintos;
    procedure ExecutarAcoesCelula(x, y: Integer);
    function ConsumeFood(x, y: Integer; ent: TSer): Boolean;
    
    function GetLimiteFome(ATipo: TTipoSer): Integer;
    function SerPossuiFome(ATipo: TTipoSer): Boolean;
    procedure ProcessaReproducao(x, y: Integer; ASer: TSer);
    function ObterReproConfig(ATipo: TTipoSer): TReproducaoConfig;
    
    // Novas funções evolutivas (Seção 22.11 e 22.13)
    function PodeComer(APredador, APresa: TSer): Boolean;
    function ObterChanceMutacao(ATipo: TTipoSer): Double;
    procedure MutarPropriedadesFilho(ATipo: TTipoSer; 
      var ATamanho: TTamanhoAnimal; var AToxicidade: TToxicidade; 
      var AResistenciaVeneno: TResistenciaVeneno; var AResistenciaToxina: TResistenciaToxina);
      
    // Comportamento Direcionado e Busca Ativa (Seções 4, 5 e 14)
    function DistanciaChebyshev(X1, Y1, X2, Y2: Integer): Integer;
    function EncontrarPresaMaisProxima(X, Y: Integer; APredador: TSer; ARaio: Integer; out AX, AY: Integer): Boolean;
    function MoverUmPassoEmDirecao(X, Y: Integer; DestX, DestY: Integer; out NovoX, NovoY: Integer): Boolean;
    function MoveUmaCasaEmDirecao(XAtual, YAtual: Integer; XAlvo, YAlvo: Integer; out NovoX, NovoY: Integer): Boolean;
    function MoveUmaCasaParaLonge(XAtual, YAtual: Integer; XPerigo, YPerigo: Integer; out NovoX, NovoY: Integer): Boolean;
    function EncontrarSerMaisProximo(X, Y: Integer; ATipo: TTipoSer; ARaio: Integer; out AlvoX, AlvoY: Integer): Boolean;
    function TentarComer(X, Y: Integer; ASer: TSer; out MorreuEnvenenado: Boolean): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Inicializar;
    procedure Configurar(const AConfig: TSimulacaoConfig);
    procedure ExecutarCiclo;
    procedure Reiniciar;
    
    function CalculaEstatisticas: TEstatisticasSimulacao;
    
    property Tabuleiro: TTabuleiro read FTabuleiro;
    property Config: TSimulacaoConfig read FConfig;
    property Historico: TEstatisticasHistorico read FHistorico;
    property CicloAtual: Int64 read FCicloAtual;
    property FPS: Double read FFPS;
  end;

implementation

procedure TSimulacao.RegistraMorte(ASer: TSer; ACausa: TTipoMorte);
var
  subNome: string;
  i: Integer;
begin
  if ASer = nil then Exit;
  
  subNome := NomeSubEspecie(ASer);
  
  // 1. Incrementar mortos acumulados da espécie principal
  case ASer.Tipo of
    tsBacteria:    Inc(FMortesAcumuladasBacteria);
    tsPlanta:      Inc(FMortesAcumuladasPlanta);
    tsVegetariano: Inc(FMortesAcumuladasVegetariano);
    tsCarnivoro:   Inc(FMortesAcumuladasCarnivoro);
  end;
  
  // 2. Incrementar mortos acumulados da subespécie e marcar JaExistiu
  for i := 0 to 14 do
  begin
    if FSubEspecies[i].Nome = subNome then
    begin
      Inc(FSubEspecies[i].Mortos);
      FSubEspecies[i].JaExistiu := True;
      Break;
    end;
  end;
  
  // 3. Registrar causa da morte
  case ACausa of
    tmIdade:     Inc(FMortesIdade);
    tmFome:      Inc(FMortesFomeCausa);
    tmPredacao:  Inc(FMortesPredacao);
    tmVeneno:    Inc(FMortesVenenoCausa);
    tmToxina:    Inc(FMortesToxinaCausa);
    tmAleatoria: Inc(FMortesAleatoria);
    tmConflito:  Inc(FMortesConflito);
  end;
  
  // 4. Gerar matéria orgânica se aplicável (não aplicável nesta versão do motor)
end;

constructor TSimulacao.Create;
var
  t: TTipoSer;
begin
  inherited Create;
  FTabuleiro := TTabuleiro.Create;
  FHistorico := TEstatisticasHistorico.Create;
  FConfig := ObterConfigPadrao;
  
  for t := Low(TTipoSer) to High(TTipoSer) do
  begin
    FClassCome[t] := tsNone;
    FClassMata[t] := tsNone;
  end;
  
  FCicloAtual := 0;
  FLastFPSTime := 0;
  FCyclesSinceLastFPS := 0;
  FFPS := 0.0;
  FLastCycleMs := 0.0;
  
  FMortesFomeBacteria := 0;
  FMortesFomeVegetariano := 0;
  FMortesFomeCarnivoro := 0;
  FMortesPorFome := 0;
  FOcupacaoGeral := 0.0;
  
  FMutacoesOcorridas := 0;
  FMortesPorVeneno := 0;
  FMortesPorToxina := 0;
  
  InicializarSubEspecies(FSubEspecies);
  FMortesIdade := 0;
  FMortesFomeCausa := 0;
  FMortesPredacao := 0;
  FMortesVenenoCausa := 0;
  FMortesToxinaCausa := 0;
  FMortesAleatoria := 0;
  FMortesConflito := 0;
  
  FMortesAcumuladasBacteria := 0;
  FMortesAcumuladasPlanta := 0;
  FMortesAcumuladasVegetariano := 0;
  FMortesAcumuladasCarnivoro := 0;
end;

destructor TSimulacao.Destroy;
begin
  FTabuleiro.Free;
  FHistorico.Free;
  inherited Destroy;
end;

procedure TSimulacao.Configurar(const AConfig: TSimulacaoConfig);
begin
  FConfig := AConfig;
end;

procedure TSimulacao.Inicializar;
begin
  if FConfig.SeedAleatoria > 0 then
    RandSeed := FConfig.SeedAleatoria
  else
    Randomize;
    
  FTabuleiro.SetTamanho(FConfig.Largura, FConfig.Altura);
  FCicloAtual := 0;
  FHistorico.Limpar;
  
  FLastFPSTime := GetTickCount64;
  FCyclesSinceLastFPS := 0;
  FFPS := 0.0;
  FLastCycleMs := 0.0;
  
  FMortesFomeBacteria := 0;
  FMortesFomeVegetariano := 0;
  FMortesFomeCarnivoro := 0;
  FMortesPorFome := 0;
  FOcupacaoGeral := 0.0;
  
  FMutacoesOcorridas := 0;
  FMortesPorVeneno := 0;
  FMortesPorToxina := 0;
  
  InicializarSubEspecies(FSubEspecies);
  FMortesIdade := 0;
  FMortesFomeCausa := 0;
  FMortesPredacao := 0;
  FMortesVenenoCausa := 0;
  FMortesToxinaCausa := 0;
  FMortesAleatoria := 0;
  FMortesConflito := 0;
  
  FMortesAcumuladasBacteria := 0;
  FMortesAcumuladasPlanta := 0;
  FMortesAcumuladasVegetariano := 0;
  FMortesAcumuladasCarnivoro := 0;
  
  // Place initial bacteria based on percentage if set, otherwise use absolute count (Seção 24.15)
  if FConfig.PercentualBacteriasInicial > 0 then
  begin
    FTabuleiro.ColocaSerNiche(
      tsBacteria,
      Round(FConfig.Largura * FConfig.Altura * FConfig.PercentualBacteriasInicial),
      LIFE_BACTERIA,
      REPRO_BACTERIA
    );
  end
  else
  begin
    FTabuleiro.ColocaSerNiche(
      tsBacteria,
      FConfig.QtdBacteriasInicial,
      LIFE_BACTERIA,
      REPRO_BACTERIA
    );
  end;
  
  // Place initial common plants (plantas comum 100)
  FTabuleiro.ColocaSerNiche(
    tsPlanta,
    FConfig.QtdPlantasInicial,
    LIFE_PLANTA,
    REPRO_PLANTA
  );
  
  // Place initial vegetarian/herbivore animals (herbivoros 10)
  FTabuleiro.ColocaSerNiche(
    tsVegetariano,
    FConfig.QtdVegetarianosInicial,
    LIFE_VEGETARIANO,
    REPRO_VEGETARIANO
  );
  
  // Place initial carnivore animals (carnivoros 4)
  FTabuleiro.ColocaSerNiche(
    tsCarnivoro,
    FConfig.QtdCarnivorosInicial,
    LIFE_CARNIVORO,
    REPRO_CARNIVORO
  );
  
  // Salva estado inicial (ciclo 0) no histórico se configurado (Seção 24.4 e 24.5)
  if (FCicloAtual mod FConfig.IntervaloRegistroHistorico = 0) then
    FHistorico.Adicionar(CalculaEstatisticas, FConfig.MaxPontosHistorico);
end;

procedure TSimulacao.Reiniciar;
begin
  Inicializar;
end;

function TSimulacao.GetLimiteFome(ATipo: TTipoSer): Integer;
begin
  case ATipo of
    tsBacteria: Result := FConfig.LimiteFomeBacteria;
    tsVegetariano: Result := FConfig.LimiteFomeVegetariano;
    tsCarnivoro: Result := FConfig.LimiteFomeCarnivoro;
    else Result := 0;
  end;
end;

function TSimulacao.SerPossuiFome(ATipo: TTipoSer): Boolean;
begin
  Result := ATipo in [tsVegetariano, tsCarnivoro];
end;

function TSimulacao.ObterReproConfig(ATipo: TTipoSer): TReproducaoConfig;
begin
  case ATipo of
    tsBacteria: Result := FConfig.ReproBacteria;
    tsPlanta: Result := FConfig.ReproPlanta;
    tsVegetariano: Result := FConfig.ReproVegetariano;
    tsCarnivoro: Result := FConfig.ReproCarnivoro;
    else FillChar(Result, SizeOf(Result), 0);
  end;
end;

function TSimulacao.PodeComer(APredador, APresa: TSer): Boolean;
begin
  Result := False;
  if (APredador = nil) or (APresa = nil) then Exit;
  
  case APredador.Tipo of
    tsVegetariano:
    begin
      // Vegetarianos (Herbívoros) comem plantas e bactérias
      if APresa.Tipo in [tsPlanta, tsBacteria] then
      begin
        // Ele sempre tenta comer (se for planta venenosa e ele for sem resistência, morre no ConsumeFood)
        Result := True;
      end;
    end;
    
    tsCarnivoro:
    begin
      // Carnívoros comem vegetarianos e outros carnívoros
      if APresa.Tipo = tsVegetariano then
      begin
        // Herbívoro maior não pode ser comido por carnívoro menor
        Result := Ord(APredador.Tamanho) >= Ord(APresa.Tamanho);
      end
      else if APresa.Tipo = tsCarnivoro then
      begin
        // Carnívoro maior pode comer carnívoro menor (mesmo tamanho não se come por padrão)
        Result := Ord(APredador.Tamanho) > Ord(APresa.Tamanho);
      end;
    end;
  end;
end;

function TSimulacao.DistanciaChebyshev(X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Max(Abs(X1 - X2), Abs(Y1 - Y2));
end;

function TSimulacao.EncontrarPresaMaisProxima(
  X, Y: Integer;
  APredador: TSer;
  ARaio: Integer;
  out AX, AY: Integer
): Boolean;
var
  R, dx, dy, nx, ny: Integer;
  candidatos: array of TPoint;
  candidatosCount: Integer;
  presa: TSer;
  idx: Integer;
begin
  candidatos := nil;
  Result := False;
  candidatosCount := 0;
  
  for R := 1 to ARaio do
  begin
    for dy := -R to R do
    begin
      for dx := -R to R do
      begin
        if (Abs(dx) = R) or (Abs(dy) = R) then
        begin
          nx := X + dx;
          ny := Y + dy;
          if FTabuleiro.InBounds(nx, ny) then
          begin
            presa := FTabuleiro.GetEntAt(nx, ny);
            if (presa <> nil) and PodeComer(APredador, presa) then
            begin
              if candidatosCount >= Length(candidatos) then
                SetLength(candidatos, candidatosCount + 16);
              candidatos[candidatosCount].X := nx;
              candidatos[candidatosCount].Y := ny;
              Inc(candidatosCount);
            end;
          end;
        end;
      end;
    end;
    
    if candidatosCount > 0 then
    begin
      idx := Random(candidatosCount);
      AX := candidatos[idx].X;
      AY := candidatos[idx].Y;
      Result := True;
      Exit;
    end;
  end;
end;

function TSimulacao.MoverUmPassoEmDirecao(
  X, Y: Integer;
  DestX, DestY: Integer;
  out NovoX, NovoY: Integer
): Boolean;
var
  lista: TListaCoordenadas;
  i: Integer;
  nx, ny: Integer;
  dist, minDist: Integer;
  candidatos: array[0..7] of TPoint;
  candidatosCount: Integer;
begin
  Result := False;
  lista := FTabuleiro.ListaVizinhosLivres(X, Y);
  if lista.Count = 0 then Exit;
  
  minDist := 999999;
  candidatosCount := 0;
  
  for i := 0 to lista.Count - 1 do
  begin
    nx := lista.Coords[i].X;
    ny := lista.Coords[i].Y;
    dist := DistanciaChebyshev(nx, ny, DestX, DestY);
    
    if dist < minDist then
    begin
      minDist := dist;
      candidatosCount := 1;
      candidatos[0].X := nx;
      candidatos[0].Y := ny;
    end
    else if dist = minDist then
    begin
      candidatos[candidatosCount].X := nx;
      candidatos[candidatosCount].Y := ny;
      Inc(candidatosCount);
    end;
  end;
  
  if candidatosCount > 0 then
  begin
    i := Random(candidatosCount);
    NovoX := candidatos[i].X;
    NovoY := candidatos[i].Y;
    Result := True;
  end;
end;

function TSimulacao.MoveUmaCasaEmDirecao(
  XAtual, YAtual: Integer;
  XAlvo, YAlvo: Integer;
  out NovoX, NovoY: Integer
): Boolean;
var
  lista: TListaCoordenadas;
  i, nx, ny, dist, currDist: Integer;
  candidatos: array[0..7] of TPoint;
  candidatosCount: Integer;
  minDist: Integer;
begin
  Result := False;
  currDist := DistanciaChebyshev(XAtual, YAtual, XAlvo, YAlvo);
  
  if currDist <= 1 then Exit;
  
  lista := FTabuleiro.ListaVizinhosLivres(XAtual, YAtual);
  if lista.Count = 0 then Exit;
  
  minDist := currDist;
  candidatosCount := 0;
  
  for i := 0 to lista.Count - 1 do
  begin
    nx := lista.Coords[i].X;
    ny := lista.Coords[i].Y;
    dist := DistanciaChebyshev(nx, ny, XAlvo, YAlvo);
    
    if dist < minDist then
    begin
      minDist := dist;
      candidatosCount := 1;
      candidatos[0].X := nx;
      candidatos[0].Y := ny;
    end
    else if (dist = minDist) and (dist < currDist) then
    begin
      candidatos[candidatosCount].X := nx;
      candidatos[candidatosCount].Y := ny;
      Inc(candidatosCount);
    end;
  end;
  
  if candidatosCount > 0 then
  begin
    i := Random(candidatosCount);
    NovoX := candidatos[i].X;
    NovoY := candidatos[i].Y;
    Result := True;
  end;
end;

function TSimulacao.MoveUmaCasaParaLonge(
  XAtual, YAtual: Integer;
  XPerigo, YPerigo: Integer;
  out NovoX, NovoY: Integer
): Boolean;
var
  lista: TListaCoordenadas;
  i, nx, ny, dist, currDist: Integer;
  candidatos: array[0..7] of TPoint;
  candidatosCount: Integer;
  maxDist: Integer;
begin
  Result := False;
  currDist := DistanciaChebyshev(XAtual, YAtual, XPerigo, YPerigo);
  
  lista := FTabuleiro.ListaVizinhosLivres(XAtual, YAtual);
  if lista.Count = 0 then Exit;
  
  maxDist := currDist;
  candidatosCount := 0;
  
  for i := 0 to lista.Count - 1 do
  begin
    nx := lista.Coords[i].X;
    ny := lista.Coords[i].Y;
    dist := DistanciaChebyshev(nx, ny, XPerigo, YPerigo);
    
    if dist > maxDist then
    begin
      maxDist := dist;
      candidatosCount := 1;
      candidatos[0].X := nx;
      candidatos[0].Y := ny;
    end
    else if (dist = maxDist) and (dist > currDist) then
    begin
      candidatos[candidatosCount].X := nx;
      candidatos[candidatosCount].Y := ny;
      Inc(candidatosCount);
    end;
  end;
  
  if candidatosCount > 0 then
  begin
    i := Random(candidatosCount);
    NovoX := candidatos[i].X;
    NovoY := candidatos[i].Y;
    Result := True;
  end;
end;

function TSimulacao.EncontrarSerMaisProximo(
  X, Y: Integer;
  ATipo: TTipoSer;
  ARaio: Integer;
  out AlvoX, AlvoY: Integer
): Boolean;
var
  R, dx, dy, nx, ny: Integer;
  candidatos: array of TPoint;
  candidatosCount: Integer;
  idx: Integer;
begin
  candidatos := nil;
  Result := False;
  candidatosCount := 0;
  
  for R := 1 to ARaio do
  begin
    for dy := -R to R do
    begin
      for dx := -R to R do
      begin
        if (Abs(dx) = R) or (Abs(dy) = R) then
        begin
          nx := X + dx;
          ny := Y + dy;
          if FTabuleiro.InBounds(nx, ny) then
          begin
            if FTabuleiro.GetTipoAt(nx, ny) = ATipo then
            begin
              if candidatosCount >= Length(candidatos) then
                SetLength(candidatos, candidatosCount + 16);
              candidatos[candidatosCount].X := nx;
              candidatos[candidatosCount].Y := ny;
              Inc(candidatosCount);
            end;
          end;
        end;
      end;
    end;
    
    if candidatosCount > 0 then
    begin
      idx := Random(candidatosCount);
      AlvoX := candidatos[idx].X;
      AlvoY := candidatos[idx].Y;
      Result := True;
      Exit;
    end;
  end;
end;

function TSimulacao.TentarComer(X, Y: Integer; ASer: TSer; out MorreuEnvenenado: Boolean): Boolean;
var
  dx, dy, nx, ny: Integer;
  presa: TSer;
  candidatos: array[0..7] of TPoint;
  candidatosCount: Integer;
  idx: Integer;
begin
  Result := False;
  MorreuEnvenenado := False;
  candidatosCount := 0;
  
  for dx := -1 to 1 do
    for dy := -1 to 1 do
    begin
      if (dx = 0) and (dy = 0) then Continue;
      nx := X + dx;
      ny := Y + dy;
      if FTabuleiro.InBounds(nx, ny) then
      begin
        presa := FTabuleiro.GetEntAt(nx, ny);
        if (presa <> nil) and PodeComer(ASer, presa) then
        begin
          candidatos[candidatosCount].X := nx;
          candidatos[candidatosCount].Y := ny;
          Inc(candidatosCount);
        end;
      end;
    end;
    
  if candidatosCount > 0 then
  begin
    idx := Random(candidatosCount);
    nx := candidatos[idx].X;
    ny := candidatos[idx].Y;
    presa := FTabuleiro.GetEntAt(nx, ny);
    
    if (ASer.Tipo = tsVegetariano) and (presa <> nil) and (presa.Tipo = tsPlanta) and (presa.Toxicidade = txToxica) then
    begin
      if ASer.ResistenciaVeneno = rvResistente then
      begin
        RegistraMorte(presa, tmPredacao);
        FTabuleiro.ConsumeCell(nx, ny);
        Result := True;
      end
      else
      begin
        RegistraMorte(presa, tmPredacao);
        FTabuleiro.ConsumeCell(nx, ny);
        MorreuEnvenenado := True;
        Result := True;
      end;
    end
    else
    begin
      if presa <> nil then
        RegistraMorte(presa, tmPredacao);
      FTabuleiro.ConsumeCell(nx, ny);
      Result := True;
    end;
  end;
end;

function TSimulacao.ObterChanceMutacao(ATipo: TTipoSer): Double;
begin
  case ATipo of
    tsBacteria: Result := FConfig.ChanceMutacaoBacteria;
    tsPlanta: Result := FConfig.ChanceMutacaoPlanta;
    tsVegetariano: Result := FConfig.ChanceMutacaoHerbivoro;
    tsCarnivoro: Result := FConfig.ChanceMutacaoCarnivoro;
    else Result := 0.0;
  end;
end;

procedure TSimulacao.MutarPropriedadesFilho(ATipo: TTipoSer; 
  var ATamanho: TTamanhoAnimal; var AToxicidade: TToxicidade; 
  var AResistenciaVeneno: TResistenciaVeneno; var AResistenciaToxina: TResistenciaToxina);
begin
  case ATipo of
    tsBacteria:
    begin
      // Mutação para Tóxica
      AToxicidade := txToxica;
    end;
    tsPlanta:
    begin
      // 50% chance Planta Venenosa, 50% chance Planta Resistente a Toxina de Bactéria
      if Random < 0.5 then
        AToxicidade := txToxica
      else
        AResistenciaToxina := rtResistente;
    end;
    tsVegetariano:
    begin
      // 50% chance mutação de tamanho, 50% chance resistência a veneno
      if Random < 0.5 then
        ATamanho := TTamanhoAnimal(Random(3))
      else
        AResistenciaVeneno := rvResistente;
    end;
    tsCarnivoro:
    begin
      // Mutação de tamanho
      ATamanho := TTamanhoAnimal(Random(3));
    end;
  end;
end;

procedure TSimulacao.MutarInstintos;
var
  tipo: TTipoSer;
  x, y: Integer;
  ent: TSer;
begin
  for tipo := tsBacteria to tsCarnivoro do
  begin
    FClassCome[tipo] := TTipoSer(Random(4) + 1);
    FClassMata[tipo] := TTipoSer(Random(4) + 1);
  end;
  
  for x := 0 to FTabuleiro.W - 1 do
    for y := 0 to FTabuleiro.H - 1 do
    begin
      ent := FTabuleiro.GetEntAt(x, y);
      if ent <> nil then
      begin
        ent.Come := FClassCome[ent.Tipo];
        ent.Mata := FClassMata[ent.Tipo];
      end;
    end;
end;

procedure TSimulacao.ProcessarEcolgicoInstintos;
var
  x, y, nx, ny: Integer;
  ent: TSer;
  comeCounts, mataCounts: array[TTipoSer] of Integer;
  neighType: TTipoSer;
  foodList, killList: array[0..8] of TPoint;
  foodCount, killCount: Integer;
  dx, dy: Integer;
  presa: TSer;
  idx: Integer;
begin
  for x := 0 to FTabuleiro.W - 1 do
    for y := 0 to FTabuleiro.H - 1 do
    begin
      ent := FTabuleiro.GetEntAt(x, y);
      if (ent = nil) or (ent.Tipo = tsNone) then Continue;
      
      FillChar(comeCounts, SizeOf(comeCounts), 0);
      FillChar(mataCounts, SizeOf(mataCounts), 0);
      
      for dx := -1 to 1 do
        for dy := -1 to 1 do
        begin
          if (dx = 0) and (dy = 0) then Continue;
          nx := x + dx; ny := y + dy;
          if FTabuleiro.InBounds(nx, ny) then
          begin
            neighType := FTabuleiro.GetTipoAt(nx, ny);
            if neighType <> tsNone then
            begin
              Inc(comeCounts[neighType]);
              Inc(mataCounts[neighType]);
            end;
          end;
        end;
        
      if (ent.Come <> tsNone) and (comeCounts[ent.Come] >= 3) then
      begin
        foodCount := 0;
        for dx := -1 to 1 do
          for dy := -1 to 1 do
          begin
            if (dx = 0) and (dy = 0) then Continue;
            nx := x + dx; ny := y + dy;
            if FTabuleiro.InBounds(nx, ny) and (FTabuleiro.GetTipoAt(nx, ny) = ent.Come) then
            begin
              foodList[foodCount].X := nx;
              foodList[foodCount].Y := ny;
              Inc(foodCount);
            end;
          end;
        if foodCount > 0 then
        begin
          idx := Random(foodCount);
          presa := FTabuleiro.GetEntAt(foodList[idx].X, foodList[idx].Y);
          if presa <> nil then
            RegistraMorte(presa, tmPredacao);
          FTabuleiro.ConsumeCell(foodList[idx].X, foodList[idx].Y);
        end;
      end;
      
      if (ent.Mata <> tsNone) and (mataCounts[ent.Mata] >= 3) then
      begin
        killCount := 0;
        for dx := -1 to 1 do
          for dy := -1 to 1 do
          begin
            if (dx = 0) and (dy = 0) then Continue;
            nx := x + dx; ny := y + dy;
            if FTabuleiro.InBounds(nx, ny) and (FTabuleiro.GetTipoAt(nx, ny) = ent.Mata) then
            begin
              killList[killCount].X := nx;
              killList[killCount].Y := ny;
              Inc(killCount);
            end;
          end;
        if killCount > 0 then
        begin
          presa := FTabuleiro.GetEntAt(killList[0].X, killList[0].Y);
          if presa <> nil then RegistraMorte(presa, tmConflito);
          FTabuleiro.ConsumeCell(killList[0].X, killList[0].Y);
          if killCount > 1 then
          begin
            presa := FTabuleiro.GetEntAt(killList[1].X, killList[1].Y);
            if presa <> nil then RegistraMorte(presa, tmConflito);
            FTabuleiro.ConsumeCell(killList[1].X, killList[1].Y);
          end;
        end;
      end;
    end;
end;

function TSimulacao.ConsumeFood(x, y: Integer; ent: TSer): Boolean;
var
  foodList: array[0..7] of TPoint;
  n, nx, ny: Integer;
  dx, dy: Integer;
  presa: TSer;
  idx: Integer;
begin
  Result := False;
  n := 0;
  case ent.Tipo of
    tsVegetariano:
    begin
      for dx := -1 to 1 do
        for dy := -1 to 1 do
        begin
          if (dx = 0) and (dy = 0) then Continue;
          nx := x + dx; ny := y + dy;
          presa := FTabuleiro.GetEntAt(nx, ny);
          if (presa <> nil) and (presa.Tipo in [tsPlanta, tsBacteria]) then
          begin
            foodList[n].X := nx;
            foodList[n].Y := ny;
            Inc(n);
          end;
        end;
    end;
    tsCarnivoro:
    begin
      for dx := -1 to 1 do
        for dy := -1 to 1 do
        begin
          if (dx = 0) and (dy = 0) then Continue;
          nx := x + dx; ny := y + dy;
          presa := FTabuleiro.GetEntAt(nx, ny);
          if (presa <> nil) and PodeComer(ent, presa) then
          begin
            foodList[n].X := nx;
            foodList[n].Y := ny;
            Inc(n);
          end;
        end;
    end;
  end;
  
  if n > 0 then
  begin
    idx := Random(n);
    nx := foodList[idx].X;
    ny := foodList[idx].Y;
    presa := FTabuleiro.GetEntAt(nx, ny);
    
    // Regra da planta venenosa (Seção 22.5)
    if (ent.Tipo = tsVegetariano) and (presa <> nil) and (presa.Tipo = tsPlanta) and (presa.Toxicidade = txToxica) then
    begin
      if ent.ResistenciaVeneno = rvResistente then
      begin
        // Come e sobrevive normalmente
        RegistraMorte(presa, tmPredacao);
        FTabuleiro.ConsumeCell(nx, ny);
        Result := True;
        Exit;
      end
      else
      begin
        // Se for não resistente, ele morre ao tentar comer a planta venenosa
        // A planta também é consumida/destruída e o herbívoro morre instantaneamente
        RegistraMorte(presa, tmPredacao);
        FTabuleiro.ConsumeCell(nx, ny); // Planta morre
        RegistraMorte(ent, tmVeneno);
        FTabuleiro.FreeCell(x, y); // Vegetariano morre
        Inc(FMortesPorVeneno);
        Result := True;
        Exit;
      end;
    end;
    
    if presa <> nil then
      RegistraMorte(presa, tmPredacao);
    FTabuleiro.ConsumeCell(nx, ny);
    Result := True;
  end;
end;

procedure TSimulacao.ProcessaReproducao(x, y: Integer; ASer: TSer);
var
  reproCfg: TReproducaoConfig;
  lista: TListaCoordenadas;
  qtdFilhos, i: Integer;
  childLifeMax, childReproMax: Integer;
  hasPlanta: Boolean;
  dx, dy, nx, ny: Integer;
  
  childTamanho: TTamanhoAnimal;
  childToxicidade: TToxicidade;
  childResistenciaVeneno: TResistenciaVeneno;
  childResistenciaToxina: TResistenciaToxina;
  
  chanceMutacao: Double;
  mutated: Boolean;
begin
  reproCfg := ObterReproConfig(ASer.Tipo);
  
  if (ASer.Tipo in [tsVegetariano, tsCarnivoro]) and (ASer.CiclosSemComida > 0) then Exit;
  
  if Random <= reproCfg.ChanceReproducao then
  begin
    lista := FTabuleiro.ListaVizinhosLivres(x, y);
    if lista.Count > 0 then
    begin
      EmbaralhaCoordenadas(lista);
      qtdFilhos := Min(reproCfg.MaxDescendentesPorCiclo, lista.Count);
      
      case ASer.Tipo of
        tsBacteria:    begin childLifeMax := LIFE_BACTERIA; childReproMax := REPRO_BACTERIA; end;
        tsPlanta:      begin childLifeMax := LIFE_PLANTA; childReproMax := REPRO_PLANTA; end;
        tsVegetariano: begin childLifeMax := LIFE_VEGETARIANO; childReproMax := REPRO_VEGETARIANO; end;
        tsCarnivoro:   begin childLifeMax := LIFE_CARNIVORO; childReproMax := REPRO_CARNIVORO; end;
        else           begin childLifeMax := 1; childReproMax := 1; end;
      end;
      
      for i := 0 to qtdFilhos - 1 do
      begin
        // Por padrão o filho herda as características do pai (Seção 22.11)
        childTamanho := ASer.Tamanho;
        childToxicidade := ASer.Toxicidade;
        childResistenciaVeneno := ASer.ResistenciaVeneno;
        childResistenciaToxina := ASer.ResistenciaToxina;
        
        // Mutação no nascimento a cada 100 gerações (Opção B)
        if (FCicloAtual mod FConfig.IntervaloMutacao = 0) then
        begin
          chanceMutacao := ObterChanceMutacao(ASer.Tipo);
          if Random < chanceMutacao then
          begin
            MutarPropriedadesFilho(ASer.Tipo, childTamanho, childToxicidade, childResistenciaVeneno, childResistenciaToxina);
            Inc(FMutacoesOcorridas);
          end;
        end;
        
        FTabuleiro.SpawnCellToNext(
          ASer.Tipo,
          lista.Coords[i].X,
          lista.Coords[i].Y,
          childLifeMax,
          childReproMax,
          FClassCome[ASer.Tipo],
          FClassMata[ASer.Tipo],
          childTamanho,
          childToxicidade,
          childResistenciaVeneno,
          childResistenciaToxina
        );
      end;
    end;
    
    ASer.CicloReproAtual := 0;
  end;
end;

procedure TSimulacao.ExecutarAcoesCelula(x, y: Integer);
var
  ent, neigh: TSer;
  dx, dy, nx, ny, viz, carnNearby, bactCount, toxicBactCount: Integer;
  Raio, AlvoX, AlvoY, Dist: Integer;
  eaten, hasMoved, MorreuEnvenenado: Boolean;
  NovoX, NovoY: Integer;
  reproCfg: TReproducaoConfig;
  lista: TListaCoordenadas;
  idx: Integer;
begin
  ent := FTabuleiro.GetEntAt(x, y);
  if ent = nil then Exit;
  
  // 1. Incrementar idade
  ent.CicloVidaAtual := ent.CicloVidaAtual + 1;
  ent.CicloReproAtual := ent.CicloReproAtual + 1;
  
  // Regra das bactérias tóxicas prejudicando plantas próximas (Seção 22.9)
  if ent.Tipo = tsPlanta then
  begin
    toxicBactCount := 0;
    for dx := -1 to 1 do
      for dy := -1 to 1 do
      begin
        if (dx = 0) and (dy = 0) then Continue;
        nx := x + dx; ny := y + dy;
        neigh := FTabuleiro.GetEntAt(nx, ny);
        if (neigh <> nil) and (neigh.Tipo = tsBacteria) and (neigh.Toxicidade = txToxica) then
          Inc(toxicBactCount);
      end;
      
    if (toxicBactCount > 0) and (ent.ResistenciaToxina = rtNenhuma) then
    begin
      ent.CicloVidaAtual := ent.CicloVidaAtual + 2 * toxicBactCount;
    end;
  end;
  
  // 2. Verificar morte por idade
  if ent.CicloVidaAtual >= ent.CicloVidaMax then
  begin
    if ent.Tipo = tsPlanta then
      RegistraMorte(ent, tmToxina)
    else
      RegistraMorte(ent, tmIdade);
      
    FTabuleiro.FreeCell(x, y);
    Exit;
  end;
  
  // Para bactérias, verificar vizinhos e morte por superpopulação local
  viz := 0;
  bactCount := 0;
  carnNearby := 0;
  for dx := -1 to 1 do
    for dy := -1 to 1 do
    begin
      if (dx = 0) and (dy = 0) then Continue;
      nx := x + dx; ny := y + dy;
      if FTabuleiro.InBounds(nx, ny) then
      begin
        if FTabuleiro.GetTipoAt(nx, ny) <> tsNone then Inc(viz);
        if ent.Tipo = tsVegetariano then
        begin
          if FTabuleiro.GetTipoAt(nx, ny) = tsCarnivoro then Inc(carnNearby);
        end
        else if ent.Tipo = tsCarnivoro then
        begin
          if FTabuleiro.GetTipoAt(nx, ny) = tsBacteria then Inc(bactCount);
        end;
      end;
    end;
    
  if (ent.Tipo = tsBacteria) and (viz > 3) then
  begin
    RegistraMorte(ent, tmConflito);
    FTabuleiro.FreeCell(x, y);
    Exit;
  end;
  
  // Carnívoros aceleram envelhecimento perto de bactérias
  if (ent.Tipo = tsCarnivoro) and (bactCount > 0) then
  begin
    ent.CicloVidaAtual := ent.CicloVidaAtual + (3 * bactCount);
    if ent.CicloVidaAtual >= ent.CicloVidaMax then
    begin
      RegistraMorte(ent, tmIdade);
      FTabuleiro.FreeCell(x, y);
      Exit;
    end;
  end;
  
  eaten := False;
  hasMoved := False;
  NovoX := x;
  NovoY := y;
  
  if ent.Tipo in [tsVegetariano, tsCarnivoro] then
  begin
    if ent.Tipo = tsVegetariano then
    begin
      // 1. Fuga do carnívoro
      Raio := FConfig.RaioBuscaHerbivoro;
      if EncontrarSerMaisProximo(NovoX, NovoY, tsCarnivoro, Raio, AlvoX, AlvoY) then
      begin
        if MoveUmaCasaParaLonge(NovoX, NovoY, AlvoX, AlvoY, nx, ny) then
        begin
          NovoX := nx;
          NovoY := ny;
          hasMoved := True;
        end;
      end;
      
      // Comer se alimento estiver adjacente na nova posição (sobreviver vem antes de comer)
      if TentarComer(NovoX, NovoY, ent, MorreuEnvenenado) then
      begin
        if MorreuEnvenenado then
        begin
          RegistraMorte(ent, tmVeneno);
          FTabuleiro.FreeCell(x, y);
          Inc(FMortesPorVeneno);
          Exit;
        end;
        eaten := True;
      end;
      
      // 2. Buscar planta se estiver com fome
      if (not eaten) and (ent.CiclosSemComida > 0) then
      begin
        if EncontrarSerMaisProximo(NovoX, NovoY, tsPlanta, Raio, AlvoX, AlvoY) then
        begin
          if MoveUmaCasaEmDirecao(NovoX, NovoY, AlvoX, AlvoY, nx, ny) then
          begin
            NovoX := nx;
            NovoY := ny;
            hasMoved := True;
            
            if TentarComer(NovoX, NovoY, ent, MorreuEnvenenado) then
            begin
              if MorreuEnvenenado then
              begin
                RegistraMorte(ent, tmVeneno);
                FTabuleiro.FreeCell(x, y);
                Inc(FMortesPorVeneno);
                Exit;
              end;
              eaten := True;
            end;
          end;
        end;
      end;
      
      // 3. Se não moveu nem na fuga nem na busca, movimento aleatório opcional como fallback
      if (not hasMoved) then
      begin
        lista := FTabuleiro.ListaVizinhosLivres(NovoX, NovoY);
        if lista.Count > 0 then
        begin
          idx := Random(lista.Count);
          NovoX := lista.Coords[idx].X;
          NovoY := lista.Coords[idx].Y;
          hasMoved := True;
          
          if TentarComer(NovoX, NovoY, ent, MorreuEnvenenado) then
          begin
            if MorreuEnvenenado then
            begin
              RegistraMorte(ent, tmVeneno);
              FTabuleiro.FreeCell(x, y);
              Inc(FMortesPorVeneno);
              Exit;
            end;
            eaten := True;
          end;
        end;
      end;
      
      // Grava no tabuleiro final
      if hasMoved then
        FTabuleiro.CopyCellToNext(x, y, NovoX, NovoY);
    end
    else if ent.Tipo = tsCarnivoro then
    begin
      Raio := FConfig.RaioBuscaCarnivoro;
      if EncontrarSerMaisProximo(NovoX, NovoY, tsVegetariano, Raio, AlvoX, AlvoY) then
      begin
        // Determina o máximo de deslocamento (2 para faminto, 1 para alimentado)
        if ent.CiclosSemComida > 0 then
          Dist := 2
        else
          Dist := 1;
          
        // Passo 1
        if DistanciaChebyshev(NovoX, NovoY, AlvoX, AlvoY) > 1 then
        begin
          if MoveUmaCasaEmDirecao(NovoX, NovoY, AlvoX, AlvoY, nx, ny) then
          begin
            NovoX := nx;
            NovoY := ny;
            hasMoved := True;
          end;
        end;
        
        // Passo 2
        if (Dist = 2) and (DistanciaChebyshev(NovoX, NovoY, AlvoX, AlvoY) > 1) then
        begin
          if MoveUmaCasaEmDirecao(NovoX, NovoY, AlvoX, AlvoY, nx, ny) then
          begin
            NovoX := nx;
            NovoY := ny;
            hasMoved := True;
          end;
        end;
        
        // Se ficou adjacente ao final do movimento, tenta comer
        if DistanciaChebyshev(NovoX, NovoY, AlvoX, AlvoY) <= 1 then
        begin
          if TentarComer(NovoX, NovoY, ent, MorreuEnvenenado) then
            eaten := True;
        end;
      end;
      
      // Se não encontrou herbívoro ou não se moveu, faz movimento aleatório opcional
      if (not hasMoved) then
      begin
        lista := FTabuleiro.ListaVizinhosLivres(NovoX, NovoY);
        if lista.Count > 0 then
        begin
          idx := Random(lista.Count);
          NovoX := lista.Coords[idx].X;
          NovoY := lista.Coords[idx].Y;
          hasMoved := True;
          
          if TentarComer(NovoX, NovoY, ent, MorreuEnvenenado) then
            eaten := True;
        end;
      end;
      
      // Grava no tabuleiro final
      if hasMoved then
        FTabuleiro.CopyCellToNext(x, y, NovoX, NovoY);
    end;
  end;
  
  if not hasMoved then
  begin
    FTabuleiro.CopyCellToNext(x, y, x, y);
  end;
  
  // 7. Atualizar fome
  if ent.Tipo in [tsVegetariano, tsCarnivoro] then
  begin
    if eaten then
      ent.CiclosSemComida := 0
    else
      ent.CiclosSemComida := ent.CiclosSemComida + 1;
      
    // 8. Verificar morte por fome
    if ent.CiclosSemComida >= GetLimiteFome(ent.Tipo) then
    begin
      RegistraMorte(ent, tmFome);
      Inc(FMortesPorFome);
      if ent.Tipo = tsVegetariano then
        Inc(FMortesFomeVegetariano)
      else
        Inc(FMortesFomeCarnivoro);
        
      if hasMoved then
        FTabuleiro.FreeCellNext(NovoX, NovoY)
      else
        FTabuleiro.FreeCell(x, y);
        
      Exit;
    end;
  end;
  
  // 9. Processar reprodução
  reproCfg := ObterReproConfig(ent.Tipo);
  if ent.CicloReproAtual >= reproCfg.CiclosParaReproduzir then
  begin
    ProcessaReproducao(NovoX, NovoY, ent);
  end;
end;

procedure TSimulacao.ExecutarCiclo;
var
  x, y: Integer;
  tStart, tEnd: QWord;
  tElapsed: QWord;
  tCurrent: QWord;
begin
  tStart := GetTickCount64;
  
  Inc(FCicloAtual);
  
  // Reseta contadores de fome/veneno da rodada
  FMortesFomeBacteria := 0;
  FMortesFomeVegetariano := 0;
  FMortesFomeCarnivoro := 0;
  FMortesPorFome := 0;
  
  // 1. Ticks periódicos de Introdução de Espécies
  if FCicloAtual = FConfig.CicloEntradaPlantas then
    FTabuleiro.ColocaSerAleatorio(tsPlanta, FConfig.QtdPlantasEntrada, LIFE_PLANTA, REPRO_PLANTA);
    
  if FCicloAtual = FConfig.CicloEntradaVegetarianos then
    FTabuleiro.ColocaSerAleatorio(tsVegetariano, FConfig.QtdVegetarianosEntrada, LIFE_VEGETARIANO, REPRO_VEGETARIANO);
    
  if FCicloAtual = FConfig.CicloEntradaCarnivoros then
    FTabuleiro.ColocaSerAleatorio(tsCarnivoro, FConfig.QtdCarnivorosEntrada, LIFE_CARNIVORO, REPRO_CARNIVORO);
    
  // 2. Evolução de Instintos a cada 500 ciclos
  if (FCicloAtual mod 500) = 0 then
    MutarInstintos;
    
  // 3. Aplica regras ecológicas de instintos (Come/Mata) no BoardAtual
  ProcessarEcolgicoInstintos;
  
  // 4. Prepara tabuleiro temporário para gravação
  FTabuleiro.PrepareNextBoard;
  
  // 5. Varre tabuleiro ativo e calcula ações
  for x := 0 to FTabuleiro.W - 1 do
    for y := 0 to FTabuleiro.H - 1 do
    begin
      if FTabuleiro.GetEntAt(x, y) <> nil then
      begin
        ExecutarAcoesCelula(x, y);
      end;
    end;
    
  // 6. Confirma o próximo tabuleiro (swap de buffers)
  FTabuleiro.CommitNextBoard;
  
  tEnd := GetTickCount64;
  FLastCycleMs := tEnd - tStart;
  
  // Atualiza FPS
  Inc(FCyclesSinceLastFPS);
  tCurrent := GetTickCount64;
  tElapsed := tCurrent - FLastFPSTime;
  if tElapsed >= 1000 then
  begin
    FFPS := (FCyclesSinceLastFPS * 1000.0) / tElapsed;
    FCyclesSinceLastFPS := 0;
    FLastFPSTime := tCurrent;
  end;
  
  // Salva estatísticas no histórico (Seção 24.9)
  if (FCicloAtual mod FConfig.IntervaloRegistroHistorico = 0) then
    FHistorico.Adicionar(CalculaEstatisticas, FConfig.MaxPontosHistorico);
end;

function TSimulacao.CalculaEstatisticas: TEstatisticasSimulacao;
var
  x, y: Integer;
  tipo: TTipoSer;
  total: Integer;
  ent: TSer;
  i: Integer;
  subNome: string;
  hasExisted, isAlive: Boolean;
begin
  Result.Ciclo := FCicloAtual;
  Result.Bacterias := 0;
  Result.Plantas := 0;
  Result.Vegetarianos := 0;
  Result.Carnivoros := 0;
  Result.Vazios := 0;
  Result.TempoCicloMs := FLastCycleMs;
  Result.FPS := FFPS;
  
  Result.MortesPorFome := FMortesPorFome;
  Result.MortesFomeBacteria := FMortesFomeBacteria;
  Result.MortesFomeVegetariano := FMortesFomeVegetariano;
  Result.MortesFomeCarnivoro := FMortesFomeCarnivoro;
  
  // Novas estatísticas mutacionais
  Result.MutacoesOcorridas := FMutacoesOcorridas;
  Result.MortesPorVeneno := FMortesPorVeneno;
  Result.MortesPorToxina := FMortesPorToxina;
  
  Result.PlantasVenenosas := 0;
  Result.PlantasResistentesToxina := 0;
  Result.HerbivorosResistentesVeneno := 0;
  Result.HerbivorosPequenos := 0;
  Result.HerbivorosMedios := 0;
  Result.HerbivorosGrandes := 0;
  Result.CarnivorosPequenos := 0;
  Result.CarnivorosMedios := 0;
  Result.CarnivorosGrandes := 0;
  Result.BacteriasToxicas := 0;
  Result.BacteriasNaoToxicas := 0;
  
  // Reset vivos counter for subspecies (Seção 23.14)
  for i := 0 to 14 do
  begin
    FSubEspecies[i].Vivos := 0;
  end;
  
  for x := 0 to FTabuleiro.W - 1 do
    for y := 0 to FTabuleiro.H - 1 do
    begin
      tipo := FTabuleiro.GetTipoAt(x, y);
      case tipo of
        tsBacteria: Inc(Result.Bacterias);
        tsPlanta: Inc(Result.Plantas);
        tsVegetariano: Inc(Result.Vegetarianos);
        tsCarnivoro: Inc(Result.Carnivoros);
        else Inc(Result.Vazios);
      end;
      
      ent := FTabuleiro.GetEntAt(x, y);
      if ent <> nil then
      begin
        // 1. Contadores específicos de características para retrocompatibilidade
        case ent.Tipo of
          tsBacteria:
          begin
            if ent.Toxicidade = txToxica then
              Inc(Result.BacteriasToxicas)
            else
              Inc(Result.BacteriasNaoToxicas);
          end;
          tsPlanta:
          begin
            if ent.Toxicidade = txToxica then
              Inc(Result.PlantasVenenosas);
            if ent.ResistenciaToxina = rtResistente then
              Inc(Result.PlantasResistentesToxina);
          end;
          tsVegetariano:
          begin
            if ent.ResistenciaVeneno = rvResistente then
              Inc(Result.HerbivorosResistentesVeneno);
            case ent.Tamanho of
              taPequeno: Inc(Result.HerbivorosPequenos);
              taMedio: Inc(Result.HerbivorosMedios);
              taGrande: Inc(Result.HerbivorosGrandes);
            end;
          end;
          tsCarnivoro:
          begin
            case ent.Tamanho of
              taPequeno: Inc(Result.CarnivorosPequenos);
              taMedio: Inc(Result.CarnivorosMedios);
              taGrande: Inc(Result.CarnivorosGrandes);
            end;
          end;
        end;
        
        // 2. Incrementar contadores de subespécies ativas
        subNome := NomeSubEspecie(ent);
        for i := 0 to 14 do
        begin
          if FSubEspecies[i].Nome = subNome then
          begin
            Inc(FSubEspecies[i].Vivos);
            FSubEspecies[i].JaExistiu := True;
            Break;
          end;
        end;
      end;
    end;
    
  // 3. Recalcular extinções e ciclos de extinção para subespécies (Seção 24.11 e 23.8)
  for i := 0 to 14 do
  begin
    if FSubEspecies[i].JaExistiu and (FSubEspecies[i].Vivos = 0) then
    begin
      if not FSubEspecies[i].Extinta then
      begin
        FSubEspecies[i].Extinta := True;
        FSubEspecies[i].CicloExtincao := FCicloAtual;
      end;
    end
    else if FSubEspecies[i].Vivos > 0 then
    begin
      FSubEspecies[i].Extinta := False;
      FSubEspecies[i].CicloExtincao := 0;
    end;
  end;
  
  // 4. Calcular estatísticas de espécies e subespécies vivas/extintas
  Result.SubEspeciesVivas := 0;
  Result.SubEspeciesExtintas := 0;
  for i := 0 to 14 do
  begin
    if FSubEspecies[i].Vivos > 0 then
      Inc(Result.SubEspeciesVivas);
    if FSubEspecies[i].Extinta then
      Inc(Result.SubEspeciesExtintas);
  end;
  
  Result.EspeciesVivas := 0;
  Result.EspeciesExtintas := 0;
  for tipo in [tsBacteria, tsPlanta, tsVegetariano, tsCarnivoro] do
  begin
    hasExisted := False;
    isAlive := False;
    for i := 0 to 14 do
    begin
      if FSubEspecies[i].TipoPrincipal = tipo then
      begin
        if FSubEspecies[i].JaExistiu then hasExisted := True;
        if FSubEspecies[i].Vivos > 0 then isAlive := True;
      end;
    end;
    if isAlive then Inc(Result.EspeciesVivas);
    if hasExisted and (not isAlive) then Inc(Result.EspeciesExtintas);
  end;
  
  Result.MortesAcumuladas := FMortesAcumuladasBacteria + FMortesAcumuladasPlanta + 
                            FMortesAcumuladasVegetariano + FMortesAcumuladasCarnivoro;
  
  // Mortes detalhadas
  Result.MortesIdade := FMortesIdade;
  Result.MortesFomeCausa := FMortesFomeCausa;
  Result.MortesPredacao := FMortesPredacao;
  Result.MortesVenenoCausa := FMortesVenenoCausa;
  Result.MortesToxinaCausa := FMortesToxinaCausa;
  Result.MortesAleatoria := FMortesAleatoria;
  Result.MortesConflito := FMortesConflito;
  
  // Copiar o estado completo das subespécies para este ciclo
  Result.SubEspecies := FSubEspecies;
  
  total := Result.Bacterias + Result.Plantas + Result.Vegetarianos + Result.Carnivoros;
  FOcupacaoGeral := total / (FTabuleiro.W * FTabuleiro.H);
end;

end.
