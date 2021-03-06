unit mneSettings;
{$mode objfpc}{$H+}
{**
 * Mini Edit
 *
 * @license    GPL 2 (http://www.gnu.org/licenses/gpl.html)
 * @author    Zaher Dirkey <zaher at parmaja dot com>
 *}

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DebugClasses, EditorEngine, Dialogs, StdCtrls, ComCtrls, Grids;

type

  { TEditorSettingForm }

  TEditorSettingForm = class(TForm)
    AutoOpenProjectChk: TCheckBox;
    IgnoreNamesEdit: TEdit;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
    PageControl: TPageControl;
    PauseChk: TCheckBox;
    RunModeCbo: TComboBox;
    TabSheet2: TTabSheet;
    Label3: TLabel;
    CollectTimeoutEdit: TEdit;
    CollectTimeoutSpn: TUpDown;
    CollectAutoCompleteChk: TCheckBox;
    AutoStartDebugServerChk: TCheckBox;
    PHPManualEdit: TEdit;
    Label2: TLabel;
    Button1: TButton;
    TabSheet4: TTabSheet;
    Label9: TLabel;
    ExtensionsGrid: TStringGrid;
    Label10: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure INIEditChange(Sender: TObject);
  private
    FEngine: TEditorEngine;
    FExtraExtensions: array of string;
    procedure Retrieve;
    procedure Apply;
  public
  end;


function ShowSettingForm(Engine: TEditorEngine): Boolean;

implementation

var
  CurrentPage: Integer;

{$R *.lfm}

function ShowSettingForm(Engine: TEditorEngine): Boolean;
begin
  with TEditorSettingForm.Create(Application) do
  begin
    FEngine := Engine;
    Retrieve;
    Result := ShowModal = mrOk;
    if Result then
    begin
      Apply;
      Engine.Options.Save(Engine.WorkSpace);
    end;
  end;
end;

procedure TEditorSettingForm.Apply;
var
  i, c: Integer;
begin
  FEngine.Options.RunMode := TmneRunMode(RunModeCbo.ItemIndex);
  FEngine.Options.PauseConsole := PauseChk.Checked;

  FEngine.Options.AutoOpenProject := AutoOpenProjectChk.Checked;
  FEngine.Options.CollectAutoComplete := CollectAutoCompleteChk.Checked;
  FEngine.Options.CollectTimeout := CollectTimeoutSpn.Position;
  FEngine.Options.AutoStartDebugServer := AutoStartDebugServerChk.Checked;
  c := 1;
  for i := 0 to FEngine.Groups.Count - 1 do
  begin
    if fgkMember in FEngine.Groups[i].Kind then
    begin
      FEngine.Options.ExtraExtensions.Values[FExtraExtensions[c - 1]] := ExtensionsGrid.Cells[1, c];
      Inc(c);
    end;
  end;
  FEngine.Options.IgnoreNames := IgnoreNamesEdit.Text;
end;

procedure TEditorSettingForm.Retrieve;
var
  i, c: Integer;
begin
  EunmRunMode(RunModeCbo.Items);
  RunModeCbo.ItemIndex := ord(FEngine.Options.RunMode);
  PauseChk.Checked := FEngine.Options.PauseConsole;

  AutoOpenProjectChk.Checked := FEngine.Options.AutoOpenProject;
  CollectAutoCompleteChk.Checked := FEngine.Options.CollectAutoComplete;
  CollectTimeoutSpn.Position := FEngine.Options.CollectTimeout;
  AutoStartDebugServerChk.Checked := FEngine.Options.AutoStartDebugServer;
  ExtensionsGrid.Cells[0, 0] := 'Group';
  ExtensionsGrid.Cells[1, 0] := 'Extensions';
  c := 1;
  for i := 0 to FEngine.Groups.Count - 1 do
  begin
    if fgkMember in FEngine.Groups[i].Kind then
    begin
      ExtensionsGrid.RowCount := c + 1;
      ExtensionsGrid.Cells[0, c] := FEngine.Groups[i].Title;
      ExtensionsGrid.Cells[1, c] := FEngine.Options.ExtraExtensions.Values[FEngine.Groups[i].Name];
      SetLength(FExtraExtensions, c);
      FExtraExtensions[c - 1] := FEngine.Groups[i].Name;
      Inc(c);
    end;
  end;
  IgnoreNamesEdit.Text := FEngine.Options.IgnoreNames;
end;


procedure TEditorSettingForm.FormCreate(Sender: TObject);
begin
  PageControl.ActivePageIndex := CurrentPage;
end;

procedure TEditorSettingForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CurrentPage := PageControl.ActivePageIndex;
end;

procedure TEditorSettingForm.INIEditChange(Sender: TObject);
begin
end;

end.

