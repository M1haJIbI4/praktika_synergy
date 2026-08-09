program TourismWebApp;

uses
  Web.WebBroker,
  Web.ReqMulti,
  Web.WebReq,
  Web.WebBroker,
  DataModule in 'DataModule.pas' {dmMain: TDataModule},
  WebModule in 'WebModule.pas' {WebModule1: TWebModule};

{$R *.RES}

begin
  WebRequestHandler.WebModuleClass := WebModuleClass;
  WebRequestHandlerProc := WebRequestHandler;
end.