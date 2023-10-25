unit DataModule.Produto;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Graphics, System.IOUtils;

type
  TDmProduto = class(TDataModule)
    Conn: TFDConnection;
    qryProduto: TFDQuery;
    qryCadProduto: TFDQuery;
    procedure ConnBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ListarProdutos(pagina: integer; busca: string);
    procedure CadastrarProduto(descricao: string;
                                      valor: double;
                                      foto: TBitmap);
    procedure EditarProduto(cod_produto: integer;
                                   descricao: string;
                                   valor: double;
                                   foto: TBitmap);
    procedure ExcluirProduto(cod_produto: integer);
  end;

var
  DmProduto: TDmProduto;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmProduto.ConnAfterConnect(Sender: TObject);
var
    x : integer;
begin
    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_PRODUTO ( ' +
                            'COD_PRODUTO   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
                            'DESCRICAO           VARCHAR (200), ' +
                            'VALOR               DECIMAL (12, 2), ' +
                            'FOTO                BLOB);'
                );

    {
    for x := 51 to 3000 do
        Conn.ExecSQL('INSERT INTO TAB_PRODUTO (DESCRICAO, VALOR, FOTO) VALUES(''Produto de Teste ' +
                    FormatFloat('00', x) + ''', ' + (100 + x).ToString + ', null)');

    }
end;

procedure TDmProduto.ConnBeforeConnect(Sender: TObject);
begin
    Conn.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    Conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\produtos.db';
    {$ELSE}
    Conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'produtos.db');
    {$ENDIF}
end;

procedure TDmProduto.DataModuleCreate(Sender: TObject);
begin
    Conn.Connected := true;
end;

procedure TDmProduto.ListarProdutos(pagina: integer; busca: string);
begin
    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('SELECT P.* ');
    qryProduto.SQL.Add('FROM TAB_PRODUTO P');

    // Filtro...
    if busca <> '' then
    begin
        qryProduto.SQL.Add('WHERE P.DESCRICAO LIKE :BUSCA ');
        qryProduto.ParamByName('BUSCA').Value := '%' + busca + '%';
    end;

    qryProduto.SQL.Add('ORDER BY DESCRICAO');
    qryProduto.SQL.Add('LIMIT :PAGINA, :QTD_REG');
    qryProduto.ParamByName('PAGINA').Value := (pagina - 1) * 15;
    qryProduto.ParamByName('QTD_REG').Value := 15;
    qryProduto.Active := true;
end;


procedure TDmProduto.CadastrarProduto(descricao: string;
                                      valor: double;
                                      foto: TBitmap);
begin
    with qryCadProduto do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('insert into tab_produto(descricao, valor, foto) ');
        SQL.Add('values(:descricao, :valor, :foto)');
        ParamByName('descricao').Value := descricao;
        ParamByName('valor').Value := valor;
        ParamByName('foto').Assign(foto);
        ExecSQL;
    end;
end;

procedure TDmProduto.EditarProduto(cod_produto: integer;
                                   descricao: string;
                                   valor: double;
                                   foto: TBitmap);
begin
    with qryCadProduto do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('update tab_produto set descricao=:descricao, valor=:valor, ');
        SQL.Add('foto=:foto where cod_produto=:cod_produto');
        ParamByName('descricao').Value := descricao;
        ParamByName('valor').Value := valor;
        ParamByName('foto').Assign(foto);
        ParamByName('cod_produto').Value := cod_produto;
        ExecSQL;
    end;
end;

procedure TDmProduto.ExcluirProduto(cod_produto: integer);
begin
    with qryCadProduto do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('delete from tab_produto where cod_produto=:cod_produto');
        ParamByName('cod_produto').Value := cod_produto;
        ExecSQL;
    end;
end;


end.
