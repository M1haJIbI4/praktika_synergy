unit DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Comp.Client,
  Data.DB, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TdmMain = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public methods for data access }
    function GetTours: TFDQuery;
    function GetOrdersByClient(ClientID: Integer): TFDQuery;
    function GetAllOrders: TFDQuery;
    function AddOrder(ClientID, TourID: Integer; StartDate: TDate;
      TotalPrice: Double; Comment: string): Integer;
    function GetCountries: TFDQuery;
    function GetClients: TFDQuery;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  // Настройка подключения к MS SQL Server
  // ВАЖНО: замените параметры на свои (сервер, база, логин, пароль)
  FDConnection1.DriverName := 'MSSQL';
  FDConnection1.Params.Values['Server'] := '127.0.0.1';
  FDConnection1.Params.Values['Database'] := 'TourismDB';
  FDConnection1.Params.Values['User_Name'] := 'sa';
  FDConnection1.Params.Values['Password'] := 'your_password';
  FDConnection1.Params.Values['MSSQL Provider'] := 'prNative';
  FDConnection1.Connected := True;
end;

function TdmMain.GetTours: TFDQuery;
begin
  FDQuery1.SQL.Text :=
    'SELECT t.*, c.name as country_name ' +
    'FROM Tours t ' +
    'JOIN Countries c ON t.country_id = c.id_country ' +
    'ORDER BY t.tour_name';
  FDQuery1.Active := True;
  Result := FDQuery1;
end;

function TdmMain.GetOrdersByClient(ClientID: Integer): TFDQuery;
begin
  FDQuery1.SQL.Text :=
    'SELECT o.*, t.tour_name, c.full_name as client_name ' +
    'FROM Orders o ' +
    'JOIN Tours t ON o.tour_id = t.id_tour ' +
    'JOIN Clients c ON o.client_id = c.id_client ' +
    'WHERE o.client_id = :client_id ' +
    'ORDER BY o.order_date DESC';
  FDQuery1.ParamByName('client_id').AsInteger := ClientID;
  FDQuery1.Active := True;
  Result := FDQuery1;
end;

function TdmMain.GetAllOrders: TFDQuery;
begin
  FDQuery1.SQL.Text :=
    'SELECT o.*, t.tour_name, c.full_name as client_name, cnt.name as country_name ' +
    'FROM Orders o ' +
    'JOIN Tours t ON o.tour_id = t.id_tour ' +
    'JOIN Clients c ON o.client_id = c.id_client ' +
    'JOIN Countries cnt ON t.country_id = cnt.id_country ' +
    'ORDER BY o.order_date DESC';
  FDQuery1.Active := True;
  Result := FDQuery1;
end;

function TdmMain.AddOrder(ClientID, TourID: Integer; StartDate: TDate;
  TotalPrice: Double; Comment: string): Integer;
begin
  FDQuery1.SQL.Text :=
    'INSERT INTO Orders (client_id, tour_id, start_date, total_price, comment) ' +
    'VALUES (:client_id, :tour_id, :start_date, :total_price, :comment); ' +
    'SELECT SCOPE_IDENTITY() AS NewID';
  FDQuery1.ParamByName('client_id').AsInteger := ClientID;
  FDQuery1.ParamByName('tour_id').AsInteger := TourID;
  FDQuery1.ParamByName('start_date').AsDate := StartDate;
  FDQuery1.ParamByName('total_price').AsFloat := TotalPrice;
  FDQuery1.ParamByName('comment').AsString := Comment;
  FDQuery1.Active := True;
  Result := FDQuery1.FieldByName('NewID').AsInteger;
end;

function TdmMain.GetCountries: TFDQuery;
begin
  FDQuery1.SQL.Text := 'SELECT * FROM Countries ORDER BY name';
  FDQuery1.Active := True;
  Result := FDQuery1;
end;

function TdmMain.GetClients: TFDQuery;
begin
  FDQuery1.SQL.Text := 'SELECT * FROM Clients ORDER BY full_name';
  FDQuery1.Active := True;
  Result := FDQuery1;
end;

end.