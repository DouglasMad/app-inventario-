object DmProduto: TDmProduto
  OnCreate = DataModuleCreate
  Height = 460
  Width = 328
  object Conn: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    AfterConnect = ConnAfterConnect
    BeforeConnect = ConnBeforeConnect
    Left = 56
    Top = 40
  end
  object qryProduto: TFDQuery
    Connection = Conn
    Left = 128
    Top = 42
  end
  object qryCadProduto: TFDQuery
    Connection = Conn
    Left = 216
    Top = 42
  end
end
