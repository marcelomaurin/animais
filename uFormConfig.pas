unit uFormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls, uTiposAnimais;

type
  TfrmConfig = class(TForm)
    lblLargura: TLabel;
    edtLargura: TSpinEdit;
    lblAltura: TLabel;
    edtAltura: TSpinEdit;
    lblVelocidade: TLabel;
    edtVelocidade: TSpinEdit;
    lblPctBacterias: TLabel;
    edtPctBacterias: TFloatSpinEdit;
    lblCicloPlanta: TLabel;
    edtCicloPlanta: TSpinEdit;
    lblQtdPlanta: TLabel;
    edtQtdPlanta: TSpinEdit;
    lblCicloVegetariano: TLabel;
    edtCicloVegetariano: TSpinEdit;
    lblQtdVegetariano: TLabel;
    edtQtdVegetariano: TSpinEdit;
    lblCicloCarnivoro: TLabel;
    edtCicloCarnivoro: TSpinEdit;
    lblQtdCarnivoro: TLabel;
    edtQtdCarnivoro: TSpinEdit;
    lblLimiteFomeBacteria: TLabel;
    edtLimiteFomeBacteria: TSpinEdit;
    lblLimiteFomeVegetariano: TLabel;
    edtLimiteFomeVegetariano: TSpinEdit;
    lblLimiteFomeCarnivoro: TLabel;
    edtLimiteFomeCarnivoro: TSpinEdit;
    lblSeed: TLabel;
    edtSeed: TSpinEdit;
    btnOk: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
  private
    procedure CarregarConfig(const AConfig: TSimulacaoConfig);
    procedure SalvarConfig(var AConfig: TSimulacaoConfig);
  public
  end;

function ObterConfigSimulacao(var AConfig: TSimulacaoConfig): Boolean;

implementation

{$R *.lfm}

function ObterConfigSimulacao(var AConfig: TSimulacaoConfig): Boolean;
var
  frm: TfrmConfig;
begin
  Result := False;
  frm := TfrmConfig.Create(Application);
  try
    frm.CarregarConfig(AConfig);
    if frm.ShowModal = mrOk then
    begin
      frm.SalvarConfig(AConfig);
      Result := True;
    end;
  finally
    frm.Free;
  end;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  // Set window properties programmatically to be extra safe
  Caption := 'Configurações da Simulação';
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;
end;

procedure TfrmConfig.CarregarConfig(const AConfig: TSimulacaoConfig);
begin
  edtLargura.Value := AConfig.Largura;
  edtAltura.Value := AConfig.Altura;
  edtVelocidade.Value := AConfig.IntervaloTimer;
  edtPctBacterias.Value := AConfig.PercentualBacteriasInicial;
  edtCicloPlanta.Value := AConfig.CicloEntradaPlantas;
  edtQtdPlanta.Value := AConfig.QtdPlantasEntrada;
  edtCicloVegetariano.Value := AConfig.CicloEntradaVegetarianos;
  edtQtdVegetariano.Value := AConfig.QtdVegetarianosEntrada;
  edtCicloCarnivoro.Value := AConfig.CicloEntradaCarnivoros;
  edtQtdCarnivoro.Value := AConfig.QtdCarnivorosEntrada;
  edtLimiteFomeBacteria.Value := AConfig.LimiteFomeBacteria;
  edtLimiteFomeVegetariano.Value := AConfig.LimiteFomeVegetariano;
  edtLimiteFomeCarnivoro.Value := AConfig.LimiteFomeCarnivoro;
  edtSeed.Value := AConfig.SeedAleatoria;
end;

procedure TfrmConfig.SalvarConfig(var AConfig: TSimulacaoConfig);
begin
  AConfig.Largura := edtLargura.Value;
  AConfig.Altura := edtAltura.Value;
  AConfig.IntervaloTimer := edtVelocidade.Value;
  AConfig.PercentualBacteriasInicial := edtPctBacterias.Value;
  AConfig.CicloEntradaPlantas := edtCicloPlanta.Value;
  AConfig.QtdPlantasEntrada := edtQtdPlanta.Value;
  AConfig.CicloEntradaVegetarianos := edtCicloVegetariano.Value;
  AConfig.QtdVegetarianosEntrada := edtQtdVegetariano.Value;
  AConfig.CicloEntradaCarnivoros := edtCicloCarnivoro.Value;
  AConfig.QtdCarnivorosEntrada := edtQtdCarnivoro.Value;
  AConfig.LimiteFomeBacteria := edtLimiteFomeBacteria.Value;
  AConfig.LimiteFomeVegetariano := edtLimiteFomeVegetariano.Value;
  AConfig.LimiteFomeCarnivoro := edtLimiteFomeCarnivoro.Value;
  AConfig.SeedAleatoria := edtSeed.Value;
end;

end.
