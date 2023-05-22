program LibraryPath;

uses
  System.StartUpCopy,
  FMX.Forms,
  U_LibraryPath in 'U_LibraryPath.pas' {frmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
