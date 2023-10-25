unit UnitProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FMX.Edit,
  UnitProdutoCad, DataModule.Produto;

type
  TFrmProduto = class(TForm)
    rectToolbar: TRectangle;
    Label1: TLabel;
    imgAdd: TImage;
    lvProdutos: TListView;
    imgSemFoto: TImage;
    Rectangle5: TRectangle;
    edtBusca: TEdit;
    btnBusca: TSpeedButton;
    Rectangle1: TRectangle;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure FormShow(Sender: TObject);
    procedure lvProdutosPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure btnBuscaClick(Sender: TObject);
    procedure imgAddClick(Sender: TObject);
    procedure lvProdutosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    procedure AddProduto(cod_produto, descricao: string;
                                 valor: double;
                                 foto : TStream);
    procedure ListarProdutos(pagina: integer; busca: string;
      ind_clear: boolean);
    procedure ThreadProdutoTerminate(Sender: TObject);
    procedure AtualizarLista;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmProduto: TFrmProduto;

implementation

{$R *.fmx}

procedure TFrmProduto.AddProduto(cod_produto, descricao: string;
                                 valor: double;
                                 foto : TStream);
var
    item: TListViewItem;
    txt: TListItemText;
    img: TListItemImage;
    bmp : TBitmap;
begin
    try
        item := lvProdutos.Items.Add;

        with item do
        begin
            Height := 55;
            Tag := cod_produto.ToInteger;

            // Descricao...
            txt := TListItemText(Objects.FindDrawable('txtDescricao'));
            txt.Text := descricao;

            // Valor Produto...
            txt := TListItemText(Objects.FindDrawable('txtValor'));
            txt.Text := FormatFloat('R$#,##0.00', valor);
            txt.TagFloat := valor;

            // Foto...
            img := TListItemImage(Objects.FindDrawable('imgFoto'));
            if foto <> nil then
            begin
                bmp := TBitmap.Create;
                bmp.LoadFromStream(foto);
                img.OwnsBitmap := true;
                img.Bitmap := bmp;
            end
            else
                img.Bitmap := imgSemFoto.Bitmap;

        end;
    except on ex:exception do
        showmessage('Erro ao inserir pedido na lista: ' + ex.Message);
    end;
end;


procedure TFrmProduto.btnBuscaClick(Sender: TObject);
begin
    ListarProdutos(1, edtBusca.Text, true);
end;

procedure TFrmProduto.FormShow(Sender: TObject);
begin
    ListarProdutos(1, edtBusca.Text, true);
end;

procedure TFrmProduto.AtualizarLista;
begin
    ListarProdutos(1, edtBusca.Text, true);
end;

procedure TFrmProduto.imgAddClick(Sender: TObject);
begin
    if NOT Assigned(FrmProdutoCad) then
        Application.CreateForm(TFrmProdutoCad, FrmProdutoCad);

    FrmProdutoCad.ModoCadastro := 'I';
    FrmProdutoCad.Cod_Produto := 0;
    FrmProdutoCad.ExecuteOnClose := AtualizarLista;
    FrmProdutoCad.Show;
end;

procedure TFrmProduto.ThreadProdutoTerminate(Sender: TObject);
begin
    lvProdutos.EndUpdate;

    // Marcar quer o processo terminou...
    lvProdutos.TagString := '';

    // Deu erro na Thread?
    if Sender is TThread then
    begin
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;
    end;
end;

procedure TFrmProduto.ListarProdutos(pagina: integer; busca: string; ind_clear: boolean);
var
    t: TThread;
begin
    // Evitar processamento concorrente...
    if lvProdutos.TagString = 'S' then
        exit;

    // Em processamento...
    lvProdutos.TagString := 'S';

    lvProdutos.BeginUpdate;

    // Limpar a lista...
    if ind_clear then
    begin
        pagina := 1;
        lvProdutos.ScrollTo(0);
        lvProdutos.Items.Clear;
    end;

    {
    Tag: contem a pagina atual solicitada ao servidor...
    >= 1 : faz o request para buscar mais dados
    -1 : indica que não tem mais dados
    }
    // Salva a pagina atual a ser exibida...
    lvProdutos.Tag := pagina;

    // Requisicao por mais dados...
    t := TThread.CreateAnonymousThread(procedure
    var
        foto : TStream;
    begin
        DmProduto.ListarProdutos(pagina, busca);

        while NOT DmProduto.qryProduto.Eof do
        begin
            if DmProduto.qryProduto.FieldByName('FOTO').AsString <> '' then
                foto := DmProduto.qryProduto.CreateBlobStream(DmProduto.qryProduto.FieldByName('FOTO'),
                                                       TBlobStreamMode.bmRead)
            else
                foto := nil;

            TThread.Synchronize(nil, procedure
            begin
                AddProduto(DmProduto.qryProduto.FieldByName('COD_PRODUTO').AsString,
                           DmProduto.qryProduto.FieldByName('DESCRICAO').AsString,
                           DmProduto.qryProduto.FieldByName('VALOR').AsFloat,
                           foto);

                if Assigned(foto) then
                    foto.DisposeOf;
            end);

            DmProduto.qryProduto.Next;
        end;

    end);

    t.OnTerminate := ThreadProdutoTerminate;
    t.Start;
end;

procedure TFrmProduto.lvProdutosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    if NOT Assigned(FrmProdutoCad) then
        Application.CreateForm(TFrmProdutoCad, FrmProdutoCad);

    FrmProdutoCad.ModoCadastro := 'A';
    FrmProdutoCad.Cod_Produto := AItem.Tag;
    FrmProdutoCad.Foto := TListItemImage(AItem.Objects.FindDrawable('imgFoto')).Bitmap;
    FrmProdutoCad.Descricao := TListItemText(AItem.Objects.FindDrawable('txtDescricao')).Text;
    FrmProdutoCad.Valor := TListItemText(AItem.Objects.FindDrawable('txtValor')).TagFloat;
    FrmProdutoCad.ExecuteOnClose := AtualizarLista;
    FrmProdutoCad.Show;
end;

procedure TFrmProduto.lvProdutosPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
    // Verifica se a rolagem atingiu o limite para uma nova carga...
    if (lvProdutos.Items.Count >= 15) and (lvProdutos.Tag >= 0) then
        if lvProdutos.GetItemRect(lvProdutos.Items.Count - 5).Bottom <= lvProdutos.Height then
            ListarProdutos(lvProdutos.Tag + 1, edtBusca.Text, false);
end;

end.
