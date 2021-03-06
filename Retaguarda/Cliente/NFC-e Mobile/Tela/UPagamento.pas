unit UPagamento;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.ListView, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope,
  Generics.Collections, Controller, Biblioteca, Constantes;

type
  TFPagamento = class(TForm)
    ToolBar1: TToolBar;
    lblTitle1: TLabel;
    ListView1: TListView;
    FDMemTablePagamento: TFDMemTable;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    procedure btnNextClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPagamento: TFPagamento;

implementation

{$R *.fmx}

uses UMenu, NfceTipoPagamentoVO, NfeFormaPagamentoVO;

/// EXERCICIO
///  Analise a possibilidade de alterar essa janela para que seja poss�vel o
///  usu�rio selecionar mais de um pagamento.
///  Analise o c�digo da janela de pagamentos da NFC-e Desktop

procedure TFPagamento.btnNextClick(Sender: TObject);
begin
  Close;
end;

procedure TFPagamento.FormShow(Sender: TObject);
var
  PagamentoVO : TNfceTipoPagamentoVO;
  ListaPagamento: TObjectList<TNfceTipoPagamentoVO>;
  i: Integer;
begin
  try
    try
      ListaPagamento := TObjectList<TNfceTipoPagamentoVO>(TController.BuscarLista('NfceTipoPagamentoController.TNfceTipoPagamentoController', 'ConsultaLista', ['ID>0'], 'GET'));
      PagamentoVO := TNfceTipoPagamentoVO.Create;

      FDMemTablePagamento.EmptyDataSet;

      for I := 0 to ListaPagamento.Count - 1 do
      begin
        PagamentoVO := ListaPagamento[I];

        FDMemTablePagamento.Append;
        FDMemTablePagamento.FieldByName('ID').AsInteger := PagamentoVO.Id;
        FDMemTablePagamento.FieldByName('CODIGO').AsString := PagamentoVO.Codigo;
        FDMemTablePagamento.FieldByName('DESCRICAO').AsString := PagamentoVO.Descricao;
        FDMemTablePagamento.FieldByName('PERMITE_TROCO').AsString := PagamentoVO.PermiteTroco;
        FDMemTablePagamento.FieldByName('GERA_PARCELAS').AsString := PagamentoVO.GeraParcelas;
        FDMemTablePagamento.Post;
      end;

    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  finally
  end;
end;

procedure TFPagamento.ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  TotalTipoPagamento: TNfeFormaPagamentoVO;
begin
  TotalTipoPagamento := TNfeFormaPagamentoVO.Create;

  TotalTipoPagamento.IdNfeCabecalho := FMenu.Sessao.VendaAtual.Id;
  TotalTipoPagamento.IdNfceTipoPagamento := 1;
  TotalTipoPagamento.Valor := TruncaValor(UMenu.TotalGeral, Constantes.TConstantes.DECIMAIS_VALOR);
  TotalTipoPagamento.Forma := '01';
  TotalTipoPagamento.Estorno := 'N';

  // grava os pagamentos no banco de dados
  TController.ExecutarMetodo('NfeFormaPagamentoController.TNfeFormaPagamentoController', 'Insere', [TotalTipoPagamento], 'PUT', 'Boolean');

  // conclui o encerramento da venda - grava dados de cabecalho no banco
  FMenu.Sessao.VendaAtual.ValorTotal := TotalTipoPagamento.Valor;
  FMenu.Sessao.VendaAtual.Troco := 0;

  /// EXERCICIO
  ///  Existe algum problema em chamar esse procediment daqui?
  FMenu.ConcluiEncerramentoVenda;

  Close;
end;

end.
