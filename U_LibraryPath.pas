unit U_LibraryPath;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types, FMX.StdCtrls,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Controls.Presentation, FMX.Objects,
  System.Win.Registry, Winapi.Windows;

type
  TfrmPrincipal = class(TForm)
    pnBackground: TPanel;
    lblTitle: TLabel;
    cbArchitecture: TComboBox;
    lblArchitecture: TLabel;
    memLibraryPath: TMemo;
    btnAdd: TCornerButton;
    imgClose: TImage;
    StyleBook1: TStyleBook;
    procedure imgCloseClick(Sender: TObject);
    procedure cbArchitectureChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    { Private declarations }
    function GetRegistryKey(ALocal: String; AKey: String): String;
    function SetRegistryKey(ALocal: String; AKey: String; AValue: String): Boolean;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.btnAddClick(Sender: TObject);
var
  i: Integer;
  AAuxValue : String;
  AAuxArch  : String;
begin
  AAuxValue := '';
  AAuxArch  := '';
  if (cbArchitecture.ItemIndex = -1) then
  begin
    ShowMessage('Escolha uma arquitetura!');
    cbArchitecture.SetFocus;
    Exit;
  end;
  
  if (Trim(memLibraryPath.Text) = EmptyStr) then
  begin
    ShowMessage('Library Path não pode ficar vazio!');
    memLibraryPath.SetFocus;
    Exit;
  end;
  
  if (MessageBox(0, 'Confirma a operação?', 'Atenção!', MB_ICONWARNING + MB_YESNO) = IDNO) then
    Exit;  

  for i := 0 to memLibraryPath.Lines.Count -1 do
  begin
    if (i = memLibraryPath.Lines.Count -1)  then
      AAuxValue := AAuxValue + memLibraryPath.Lines[i]
    else
      AAuxValue := AAuxValue + memLibraryPath.Lines[i] + ';';
  end;

  
  case (cbArchitecture.ItemIndex) of
    0: AAuxArch := 'Win32';
    1: AAuxArch := 'Win64'; 
  end;
  if SetRegistryKey('Software\Embarcadero\BDS\22.0\Library\' + AAuxArch, 'Search Path', AAuxValue) then
    MessageBox(0, 'Registro adicionado com sucesso!', 'Successo!', MB_ICONQUESTION + MB_OK);
end;

procedure TfrmPrincipal.cbArchitectureChange(Sender: TObject);
var
  AList : TStringList;
  i     : Integer;
begin
  AList := TStringList.Create;

  try
    memLibraryPath.Lines.Clear;
    AList.Clear;
    AList.StrictDelimiter := True;
    AList.Delimiter       := ';';

    case (cbArchitecture.ItemIndex) of
      // Win32
      0: AList.DelimitedText   := GetRegistryKey('Software\Embarcadero\BDS\22.0\Library\Win32', 'Search Path');
      // Win64
      1: AList.DelimitedText   := GetRegistryKey('Software\Embarcadero\BDS\22.0\Library\Win64', 'Search Path');
    end;


    for i := 0 to AList.Count -1 do
      memLibraryPath.Lines.Add(AList[i]);
  finally
    FreeAndNil(AList);
  end;
end;

function TfrmPrincipal.GetRegistryKey(ALocal: String; AKey: String): String;
var
  ARegistry : TRegistry;
begin
  Result    := '';
  ARegistry := TRegistry.Create;

  try
    ARegistry.RootKey := HKEY_CURRENT_USER;

    if (ARegistry.OpenKey(ALocal, True)) then
      Result  := ARegistry.ReadString(AKey);
  finally
    ARegistry.CloseKey;
    ARegistry.Free;
  end;
end;

procedure TfrmPrincipal.imgCloseClick(Sender: TObject);
begin
  Close;
end;

function TfrmPrincipal.SetRegistryKey(ALocal, AKey: String; AValue: String): Boolean;
var
  ARegistry : TRegistry;
begin
  Result    := False;
  ARegistry := TRegistry.Create;

  try
    ARegistry.RootKey := HKEY_CURRENT_USER;

    if (ARegistry.OpenKey(ALocal, True)) then
    try 
      ARegistry.WriteString(AKey, AValue);
      Result  := True;
    except
      on E: Exception do
      begin
        Result  := False;
        raise Exception.Create('Falha ao salvar o registro!' + sLineBreak + E.Message);
      end;
    end;
  finally
    ARegistry.CloseKey;
    ARegistry.Free;
  end;
end;

end.
