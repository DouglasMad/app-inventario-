unit UnitProdutoCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Layouts,
  DataModule.Produto, u99Permissions, System.Actions, FMX.ActnList,
  FMX.StdActns, FMX.MediaLibrary.Actions;

type
  TExecuteOnClose = procedure of Object;

  TFrmProdutoCad = class(TForm)
    rectToolbar: TRectangle;
    lblTitulo: TLabel;
    imgFoto: TImage;
    Layout1: TLayout;
    edtDescricao: TEdit;
    edtValor: TEdit;
    Rectangle1: TRectangle;
    btnSalvar: TSpeedButton;
    OpenDialog: TOpenDialog;
    ActionList1: TActionList;
    ActCamera: TTakePhotoFromCameraAction;
    ActLibrary: TTakePhotoFromLibraryAction;
    imgExcluir: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalvarClick(Sender: TObject);
    procedure imgFotoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActCameraDidFinishTaking(Image: TBitmap);
    procedure ActLibraryDidFinishTaking(Image: TBitmap);
    procedure imgExcluirClick(Sender: TObject);
  private
    FModoCadastro: string;
    FCod_Produto: integer;
    FValor: double;
    FDescricao: string;
    FFoto: TBitmap;
    permissao: T99Permissions;
    FExecuteOnClose: TExecuteOnClose;
    procedure TratarErroPermissao(Sender: TObject);
  public
    property ModoCadastro: string read FModoCadastro write FModoCadastro;
    property Cod_Produto: integer read FCod_Produto write FCod_Produto;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: double read FValor write FValor;
    property Foto: TBitmap read FFoto write FFoto;
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmProdutoCad: TFrmProdutoCad;

implementation

{$R *.fmx}

procedure TFrmProdutoCad.ActCameraDidFinishTaking(Image: TBitmap);
begin
    imgFoto.Bitmap := Image;
end;

procedure TFrmProdutoCad.ActLibraryDidFinishTaking(Image: TBitmap);
begin
    imgFoto.Bitmap := Image;
end;

procedure TFrmProdutoCad.btnSalvarClick(Sender: TObject);
begin
    try
        if ModoCadastro = 'I' then
            DmProduto.CadastrarProduto(edtDescricao.Text,
                                       edtValor.Text.ToDouble,
                                       imgFoto.Bitmap)
        else
            DmProduto.EditarProduto(Cod_Produto,
                                    edtDescricao.Text,
                                    edtValor.Text.ToDouble,
                                    imgFoto.Bitmap);


        if Assigned(ExecuteOnClose) then
            ExecuteOnClose;

        close;

    except on ex:exception do
        showmessage('Erro ao salvar dados do produto: ' + ex.Message);
    end;
end;

procedure TFrmProdutoCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmProdutoCad := nil;
end;

procedure TFrmProdutoCad.FormCreate(Sender: TObject);
begin
    permissao := T99Permissions.Create;
end;

procedure TFrmProdutoCad.FormDestroy(Sender: TObject);
begin
    permissao.DisposeOf;
end;

procedure TFrmProdutoCad.FormShow(Sender: TObject);
begin
    if ModoCadastro = 'I' then
        lblTitulo.Text := 'Novo Produto'
    else
    begin
        lblTitulo.Text := 'Editar Produto';
        edtDescricao.Text := Descricao;
        edtValor.Text := FormatFloat('#,##0.00', Valor);
        imgFoto.Bitmap := Foto;
        imgExcluir.Visible := true;
    end;
end;


procedure TFrmProdutoCad.TratarErroPermissao(Sender: TObject);
begin
    showmessage('Você não possui acesso a esse recurso do aparelho');
end;

procedure TFrmProdutoCad.imgExcluirClick(Sender: TObject);
begin
    try
        DmProduto.ExcluirProduto(Cod_Produto);

        if Assigned(ExecuteOnClose) then
            ExecuteOnClose;

        close;

    except on ex:exception do
        showmessage('Erro ao excluir produto: ' + ex.Message);
    end;
end;

procedure TFrmProdutoCad.imgFotoClick(Sender: TObject);
begin
    {$IFDEF MSWINDOWS}
    if OpenDialog.Execute then
        imgFoto.Bitmap.LoadFromFile(OpenDialog.FileName);
    {$ELSE}
    //permissao.Camera(ActCamera, TratarErroPermissao);
    permissao.PhotoLibrary(ActLibrary, TratarErroPermissao);
    {$ENDIF}
end;

end.
