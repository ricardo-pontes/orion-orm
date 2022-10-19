program Sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm.View in 'MainForm.View.pas' {Form1},
  Infra.DTO.Produtos in 'Infra.DTO.Produtos.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
