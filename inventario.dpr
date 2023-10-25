program inventario;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitProduto in 'UnitProduto.pas' {FrmProduto},
  UnitProdutoCad in 'UnitProdutoCad.pas' {FrmProdutoCad},
  u99Permissions in 'u99Permissions.pas',
  UnitCamera in 'UnitCamera.pas' {FrmCamera},
  UnitPrincipal in 'UnitPrincipal.pas' {Form1},
  DataModule.Produto in 'DataModules\DataModule.Produto.pas' {DmProduto: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmProduto, FrmProduto);
  Application.CreateForm(TFrmProdutoCad, FrmProdutoCad);
  Application.CreateForm(TFrmCamera, FrmCamera);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDmProduto, DmProduto);
  Application.Run;
end.
