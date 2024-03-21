program World3D;

uses
  Vcl.Forms,
  ThirdTask in 'ThirdTask.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
