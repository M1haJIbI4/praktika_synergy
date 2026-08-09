unit WebModule;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, DataModule;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1GetToursAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1GetOrdersAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AddOrderAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1GetClientsAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1GetCountriesAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
    function GenerateHTMLTable(DataSet: TDataSet): string;
    function GenerateJSON(DataSet: TDataSet): string;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content :=
    '<html>' +
    '<head><title>Туристическое агентство</title>' +
    '<style>' +
    'body { font-family: Arial, sans-serif; margin: 40px; }' +
    'h1 { color: #2c3e50; }' +
    'a { display: inline-block; margin: 10px 0; padding: 10px 20px; ' +
    'background: #3498db; color: white; text-decoration: none; border-radius: 5px; }' +
    'a:hover { background: #2980b9; }' +
    '</style>' +
    '</head>' +
    '<body>' +
    '<h1>🌍 Добро пожаловать в систему управления турами!</h1>' +
    '<p>Выберите действие:</p>' +
    '<a href="/tours">📋 Список туров</a><br>' +
    '<a href="/orders">📦 Все заказы</a><br>' +
    '<a href="/clients">👤 Список клиентов</a><br>' +
    '<a href="/countries">🌏 Список стран</a><br>' +
    '<p><i>Для создания заказа используйте API: /addorder?client=1&tour=1&date=2025-08-01&price=850&comment=Test</i></p>' +
    '</body>' +
    '</html>';
end;

procedure TWebModule1.WebModule1GetToursAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  ds: TDataSet;
  format: string;
begin
  format := Request.QueryFields.Values['format'];
  ds := dmMain.GetTours;

  if format = 'json' then
    Response.Content := GenerateJSON(ds)
  else
    Response.Content :=
      '<html><head><title>Список туров</title>' +
      '<style>body { font-family: Arial; margin: 40px; } ' +
      'table { border-collapse: collapse; width: 100%; } ' +
      'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; } ' +
      'th { background-color: #3498db; color: white; } ' +
      'tr:nth-child(even) { background-color: #f2f2f2; } ' +
      'a { color: #3498db; text-decoration: none; }</style>' +
      '</head><body>' +
      '<h1>Доступные туры</h1>' +
      GenerateHTMLTable(ds) +
      '<p><a href="/">← На главную</a></p>' +
      '</body></html>';
end;

procedure TWebModule1.WebModule1GetOrdersAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  ClientID: Integer;
  ds: TDataSet;
  format: string;
begin
  format := Request.QueryFields.Values['format'];
  ClientID := StrToIntDef(Request.QueryFields.Values['client'], 0);

  if ClientID > 0 then
    ds := dmMain.GetOrdersByClient(ClientID)
  else
    ds := dmMain.GetAllOrders;

  if format = 'json' then
    Response.Content := GenerateJSON(ds)
  else
    Response.Content :=
      '<html><head><title>Заказы</title>' +
      '<style>body { font-family: Arial; margin: 40px; } ' +
      'table { border-collapse: collapse; width: 100%; } ' +
      'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; } ' +
      'th { background-color: #2ecc71; color: white; } ' +
      'tr:nth-child(even) { background-color: #f2f2f2; } ' +
      'a { color: #3498db; text-decoration: none; }</style>' +
      '</head><body>' +
      '<h1>Заказы' + IfThen(ClientID > 0, ' клиента #' + IntToStr(ClientID), ' (все)') + '</h1>' +
      GenerateHTMLTable(ds) +
      '<p><a href="/">← На главную</a></p>' +
      '</body></html>';
end;

procedure TWebModule1.WebModule1GetClientsAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  ds: TDataSet;
  format: string;
begin
  format := Request.QueryFields.Values['format'];
  ds := dmMain.GetClients;

  if format = 'json' then
    Response.Content := GenerateJSON(ds)
  else
    Response.Content :=
      '<html><head><title>Клиенты</title>' +
      '<style>body { font-family: Arial; margin: 40px; } ' +
      'table { border-collapse: collapse; width: 100%; } ' +
      'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; } ' +
      'th { background-color: #9b59b6; color: white; } ' +
      'tr:nth-child(even) { background-color: #f2f2f2; } ' +
      'a { color: #3498db; text-decoration: none; }</style>' +
      '</head><body>' +
      '<h1>Список клиентов</h1>' +
      GenerateHTMLTable(ds) +
      '<p><a href="/">← На главную</a></p>' +
      '</body></html>';
end;

procedure TWebModule1.WebModule1GetCountriesAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  ds: TDataSet;
  format: string;
begin
  format := Request.QueryFields.Values['format'];
  ds := dmMain.GetCountries;

  if format = 'json' then
    Response.Content := GenerateJSON(ds)
  else
    Response.Content :=
      '<html><head><title>Страны</title>' +
      '<style>body { font-family: Arial; margin: 40px; } ' +
      'table { border-collapse: collapse; width: 100%; } ' +
      'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; } ' +
      'th { background-color: #e67e22; color: white; } ' +
      'tr:nth-child(even) { background-color: #f2f2f2; } ' +
      'a { color: #3498db; text-decoration: none; }</style>' +
      '</head><body>' +
      '<h1>Список стран</h1>' +
      GenerateHTMLTable(ds) +
      '<p><a href="/">← На главную</a></p>' +
      '</body></html>';
end;

procedure TWebModule1.WebModule1AddOrderAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  ClientID, TourID: Integer;
  StartDate: TDate;
  TotalPrice: Double;
  Comment: string;
  NewOrderID: Integer;
begin
  ClientID := StrToIntDef(Request.QueryFields.Values['client'], 0);
  TourID := StrToIntDef(Request.QueryFields.Values['tour'], 0);
  StartDate := StrToDateDef(Request.QueryFields.Values['date'], Date);
  TotalPrice := StrToFloatDef(Request.QueryFields.Values['price'], 0);
  Comment := Request.QueryFields.Values['comment'];

  if (ClientID > 0) and (TourID > 0) and (TotalPrice > 0) then
  begin
    NewOrderID := dmMain.AddOrder(ClientID, TourID, StartDate, TotalPrice, Comment);
    Response.Content :=
      '<html><body style="font-family: Arial; margin: 40px;">' +
      '<h2 style="color: green;">✅ Заказ успешно создан!</h2>' +
      '<p><b>Номер заказа:</b> ' + IntToStr(NewOrderID) + '</p>' +
      '<p><a href="/">← На главную</a></p>' +
      '</body></html>';
  end
  else
  begin
    Response.Content :=
      '<html><body style="font-family: Arial; margin: 40px;">' +
      '<h2 style="color: red;">❌ Ошибка: неверные параметры заказа</h2>' +
      '<p>Требуются параметры: client, tour, date (ГГГГ-ММ-ДД), price</p>' +
      '<p><a href="/">← На главную</a></p>' +
      '</body></html>';
  end;
end;

function TWebModule1.GenerateHTMLTable(DataSet: TDataSet): string;
var
  i: Integer;
begin
  if DataSet.IsEmpty then
  begin
    Result := '<p><i>Нет данных для отображения.</i></p>';
    Exit;
  end;

  Result := '<table>';
  // Заголовки
  Result := Result + '<tr>';
  for i := 0 to DataSet.FieldCount - 1 do
    Result := Result + '<th>' + DataSet.Fields[i].FieldName + '</th>';
  Result := Result + '</tr>';

  // Данные
  DataSet.First;
  while not DataSet.Eof do
  begin
    Result := Result + '<tr>';
    for i := 0 to DataSet.FieldCount - 1 do
      Result := Result + '<td>' + DataSet.Fields[i].AsString + '</td>';
    Result := Result + '</tr>';
    DataSet.Next;
  end;

  Result := Result + '</table>';
end;

function TWebModule1.GenerateJSON(DataSet: TDataSet): string;
var
  i: Integer;
begin
  if DataSet.IsEmpty then
  begin
    Result := '[]';
    Exit;
  end;

  Result := '[';
  DataSet.First;
  while not DataSet.Eof do
  begin
    if DataSet.RecNo > 1 then
      Result := Result + ',';
    Result := Result + '{';
    for i := 0 to DataSet.FieldCount - 1 do
    begin
      if i > 0 then
        Result := Result + ',';
      Result := Result + '"' + DataSet.Fields[i].FieldName + '":"' +
        StringReplace(DataSet.Fields[i].AsString, '"', '\"', [rfReplaceAll]) + '"';
    end;
    Result := Result + '}';
    DataSet.Next;
  end;
  Result := Result + ']';
end;

end.